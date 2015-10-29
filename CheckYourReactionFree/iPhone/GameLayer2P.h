//
//  Created by Grigory Lutkov on 04.03.11.
//  Copyright 2011 Apogee Studio. All rights reserved.
//

#import "cocos2d.h"

@interface GameLayer2P : CCLayer
{
	int             i;
	int             t;
    int             z;
    int             changer;
	int             check;
    int             touchedP1;
    int             touchedP2;
    int             touchCount;
    int             gameEnd;
    int             longReactionDone;
    int             timingsFontSize;
    int             attentionFontSize;
    int             warningFontSize;
    int             finalFontSize;
    int             warningOnScreen;
	float           number;
	float           time1;
    float           time2;
    float           score1;
    float           score2;
	float           result1;
    float           result2;
    
    NSDate          *start;
    NSDate          *end;
	
    CCSprite        *iAdBanner;
    CCSprite        *backButton;
	CCSprite        *retryButton;
	CCSprite        *circle;
	CCSprite        *circleAlert;
	CCLabelTTF      *timingsP1;
    CCLabelTTF      *timingsP2;
	CCLabelTTF      *timing;
	CCLabelTTF      *timing1;
	CCLabelTTF      *timing2;
	CCLabelTTF      *timing3;
	CCLabelTTF      *timing4;
	CCLabelTTF      *timing5;
    CCLabelTTF      *timing6;
	CCLabelTTF      *timing7;
	CCLabelTTF      *timing8;
	CCLabelTTF      *timing9;
	CCLabelTTF      *timing10;
	CCLabelTTF      *element1;
    CCLabelTTF      *element2;
	CCLabelTTF      *attention;
	CCLabelTTF      *warning;
    CCLabelTTF      *finalScore1;
    CCLabelTTF      *finalScore2;
    CCSprite        *stripe;
    
    CCTexture2D     *backButtonT[2];
    CCTexture2D     *retryButtonT[2];
	
    CGSize          winSize;
	NSArray         *myTimings1;
    NSArray         *myTimings2;
	ccColor3B       lightColor;
    UITouch         *touch;
    CGPoint         touchPoint;
    UITouch         *touch1;
    CGPoint         touchPoint1;
    UITouch         *touch2;
    CGPoint         touchPoint2;
}

+ (id) scene;

@end
