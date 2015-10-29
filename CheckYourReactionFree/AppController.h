//
//  Created by Grigory Lutkov on 01.10.12.
//  Copyright (c) 2012 Grigory Lutkov. All rights reserved.
//

#import "cocos2d.h"
#import "NavigationController.h"

@interface AppController : NSObject <UIApplicationDelegate, CCDirectorDelegate>
{
	UIWindow                *window_;
	CCDirectorIOS           *director_;							// weak ref
    NavigationController    *navigationController;
}

@property (nonatomic, retain) UIWindow *window;
@property (readonly) CCDirectorIOS *director;
@property (nonatomic, retain) NavigationController *navigationController;
@property int helpShownCheck;

@end
