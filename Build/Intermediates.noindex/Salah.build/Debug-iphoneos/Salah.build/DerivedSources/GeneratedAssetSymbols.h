#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The resource bundle ID.
static NSString * const ACBundleID AC_SWIFT_PRIVATE = @"com.kamsque.Salah";

/// The "Journal" asset catalog color resource.
static NSString * const ACColorNameJournal AC_SWIFT_PRIVATE = @"Journal";

/// The "Journal2" asset catalog color resource.
static NSString * const ACColorNameJournal2 AC_SWIFT_PRIVATE = @"Journal2";

/// The "Sky" asset catalog color resource.
static NSString * const ACColorNameSky AC_SWIFT_PRIVATE = @"Sky";

/// The "Sky2" asset catalog color resource.
static NSString * const ACColorNameSky2 AC_SWIFT_PRIVATE = @"Sky2";

/// The "Sunset" asset catalog color resource.
static NSString * const ACColorNameSunset AC_SWIFT_PRIVATE = @"Sunset";

/// The "Sunset2" asset catalog color resource.
static NSString * const ACColorNameSunset2 AC_SWIFT_PRIVATE = @"Sunset2";

/// The "compass" asset catalog image resource.
static NSString * const ACImageNameCompass AC_SWIFT_PRIVATE = @"compass";

/// The "kabba" asset catalog image resource.
static NSString * const ACImageNameKabba AC_SWIFT_PRIVATE = @"kabba";

/// The "logo" asset catalog image resource.
static NSString * const ACImageNameLogo AC_SWIFT_PRIVATE = @"logo";

/// The "makkah" asset catalog image resource.
static NSString * const ACImageNameMakkah AC_SWIFT_PRIVATE = @"makkah";

/// The "qibla" asset catalog image resource.
static NSString * const ACImageNameQibla AC_SWIFT_PRIVATE = @"qibla";

#undef AC_SWIFT_PRIVATE