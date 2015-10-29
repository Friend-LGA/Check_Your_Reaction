//
//  Created by Grigory Lutkov on 31.10.12.
//  Copyright (c) 2012 Grigory Lutkov. All rights reserved.
//

#import "LGKit.h"
#import "LGLocalization.h"

@implementation LGKit

//Singleton instance
static LGKit *_sharedManager = nil;

#pragma mark - Singleton Methods

+ (LGKit *)sharedManager
{
	@synchronized([LGKit class])
	{
		if (!_sharedManager) _sharedManager = [[self alloc] init];
        
		return _sharedManager;
	}
	// to avoid compiler warning
	return nil;
}

+ (id)alloc
{
	@synchronized([LGKit class])
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
        NSLog(@"LGKit: Initialising...");
    }
	return self;
}

#pragma mark - Дополнительные -

#pragma mark Sprite Appear / Disappear

- (void)spriteFade:(CCSprite *)sprite duration:(ccTime)time opacity:(int)opacity
{
    [sprite runAction:[CCFadeTo actionWithDuration:time opacity:opacity]];
}

#pragma mark Save in standartUserDefaults

- (void)setObject:(id)obj forKey:(NSString *)key
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:obj];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:key];
}

- (id)objectForKey:(NSString *)key
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    id obj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return obj;
}

#pragma mark Alerts

- (void)createAlertWithTitle:(NSString *)title
                     message:(NSString *)message
                    delegate:(id)delegate
           cancelButtonTitle:(NSString *)cancelButton
            otherButtonTitle:(NSString *)otherButton
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:delegate
                                          cancelButtonTitle:cancelButton
                                          otherButtonTitles:otherButton, nil];
    [alert show];
}

- (UIAlertView *)createProgressAlertWithActivity:(BOOL)activity
                                           title:(NSString *)title
                                         message:(NSString *)message
                                        delegate:(id)delegate
                               cancelButtonTitle:(NSString *)cancelButton
                                otherButtonTitle:(NSString *)otherButton
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:delegate
                                          cancelButtonTitle:cancelButton
                                          otherButtonTitles:otherButton, nil];
    if (activity)
    {
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activityView.frame = CGRectMake(139-18, 74, 37, 37);
        [alert addSubview:activityView];
        [activityView startAnimating];
    }
    else
    {
        UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(30, 80, 225, 90)];
        [alert addSubview:progressView];
        [progressView setProgressViewStyle:UIProgressViewStyleBar];
    }
    
    [alert show];
    return alert;
}

- (void)createAlertNoInternet
{
    [[[UIAlertView alloc] initWithTitle:LGLocalizedString(@"noInternetConnectionTitle", nil)
                                message:LGLocalizedString(@"noInternetConnectionMessage", nil)
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

#pragma mark Touch Enable / Disable

- (void)touchEnableWithTarget:(CCLayer *)target
{
    target.isTouchEnabled = YES;
}

- (void)touchDisableWithTarget:(CCLayer *)target
{
    target.isTouchEnabled = NO;
}

#pragma mark Button Select / Unselect

- (void)buttonSelect:(CCSprite *)buttonBg color:(ccColor3B)color buttonText:(CCLabelTTF *)buttonText withText:(NSString *)text
{
    buttonBg.color = color;
    buttonBg.opacity = 150;
    [buttonText setString:LGLocalizedString(text, nil)];
}

- (void)buttonSelect:(CCSprite *)buttonBg color:(ccColor3B)color
{
    buttonBg.color = color;
    buttonBg.opacity = 150;
}

- (void)buttonUnselect:(CCSprite *)buttonBg color:(ccColor3B)color buttonText:(CCLabelTTF *)buttonText withText:(NSString *)text
{
    buttonBg.color = color;
    buttonBg.opacity = 30;
    [buttonText setString:LGLocalizedString(text, nil)];
}

- (void)buttonUnselect:(CCSprite *)buttonBg color:(ccColor3B)color
{
    buttonBg.color = color;
    buttonBg.opacity = 30;
}

@end














