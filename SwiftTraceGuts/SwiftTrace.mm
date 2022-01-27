//
//  SwiftTrace.m
//  SwiftTrace
//
//  Repo: https://github.com/johnno1962/SwiftTrace
//  $Id: //depot/SwiftTrace/SwiftTraceGuts/SwiftTrace.mm#98 $
//

#import "include/SwiftTrace.h"
#import <mach-o/dyld.h>

NSArray<Class> *objc_classArray() {
    unsigned nc;
    NSMutableArray<Class> *array = [NSMutableArray new];
    if (Class *classes = objc_copyClassList(&nc))
        for (int i=0; i<nc; i++) {
            if (class_getSuperclass(classes[i]))
                [array addObject:classes[i]];
            else {
                const char *name = class_getName(classes[i]);
                printf("%s\n", name);
                if (strcmp(name, "JSExport") && strcmp(name, "_NSZombie_") &&
                    strcmp(name, "__NSMessageBuilder") && strcmp(name, "__NSAtom") &&
                    strcmp(name, "__ARCLite__") && strcmp(name, "__NSGenericDeallocHandler") &&
                    strcmp(name, "CNZombie") && strcmp(name, "_CNZombie_") &&
                    strcmp(name, "NSVB_AnimationFencingSupport"))
                    [array addObject:classes[i]];
            }
        }
    return array;
}

NSMethodSignature *method_getSignature(Method method) {
    const char *encoding = method_getTypeEncoding(method);
    @try {
        return [NSMethodSignature signatureWithObjCTypes:encoding];
    }
    @catch(NSException *err) {
        NSLog(@"*** Unsupported method encoding: %s", encoding);
        return nil;
    }
}

const char *sig_argumentType(id signature, NSUInteger index) {
    return [signature getArgumentTypeAtIndex:index];
}

const char *sig_returnType(id signature) {
    return [signature methodReturnType];
}

const char *swiftUIBundlePath() {
    if (Class AnyText = (__bridge Class)
        dlsym(RTLD_DEFAULT, "$s7SwiftUI14AnyTextStorageCN"))
        return class_getImageName(AnyText);
    return nullptr;
}

static char lastLoadedPath[PATH_MAX];
const char *searchMainImage() {
    const char *mainImage = [NSBundle mainBundle]
        .executablePath.UTF8String;
    strcpy(lastLoadedPath, mainImage);
    return mainImage;
}
const char *searchLastLoaded() {
    strcpy(lastLoadedPath, getLoadedPseudoImages().empty() ?
           _dyld_get_image_name(_dyld_image_count()-1) :
           getLoadedPseudoImages().back().first);
    return lastLoadedPath;
}
const char *searchAllImages() {
    return nullptr;
}

static char mainBundlePath[PATH_MAX];
const char *searchBundleImages() {
    const char *bundlePath = [NSBundle mainBundle]
        .bundlePath.UTF8String;
    strcpy(mainBundlePath, bundlePath);
    return mainBundlePath;
}

static char includeObjcClasses[] = {"CN"};
static char objcClassPrefix[] = {"_OBJC_CLASS_$_"};

const char *classesIncludingObjc() {
    return includeObjcClasses;
}

void findSwiftSymbols(const char *bundlePath, const char *suffix,
        void (^callback)(const void *symval, const char *symname, void *typeref, void *typeend)) {
    findHiddenSwiftSymbols(bundlePath, suffix,
                           STVisibilityGlobal, callback);
}

void findHiddenSwiftSymbols(const char *bundlePath, const char *suffix, STVisibility visibility,
        void (^callback)(const void *symval, const char *symname, void *typeref, void *typeend)) {
    size_t sufflen = strlen(suffix);
    STSymbolFilter swiftSymbolsWithSuffixOrObjcClass = ^BOOL(const char *symname) {
        return ((strncmp(symname, "_$s", 3) == 0 || *symname == '-' || *symname == '+') &&
                strcmp(symname+strlen(symname)-sufflen, suffix) == 0) ||
            (suffix == includeObjcClasses && strncmp(symname,
             objcClassPrefix, sizeof objcClassPrefix-1) == 0);
    };

    if (bundlePath == searchLastLoaded()) {
        filterImageSymbols(ST_LAST_IMAGE, visibility,
                           swiftSymbolsWithSuffixOrObjcClass, callback);
        return;
    }

    for (int32_t i = _dyld_image_count()-1; i >= 0 ; i--) {
        const char *imageName = _dyld_get_image_name(i);
        if (!(imageName && (bundlePath == searchAllImages() ||
                            imageName == bundlePath ||
                            strstr(imageName, bundlePath)) &&
              !strstr(imageName, "InjectionScratch.framework")))
            continue;

        filterImageSymbols(i, visibility,
                           swiftSymbolsWithSuffixOrObjcClass, callback);
        if (bundlePath != searchAllImages() &&
            bundlePath != mainBundlePath)
            break;
    }
}

void filterImageSymbols(int32_t imageNumber, STVisibility visibility, STSymbolFilter filter,
    void (^ _Nonnull callback)(const void * _Nonnull address, const char * _Nonnull symname,
                               void * _Nonnull typeref, void * _Nonnull typeend)) {
    const struct mach_header *header = nullptr;
    if (imageNumber < 0) {
        imageNumber = _dyld_image_count()+imageNumber;
        header = lastPseudoImage();
    }
    if (!header)
        header = _dyld_get_image_header(imageNumber);
    filterHeaderSymbols(header, visibility, filter, callback);
}

