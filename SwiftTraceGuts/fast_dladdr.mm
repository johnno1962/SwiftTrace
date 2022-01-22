//
//  fast_dladdr.mm
//  
//  Created by John Holdsworth on 21/01/2022.
//  Repo: https://github.com/johnno1962/SwiftTrace
//  $Id: //depot/SwiftTrace/SwiftTraceGuts/fast_dladdr.mm#1 $
//

#import "include/SwiftTrace.h"

#import <mach-o/dyld.h>
#import <mach-o/arch.h>
#import <mach-o/nlist.h>
#import <dlfcn.h>

// A "pseudo image" is read into InjectionScratch rather than using dlopen().
static std::vector<PseudoImage> loadedPseudoImages;

void pushPseudoImage(const char *path, const void *header) {
    loadedPseudoImages.push_back(PseudoImage(strdup(path),
                   (const struct mach_header *)header));
}

const struct mach_header * _Nullable lastPseudoImage() {
    if (loadedPseudoImages.empty())
        return nullptr;
    return loadedPseudoImages.back().second;
}

const std::vector<PseudoImage> &getLoadedPseudoImages(void) {
    return loadedPseudoImages;
}

// We need a version of dladdr() that supports pseudo images.
#define TRY_TO_OPTIMISE_DLADDR 1
#if TRY_TO_OPTIMISE_DLADDR
#import <algorithm>

using namespace std;

class DySymbol {
public:
    nlist_t *sym;
    DySymbol(nlist_t *sym) {
        this->sym = sym;
    }
};

static bool operator < (DySymbol s1, DySymbol s2) {
    return s1.sym->n_value < s2.sym->n_value;
}

class Dylib {
    const mach_header_t *header;
    segment_command_t *seg_linkedit = nullptr;
    segment_command_t *seg_text = nullptr;
    struct symtab_command *symtab = nullptr;
    vector<DySymbol> symbols;

public:
    char *start = nullptr, *end = nullptr;
    const char *imageName;

    Dylib(const char *imageName, const struct mach_header *header, size_t slide) {
        this->imageName = imageName; // = _dyld_get_image_name(imageIndex);
        this->header = (const mach_header_t *)header; //_dyld_get_image_header(imageIndex);
        struct load_command *cmd = (struct load_command *)((intptr_t)header + sizeof(mach_header_t));
        assert(header);

        for (uint32_t i = 0; i < header->ncmds; i++, cmd = (struct load_command *)((intptr_t)cmd + cmd->cmdsize))
        {
            switch(cmd->cmd)
            {
                case LC_SEGMENT:
                case LC_SEGMENT_64:
                    if (!strcmp(((segment_command_t *)cmd)->segname, SEG_TEXT))
                        seg_text = (segment_command_t *)cmd;
                    else if (!strcmp(((segment_command_t *)cmd)->segname, SEG_LINKEDIT))
                        seg_linkedit = (segment_command_t *)cmd;
                    break;

                case LC_SYMTAB:
                    symtab = (struct symtab_command *)cmd;
            }
        }

//        const struct section_64 *section = getsectbynamefromheader_64( (const struct mach_header_64 *)header, SEG_TEXT, SECT_TEXT );
        if (!seg_text) return;
        start = (char *)header;
        end = start + symtab->symoff;
    }

    void dump(const char *prefix) {
        printf("%s %p %p %s\n", prefix, start, end, imageName);
    }

    bool contains(const void *p) {
        return p >= start && p < end;
    }

    int dladdr(const void *ptr, Dl_info *info) {
        intptr_t file_slide = ((intptr_t)seg_linkedit->vmaddr - (intptr_t)seg_text->vmaddr) - seg_linkedit->fileoff;
        const char *strings = (const char *)header + (symtab->stroff + file_slide);

        if (symbols.empty()) {
            nlist_t *sym = (nlist_t *)((intptr_t)header + (symtab->symoff + file_slide));

            for (uint32_t i = 0; i < symtab->nsyms; i++, sym++)
                if (sym->n_sect != NO_SECT)
//                    if (!(sym->n_type & N_STAB))
                        symbols.push_back(DySymbol(sym));

            sort(symbols.begin(), symbols.end());
        }

        nlist_t nlist;
        nlist.n_value = (intptr_t)ptr - ((intptr_t)header - (intptr_t)seg_text->vmaddr);

        auto it = upper_bound(symbols.begin(), symbols.end(), DySymbol(&nlist));
        if (it == symbols.end()) {
            info->dli_sname = "fast_dladdr: symbol not found";
            return 0;
        }

        size_t bound = distance(symbols.begin(), it);
//        for (int i=-15; i<15; i++)
//            printf("%ld %d %x %s\n", distance(symbols.begin(), it),
//                   i, symbols[found+i].sym->n_type,
//                   strings + symbols[found+i].sym->n_un.n_strx);
        info->dli_sname = strings + symbols[bound-1].sym->n_un.n_strx;
        if (!*info->dli_sname) // Some symbols not located at found-1??
            info->dli_sname = strings + symbols[bound-2].sym->n_un.n_strx;
        if (*info->dli_sname == '_')
            info->dli_sname++;
        return 1;
    }
};

