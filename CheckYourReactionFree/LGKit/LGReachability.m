//
//  Created by Grigory Lutkov on 09.08.12.
//  Copyright (c) 2011 Apogee Studi. All rights reserved.
//

#import "LGReachability.h"
#import "LGLocalization.h"

@implementation LGReachability

//Singleton instance
static LGReachability *_sharedManager = nil;

@synthesize label;

#pragma mark - Singleton Methods

+ (LGReachability *)sharedManager
{
	@synchronized([LGReachability class])
	{
		if (!_sharedManager) _sharedManager = [[self alloc] init];
        
		return _sharedManager;
	}
	// to avoid compiler warning
	return nil;
}

+ (id)alloc
{
	@synchronized([LGReachability class])
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
        NSLog(@"LGReachability: Initialising...");
        
        [self initReachability];
    }
	return self;
}

#pragma mark - Init Methods
#pragma mark Непрерывное слежение

- (void)initReachability
{
	// наблюдаем за изменением состояния сети
    // при изменении вызовем reachabilityChanged
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    // проверяем доступность интернет соединения
    internetReach = [Reachability reachabilityForInternetConnection];
    [internetReach startNotifier];
    
    // узнаем состояние сети при запуске приложения
    [self updateInternetStatus:internetReach];
}

// вызывается при обнаружении изменения состояния
- (void)reachabilityChanged:(NSNotification *)note
{
    Reachability *curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    [self updateInternetStatus:curReach];
}

- (void)updateInternetStatus:(Reachability *)curReach
{
    // определяем состояние
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    
    switch (netStatus)
    {
        case NotReachable:
        {
            NSLog(@"LGReachability: Access not available");
            
            [label setString:LGLocalizedString(@"NotReachable", nil)];
            label.color = ccc3(230, 0, 0);
            
            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"LGReachability: Reachable WWAN");
            
            [label setString:LGLocalizedString(@"ReachableViaWWAN", nil)];
            label.color = ccc3(0, 230, 0);
            
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"LGReachability: Reachable WiFi");
            
            [label setString:LGLocalizedString(@"ReachableViaWiFi", nil)];
            label.color = ccc3(0, 230, 0);
            
            break;
        }
    }
}

#pragma mark - Разовое информирование

- (int)internetStatus
{
    NetworkStatus netStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    int internetStatus;
    
    switch (netStatus)
    {
        case NotReachable:
        {
            internetStatus = 0;
            NSLog(@"LGReachability: Access not available");
            
            [label setString:LGLocalizedString(@"NotReachable", nil)];
            label.color = ccc3(230, 0, 0);
            
            break;
        }
        case ReachableViaWWAN:
        {
            internetStatus = 1;
            NSLog(@"LGReachability: Reachable WWAN");
            
            [label setString:LGLocalizedString(@"ReachableViaWWAN", nil)];
            label.color = ccc3(0, 230, 0);
            
            break;
        }
        case ReachableViaWiFi:
        {
            internetStatus = 2;
            NSLog(@"LGReachability: Reachable WiFi");
            
            [label setString:LGLocalizedString(@"ReachableViaWiFi", nil)];
            label.color = ccc3(0, 230, 0);
            
            break;
        }
    }
    
    return internetStatus;
}

@end
