//
//  fast_dladdr.mm
//  
//  Created by John Holdsworth on 21/01/2022.
//  Repo: https://github.com/johnno1962/SwiftTrace
//  $Id: //depot/SwiftTrace/SwiftTraceGuts/fast_dladdr.mm#14 $
//

#import "include/SwiftTrace.h"

#import <mach-o/dyld.h>
#import <mach-o/arch.h>
#import <mach-o/nlist.h>
#import <mach-o/getsect.h>
#import <dlfcn.h>
#import <string>
#import <map>

#ifdef __LP64__
#define mach_header_t struct mach_header_64
#define segment_command_t struct segment_command_64
#define nlist_t nlist_64
#define sectsize_t uint64_t
#define getsectdatafromheader_f getsectdatafromheader_64
#else
#define mach_header_t struct mach_header
#define segment_command_t struct segment_command
#define nlist_t nlist
#define sectsize_t uint32_t
#define getsectdatafromheader_f getsectdatafromheader
#endif

// A "pseudo image" is read into InjectionScratch rather than by using dlopen().
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

// We need a version of dladdr() and co. that supports non-dlopen'd images.
#define TRY_TO_OPTIMISE_DLADDR 1
#if TRY_TO_OPTIMISE_DLADDR
namespace fastdladdr {

#import <algorithm>

using namespace std;

// Used to sort by address (n_value)
class DySymbol {
public:
    const nlist_t *sym;
    DySymbol(const nlist_t *_Nonnull sym) : sym(sym) {}
};

static bool operator < (const DySymbol &s1, const DySymbol &s2) {
    return s1.sym->n_value < s2.sym->n_value;
}

// See: https://stackoverflow.com/questions/20481058/find-pathname-from-dlopen-handle-on-osx

/// Base class which can find the symbol name for  pointer.
class Dylib {
    segment_command_t *seg_linkedit = nullptr;
protected:
    struct symtab_command *symtab = nullptr;
    vector<DySymbol> symsByValue;
    intptr_t file_slide;
    const nlist_t *symbols;
public:
    const mach_header_t *header;
    const segment_command_t *seg_text = nullptr;
    const char *imageName, *start, *end, *strings;
    sectsize_t typeref_size = 0;
    char *typeref_start;

    Dylib(const char *_Nonnull imageName, const struct mach_header *_Nonnull header) {
        this->imageName = imageName; // = _dyld_get_image_name(imageIndex);
        if (!(this->header = (const mach_header_t *)header)) return; //_dyld_get_image_header(imageIndex);
        struct load_command *cmd = (struct load_command *)((intptr_t)header + sizeof(mach_header_t));

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
        file_slide = ((intptr_t)seg_linkedit->vmaddr -
                      (intptr_t)seg_text->vmaddr) - seg_linkedit->fileoff;
        symbols = (nlist_t *)((intptr_t)header + (symtab->symoff + file_slide));
        end = strings = (char *)header + (symtab->stroff + file_slide);
        typeref_start = getsectdatafromheader_f(this->header, SEG_TEXT,
                                                "__swift5_typeref", &typeref_size);
    }

    void dump(const char *prefix) {
        printf("%s %p %p %s\n", prefix, start, end, imageName);
    }

    bool contains(const void *p) {
        return p >= start && p < end;
    }

    const vector<DySymbol> &populate() {
        if (symsByValue.empty() && header) {
            const nlist_t *sym = symbols;
            for (uint32_t i = 0; i < symtab->nsyms; i++, sym++)
                if (sym->n_sect != NO_SECT)
                    if (!(sym->n_type & N_STAB))
                        symsByValue.push_back(DySymbol(sym));
            sort(symsByValue.begin(), symsByValue.end());
        }
        return symsByValue;
    }

