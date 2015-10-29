//
//  Created by Grigory Lutkov on 04.03.11.
//  Copyright 2011 Apogee Studio. All rights reserved.
//

#import "cocos2d.h"

@interface GameLayer1P : CCLayer
{
	int             i;
	int             t;
    int             z;
    int             changer;
	int             check;
	int             checkColor;
    int             checkColorRoot;
	int             checkColorText;
	int             checkColorTextPrevious;
	int             checkColorNew;
	int             count;
    int             badTouchCount;
    int             timingsFontSize;
    int             attentionFontSize;
    int             warningFontSize;
    int             textBorderSize;
    int             warningOnScreen;
    int             difficulty;
    int             colorTextFontSize;
    int             numberColor;
	int             numberAdd;
    int             numberColorText;
    int             actionRun;
	float           number;
	float           time;
	float           result;
    float           score;
    
    NSDate          *start;
    NSDate          *end;
	
    CCSprite        *iAdBanner;
    CCSprite        *backButton;
	CCSprite        *retryButton;
	CCSprite        *circle;
	CCSprite        *circleAlert;
	CCLabelTTF      *bestScore;
	CCLabelTTF      *bestScoreValue;
	CCLabelTTF      *timings;
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
	CCLabelTTF      *text;
	CCLabelTTF      *element;
	CCLabelTTF      *attention;
	CCLabelTTF      *warningMistake;
    CCLabelTTF      *warningLate;
    CCLabelTTF      *colorText;
    
    CCTexture2D     *backButtonT[2];
    CCTexture2D     *retryButtonT[2];
	
	NSArray         *myTimings;
	ccColor3B       lightColor;
    NSString        *lightColorText;
	CGSize          winSize;
    UITouch         *touch;
	CGPoint         touchPoint;
    
    CCAction        *action;
}

+ (id) scene;

@end
