//
//  Created by Grigory Lutkov on 01.10.12.
//  Copyright (c) 2012 Grigory Lutkov. All rights reserved.
//

#import "LGAdWhirl.h"
#import "AdWhirlView.h"
#import "AppController.h"
#import "GADAdSize.h"
#import "LGKit.h"

@implementation LGAdWhirl

//Singleton instance
static LGAdWhirl *_sharedManager = nil;

@synthesize adView;

#pragma mark - Singleton Methods

+ (LGAdWhirl *)sharedManager
{
	@synchronized([LGAdWhirl class])
	{
		if (!_sharedManager) _sharedManager = [[self alloc] init];
        
		return _sharedManager;
	}
	// to avoid compiler warning
	return nil;
}

+ (id)alloc
{
	@synchronized([LGAdWhirl class])
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
        NSLog(@"LGAdWhirl: Initialising...");
    }
	return self;
}

#pragma mark - Init Methods

- (void)initAdWhirlWithOrientation:(UIInterfaceOrientationMask)orientation
{
    UINavigationController *navigationController = [(AppController *)[[UIApplication sharedApplication] delegate] navigationController];
    self.adView = [AdWhirlView requestAdWhirlViewWithDelegate:self];
    self.adView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    [adView updateAdWhirlConfig];
    CGSize adSize;
    if (kDevicePhone && orientation == UIInterfaceOrientationMaskLandscape && navigationController.view.bounds.size.width == 568) adSize = CGSizeMake(568, 32);
    else if (kDevicePhone && orientation == UIInterfaceOrientationMaskLandscape) adSize = CGSizeMake(480, 32);
    else if (kDevicePhone && orientation == UIInterfaceOrientationMaskPortrait) adSize = CGSizeMake(320, 50);
    else if (kDevicePad && orientation == UIInterfaceOrientationMaskLandscape) adSize = CGSizeMake(1024, 66);
    else if (kDevicePad && orientation == UIInterfaceOrientationMaskPortrait) adSize = CGSizeMake(768, 66);
    NSLog(@"adSize (%.0f, %.0f)", adSize.width, adSize.height);
	self.adView.frame = CGRectMake(0, -adSize.height, adSize.width, adSize.height);
	self.adView.clipsToBounds = YES;
    [navigationController.view addSubview:adView];
    [navigationController.view bringSubviewToFront:adView];
}

- (void)adWhirlDidReceiveAd:(AdWhirlView *)adWhirlView
{
    [UIView beginAnimations:@"AdResize" context:nil];
	[UIView setAnimationDuration:0.5];
	CGSize adSize = [adView actualAdSize];
    self.adView.frame = CGRectMake(0, 0, adSize.width, adSize.height);
	[UIView commitAnimations];
    
    NSLog(@"adSize (%.0f, %.0f)", adSize.width, adSize.height);
}

- (void)removeAdWhirl
{
    [adView removeFromSuperview];
    [adView replaceBannerViewWith:nil];
    [adView ignoreNewAdRequests];
    [adView setDelegate:nil];
    self.adView = nil;
}

#pragma mark - Delegates

- (void)adWhirlWillPresentFullScreenModal
{
    //[self pauseGame];
}

- (void)adWhirlDidDismissFullScreenModal
{
    //[self resumeGame];
}

- (NSString *)adWhirlApplicationKey
{
    return kAdWhirlApplicationKey;
}

- (UINavigationController *)viewControllerForPresentingModalView
{
    return [(AppController *)[[UIApplication sharedApplication] delegate] navigationController];
}

@end