class DylibPtr {
public:
    Dylib *dylib;
    const char *start;
    DylibPtr(Dylib *dylib) {
        if ((this->dylib = dylib))
            this->start = dylib->start;
    }
    DylibPtr(const char *start) {
        this->start = start;
    }
};

bool operator < (DylibPtr s1, DylibPtr s2) {
    return s1.start < s2.start;
}

class DyLookup {
    vector<DylibPtr> dylibs;
    int nimages = 0, pseudos = 0, nscratch = 0;
public:
    int dladdr(const void *ptr, Dl_info *info) {
        int nextnimages = _dyld_image_count();
        for (int i = nimages; i < nextnimages; i++)
            if (!strstr(_dyld_get_image_name(i), "InjectionScratch"))
                dylibs.push_back(DylibPtr(new Dylib(
                    _dyld_get_image_name(i),
                    _dyld_get_image_header(i),
                    _dyld_get_image_vmaddr_slide(i))));
            else
                nscratch++;

        int nextpseudos = (int)loadedPseudoImages.size();
        for (int p = pseudos; p < nextpseudos; p++)
            dylibs.push_back(DylibPtr(new
                Dylib(loadedPseudoImages[p].first,
                      loadedPseudoImages[p].second, 0)));

//            dylibs[dylibs.size()-1].dylib->dump("?");
        if (nimages - nscratch + pseudos != dylibs.size()) {
//            printf("Adding %d -> %d %d -> %d\n", nimages, nextnimages, pseudos, nextpseudos);
            sort(dylibs.begin(), dylibs.end());
            nimages = nextnimages;
            pseudos = nextpseudos;
        }

//        info->dli_fname = "/fast_dladdr: symbol not found";
        if (ptr < dylibs[0].dylib->start) {
            info->dli_sname = "fast_dladdr: address too low";
            return 0;
        }

        DylibPtr dylibPtr((const char *)ptr);
        auto it = upper_bound(dylibs.begin(), dylibs.end(), dylibPtr);
//        printf("%llx %d?????\n", ptr, dist);
        if (it == dylibs.end()) {
            info->dli_sname = "fast_dladdr: address too high";
            return 0;
        }

        size_t bound = distance(dylibs.begin(), it);
        Dylib *dylib = dylibs[bound-1].dylib;
        info->dli_fname = dylib->imageName;
        info->dli_fbase = dylib->start;
        if (!dylib || !dylib->contains(ptr)) {
//            dylib->dump("????");
            info->dli_sname = "fast_dladdr: address not in image";
            return 0;
        }
//            printf("%llx %llx %llx %d %s\n", ptr, dylib->start, dylib->stop, dylib->contains(ptr), info->dli_sname);
        return dylib->dladdr(ptr, info);
    }
};
#endif

int fast_dladdr(const void *ptr, Dl_info *info) {
#if TRY_TO_OPTIMISE_DLADDR
    static DyLookup lookup;
    return lookup.dladdr(ptr, info);
#else
    return dladdr(ptr, info);
#endif
}

@implementation DYLookup
- (instancetype)init {
    return [super init];
}
- (int)dladdr:(void *)pointer info:(Dl_info *)info {
    if (!dyLookup)
        dyLookup = new DyLookup();
    return ((class DyLookup *)dyLookup)->dladdr(pointer, info);
}
- (void)dealloc {
    if (dyLookup)
        delete (class DyLookup *)dyLookup;
}
@end

NSString *describeImageSymbol(const char *symname) {
    if (NSString *description = [NSObject swiftTraceDemangle:symname])
        return [description stringByAppendingFormat:@" %s", symname];
    return [NSString stringWithUTF8String:symname];
}

NSString *describeImageInfo(const Dl_info *info) {
    return [describeImageSymbol(info->dli_sname)
            stringByAppendingFormat:@"%s %p",
            rindex(info->dli_fname, '/'), info->dli_fbase];
}

NSString *describeImagePointer(const void *pointer) {
    Dl_info info;
    if (!fast_dladdr(pointer, &info))
        return [NSString stringWithFormat:@"%p??", pointer];
    return describeImageInfo(&info);
}

void injection_stack(void) {
    Dl_info info, info2;
    int level = 0;
    for (NSValue *value in [NSThread.callStackReturnAddresses reverseObjectEnumerator]) {
        void *pointer = value.pointerValue;
        printf("#%d %p", level++, pointer);
        info.dli_fname = "/bad image";
        if (!dladdr(pointer, &info))  {
            printf(" %p", pointer);
            info.dli_sname = "?";
        }
        if (!fast_dladdr(pointer, &info2))
            printf(" %p?", pointer);
        else
            info = info2;
        if (strcmp(info.dli_sname, "injection_scratch") == 0)
            printf(" injection_scratch:");
        else if (strcmp(info2.dli_sname, info.dli_sname) != 0 &&
                 strcmp(info2.dli_sname, "redacted>") != 0 && info.dli_sname[0] != '?')
            printf("%s: %s WTF? %s ", info2.dli_fname, info2.dli_sname, info.dli_sname);
        printf(" %s\n", describeImageInfo(&info).UTF8String);
    }
}
