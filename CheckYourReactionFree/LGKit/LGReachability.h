//
//  Created by Grigory Lutkov on 09.08.12.
//  Copyright (c) 2011 Apogee Studi. All rights reserved.
//

#import "Reachability.h"
#import "cocos2d.h"

@interface LGReachability : NSObject
{
    Reachability    *internetReach;
    CCLabelTTF      *label;
}

@property (nonatomic, retain) CCLabelTTF *label;

+ (LGReachability *)sharedManager;
- (void)initReachability;
- (void)reachabilityChanged:(NSNotification *)note;
- (void)updateInternetStatus:(Reachability *)curReach;
- (int)internetStatus;

@end
