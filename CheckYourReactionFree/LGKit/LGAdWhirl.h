//
//  Created by Grigory Lutkov on 01.10.12.
//  Copyright (c) 2012 Grigory Lutkov. All rights reserved.
//

#import "AdWhirlDelegateProtocol.h"

#define kAdWhirlApplicationKey @"f075743e698c4739bb34d0a4f53b62b4"

@interface LGAdWhirl : NSObject <AdWhirlDelegate>

@property (nonatomic, retain) AdWhirlView *adView;

+ (LGAdWhirl *)sharedManager;
- (void)initAdWhirlWithOrientation:(UIInterfaceOrientationMask)orientation;
- (void)removeAdWhirl;

@end