void filterHeaderSymbols(const struct mach_header *_header, STVisibility visibility, STSymbolFilter filter,
    void (^ _Nonnull callback)(const void * _Nonnull address, const char * _Nonnull symname,
                               void * _Nonnull typeref, void * _Nonnull typeend)) {
#if 01
    fast_dlscan(_header, visibility, filter, callback);
#else

// See: https://stackoverflow.com/questions/20481058/find-pathname-from-dlopen-handle-on-osx

        auto header = (const mach_header_t *)_header;
        segment_command_t *seg_linkedit = nullptr;
        segment_command_t *seg_text = nullptr;
        struct symtab_command *symtab = nullptr;
        // to filter associated type witness entries
        sectsize_t typeref_size = 0;
        char *typeref_start = getsectdatafromheader_f(header, SEG_TEXT,
                                            "__swift5_typeref", &typeref_size);

        struct load_command *cmd =
            (struct load_command *)((intptr_t)header + sizeof(mach_header_t));
        for (uint32_t i = 0; i < header->ncmds; i++,
             cmd = (struct load_command *)((intptr_t)cmd + cmd->cmdsize)) {
            switch(cmd->cmd) {
                case LC_SEGMENT:
                case LC_SEGMENT_64:
                    if (!strcmp(((segment_command_t *)cmd)->segname, SEG_TEXT))
                        seg_text = (segment_command_t *)cmd;
                    else if (!strcmp(((segment_command_t *)cmd)->segname, SEG_LINKEDIT))
                        seg_linkedit = (segment_command_t *)cmd;
                    break;

                case LC_SYMTAB: {
                    symtab = (struct symtab_command *)cmd;
                    intptr_t file_slide = ((intptr_t)seg_linkedit->vmaddr - (intptr_t)seg_text->vmaddr) - seg_linkedit->fileoff;
                    const char *strings = (const char *)header +
                                               (symtab->stroff + file_slide);
                    nlist_t *sym = (nlist_t *)((intptr_t)header +
                                               (symtab->symoff + file_slide));

                    for (uint32_t i = 0; i < symtab->nsyms; i++, sym++) {
                        const char *symname = strings + sym->n_un.n_strx;
                        void *address;

//                        printf("%d %s %d %d %d\n", visibility, symname,
//                               sym->n_type, sym->n_sect, filter(symname));

                        if ((!visibility || sym->n_type == visibility) &&
                            sym->n_sect != NO_SECT && filter(symname) &&
                            (address = (void *)(sym->n_value +
                             (intptr_t)header - (intptr_t)seg_text->vmaddr))) {
                            #if DEBUG
                            Dl_info info;
                            if (dladdr(address, &info) &&
                                strcmp(info.dli_sname, "injected_code") != 0 &&
                                !strstr(info.dli_sname, symname+1))
                                printf("SwiftTrace: dladdr %p does not verify! %s %s\n",
                                       address, symname,
                                       describeImageInfo(&info).UTF8String);
                            fast_dladdr(address, &info);
                            if (!strstr(info.dli_sname, symname+1))
                                printf("SwiftTrace: fast_dladdr %p does not verify: %s %s\n",
                                       address, symname,
                                       describeImageInfo(&info).UTF8String);
                            const void *ptr = fast_dlsym(header, symname+1);
                            if (ptr != address)
                                printf("SwiftTrace: fast_dlsym %s does not verify: %p %p\n",
                                       symname, ptr, address);
                            #endif
                            callback(address, symname+1, typeref_start,
                                     typeref_start + typeref_size);
                        }
                    }
                }
            }
        }
#endif
}

void *findSwiftSymbol(const char *path, const char *suffix, STVisibility visibility) {
    __block void *found = nullptr;
    findHiddenSwiftSymbols(path, suffix, visibility,
        ^(const void * _Nonnull address, const char * _Nonnull symname,
          void * _Nonnull typeref, void * _Nonnull typeend) {
        #if DEBUG
        if (found && found != address)
            NSLog(@"SwiftTrace: Contradicting values for %s: %@ %p != %@ %p", suffix,
                  describeImagePointer(found), found,
                  describeImagePointer(address), address);
//        else
        #endif
        found = (void *)address;
    });
    return found;
}

void appBundleImages(void (^callback)(const char *imageName, const struct mach_header *, intptr_t slide)) {
    for (ssize_t i = getLoadedPseudoImages().size()-1; i>=0 ; i--)
        callback(getLoadedPseudoImages()[i].first, (struct mach_header *)
                 getLoadedPseudoImages()[i].second, 0);
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    const char *mainExecutable = mainBundle.executablePath.UTF8String;
    const char *bundleFrameworks = mainBundle.privateFrameworksPath.UTF8String;
    size_t frameworkPathLength = strlen(bundleFrameworks);

    for (int32_t i = _dyld_image_count()-1; i >= 0 ; i--) {
        const char *imageName = _dyld_get_image_name(i);
//        NSLog(@"findImages: %s", imageName);
        if (strcmp(imageName, mainExecutable) == 0 ||
            strncmp(imageName, bundleFrameworks, frameworkPathLength) == 0 ||
            (strstr(imageName, "/DerivedData/") &&
             strstr(imageName, ".framework/")) ||
            strstr(imageName, "/eval"))
            callback(imageName, _dyld_get_image_header(i),
                     _dyld_get_image_vmaddr_slide(i));
    }
}

const char *callerBundle() {
    void *returnAddress = __builtin_return_address(1);
    Dl_info info;
    if (dladdr(returnAddress, &info))
        return info.dli_fname;
    return nullptr;
}