    int dladdr(const void *_Nonnull ptr, Dl_info *_Nonnull info) {
        populate();

        nlist_t nlist;
        nlist.n_value = (intptr_t)ptr - ((intptr_t)header - (intptr_t)seg_text->vmaddr);

        auto it = upper_bound(symsByValue.begin(), symsByValue.end(), DySymbol(&nlist));
        size_t bound = distance(symsByValue.begin(), it);
        if (!bound) {
            info->dli_sname = "fast_dladdr: address should be too low";
            return 0;
        }
//        for (size_t i=MAX(bound-15,0);
//             i<MIN(bound+15,symsByValue.size()); i++)
//            printf("%ld %d %x %s\n", bound,
//                   (int)i, symsByValue[i].sym->n_type,
//                   strings + symsByValue[i].sym->n_un.n_strx);
        info->dli_sname = strings + symsByValue[bound-1].sym->n_un.n_strx;
        info->dli_saddr = (void *)(symsByValue[bound-1].sym->n_value +
                                   ((intptr_t)header - (intptr_t)seg_text->vmaddr));
        if (!*info->dli_sname && bound > 1) // Some symbols not located at found-1??
            info->dli_sname = strings + symsByValue[bound-2].sym->n_un.n_strx;
        if (*info->dli_sname == '_')
            info->dli_sname++;
        return 1;
    }
};

// Used to sort my name
class DySymName: public DySymbol {
public:
    const char *name;
    DySymName(const nlist_t *_Nullable sym, const char *_Nonnull name) : DySymbol(sym) {
        this->name = name;
    }
};

static bool operator < (const DySymName &s1, const DySymName &s2) {
    return strcmp(s1.name, s2.name) < 0;
}

/// Something like the handle returned by dlopen which can convert a symbol name info a pointer.
class DyHandle: public Dylib {
    vector<DySymName> symsByName;
    void populate() {
        if (symsByName.empty() && header) {
            const nlist_t *sym = symbols;
            for (uint32_t i = 0; i < symtab->nsyms; i++, sym++)
                if (sym->n_sect != NO_SECT)
                    if (const char *symname = strings+sym->n_un.n_strx) {
                        if (*symname == '_')
                            symname++;
                        symsByName.push_back(DySymName(sym, symname));
                    }
#if 00 // Using C++11 lambdas requires special Swift Package option.
            auto cmp = [&] (const DySymbol &l, const DySymbol &r) {
                return strcmp(strings+l.sym->n_un.n_strx+1,
                              strings+r.sym->n_un.n_strx+1) < 0;
            };
#endif
            sort(symsByName.begin(), symsByName.end());
        }
    }
public:
    DyHandle(const char *_Nonnull imageName,
             const struct mach_header *_Nullable header) :
        Dylib(imageName, header) {}

    void *dlsym(const char *symname) {
        populate();
        auto it = upper_bound(symsByName.begin(), symsByName.end(),
                              DySymName(nullptr, symname));
        size_t bound = distance(symsByName.begin(), it);
        if (!bound || strcmp(symsByName[bound-1].name, symname) != 0)
            return nullptr;
        return (void *)(symsByName[bound-1].sym->n_value +
                        ((intptr_t)header - (intptr_t)seg_text->vmaddr));
    }
};

class DyRange : DyHandle {
public:
    DyRange(const char *name, uintptr_t start, uintptr_t end)
        : DyHandle(name, nullptr) {
        this->start = (char *)start;
        this->end = (char *)end;
    }
};

// Used to sort by load address.
class DylibPtr {
public:
    DyHandle *dylib;
    const char *start;
    DylibPtr(DyHandle *dylib) {
        if ((this->dylib = dylib))
            this->start = dylib->start;
    }
    DylibPtr(const char *_Nonnull start) {
        this->start = start;
    }
};

bool operator < (const DylibPtr &s1, const DylibPtr &s2) {
    return s1.start < s2.start;
}

/// Model for images loaded.
class DyLookup {
    vector<DylibPtr> dylibsByStart;
    map<string,DyHandle *> registered;
    int nimages = 0, pseudos = 0, nscratch = 0;
    void addImage(const char *path, const struct mach_header *header) {
        DyHandle *handle = new DyHandle(path, header);
//        NSLog(@"fast_dladdr: Adding #%lu %s %p %p\n",
//              dylibs.size(), path, header, handle);
        dylibsByStart.push_back(DylibPtr(handle));
        registered[path] = handle;
    }
    void populate() {
        int nextnimages = _dyld_image_count();
        for (int i = nimages; i < nextnimages; i++)
            if (!strstr(_dyld_get_image_name(i), "InjectionScratch"))
                addImage(_dyld_get_image_name(i),
                         _dyld_get_image_header(i));
            else
                nscratch++;

        int nextpseudos = (int)loadedPseudoImages.size();
        for (int p = pseudos; p < nextpseudos; p++)
            addImage(loadedPseudoImages[p].first,
                     loadedPseudoImages[p].second);

        if (nimages + pseudos != dylibsByStart.size() + nscratch) {
            sort(dylibsByStart.begin(), dylibsByStart.end());
            nimages = nextnimages;
            pseudos = nextpseudos;
        }
    }
public:
    DyHandle *dlopen(const char *_Nonnull path) {
        return registered[path];
    }

