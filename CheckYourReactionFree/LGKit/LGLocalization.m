//
//  Created by Grigory Lutkov on 01.10.12.
//  Copyright (c) 2012 Grigory Lutkov. All rights reserved.
//

#import "LGLocalization.h"

@implementation LGLocalization

//Singleton instance
static LGLocalization *_sharedManager = nil;

//Current application bungle to get the languages.
static NSBundle *bundle = nil;

#pragma mark - Singleton Methods

+ (LGLocalization *)sharedManager
{
	@synchronized([LGLocalization class])
	{
		if (!_sharedManager) _sharedManager = [[self alloc] init];
        
		return _sharedManager;
	}
	// to avoid compiler warning
	return nil;
}

+ (id)alloc
{
	@synchronized([LGLocalization class])
	{
		NSAssert(_sharedManager == nil, @"Attempted to allocate a second instance of a singleton.");
		_sharedManager = [super alloc];
		return _sharedManager;
	}
	// to avoid compiler warning
	return nil;
}

- (id)init
{
    if ((self = [super init]))
    {
        NSLog(@"LGLocalization: Initialising...");
        
		bundle = [NSBundle mainBundle];
        
        LGLocalizationGetSystemLanguage;
        if (LGLocalizationGetPreferredLanguage) LGLocalizationSetLanguage(LGLocalizationGetPreferredLanguage);
        else LGLocalizationSetLanguage(LGLocalizationGetSystemLanguage);
	}
    return self;
}

#pragma mark - Init Methods

// Gets the current localized string as in NSLocalizedString.
//
// example calls:
// LGLocalizedString(@"Text to localize",@"Alternative text, in case hte other is not find");

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)comment
{
	return [bundle localizedStringForKey:key value:comment table:nil];
}

// Sets the desired language of the ones you have.
// example calls:
// LGLocalizationSetLanguage(@"English");
// LGLocalizationSetLanguage(@"German");
// LGLocalizationSetLanguage(@"Russian");
//
// If this function is not called it will use the default OS language.
// If the language does not exists y returns the default OS language.

- (void)setLanguage:(NSString *)l
{
	NSLog(@"LGLocalization: Preferred Language: %@", l);
    
    [[NSUserDefaults standardUserDefaults] setObject:l forKey:@"PreferredLanguage"];
	
	NSString *path = [[ NSBundle mainBundle ] pathForResource:l ofType:@"lproj" ];
	
	if (path == nil)
		//in case the language does not exists
		[self resetLocalization];
	else
		bundle = [NSBundle bundleWithPath:path];
}

// Just gets the current setted up system language.
// returns "es","fr",...
//
// example call:
// NSString * currentL = LGLocalizationGetSystemLanguage;

- (NSString *)getSystemLanguage
{
	NSArray *languages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    
	NSString *preferredLang = [languages objectAtIndex:0];
    
    NSLog(@"LGLocalization: System Language: %@", preferredLang);
    
	return preferredLang;
}

// Just gets the current setted up preferred language.
// returns "es","fr",...
//
// example call:
// NSString *currentL = LGLocalizationGetPreferredLanguage;

- (NSString *)getPreferredLanguage
{
	return [[NSUserDefaults standardUserDefaults] objectForKey:@"PreferredLanguage"];
}

// Resets the localization system, so it uses the OS default language.
//
// example call:
// LGLocalizationReset;

- (void)resetLocalization
{
	bundle = [NSBundle mainBundle];
}

@end