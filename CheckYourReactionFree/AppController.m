//
//  Created by Grigory Lutkov on 01.10.12.
//  Copyright (c) 2012 Grigory Lutkov. All rights reserved.
//

#import "AppController.h"
#import "MenuLayer.h"
#import "SimpleAudioEngine.h"
#import "LGGameCenter.h"
#import "LGLocalization.h"
#import "LGAdWhirl.h"
#import "LGInAppPurchases.h"
#import "LGReachability.h"
#import "LGKit.h"
#import "LGRemainder.h"
#import <FacebookSDK/FacebookSDK.h>

#pragma mark - AppController

@implementation AppController

@synthesize window = window_,
director = director_,
navigationController;

#pragma mark - For DEFacebook

void uncaughtExceptionHandler(NSException *exception)
{
    NSString *crashString = [NSString stringWithFormat:@"Crash info: %@ \nStack: %@", exception, [exception callStackSymbols]];
    
    // Internal error reporting
    NSLog(@"%@", crashString);
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    // attempt to extract a token from the url
    return [FBSession.activeSession handleOpenURL:url];
}

#pragma mark

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Create the main window
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    
	// Create an CCGLView with a RGB565 color buffer, and a depth buffer of 0-bits
	CCGLView *glView = [CCGLView viewWithFrame:[window_ bounds]
								   pixelFormat:kEAGLColorFormatRGB565	//kEAGLColorFormatRGBA8
								   depthFormat:0                        //GL_DEPTH_COMPONENT24_OES
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];
    
	director_ = (CCDirectorIOS *)[CCDirector sharedDirector];
    
	director_.wantsFullScreenLayout = YES;
    
	// Display FSP and SPF
	[director_ setDisplayStats:NO];
    
	// set FPS at 60
	[director_ setAnimationInterval:1.0/60];
    
	// attach the openglView to the director
	[director_ setView:glView];
    
	// for rotation and other messages
	[director_ setDelegate:self];
    
	// 2D projection
	[director_ setProjection:kCCDirectorProjection2D];
    //	[director setProjection:kCCDirectorProjection3D];
    
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if (![director_ enableRetinaDisplay:YES])
        CCLOG(@"AppController: Retina Display Not supported");
    
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
    
	// If the 1st suffix is not found and if fallback is enabled then fallback suffixes are going to searched. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:NO];				// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"
    
	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
    
	// Create a Navigation Controller with the Director
    navigationController = [[NavigationController alloc] initWithRootViewController:director_];
    navigationController.navigationBarHidden = YES;
    
	// set the Navigation Controller as the root view controller
	[window_ setRootViewController:navigationController];
    
	// make main window visible
	[window_ makeKeyAndVisible];
    
	return YES;
}

#pragma mark - Running Scene

// This is needed for iOS4 and iOS5 in order to ensure
// that the 1st scene has the correct dimensions
// This is not needed on iOS6 and could be added to the application:didFinish...
- (void) directorDidReshapeProjection:(CCDirector *)director
{
	if (director.runningScene == nil)
    {
		// Add the first scene to the stack. The director will draw it immediately into the framebuffer. (Animation is started automatically when the view is displayed.)
		// and add the scene to the stack. The director will run it when it automatically when the view is displayed.
        
        // My Kit
        kLGKit;
        
        // clear UserDefaults
        //[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
        //[kLGGameCenter resetAchievementsWithAlert:NO];
        
        // Checking first launch & new version
        if (![[kStandartUserDefaults stringForKey:@"gameVersion"] isEqualToString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]])
        {
            [kStandartUserDefaults setBool:NO forKey:@"isGameRated"];
            [kStandartUserDefaults setBool:NO forKey:@"isNewsShowed"];
            [kStandartUserDefaults setInteger:0 forKey:@"launchCounter"];
            [kStandartUserDefaults setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"gameVersion"];
        }
        
        // Checking iOS Version
        NSLog(@"AppController: iOS Version %.1f", kOSVersion);
        
        // Checking internet connection
        kLGReachability;
        
        // Testing for Game Center Availability
        kLGGameCenter;
        
        // Checking sound volume
        if ([kStandartUserDefaults boolForKey:@"soundIsOn"] == NO && !kIsHelpShowed)
        {
            [SimpleAudioEngine sharedEngine].effectsVolume = 1;
            [kStandartUserDefaults setBool:YES forKey:@"soundIsOn"];
        }
        else if ([kStandartUserDefaults boolForKey:@"soundIsOn"] == NO && kIsHelpShowed)
            [SimpleAudioEngine sharedEngine].effectsVolume = 0;
        NSLog(@"AppController: Sound Volume is %.1f", [[SimpleAudioEngine sharedEngine] effectsVolume]);
        
        // Checking current languages
        kLGLocalization;
        
        // Launching In-App Purchases
        kLGInAppPurchases;
        
        // Checking Full game or Free
        if ([kStandartUserDefaults boolForKey:@"isRemoveAdsPurchased"])
        {
            NSLog(@"AppController: Game is FULL");
            [kStandartUserDefaults setBool:YES forKey:@"isGameFull"];
        }
        else
        {
            NSLog(@"AppController: Game is FREE");
            [kStandartUserDefaults setBool:NO forKey:@"isGameFull"];
            
            // Launching AdWhirl
            [kLGAdWhirl initAdWhirlWithOrientation:UIInterfaceOrientationMaskPortrait];
        }
        
        // Напоминалка
        kLGRemainder;
        
		[director runWithScene:[MenuLayer scene]];
	}
}

#pragma mark - Delegates

// getting a call, pause the game
- (void) applicationWillResignActive:(UIApplication *)application
{
	if( [navigationController visibleViewController] == director_ )
		[director_ pause];
}

// call got rejected
- (void) applicationDidBecomeActive:(UIApplication *)application
{
	if( [navigationController visibleViewController] == director_ )
		[director_ resume];
}

- (void) applicationDidEnterBackground:(UIApplication*)application
{
	if( [navigationController visibleViewController] == director_ )
		[director_ stopAnimation];
}

- (void) applicationWillEnterForeground:(UIApplication*)application
{
	if( [navigationController visibleViewController] == director_ )
		[director_ startAnimation];
}

// application will be killed
- (void) applicationWillTerminate:(UIApplication *)application
{
	CC_DIRECTOR_END();
}

// purge memory
- (void) applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCDirector sharedDirector] purgeCachedData];
}

// next delta time will be zero
- (void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

@end