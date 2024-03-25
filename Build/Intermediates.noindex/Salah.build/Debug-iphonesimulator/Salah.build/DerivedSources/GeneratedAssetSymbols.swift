import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ColorResource {

    /// The "Journal" asset catalog color resource.
    static let journal = DeveloperToolsSupport.ColorResource(name: "Journal", bundle: resourceBundle)

    /// The "Journal2" asset catalog color resource.
    static let journal2 = DeveloperToolsSupport.ColorResource(name: "Journal2", bundle: resourceBundle)

    /// The "Sky" asset catalog color resource.
    static let sky = DeveloperToolsSupport.ColorResource(name: "Sky", bundle: resourceBundle)

    /// The "Sky2" asset catalog color resource.
    static let sky2 = DeveloperToolsSupport.ColorResource(name: "Sky2", bundle: resourceBundle)

    /// The "Sunset" asset catalog color resource.
    static let sunset = DeveloperToolsSupport.ColorResource(name: "Sunset", bundle: resourceBundle)

    /// The "Sunset2" asset catalog color resource.
    static let sunset2 = DeveloperToolsSupport.ColorResource(name: "Sunset2", bundle: resourceBundle)

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

    /// The "compass" asset catalog image resource.
    static let compass = DeveloperToolsSupport.ImageResource(name: "compass", bundle: resourceBundle)

    /// The "kabba" asset catalog image resource.
    static let kabba = DeveloperToolsSupport.ImageResource(name: "kabba", bundle: resourceBundle)

    /// The "logo" asset catalog image resource.
    static let logo = DeveloperToolsSupport.ImageResource(name: "logo", bundle: resourceBundle)

    /// The "makkah" asset catalog image resource.
    static let makkah = DeveloperToolsSupport.ImageResource(name: "makkah", bundle: resourceBundle)

    /// The "qibla" asset catalog image resource.
    static let qibla = DeveloperToolsSupport.ImageResource(name: "qibla", bundle: resourceBundle)

}

// MARK: - Color Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    /// The "Journal" asset catalog color.
    static var journal: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .journal)
#else
        .init()
#endif
    }

    /// The "Journal2" asset catalog color.
    static var journal2: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .journal2)
#else
        .init()
#endif
    }

    /// The "Sky" asset catalog color.
    static var sky: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .sky)
#else
        .init()
#endif
    }

    /// The "Sky2" asset catalog color.
    static var sky2: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .sky2)
#else
        .init()
#endif
    }

    /// The "Sunset" asset catalog color.
    static var sunset: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .sunset)
#else
        .init()
#endif
    }

    /// The "Sunset2" asset catalog color.
    static var sunset2: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .sunset2)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    /// The "Journal" asset catalog color.
    static var journal: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .journal)
#else
        .init()
#endif
    }

    /// The "Journal2" asset catalog color.
    static var journal2: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .journal2)
#else
        .init()
#endif
    }

    /// The "Sky" asset catalog color.
    static var sky: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .sky)
#else
        .init()
#endif
    }

    /// The "Sky2" asset catalog color.
    static var sky2: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .sky2)
#else
        .init()
#endif
    }

    /// The "Sunset" asset catalog color.
    static var sunset: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .sunset)
#else
        .init()
#endif
    }

    /// The "Sunset2" asset catalog color.
    static var sunset2: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .sunset2)
#else
        .init()
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    /// The "Journal" asset catalog color.
    static var journal: SwiftUI.Color { .init(.journal) }

    /// The "Journal2" asset catalog color.
    static var journal2: SwiftUI.Color { .init(.journal2) }

    /// The "Sky" asset catalog color.
    static var sky: SwiftUI.Color { .init(.sky) }

    /// The "Sky2" asset catalog color.
    static var sky2: SwiftUI.Color { .init(.sky2) }

    /// The "Sunset" asset catalog color.
    static var sunset: SwiftUI.Color { .init(.sunset) }

    /// The "Sunset2" asset catalog color.
    static var sunset2: SwiftUI.Color { .init(.sunset2) }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    /// The "Journal" asset catalog color.
    static var journal: SwiftUI.Color { .init(.journal) }

    /// The "Journal2" asset catalog color.
    static var journal2: SwiftUI.Color { .init(.journal2) }

    /// The "Sky" asset catalog color.
    static var sky: SwiftUI.Color { .init(.sky) }

    /// The "Sky2" asset catalog color.
    static var sky2: SwiftUI.Color { .init(.sky2) }

    /// The "Sunset" asset catalog color.
    static var sunset: SwiftUI.Color { .init(.sunset) }

    /// The "Sunset2" asset catalog color.
    static var sunset2: SwiftUI.Color { .init(.sunset2) }

}
#endif

// MARK: - Image Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    /// The "compass" asset catalog image.
    static var compass: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .compass)
#else
        .init()
#endif
    }

    /// The "kabba" asset catalog image.
    static var kabba: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .kabba)
#else
        .init()
#endif
    }

    /// The "logo" asset catalog image.
    static var logo: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .logo)
#else
        .init()
#endif
    }

    /// The "makkah" asset catalog image.
    static var makkah: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .makkah)
#else
        .init()
#endif
    }

    /// The "qibla" asset catalog image.
    static var qibla: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .qibla)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// The "compass" asset catalog image.
    static var compass: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .compass)
#else
        .init()
#endif
    }

    /// The "kabba" asset catalog image.
    static var kabba: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .kabba)
#else
        .init()
#endif
    }

    /// The "logo" asset catalog image.
    static var logo: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .logo)
#else
        .init()
#endif
    }

    /// The "makkah" asset catalog image.
    static var makkah: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .makkah)
#else
        .init()
#endif
    }

    /// The "qibla" asset catalog image.
    static var qibla: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .qibla)
#else
        .init()
#endif
    }

}
#endif

// MARK: - Thinnable Asset Support -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ColorResource {

    private init?(thinnableName: String, bundle: Bundle) {
#if canImport(AppKit) && os(macOS)
        if AppKit.NSColor(named: NSColor.Name(thinnableName), bundle: bundle) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIColor(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}
#endif

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ImageResource {

    private init?(thinnableName: String, bundle: Bundle) {
#if canImport(AppKit) && os(macOS)
        if bundle.image(forResource: NSImage.Name(thinnableName)) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIImage(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

