//
//  Created by Grigory Lutkov on 01.10.12.
//  Copyright (c) 2012 Grigory Lutkov. All rights reserved.
//

#define LGLocalizedString(key, comment) \
[[LGLocalization sharedManager] localizedStringForKey:(key) value:(comment)]

#define LGLocalizationSetLanguage(language) \
[[LGLocalization sharedManager] setLanguage:(language)]

#define LGLocalizationGetSystemLanguage \
[[LGLocalization sharedManager] getSystemLanguage]

#define LGLocalizationGetPreferredLanguage \
[[LGLocalization sharedManager] getPreferredLanguage]

#define LGLocalizationReset \
[[LGLocalization sharedManager] resetLocalization]

@interface LGLocalization : NSObject
{
	NSString *language;
}

+ (LGLocalization *)sharedManager;
//gets the string localized
- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)comment;
//sets the language
- (void)setLanguage:(NSString*) language;
//gets the system language
- (NSString *)getSystemLanguage;
//gets the preferred language
- (NSString *)getPreferredLanguage;
//resets this system.
- (void)resetLocalization;

@end
