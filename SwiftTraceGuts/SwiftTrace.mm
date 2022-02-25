//
//  SwiftTrace.m
//  SwiftTrace
//
//  Repo: https://github.com/johnno1962/SwiftTrace
//  $Id: //depot/SwiftTrace/SwiftTraceGuts/SwiftTrace.mm#101 $
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
    BOOL swiftPrefixed = strncmp(suffix, "_$s", 3) == 0;
    STSymbolFilter swiftSymbolsWithSuffixOrObjcClass = ^BOOL(const char *symname) {
        return swiftPrefixed ? strncmp(symname, suffix, sufflen) == 0 :
            ((strncmp(symname, "_$s", 3) == 0 || *symname == '-' || *symname == '+') &&
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

void filterHeaderSymbols(const struct mach_header *header, STVisibility visibility, STSymbolFilter filter,
    void (^ _Nonnull callback)(const void * _Nonnull address, const char * _Nonnull symname,
                               void * _Nonnull typeref, void * _Nonnull typeend)) {
    fast_dlscan(header, visibility, filter, callback);
}

void *findSwiftSymbol(const char *path, const char *suffix, STVisibility visibility) {
    __block void *found = nullptr;
    findHiddenSwiftSymbols(path, suffix, visibility,
        ^(const void * _Nonnull address, const char * _Nonnull symname,
          void * _Nonnull typeref, void * _Nonnull typeend) {
        #if DEBUG && 0
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
