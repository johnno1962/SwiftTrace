//
//  SwiftMeta.swift
//  SwiftTwaceApp
//
//  Created by John Holdsworth on 20/04/2020.
//  Copyright © 2020 John Holdsworth. All rights reserved.
//
//  Repo: https://github.com/johnno1962/SwiftTrace
//  $Id: //depot/SwiftTrace/SwiftTrace/SwiftRefs.swift#4 $
//
//  Requires https://github.com/johnno1962/StringIndex.git
//
//  Code to estimate if a tye is passed by reference
//  ================================================
//

#if DEBUG || !DEBUG_ONLY
import Foundation

extension SwiftMeta {
    /**
     Information about a field of a struct or class
     */
    public struct FieldInfo {
        let name: String
        let type: Any.Type
        let offset: size_t
    }

    /**
     Get approximate nformation about the fields of a type
     */
    open class func fieldInfo(forAnyType: Any.Type) -> [FieldInfo]? {
        _ = structsPassedByReference
        return approximateFieldInfoByTypeName[_typeName(forAnyType)]
    }

    static var approximateFieldInfoByTypeName = [String: [FieldInfo]]()
    static var doesntHaveStorage = Set<String>()

    /**
     Structs that have only fields that conform to .SwiftTraceFloatArg
     */
    static var structsAllFloats = Set<UnsafeRawPointer>()
    static var enumTypes = Set<UnsafeRawPointer>()

    public static var usePrecalculated = 01 == 1
    public static var swiftUIPassedByReference = """
        SwiftUI.AnimationCompletionCriteria
        SwiftUI.ArchivedViewCore.Metadata
        SwiftUI.DiffResult
        SwiftUI.DisplayList.ArchiveIDs
        SwiftUI.ImageResolutionContext
        SwiftUI.LinkDestination
        SwiftUI.LinkDestination.Configuration
        SwiftUI.OpenURLAction.SystemHandlerInput
        SwiftUI.ReferenceDateModifier
        SwiftUI.ResolvableAbsoluteDate
        SwiftUI.ResolvableStringResolutionContext
        SwiftUI.SystemFormatStyle.DateOffset
        SwiftUI.SystemFormatStyle.Timer
        SwiftUI.ScrollTargetBehavior
        SwiftUI.ScrollIndicatorVisibility
        SwiftUI.ScenePhase
        """
    public static var swiftUIStructsAllFloats = """
        SwiftUI.AngularGradient._Paint
        SwiftUI.Capsule._Inset
        SwiftUI.Circle._Inset
        SwiftUI.ColorMatrix
        SwiftUI.ConcentricRectangle.AnimatableData
        SwiftUI.ContainerRelativeShape._Inset
        SwiftUI.CoreBaselineOffsetPair
        SwiftUI.DistanceGesture
        SwiftUI.EdgeInsets
        SwiftUI.Ellipse._Inset
        SwiftUI.EllipticalGradient._Paint
        SwiftUI.EmptyAnimatableData
        SwiftUI.FocusableFillerBounds.Metrics
        SwiftUI.Font.ResolvedTraits
        SwiftUI.GlassContainer.AppearanceSettings
        SwiftUI.GlassContainer.Entry.ShapeBoundsResult
        SwiftUI.GlassContainer.TranslationKick
        SwiftUI.GraphicsFilter.DisplacementMap
        SwiftUI.GraphicsFilter.GlassBackgroundStyle
        SwiftUI.LayoutPositionQuery
        SwiftUI.LayoutPriorityLayout
        SwiftUI.LinearGradient._Paint
        SwiftUI.NamedImage.DecodedInfo
        SwiftUI.OffsetTransition
        SwiftUI.OpacityRendererEffect
        SwiftUI.RadialGradient._Paint
        SwiftUI.Rectangle._Inset
        SwiftUI.RectangleCornerRadii
        SwiftUI.ResolvedGradientVector
        SwiftUI.ResolvedSafeAreaInsets
        SwiftUI.RootSizeInfo
        SwiftUI.RoundedRectangle
        SwiftUI.RoundedRectangle._Inset
        SwiftUI.RoundedRectangularShapeCorners.AnimatableData
        SwiftUI.RoundedSize
        SwiftUI.SDFStyle.Group
        SwiftUI.ScrollStateRequestKind.UpdateValueConfig
        SwiftUI.ShaderVectorData
        SwiftUI.ShaderVectorData.Element
        SwiftUI.Spacing.TextMetrics
        SwiftUI.SystemHoverEffectStyleMetrics
        SwiftUI.SystemShadowStyleMetrics.Grounding
        SwiftUI.SystemShadowStyleMetrics.Separated
        SwiftUI.Text.Layout.TypographicBounds
        SwiftUI.TextProxy
        SwiftUI.UnevenRoundedRectangle
        SwiftUI.UnevenRoundedRectangle._Inset
        SwiftUI.ViewFrame
        SwiftUI.ViewListSublistSlice
        SwiftUI.ViewSize
        SwiftUI._BrightnessEffect
        SwiftUI._ColorMatrix
        SwiftUI._ContrastEffect
        SwiftUI._GrayscaleEffect
        SwiftUI._LayoutTraits
        SwiftUI._LayoutTraits.Dimension
        SwiftUI._OffsetEffect
        SwiftUI._OpacityEffect
        SwiftUI._PositionLayout
        SwiftUI._SaturationEffect
        SwiftUI._ScaledValue
        SwiftUI._ScrollLayout
        SwiftUI._ShapeStyle_Pack.Effect
        SwiftUI._ShapeStyle_Pack.Effect.Kind.AnimatableData
        SwiftUI._ShapeStyle_Pack.Fill.AnimatableData
        SwiftUI._ShapeStyle_RenderedShape
        SwiftUI._ViewList_Group
        SwiftUI.UnitPoint
        __C.CGSize
        """