    DyHandle *dlhandle(const void *_Nonnull ptr, Dl_info *_Nonnull info) {
        populate();
        auto it = upper_bound(dylibsByStart.begin(), dylibsByStart.end(),
                              DylibPtr((const char *)ptr));
        size_t bound = distance(dylibsByStart.begin(), it);
        if (!bound) {
            info->dli_fbase = nullptr;
            info->dli_sname = info->dli_fname = "fast_dladdr: address too low?";
            return nullptr;
        }
        DyHandle *handle = dylibsByStart[bound-1].dylib;
        info->dli_fbase = (void *)handle->start;
        info->dli_fname = handle->imageName;
        if (!handle->contains(ptr)) {
            info->dli_saddr = (void *)handle->end;
            info->dli_sname = "fast_dladdr: address not in image";
            return nullptr;
        }
        return handle;
    }

    int dladdr(const void *_Nonnull ptr, Dl_info *_Nonnull info) {
        Dylib *dylib = dlhandle(ptr, info);
//            printf("%llx %llx %llx %d %s\n", ptr, dylib->start, dylib->stop, dylib->contains(ptr), info->dli_sname);
        return dylib ? dylib->dladdr(ptr, info) : 0;
    }
};

static DyLookup loadedImages;
}
#endif

using namespace fastdladdr;

int fast_dladdr(const void *ptr, Dl_info *info) {
    info->dli_fname = "/no image";
    info->dli_sname = "no symbol";
#if TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR
    return loadedImages.dladdr(ptr, info);
#else
    return dladdr(ptr, info);
#endif
}

void *fast_dlsym(const void *ptr, const char *symname) {
    Dl_info info;
    DyHandle *dylib = loadedImages.dlhandle(ptr, &info);
    return dylib ? dylib->dlsym(symname) : nullptr;
}

void fast_dlscan(const void *header, STVisibility visibility,
                 STSymbolFilter filter, STSymbolCallback callback) {
    if (!header)
        NSLog(@"SwiftTrace::fast_dlscan: No header for %p", header);
    Dl_info info;
    Dylib *dylib = loadedImages.dlhandle(header, &info);
    if (!dylib)
        NSLog(@"SwiftTrace::fast_dlscan: No handle for %p - %s",
              header, info.dli_sname);
    const char *symname; void *address;
    for (auto &sym : dylib->populate()) {
        if ((visibility == STVisibilityAny || sym.sym->n_type == visibility) &&
            (symname = dylib->strings+sym.sym->n_un.n_strx) && filter(symname++) &&
            (address = (void *)(sym.sym->n_value + (intptr_t)dylib->header -
                                (intptr_t)dylib->seg_text->vmaddr))) {
            #if DEBUG && 0
            Dl_info info;
            if (dladdr(address, &info) &&
                strcmp(info.dli_sname, "injected_code") != 0 &&
                !strstr(info.dli_sname, symname))
                printf("SwiftTrace: dladdr %p does not verify! %s %s\n",
                       address, symname, describeImageInfo(&info).UTF8String);
            if (!fast_dladdr(address, &info) || !strstr(info.dli_sname, symname))
                printf("SwiftTrace: fast_dladdr %p does not verify: %s %s\n",
                       address, symname, describeImageInfo(&info).UTF8String);
            const void *ptr = fast_dlsym(header, symname);
            if (ptr != address)
                printf("SwiftTrace: fast_dlsym %s does not verify: %p %p\n",
                       symname, ptr, address);
            if (ptr != info.dli_saddr)
                printf("SwiftTrace: round trip %s does not verify: %p %p\n",
                       symname, ptr, info.dli_saddr);
            #endif
            callback(address, symname, dylib->typeref_start,
                     dylib->typeref_start+dylib->typeref_size);
        }
    }
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
            rindex(info->dli_fname, '/'), info->dli_saddr];
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
        void *caller = value.pointerValue;
        printf("#%d %p", level++, caller);
        info.dli_fname = "/bad image";
        if (!dladdr(caller, &info))  {
            printf(" %p", caller);
            info.dli_sname = "?";
        }
        if (!fast_dladdr(caller, &info2))
            printf(" %p?", caller);
        else
            info = info2;
        if (strcmp(info.dli_sname, "injected_code") == 0)
            printf(" injected_code:");
        else if (strcmp(info2.dli_sname, info.dli_sname) != 0 &&
                 strcmp(info2.dli_sname, "redacted>") != 0 && info.dli_sname[0] != '?')
            printf("%s: %s WTF? %s ", info2.dli_fname, info2.dli_sname, info.dli_sname);
        printf(" %s\n", describeImageInfo(&info).UTF8String);
    }
}
