//
//  Created by Grigory Lutkov on 04.03.11.
//  Copyright 2011 Apogee Studio. All rights reserved.
//

#import "GameLayer2P.h"
#import "SimpleAudioEngine.h"
#import "MenuLayer.h"
#import "LGKit.h"
#import "AppController.h"
#import "LGLocalization.h"

@implementation GameLayer2P

+ (id) scene
{
	CCScene *scene = [CCScene node];
	GameLayer2P *layer = [GameLayer2P node];
	[scene addChild:layer];
	return scene;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (id) init
{
	if ((self = [super init]))
	{
        self.isTouchEnabled = YES;
        
        changer = [kStandartUserDefaults integerForKey:@"retry"];
        
		winSize = [[CCDirector sharedDirector] winSize];
        
        [self checkAdsRemoved];
		
        gameEnd = 0;
		t = -1;
		result1 = 0;
        result2 = 0;
		score1 = 0;
        score2 = 0;
        
        start = nil;
        end = nil;
		
		[self gameMenu];
		[self myTimings];
        [self scheduleOnce:@selector(changeLightTimer) delay:0];
        if (changer == 0) { [self allSpritesAppear]; }
        if (changer == 1) { [self retryAppear]; }
	}
	return self;
}

- (void) checkAdsRemoved
{
    if (!kIsGameFull)
    {
        iAdBanner = [CCSprite spriteWithFile:@"adsBannerP.png"];
        iAdBanner.position = ccp(winSize.width/2, winSize.height-iAdBanner.contentSize.height/2);
        [self addChild:iAdBanner z:10];
        
        winSize.height = winSize.height - iAdBanner.contentSize.height;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) checkColor
{
	if ([kStandartUserDefaults integerForKey:@"colorOfLight"] == 1) lightColor = kColorBlue;
	if ([kStandartUserDefaults integerForKey:@"colorOfLight"] == 2) lightColor = kColorGreen;
	if ([kStandartUserDefaults integerForKey:@"colorOfLight"] == 3) lightColor = kColorYellow;
	if ([kStandartUserDefaults integerForKey:@"colorOfLight"] == 4) lightColor = kColorViolet;
	if ([kStandartUserDefaults integerForKey:@"colorOfLight"] == 5) lightColor = kColorOrange;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) gameMenu
{
    [kStandartUserDefaults setInteger:0 forKey:@"retry"];
    
    if (kDevicePhone)
    {
        timingsFontSize = 22;
        if (kIsGameFull || height(kNavController) == 568) finalFontSize = 22;
        else finalFontSize = 21;
        attentionFontSize = 85;
        if (kIsGameFull || height(kNavController) == 568) warningFontSize = 17;
        else warningFontSize = 15;
    }
    else
    {
        timingsFontSize = 40;
        finalFontSize = 40;
        attentionFontSize = 170;
        warningFontSize = 30;
    }
    
    backButtonT[0] = [[CCTextureCache sharedTextureCache] addImage:@"backTop.png"];
	backButtonT[1] = [[CCTextureCache sharedTextureCache] addImage:@"backTopTapped.png"];
    
    retryButtonT[0] = [[CCTextureCache sharedTextureCache] addImage:@"retry.png"];
	retryButtonT[1] = [[CCTextureCache sharedTextureCache] addImage:@"retryTapped.png"];
    
    bg = [CCSprite spriteWithFile:@"bg.png"];
    bg.position = ccp(width(kNavController)/2, height(kNavController)/2);
    [self addChild:bg z:-1];
    
    stripe = [CCSprite spriteWithFile:@"stripe.png"];
    stripe.position = ccp(winSize.width/2, winSize.height/2);
    stripe.opacity = 0;
    stripe.rotation = 90;
    [self addChild:stripe z:0];
    
	backButton = [CCSprite spriteWithTexture:backButtonT[0]];
	backButton.position = ccp(winSize.width-backButton.contentSize.width/2, winSize.height-backButton.contentSize.height/2);
    backButton.opacity = 0;
    backButton.rotation = 90;
    [self addChild:backButton z:2];
    
	retryButton = [CCSprite spriteWithTexture:retryButtonT[0]];
	retryButton.position = ccp(winSize.width-retryButton.contentSize.width/2, retryButton.contentSize.height/2);
    retryButton.opacity = 0;
    retryButton.rotation = 90;
    [self addChild:retryButton z:2];
    
    circle = [CCSprite spriteWithFile:@"circle.png"];
	circle.position = ccp(winSize.width*0.75, winSize.height/2);
    circle.color = lightColor;
    circle.opacity = 0;
	[self addChild:circle z:1];
    
    attention = [CCLabelTTF labelWithString:@"!" fontName:kFontPlaytime fontSize:attentionFontSize];
	attention.color = ccc3(50,50,50);
	attention.position = circle.position;
    attention.anchorPoint = ccp(0.5, 0.55);
    attention.rotation = 90;
    attention.opacity = 0;
	[self addChild:attention z:2];
    
    warning = [CCLabelTTF labelWithString:@"TEMP"
                                 fontName:kFontComicSans
                                 fontSize:warningFontSize
                               dimensions:CGSizeMake(winSize.height*0.31, winSize.width/2)
                               hAlignment:kCCTextAlignmentCenter
                               vAlignment:kCCVerticalTextAlignmentCenter];
	warning.color = ccc3(50,50,50);
    warning.anchorPoint = ccp(0.5, 0.5);
    warning.rotation = 90;
    warning.opacity = 0;
	[self addChild:warning z:2];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) myTimings
{
	timing1 = [CCLabelTTF labelWithString:@"0.000" fontName:kFontComicSans fontSize:timingsFontSize];
	timing2 = [CCLabelTTF labelWithString:@"0.000" fontName:kFontComicSans fontSize:timingsFontSize];
	timing3 = [CCLabelTTF labelWithString:@"0.000" fontName:kFontComicSans fontSize:timingsFontSize];
	timing4 = [CCLabelTTF labelWithString:@"0.000" fontName:kFontComicSans fontSize:timingsFontSize];
	timing5 = [CCLabelTTF labelWithString:@"0.000" fontName:kFontComicSans fontSize:timingsFontSize];
    timing6 = [CCLabelTTF labelWithString:@"0.000" fontName:kFontComicSans fontSize:timingsFontSize];
	timing7 = [CCLabelTTF labelWithString:@"0.000" fontName:kFontComicSans fontSize:timingsFontSize];
	timing8 = [CCLabelTTF labelWithString:@"0.000" fontName:kFontComicSans fontSize:timingsFontSize];
	timing9 = [CCLabelTTF labelWithString:@"0.000" fontName:kFontComicSans fontSize:timingsFontSize];
	timing10 = [CCLabelTTF labelWithString:@"0.000" fontName:kFontComicSans fontSize:timingsFontSize];
	
	myTimings1 = [NSArray arrayWithObjects:timing1, timing2, timing3, timing4, timing5, nil];
    myTimings2 = [NSArray arrayWithObjects:timing6, timing7, timing8, timing9, timing10, nil];
	
	for (i=0; i<5; i++)
	{
        element1 = [myTimings1 objectAtIndex:i];
        element1.color = ccc3(120,120,120);
        element1.position = ccp(element1.contentSize.height*0.8*(5-i), winSize.height-element1.contentSize.height/2*0.8-element1.contentSize.width/2);
        element1.opacity = 0;
        element1.rotation = 90;
        [self addChild:element1 z:2];
        
        element2 = [myTimings2 objectAtIndex:i];
        element2.color = ccc3(120,120,120);
        element2.position = ccp(element2.contentSize.height*0.8*(5-i), element2.contentSize.height/2*0.8+element2.contentSize.width/2);
        element2.opacity = 0;
        element2.rotation = 90;
        [self addChild:element2 z:2];
	}
    
    timingsP1 = [CCLabelTTF labelWithString:LGLocalizedString(@"timings", nil) fontName:kFontComicSans fontSize:timingsFontSize];
	timingsP1.color = ccc3(120,120,120);
	timingsP1.position = ccp(timing1.position.x+timingsP1.contentSize.height*0.8, timing1.position.y+timing1.contentSize.width/2);
    timingsP1.opacity = 0;
    timingsP1.rotation = 90;
    timingsP1.anchorPoint = ccp(0, 0.5);
	[self addChild:timingsP1 z:2];
    
    timingsP2 = [CCLabelTTF labelWithString:LGLocalizedString(@"timings", nil) fontName:kFontComicSans fontSize:timingsFontSize];
	timingsP2.color = ccc3(120,120,120);
	timingsP2.position = ccp(timing6.position.x+timingsP2.contentSize.height*0.8, timing6.position.y-timing6.contentSize.width/2);
    timingsP2.opacity = 0;
    timingsP2.rotation = 90;
    timingsP2.anchorPoint = ccp(1, 0.5);
	[self addChild:timingsP2 z:2];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) changeLightTimer
{
	warningOnScreen = 0;
	
	[self checkColor];
	
	attention.opacity = 0;
	warning.opacity = 0;
	circle.color = lightColor;
    
    touchCount = 0;
    touchedP1 = 0;
    touchedP2 = 0;
	time1 = 0.000;
    time2 = 0.000;
    t = t + 1;
	
	number = (arc4random() % 81) + 20;
	number = number / 10;
	
	if (t < 5)
	{
		[self scheduleOnce:@selector(changeLightSprite) delay:number];
	}
	else
	{
        gameEnd = 1;
        
		score1 = result1 / 5;
        score2 = result2 / 5;
		
        finalScore1 = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@\n%.3f", LGLocalizedString(@"finalScore", nil), score1] fontName:kFontComicSans fontSize:finalFontSize];
        finalScore1.color = ccc3(50,50,50);
        if (kDevicePhone) finalScore1.position = ccp(timing2.position.x, (winSize.height/2+(timing1.position.y-timing1.contentSize.width/2))/2);
        else finalScore1.position = ccp((circle.position.x+timingsP1.position.x)/2, winSize.height*0.8);
        finalScore1.rotation = 90;
        [self addChild:finalScore1 z:2];
        
        finalScore2 = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@\n%.3f", LGLocalizedString(@"finalScore", nil), score2] fontName:kFontComicSans fontSize:finalFontSize];
        finalScore2.color = ccc3(50,50,50);
        if (kDevicePhone) finalScore2.position = ccp(timing7.position.x, (winSize.height/2+(timing6.position.y+timing6.contentSize.width/2))/2);
        else finalScore2.position = ccp((circle.position.x+timingsP2.position.x)/2, winSize.height*0.2);
        finalScore2.rotation = 90;
        [self addChild:finalScore2 z:2];
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) changeLightSprite
{
    [self unschedule:@selector(changeLightTimer)];
	
    circle.color = kColorRed;
    
    start = [NSDate date];
    [kStandartUserDefaults setValue:start forKey:@"timer"];
    
    [self schedule:@selector(stopWatch1:)];
    [self schedule:@selector(stopWatch2:)];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) stopWatch1:(ccTime)dt
{
	start = [kStandartUserDefaults objectForKey:@"timer"];
    end = [NSDate date];
    
    time1 = [end timeIntervalSinceDate:start];
    
	myTimings1 = [NSArray arrayWithObjects:timing1, timing2, timing3, timing4, timing5, nil];
	
	element1 = [myTimings1 objectAtIndex:t];
	[element1 setString:[NSString stringWithFormat:@"%.3f", time1]];
	
	if (time1 >= 3.000)
	{
		[self unschedule:@selector(stopWatch1:)];
		[self longReaction1];
	}
}

- (void) stopWatch2:(ccTime)dt
{
	start = [kStandartUserDefaults objectForKey:@"timer"];
    end = [NSDate date];
    
    time2 = [end timeIntervalSinceDate:start];
    
	myTimings2 = [NSArray arrayWithObjects:timing6, timing7, timing8, timing9, timing10, nil];
	
	element2 = [myTimings2 objectAtIndex:t];
	[element2 setString:[NSString stringWithFormat:@"%.3f", time2]];
	
	if (time2 >= 3.000)
	{
		[self unschedule:@selector(stopWatch2:)];
		[self longReaction2];
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) longReaction1
{
    warningOnScreen = 1;
    
    longReactionDone = 0;
    
	myTimings1 = [NSArray arrayWithObjects:timing1, timing2, timing3, timing4, timing5, nil];
	
	element1 = [myTimings1 objectAtIndex:t];
	element1.color = ccc3(230,50,50);
	[element1 setString:[NSString stringWithFormat:@"3.000"]];
    
    result1 = result1 + 3.000;
    
	if (!longReactionDone)
    {
        longReactionDone = 1;
        [self unschedule:@selector(changeLightSprite)];
        [self scheduleOnce:@selector(changeLightTimer) delay:0];
    }
}

- (void) longReaction2
{
    warningOnScreen = 1;
    
    longReactionDone = 0;
    
    myTimings2 = [NSArray arrayWithObjects:timing6, timing7, timing8, timing9, timing10, nil];
	
    element2 = [myTimings2 objectAtIndex:t];
	element2.color = ccc3(230,50,50);
	[element2 setString:[NSString stringWithFormat:@"3.000"]];
    
    result2 = result2 + 3.000;
    
	if (!longReactionDone)
    {
        longReactionDone = 1;
        [self unschedule:@selector(changeLightSprite)];
        [self scheduleOnce:@selector(changeLightTimer) delay:0];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) badTouch2
{
	warningOnScreen = 1;
    
    [self unschedule:@selector(changeLightSprite)];
    
    t--;
	
	attention.opacity = 255;
    
    [warning setString:LGLocalizedString(@"earlyWarning2Players", nil)];
    if (kDevicePhone) warning.position = ccp(timing8.position.x, (winSize.height/2+(timing6.position.y+timing6.contentSize.width/2))/2);
    else warning.position = ccp((circle.position.x+timingsP2.position.x)/2, winSize.height*0.2);
    warning.opacity = 255;
    
	[self scheduleOnce:@selector(changeLightTimer) delay:2];
}

- (void) badTouch1
{
	warningOnScreen = 1;
    
    [self unschedule:@selector(changeLightSprite)];
    
    t--;
	
	attention.opacity = 255;
	
    [warning setString:LGLocalizedString(@"earlyWarning2Players", nil)];
    if (kDevicePhone) warning.position = ccp(timing3.position.x, (winSize.height/2+(timing1.position.y-timing1.contentSize.width/2))/2);
    else warning.position = ccp((circle.position.x+timingsP1.position.x)/2, winSize.height*0.8);
	warning.opacity = 255;
    
	[self scheduleOnce:@selector(changeLightTimer) delay:2];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) goodTouch1
{
    [self unschedule:@selector(stopWatch1:)];
    
    touchedP1 = 1;
    
	start = [kStandartUserDefaults objectForKey:@"timer"];
    end = [NSDate date];
    
    time1 = [end timeIntervalSinceDate:start];
	
	myTimings1 = [NSArray arrayWithObjects:timing1, timing2, timing3, timing4, timing5, nil];
	
	element1 = [myTimings1 objectAtIndex:t];
	[element1 setString:[NSString stringWithFormat:@"%.3f", time1]];
    
    result1 = result1 + time1;
    
    if (touchedP1 == 1 && touchedP2 == 1)
    {
        touchedP1 = 0;
        touchedP2 = 0;
        [self scheduleOnce:@selector(changeLightTimer) delay:0];
    }
}

- (void) goodTouch2
{
    [self unschedule:@selector(stopWatch2:)];
    
    touchedP2 = 1;
    
	start = [kStandartUserDefaults objectForKey:@"timer"];
    end = [NSDate date];
    
    time2 = [end timeIntervalSinceDate:start];
	
	myTimings2 = [NSArray arrayWithObjects:timing6, timing7, timing8, timing9, timing10, nil];
	
	element2 = [myTimings2 objectAtIndex:t];
	[element2 setString:[NSString stringWithFormat:@"%.3f", time2]];
    
    result2 = result2 + time2;
    
    if (touchedP1 == 1 && touchedP2 == 1)
    {
        touchedP1 = 0;
        touchedP2 = 0;
        [self scheduleOnce:@selector(changeLightTimer) delay:0];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) allSpritesAppear
{
    circle.opacity = 0;
    
	[kLGKit spriteFade:timingsP1 duration:.2 opacity:255];
	[kLGKit spriteFade:timingsP2 duration:.2 opacity:255];
	[kLGKit spriteFade:backButton duration:.2 opacity:255];
	[kLGKit spriteFade:retryButton duration:.2 opacity:255];
    
    myTimings1 = [NSArray arrayWithObjects:timing1, timing2, timing3, timing4, timing5, nil];
    myTimings2 = [NSArray arrayWithObjects:timing6, timing7, timing8, timing9, timing10, nil];
    for (i=0; i<5; i++)
	{
        element1 = [myTimings1 objectAtIndex:i];
        element2 = [myTimings2 objectAtIndex:i];
        
        [kLGKit spriteFade:element1 duration:.2 opacity:255];
        [kLGKit spriteFade:element2 duration:.2 opacity:255];
    }
	
	[kLGKit spriteFade:circle duration:.2 opacity:200];
    [kLGKit spriteFade:stripe duration:.2 opacity:125];
}

- (void) retryAppear
{
    circle.opacity = 0;
    stripe.opacity = 125;
	backButton.opacity = 255;
	retryButton.opacity = 255;
    
    [kLGKit spriteFade:timingsP1 duration:.2 opacity:255];
	[kLGKit spriteFade:timingsP2 duration:.2 opacity:255];
    
    myTimings1 = [NSArray arrayWithObjects:timing1, timing2, timing3, timing4, timing5, nil];
    myTimings2 = [NSArray arrayWithObjects:timing6, timing7, timing8, timing9, timing10, nil];
    for (i=0; i<5; i++)
	{
        element1 = [myTimings1 objectAtIndex:i];
        element2 = [myTimings2 objectAtIndex:i];
        
        [kLGKit spriteFade:element1 duration:.2 opacity:255];
        [kLGKit spriteFade:element2 duration:.2 opacity:255];
    }
	
	[kLGKit spriteFade:circle duration:.2 opacity:200];
}

- (void) allSpritesDisappear
{
	[kLGKit spriteFade:timingsP1 duration:.2 opacity:0];
	[kLGKit spriteFade:timingsP2 duration:.2 opacity:0];
	[kLGKit spriteFade:backButton duration:.2 opacity:0];
	[kLGKit spriteFade:retryButton duration:.2 opacity:0];
    
    myTimings1 = [NSArray arrayWithObjects:timing1, timing2, timing3, timing4, timing5, nil];
    myTimings2 = [NSArray arrayWithObjects:timing6, timing7, timing8, timing9, timing10, nil];
    for (i=0; i<5; i++)
	{
        element1 = [myTimings1 objectAtIndex:i];
        element2 = [myTimings2 objectAtIndex:i];
        
        [kLGKit spriteFade:element1 duration:.2 opacity:0];
        [kLGKit spriteFade:element2 duration:.2 opacity:0];
    }
	
	[kLGKit spriteFade:circle duration:.2 opacity:0];
    [kLGKit spriteFade:stripe duration:.2 opacity:0];
    
    if (gameEnd)
    {
        [kLGKit spriteFade:finalScore1 duration:.2 opacity:0];
        [kLGKit spriteFade:finalScore2 duration:.2 opacity:0];
    }
    if (warningOnScreen)
    {
        [kLGKit spriteFade:warning duration:.2 opacity:0];
        [kLGKit spriteFade:attention duration:.2 opacity:0];
    }
}

- (void) retryDisappear
{
    [kLGKit spriteFade:timingsP1 duration:.2 opacity:0];
	[kLGKit spriteFade:timingsP2 duration:.2 opacity:0];
    
    myTimings1 = [NSArray arrayWithObjects:timing1, timing2, timing3, timing4, timing5, nil];
    myTimings2 = [NSArray arrayWithObjects:timing6, timing7, timing8, timing9, timing10, nil];
    for (i=0; i<5; i++)
	{
        element1 = [myTimings1 objectAtIndex:i];
        element2 = [myTimings2 objectAtIndex:i];
        
        [kLGKit spriteFade:element1 duration:.2 opacity:0];
        [kLGKit spriteFade:element2 duration:.2 opacity:0];
    }
	
	[kLGKit spriteFade:circle duration:.2 opacity:0];
    
    if (gameEnd)
    {
        [kLGKit spriteFade:finalScore1 duration:.2 opacity:0];
        [kLGKit spriteFade:finalScore2 duration:.2 opacity:0];
    }
    if (warningOnScreen)
    {
        [kLGKit spriteFade:warning duration:.2 opacity:0];
        [kLGKit spriteFade:attention duration:.2 opacity:0];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) goToMainMenu
{
	[[CCDirector sharedDirector] replaceScene:[MenuLayer scene]];
}

- (void) goToRetry
{
	[[CCDirector sharedDirector] replaceScene:[GameLayer2P scene]];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) soundButton
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"soundButton.wav" pitch:1 pan:0 gain:0.8];
}

- (void) soundChoose
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"soundButton.wav" pitch:1.3 pan:0 gain:0.8];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *myTouches = [event allTouches];
    
    if (myTouches.count == 1)
    {
        touch = [touches anyObject];
        touchPoint = [touch locationInView:[touch view]];
        touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
        
        touchCount = 1;
    }
    else if (myTouches.count == 2)
    {
        touch1 = [[myTouches allObjects] objectAtIndex:0];
        touchPoint1 = [touch1 locationInView:[touch1 view]];
        touchPoint1 = [[CCDirector sharedDirector] convertToGL:touchPoint1];
        
        touch2 = [[myTouches allObjects] objectAtIndex:1];
        touchPoint2 = [touch2 locationInView:[touch2 view]];
        touchPoint2 = [[CCDirector sharedDirector] convertToGL:touchPoint2];
        
        if (((touchPoint.y > winSize.height/2 && touchPoint1.y > winSize.height/2) ||
             (touchPoint.y < winSize.height/2 && touchPoint1.y < winSize.height/2)) && touchCount == 1) { }
        if (((touchPoint.y > winSize.height/2 && touchPoint1.y < winSize.height/2) ||
             (touchPoint.y < winSize.height/2 && touchPoint1.y > winSize.height/2)) && touchCount == 1)
        {
            touchPoint2 = touchPoint1;
            touchPoint1 = touchPoint;
        }
    }
    
    if (CGRectContainsPoint(backButton.boundingBox, touchPoint)) ////////// backButton //////////
    {
        [backButton setTexture:backButtonT[1]];
        
        z = 1;
    }
    else if (CGRectContainsPoint(retryButton.boundingBox, touchPoint)) ////////// retryButton //////////
    {
        [retryButton setTexture:retryButtonT[1]];
        
        z = 2;
    }
	else if ((time1 == 0.000 || time2 == 0.000) && gameEnd == 0 && !warningOnScreen)
    {
        if (touchPoint.y < winSize.height/2 && !CGRectContainsPoint(backButton.boundingBox, touchPoint))
        {
            [self badTouch2];
            [self soundChoose];
        }
        else if (touchPoint.y > winSize.height/2 && !CGRectContainsPoint(retryButton.boundingBox, touchPoint))
        {
            [self badTouch1];
            [self soundChoose];
        }
    }
	else if (!warningOnScreen)
    {
        if (myTouches.count == 1 && gameEnd == 0 && !CGRectContainsPoint(backButton.boundingBox, touchPoint) && !CGRectContainsPoint(retryButton.boundingBox, touchPoint))
        {
            if (touchPoint.y < winSize.height/2 && touchedP2 == 0)
            {
                [self goodTouch2];
                [self soundChoose];
            }
            else if (touchPoint.y > winSize.height/2 && touchedP1 == 0)
            {
                [self goodTouch1];
                [self soundChoose];
            }
        }
        else if (myTouches.count == 2 && gameEnd == 0 && !CGRectContainsPoint(backButton.boundingBox, touchPoint1) && !CGRectContainsPoint(retryButton.boundingBox, touchPoint1) &&
                 !CGRectContainsPoint(backButton.boundingBox, touchPoint2) && !CGRectContainsPoint(retryButton.boundingBox, touchPoint2))
        {
            if (((touchPoint1.y < winSize.height/2 && touchPoint2.y > winSize.height/2) ||
                 (touchPoint1.y > winSize.height/2 && touchPoint2.y < winSize.height/2)) && touchCount == 0)
            {
                [self goodTouch1];
                [self goodTouch2];
                [self soundChoose];
            }
            else if (touchPoint1.y > winSize.height/2 && touchPoint2.y < winSize.height/2 && touchCount == 1)
            {
                [self goodTouch2];
                [self soundChoose];
            }
            else if (touchPoint1.y < winSize.height/2 && touchPoint2.y > winSize.height/2 && touchCount == 1)
            {
                [self goodTouch1];
                [self soundChoose];
            }
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    touch = [touches anyObject];
    touchPoint = [touch locationInView:[touch view]];
    touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
    
    if (CGRectContainsPoint(backButton.boundingBox, touchPoint) && z == 1) ////////// backButton //////////
    {
        self.isTouchEnabled = NO;
        
        [self allSpritesDisappear];
        [self performSelector:@selector(goToMainMenu) withObject:nil afterDelay:.2];
        
        [self soundButton];
    }
    else
    {
        [backButton setTexture:backButtonT[0]];
    }
    if (CGRectContainsPoint(retryButton.boundingBox, touchPoint) && z == 2) ////////// retryButton //////////
    {
        self.isTouchEnabled = NO;
        
        [self retryDisappear];
        [self performSelector:@selector(goToRetry) withObject:nil afterDelay:.2];
        
        [kStandartUserDefaults setInteger:1 forKey:@"retry"];
        
        [self soundButton];
    }
    else
    {
        [retryButton setTexture:retryButtonT[0]];
    }
}

@end