    public static var structsPassedByReference: Set<UnsafeRawPointer> = {
        var problemTypes = Set<UnsafeRawPointer>()
        func passedByReference(_ type: Any.Type) {
            problemTypes.insert(autoBitCast(type))
            if let type = convert(type: type, handler: getOptionalTypeFptr) {
                problemTypes.insert(autoBitCast(type))
            }
        }

        for type: Any.Type in [URL.self, UUID.self, Date.self,
                               IndexPath.self, IndexSet.self, URLRequest.self] {
            passedByReference(type)
        }

        for iOS15ResilientTypeName in ["Foundation.AttributedString",
                                       "Foundation.AttributedString.Index"] {
            if let resilientType = lookupType(named: iOS15ResilientTypeName) {
                passedByReference(resilientType)
            }
        }

        #if true // Attempts to determine which getters have storage
        // properties that have key path getters are not stored??
        let appImages = searchBundleImages()
        findHiddenSwiftSymbols(appImages, "pACTK",
                               .hidden) { (_, symbol, _, _) in
            doesntHaveStorage.insert(String(cString: symbol)
                .replacingOccurrences(of: "pACTK", with: "g"))
        }
        // ...unless they have a field offset
        // ...or property wrapper backing initializer ??
        for suffix in ["pWvd", "pfP"] {
            findSwiftSymbols(appImages, suffix) {
                (_, symbol, _, _) in
                doesntHaveStorage.remove(String(cString: symbol)
                    .replacingOccurrences(of: suffix, with: "g"))
            }
        }
//        print(doesntHaveStorage)
        #endif
   
        structsAllFloats.insert(autoBitCast(CGFloat.self))
        for typ: Any.Type in [CGFloat.self, OSPoint.self, OSSize.self,
                              OSRect.self, OSEdgeInsets.self] {
            structsAllFloats.insert(autoBitCast(typ))
        }
        if let swiftUIFramework = swiftUIBundlePath() {
            let saveProblemTypes = problemTypes
            let saveFloatStructs = structsAllFloats
            process(bundlePath: swiftUIFramework, skip: usePrecalculated,
                    problemTypes: &problemTypes)
            if !usePrecalculated {
                for typ in problemTypes.subtracting(saveProblemTypes)
                    .map({ _typeName(autoBitCast($0)) }).sorted() {
                    print(typ)
                }
                print("--")
                for typ in structsAllFloats.subtracting(saveFloatStructs)
                    .map({ _typeName(autoBitCast($0)) }).sorted() {
                    print(typ)
                }
            }
        }
        if usePrecalculated {
            for byReference in swiftUIPassedByReference.components(separatedBy: "\n") {
                if let type = SwiftMeta.lookupType(named: byReference) {
                    passedByReference(autoBitCast(type))
                }
            }
            for allFloats in swiftUIStructsAllFloats.components(separatedBy: "\n") {
                if let typ = lookupType(named: allFloats) {
                    structsAllFloats.insert(autoBitCast(typ))
                }
            }
        }

        appBundleImages { bundlePath, _, _ in
            process(bundlePath: bundlePath, problemTypes: &problemTypes)
        }

        passedByReference(Any.self)
//        print(problemTypes.map {unsafeBitCast($0, to: Any.Type.self)}, approximateFieldInfoByTypeName)
        return problemTypes
    }()

