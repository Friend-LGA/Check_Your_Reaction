//
//  Created by Grigory Lutkov on 09.08.12.
//  Copyright (c) 2011 Apogee Studi. All rights reserved.
//

#import "LGRemainder.h"
#import "LGLocalization.h"
#import "LGKit.h"

@implementation LGRemainder

//Singleton instance
static LGRemainder *_sharedManager = nil;

#pragma mark - Singleton Methods

+ (LGRemainder *)sharedManager
{
	@synchronized([LGRemainder class])
	{
		if (!_sharedManager) _sharedManager = [[self alloc] init];
        
		return _sharedManager;
	}
	// to avoid compiler warning
	return nil;
}

+ (id)alloc
{
	@synchronized([LGRemainder class])
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
        NSLog(@"LGRemainder: Initialising...");
        
        // Счетчик запусков
        int k = kLaunchCounter;
        [[NSUserDefaults standardUserDefaults] setInteger:(k+1) forKey:@"launchCounter"];
        NSLog(@"LGRemainder: Launch Counter = %i", kLaunchCounter);
        
        [self showAlert];
    }
	return self;
}

- (void)showAlert
{
    if (!(kLaunchCounter % 3) && !kIsGameRated)
    {
        [[[UIAlertView alloc] initWithTitle:LGLocalizedString(@"RateTitle", nil)
                                    message:LGLocalizedString(@"RateMessage", nil)
                                   delegate:self
                          cancelButtonTitle:LGLocalizedString(@"RateLater", nil)
                          otherButtonTitles:LGLocalizedString(@"RateOk", nil), LGLocalizedString(@"RateNo", nil), nil] show];
    }
}

/* // For Landscape
- (void)willPresentAlertView:(UIAlertView *)alertView
{
    if (kDevicePhone && [alertView.title isEqualToString:LGLocalizedString(@"RateTitle", nil)])
    {
        alertView.frame = CGRectMake(alertView.frame.origin.x, alertView.frame.origin.y - 25, alertView.frame.size.width, alertView.frame.size.height + 50);
        for (UIView *subview in [alertView subviews])
        {
            if ([subview isKindOfClass:[UILabel class]])
            {
                UILabel *label = (UILabel *)subview;
                if ([label.text isEqualToString:alertView.message])
                {
                    label.frame = CGRectMake(12, 45, 260, 60);
                    label.alpha = 1.0f;
                    label.lineBreakMode = UILineBreakModeWordWrap;
                    label.numberOfLines = 0;
                }
            }
            else if ([subview isKindOfClass:[UIControl class]])
            {
                UIControl *button = (UIControl *)subview;
                button.frame = CGRectMake(button.frame.origin.x, button.frame.origin.y + 50, button.frame.size.width, button.frame.size.height);
            }
        }
    }
}
*/
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [[UIApplication sharedApplication] openURL:
         [NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", kAppId]]];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isGameRated"];
        
        [[[UIAlertView alloc] initWithTitle:LGLocalizedString(@"RatedTitle", nil)
                                    message:LGLocalizedString(@"RatedMessage", nil)
                                   delegate:self
                          cancelButtonTitle:LGLocalizedString(@"cancel", nil)
                          otherButtonTitles:nil] show];
    }
    else if (buttonIndex == 2)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isGameRated"];
    }
}

@end





