//
//  Created by Grigory Lutkov on 31.10.12.
//  Copyright (c) 2012 Grigory Lutkov. All rights reserved.
//

#pragma mark - Основные -

#define kAppDelegate            (AppDelegate *)[UIApplication sharedApplication].delegate
#define kStandartUserDefaults   [NSUserDefaults standardUserDefaults]
#define kLGKit                  [LGKit sharedManager]
#define kLGGameCenter           [LGGameCenter sharedManager]
#define kLGLocalization         [LGLocalization sharedManager]
#define kLGInAppPurchases       [LGInAppPurchases sharedManager]
#define kLGAdWhirl              [LGAdWhirl sharedManager]
#define kLGReachability         [LGReachability sharedManager]
#define kLGRemainder            [LGRemainder sharedManager]

#define kIsGameFull     [[NSUserDefaults standardUserDefaults] boolForKey:@"isGameFull"]
#define kIsGameRated    [[NSUserDefaults standardUserDefaults] boolForKey:@"isGameRated"]
#define kIsNewsShowed   [[NSUserDefaults standardUserDefaults] boolForKey:@"isNewsShowed"]
#define kIsHelpShowed   [[NSUserDefaults standardUserDefaults] boolForKey:@"isHelpShowed"]
#define kLaunchCounter  [[NSUserDefaults standardUserDefaults] integerForKey:@"launchCounter"]

#define degreesToRadian(x) (M_PI * (x) / 180.0)

#define width(x) [[x view] bounds].size.width
#define height(y) [[y view] bounds].size.height

#define kDevicePad      UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
#define kDevicePhone    UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone
#define kDevicePhone5   [[UIScreen mainScreen] bounds].size.height == 568

#define kIsRetina       [UIScreen mainScreen].scale == 2
#define kIsNotRetina    [UIScreen mainScreen].scale == 1

#define kOSVersion [[[UIDevice currentDevice] systemVersion] floatValue]

#define kInternetStatus [[LGReachability sharedManager] internetStatus]

#define kIsAchievementEarned(key) [[LGGameCenter sharedManager] isAchievementEarned:key]

#pragma mark - Дополнительные -

#define kNavController          [(AppController *)[UIApplication sharedApplication].delegate navigationController]
#define kAppController          (AppController *)[UIApplication sharedApplication].delegate
#define kSimpleAudioEngine      [SimpleAudioEngine sharedEngine]

#define kVkontakte  [Vkontakte sharedManager]

#define kFontComicSans      @"Comic Sans MS"
#define kFontOsakaMono      @"Osaka"
#define kFontPlaytime       @"Playtime With Hot Toddies"
#define kFontArial          @"Arial"
#define kFontArialBlack     @"Arial Black"

#define kCircleBgString     @"●"
#define kCircleStrokeString @"○"
#define kSquareBgString     @"■"
#define kSquareStrokeString @"□"

#define kColorLight ccc3(230,230,230)
#define kColorDark ccc3(50,50,50)
#define kColorRed ccc3(230,0,0)
#define kColorBlue ccc3(0,127,255)
#define kColorGreen ccc3(0,255,0)
#define kColorYellow ccc3(255,255,0)
#define kColorViolet ccc3(128,0,255)
#define kColorOrange ccc3(255,128,0)

#import "cocos2d.h"

CGSize                  winSize;
CGPoint                 touchPoint;
UITouch                 *touch;
CCSprite                *bg;
CCSprite                *adsBanner;
int                     z;

@interface LGKit : NSObject

+ (LGKit *)sharedManager;

#pragma mark Sprite Appear / Disappear
- (void)spriteFade:(CCSprite *)sprite duration:(ccTime)time opacity:(int)opacity;

#pragma mark Save in standartUserDefaults
- (void)setObject:(id)obj forKey:(NSString *)key;
- (id)objectForKey:(NSString *)key;

#pragma mark Alerts
- (UIAlertView *)createProgressAlertWithActivity:(BOOL)activity
                                           title:(NSString *)title
                                         message:(NSString *)message
                                        delegate:(id)delegate
                               cancelButtonTitle:(NSString *)cancelButton
                                otherButtonTitle:(NSString *)otherButton;

- (void)createAlertNoInternet;

#pragma mark Touch Enable / Disable
- (void)touchEnableWithTarget:(CCLayer *)target;
- (void)touchDisableWithTarget:(CCLayer *)target;

#pragma mark Button Select / Unselect
- (void)buttonSelect:(CCSprite *)buttonBg color:(ccColor3B)color buttonText:(CCLabelTTF *)buttonText withText:(NSString *)text;
- (void)buttonSelect:(CCSprite *)buttonBg color:(ccColor3B)color;
- (void)buttonUnselect:(CCSprite *)buttonBg color:(ccColor3B)color buttonText:(CCLabelTTF *)buttonText withText:(NSString *)text;
- (void)buttonUnselect:(CCSprite *)buttonBg color:(ccColor3B)color;

@end