    /**
     Performs a one time scan of all property getters at a bundlePath to
     look out for structs that are or contain bridged(?) values such as URL
     or UUID and are passed by reference by the compiler for some reason.
     */
    open class func process(bundlePath: UnsafePointer<Int8>,
                            skip: Bool = !SwiftTrace.typeLookup, problemTypes:
                            UnsafeMutablePointer<Set<UnsafeRawPointer>>) {
//        let start = Date.timeIntervalSinceReferenceDate
//        defer { print("Took \(Date.timeIntervalSinceReferenceDate-start) " +
//                      "to process \(String(cString: bundlePath))") }
        findHiddenSwiftSymbols(bundlePath, "ON", .any) { (symval, symbol, _, _) in
            enumTypes.insert(symval)
        }

        if skip { return }

        var offset = 0
        var currentType = ""
        var wasFloatType = false

        var symbols = [(symval: UnsafeRawPointer, symname: UnsafePointer<Int8>)]()
        findHiddenSwiftSymbols(bundlePath, "g", .any) { (symval, symbol, _, _) in
            symbols.append((symval, symbol))
        }

        // Need to process symbols in emitted order if we are
        // to have any hope of recovering type memory layout.
        let debugPassedByReference = getenv("DEBUG_BYREFERENCE") != nil
        for (_, symbol) in symbols.sorted(by: { $0.symval < $1.symval }) {
            guard let demangled = SwiftMeta.demangle(symbol: symbol) else {
                print("Could not demangle: \(String(cString: symbol))")
                continue
            }
            if demangled.hasPrefix("(extension in ") {
                continue
            }
            func debug(_ str: @autoclosure () -> String) {
                if !debugPassedByReference { return }
                print(demangled)
                print(str())
            }
            guard let fieldStart = demangled.index(of: .first(of: " : ")+3),
               let nameEnd = demangled.index(of: fieldStart + .last(of: ".")),
               let typeEnd = demangled.index(of: nameEnd + .last(of: ".")),
               let typeName = demangled[..<typeEnd][safe:
                                     (.last(of: ":")+1 || .start)...],
               let fieldName = demangled[safe: typeEnd+1 ..< nameEnd],
               let fieldTypeName = demangled[safe: (fieldStart+0)...] else {
                 debug("Could not parse: \(demangled)")
                 continue
            }

            guard let type = SwiftMeta.lookupType(named: typeName) else {
                 debug("Could not lookup type: \(typeName)")
                 continue
             }

//            debug("\(typeName).\(fieldName): \(fieldTypeName)")
            let typeIsClass = type is AnyClass
            let symend = symbol+strlen(symbol)
            if strcmp(symend-3, "Ovg") == 0 || // enum
                strcmp(symend-5, "OSgvg") == 0, !typeIsClass {
                debug("\(typeName) enum prop \(fieldTypeName)")
                if let _ = typeLookupCache[typeName] {} else {
                    if !(type is UnsupportedTyping.Type) {
                        typeLookupCache[typeName] =
                            convert(type: type, handler: getEnumTypeFptr)
                    }
                }
                continue
            }

            func nextType(floatField: Bool) {
                if currentType != typeName {
                    currentType = typeName
                    wasFloatType = floatField
                    approximateFieldInfoByTypeName[typeName] = [FieldInfo]()
                    offset = type is AnyClass ? 8 * 3 : 0
                    if floatField && !typeIsClass {
                        structsAllFloats.insert(autoBitCast(type))
                    }
                }
            }

            guard let fieldType = SwiftMeta.lookupType(named: fieldTypeName) else {
                debug("Could not lookup field type: \"\(fieldTypeName)\", \(demangled) ")
                nextType(floatField: false)
                continue
            }

            let isFloatField = fieldType is SwiftTraceFloatArg.Type ||
                structsAllFloats.contains(autoBitCast(fieldType))
            nextType(floatField: isFloatField)

            // Ignore non stored properties
            if doesntHaveStorage.contains(String(cString: symbol)) {
                debug("No Storage \(typeName).\(fieldName)")
                continue
            }

            let strideMinus1 = strideof(anyType: fieldType) - 1
            offset = (offset + strideMinus1) & ~strideMinus1
            approximateFieldInfoByTypeName[typeName]?.append(
                FieldInfo(name: fieldName, type: fieldType, offset: offset))
            offset += sizeof(anyType: fieldType)

            if !isFloatField {
                structsAllFloats.remove(autoBitCast(type))
            }

            if typeIsClass {
                continue
            }

            if isFloatField != wasFloatType &&
                !(type is SwiftTraceFloatArg.Type) &&
                !problemTypes.pointee.contains(autoBitCast(type)) {
                debug("\(typeName) Mixed properties")
                if !(type is UnsupportedTyping.Type) {
                    typeLookupCache[typeName] =
                        convert(type: type, handler: getMixedTypeFptr)
                }
            }

            func passedByReference(_ type: Any.Type) {
                if !_typeName(type).hasPrefix("Swift.") &&
                    problemTypes.pointee.insert(autoBitCast(type)).inserted {
                    debug("\(_typeName(type)) passed by reference")
                }
            }

            if problemTypes.pointee.contains(autoBitCast(fieldType)) ||
                fieldTypeName.hasPrefix("Foundation.Measurement<") {
                debug("\(typeName) Reference prop \(fieldTypeName)")
//                            typeLookupCache[typeName] = PreventLookup
                passedByReference(type)
                passedByReference(fieldType)
            } else if let optional = fieldType as? OptionalTyping.Type,
                problemTypes.pointee.contains(autoBitCast(optional.wrappedType)) {
                debug("\(typeName) Reference optional prop \(fieldTypeName)")
                passedByReference(type)
                passedByReference(fieldType)
            }
        }
    }
}
#endif
