//
//  Created by Grigory Lutkov on 04.03.11.
//  Copyright 2011 Apogee Studio. All rights reserved.
//

#import "GameLayer1P.h"
#import "SimpleAudioEngine.h"
#import "MenuLayer.h"
#import "HighscoresLayer.h"
#import "LGKit.h"
#import "AppController.h"
#import "LGLocalization.h"
#import "LGGameCenter.h"

@implementation GameLayer1P

+ (id) scene
{
	CCScene *scene = [CCScene node];
	GameLayer1P *layer = [GameLayer1P node];
	[scene addChild:layer];
	return scene;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (id) init
{
	if ((self = [super init]))
	{
        self.isTouchEnabled = YES;
        
        difficulty = [kStandartUserDefaults integerForKey:@"difficulty"];
        changer = [kStandartUserDefaults integerForKey:@"retry"];
		winSize = [[CCDirector sharedDirector] winSize];
		
		t = -1;
		result = 0;
		score = 0;
        badTouchCount = 3;
        
        start = nil;
        end = nil;
        
		[self checkAdsRemoved];
        [self checkColor];
        [self gameMenu];
		[self myTimings];
        if (changer == 0) [self allSpritesAppear];
        else if (changer == 1) [self retryAppear];
        [self scheduleOnce:@selector(changeLightTimer) delay:0];
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
	if ([kStandartUserDefaults integerForKey:@"colorOfLight"] == 1)
	{
		lightColor = kColorBlue;
		checkColor = 1;
        checkColorRoot = 1;
	}
	else if ([kStandartUserDefaults integerForKey:@"colorOfLight"] == 2)
	{
		lightColor = kColorGreen;
		checkColor = 2;
        checkColorRoot = 2;
	}
	else if ([kStandartUserDefaults integerForKey:@"colorOfLight"] == 3)
	{
		lightColor = kColorYellow;
		checkColor = 3;
        checkColorRoot = 3;
	}
	else if ([kStandartUserDefaults integerForKey:@"colorOfLight"] == 4)
	{
		lightColor = kColorViolet;
		checkColor = 4;
        checkColorRoot = 4;
	}
	else if ([kStandartUserDefaults integerForKey:@"colorOfLight"] == 5)
	{
		lightColor = kColorOrange;
		checkColor = 5;
        checkColorRoot = 5;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) checkColorText
{
    numberColorText = (arc4random() % 6) + 1;
    if (checkColorTextPrevious) while (numberColorText == checkColorRoot || numberColorText == checkColorTextPrevious) numberColorText = (arc4random() % 6) + 1;
    else while (numberColorText == checkColorRoot) numberColorText = (arc4random() % 6) + 1;
    checkColorTextPrevious = numberColorText;
    
    switch (numberColorText)
    {
        case 1:
            lightColorText = [NSString stringWithFormat:@"%@", LGLocalizedString(@"BLUE", nil)];
            checkColorText = 1;
            break;
        case 2:
            lightColorText = [NSString stringWithFormat:@"%@", LGLocalizedString(@"GREEN", nil)];
            checkColorText = 2;
            break;
        case 3:
            lightColorText = [NSString stringWithFormat:@"%@", LGLocalizedString(@"YELLOW", nil)];
            checkColorText = 3;
            break;
        case 4:
            lightColorText = [NSString stringWithFormat:@"%@", LGLocalizedString(@"VIOLET", nil)];
            checkColorText = 4;
            break;
        case 5:
            lightColorText = [NSString stringWithFormat:@"%@", LGLocalizedString(@"ORANGE", nil)];
            checkColorText = 5;
            break;
        case 6:
            lightColorText = [NSString stringWithFormat:@"%@", LGLocalizedString(@"RED", nil)];
            checkColorText = 6;
            break;
            
        default:
            break;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) gameMenu
{
    [kStandartUserDefaults setInteger:0 forKey:@"retry"];
    
    if (kDevicePhone)
    {
        timingsFontSize = 22;
        attentionFontSize = 85;
        if (difficulty < 3)
        {
            if (kIsGameFull || height(kNavController) == 568) warningFontSize = 18;
            else warningFontSize = 16;
        }
        else warningFontSize = 16;
        textBorderSize = 20;
        colorTextFontSize = 26;
    }
    else
    {
        timingsFontSize = 40;
        attentionFontSize = 170;
        warningFontSize = 30;
        textBorderSize = 80;
        colorTextFontSize = 50;
    }
    
    backButtonT[0] = [[CCTextureCache sharedTextureCache] addImage:@"backTop.png"];
	backButtonT[1] = [[CCTextureCache sharedTextureCache] addImage:@"backTopTapped.png"];
    
    retryButtonT[0] = [[CCTextureCache sharedTextureCache] addImage:@"retry.png"];
	retryButtonT[1] = [[CCTextureCache sharedTextureCache] addImage:@"retryTapped.png"];
    
    bg = [CCSprite spriteWithFile:@"bg.png"];
    bg.position = ccp(width(kNavController)/2, height(kNavController)/2);
    [self addChild:bg z:0];
    
	backButton = [CCSprite spriteWithTexture:backButtonT[0]];
	backButton.position = ccp(backButton.contentSize.width/2, winSize.height-backButton.contentSize.height/2);
    backButton.opacity = 0;
    [self addChild:backButton z:3];
    
	retryButton = [CCSprite spriteWithTexture:retryButtonT[0]];
	retryButton.position = ccp(winSize.width-retryButton.contentSize.width/2, winSize.height-retryButton.contentSize.height/2);
    retryButton.opacity = 0;
    [self addChild:retryButton z:3];
    
    circle = [CCSprite spriteWithFile:@"circle.png"];
	if (difficulty < 3) circle.position = ccp(winSize.width/2, winSize.height*0.8);
    else if (difficulty > 2) circle.position = ccp(winSize.width/2, winSize.height*0.75);
    circle.color = lightColor;
    circle.opacity = 0;
	[self addChild:circle z:2];
    
    if (difficulty > 2)
    {
        colorText = [CCLabelTTF labelWithString:@"TEMP" fontName:kFontComicSans fontSize:colorTextFontSize];
        colorText.color = ccc3(50,50,50);
        colorText.position = ccp(winSize.width/2-2, (circle.position.y+circle.contentSize.height/5+winSize.height)/2);
        colorText.opacity = 0;
        [self addChild:colorText z:1];
    }
    
    if (difficulty == 1) bestScoreValue = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%.3f", [kStandartUserDefaults floatForKey:@"bestScoreEasy"]] fontName:kFontComicSans fontSize:timingsFontSize];
    else if (difficulty == 2) bestScoreValue = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%.3f", [kStandartUserDefaults floatForKey:@"bestScoreNormal"]] fontName:kFontComicSans fontSize:timingsFontSize];
    else if (difficulty == 3) bestScoreValue = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%.3f", [kStandartUserDefaults floatForKey:@"bestScoreHard"]] fontName:kFontComicSans fontSize:timingsFontSize];
    else if (difficulty == 4) bestScoreValue = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%.3f", [kStandartUserDefaults floatForKey:@"bestScoreInsane"]] fontName:kFontComicSans fontSize:timingsFontSize];
	bestScoreValue.color = ccc3(120,120,120);
	bestScoreValue.position = ccp(bestScoreValue.contentSize.height/2*0.8, bestScoreValue.contentSize.height*0.8);
    bestScoreValue.opacity = 0;
    bestScoreValue.anchorPoint = ccp(0, 0.5);
	[self addChild:bestScoreValue z:3];
    
    bestScore = [CCLabelTTF labelWithString:LGLocalizedString(@"bestScore", nil) fontName:kFontComicSans fontSize:timingsFontSize];
	bestScore.color = ccc3(120,120,120);
	bestScore.position = ccp(bestScoreValue.position.x, bestScoreValue.position.y+bestScore.contentSize.height*0.8);
    bestScore.opacity = 0;
    bestScore.anchorPoint = ccp(0, 0.5);
	[self addChild:bestScore z:3];
    
    attention = [CCLabelTTF labelWithString:@"!" fontName:kFontPlaytime fontSize:attentionFontSize];
	attention.color = ccc3(50,50,50);
	attention.position = circle.position;
    attention.anchorPoint = ccp(0.5, 0.55);
    attention.opacity = 0;
	[self addChild:attention z:3];
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
	
	myTimings = [NSArray arrayWithObjects:timing1, timing2, timing3, timing4, timing5, timing6, timing7, timing8, timing9, timing10, nil];
	
	for (i=0; i<10; i++)
	{
		if (i < 5)
		{
			element = [myTimings objectAtIndex:i];
			element.color = ccc3(120,120,120);
			element.position = ccp(winSize.width-element.contentSize.width*2.5-element.contentSize.height/2*0.8, element.contentSize.height*0.8*(5-i));
            element.opacity = 0;
            element.anchorPoint = ccp(0, 0.5);
			[self addChild:element z:3];
		}
		else
		{
			element = [myTimings objectAtIndex:i];
			element.color = ccc3(120,120,120);
			element.position = ccp(winSize.width-element.contentSize.height/2*0.8, element.contentSize.height*0.8*(10-i));
            element.opacity = 0;
            element.anchorPoint = ccp(1, 0.5);
			[self addChild:element z:3];
		}
	}
    
    timings = [CCLabelTTF labelWithString:LGLocalizedString(@"timings", nil) fontName:kFontComicSans fontSize:timingsFontSize];
	timings.color = ccc3(120,120,120);
	timings.position = ccp(timing1.position.x, timing1.position.y+timings.contentSize.height*0.8);
    timings.opacity = 0;
    timings.anchorPoint = ccp(0, 0.5);
	[self addChild:timings z:3];
    
    warningLate = [CCLabelTTF labelWithString:LGLocalizedString(@"lateWarning", nil)
                                     fontName:kFontComicSans
                                     fontSize:timingsFontSize
                                   dimensions:CGSizeMake(winSize.width-textBorderSize, winSize.height/6)
                                   hAlignment:kCCTextAlignmentCenter
                                   vAlignment:kCCVerticalTextAlignmentCenter];
	warningLate.color = ccc3(50,50,50);
	warningLate.position = ccp(winSize.width/2, (circle.position.y-circle.contentSize.height/5+timings.position.y)/2);
    warningLate.opacity = 0;
	[self addChild:warningLate z:3];
    
    warningMistake = [CCLabelTTF labelWithString:@"TEMP"
                                        fontName:kFontComicSans
                                        fontSize:warningFontSize
                                      dimensions:CGSizeMake(winSize.width-textBorderSize, winSize.height/6)
                                      hAlignment:kCCTextAlignmentCenter
                                      vAlignment:kCCVerticalTextAlignmentCenter];
    warningMistake.color = ccc3(50,50,50);
    warningMistake.position = ccp(winSize.width/2, (circle.position.y-circle.contentSize.height/5+timings.position.y)/2);
    warningMistake.opacity = 0;
    [self addChild:warningMistake z:3];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) changeLightTimer
{
	warningOnScreen = 0;
	attention.opacity = 0;
	warningLate.opacity = 0;
    warningMistake.opacity = 0;
	circle.color = lightColor;
    
	if (difficulty == 1) number = (arc4random() % 81) + 20;
    else
    {
        number = (arc4random() % 46) + 20;
        if (difficulty > 2)
        {
            [self checkColorText];
            [colorText setString:[NSString stringWithFormat:@"%@", lightColorText]];
        }
        checkColorNew = 0;
        count = 0;
    }
	
    number = number / 10;
	t++;
	time = 0.000;
	
	if (t < 10) [self scheduleOnce:@selector(changeLightSprite) delay:number];
	else
	{
        self.isTouchEnabled = NO;
        
		score = result / 10;
        
        if (difficulty == 1) [kStandartUserDefaults setFloat:score forKey:@"currentScoreEasy"];
        else if (difficulty == 2) [kStandartUserDefaults setFloat:score forKey:@"currentScoreNormal"];
        else if (difficulty == 3) [kStandartUserDefaults setFloat:score forKey:@"currentScoreHard"];
        else if (difficulty == 4) [kStandartUserDefaults setFloat:score forKey:@"currentScoreInsane"];
		
        [self performSelector:@selector(endOfGame) withObject:nil afterDelay:1];
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) changeLightSprite
{
    [self unschedule:@selector(changeLightTimer)];
    actionRun = 0;
    
    if (difficulty == 1)
    {
        circle.color = kColorRed;
        
        start = [NSDate date];
        [kStandartUserDefaults setValue:start forKey:@"timer"];
        
        [self schedule:@selector(stopWatch:)];
    }
    else
    {
        count = count + 1;
        if (checkColorNew != 0) checkColor = checkColorNew;
        
        if (count < 3) ////////// count < 3
        {
            numberAdd = (arc4random() % 3);
            
            if (numberAdd != 0)
            {
                if (difficulty == 2) [self changeToNormalNot:checkColor];
                else if (difficulty == 3) [self changeToHardNot:checkColor];
                else if (difficulty == 4) [self changeToInsaneNot:checkColor];
            }
            else if (numberAdd == 0)
            {
                if (difficulty == 2) [self changeToRed];
                else if (difficulty == 3) [self changeToSelect];
                else if (difficulty == 4) [self changeToSelectNot:checkColor];
            }
        }
        else if (count == 3) ////////// count = 3
        {
            numberAdd = (arc4random() % 2);
            
            if (numberAdd == 0)
            {
                if (difficulty == 2) [self changeToNormalNot:checkColor];
                else if (difficulty == 3) [self changeToHardNot:checkColor];
                else if (difficulty == 4) [self changeToInsaneNot:checkColor];
            }
            else if (numberAdd == 1)
            {
                if (difficulty == 2) [self changeToRed];
                else if (difficulty == 3) [self changeToSelect];
                else if (difficulty == 4) [self changeToSelectNot:checkColor];
            }
        }
        else if (count > 3) ////////// count > 3
        {
            numberAdd = (arc4random() % 3);
            
            if (numberAdd == 0)
            {
                if (difficulty == 2) [self changeToNormalNot:checkColor];
                else if (difficulty == 3) [self changeToHardNot:checkColor];
                else if (difficulty == 4) [self changeToInsaneNot:checkColor];
            }
            else if (numberAdd != 0)
            {
                if (difficulty == 2) [self changeToRed];
                else if (difficulty == 3) [self changeToSelect];
                else if (difficulty == 4) [self changeToSelectNot:checkColor];
            }
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) changeToRed // for normal
{
	circle.color = kColorRed;
    
    start = [NSDate date];
    [kStandartUserDefaults setValue:start forKey:@"timer"];
	
	[self schedule:@selector(stopWatch:)];
}

- (void) changeToSelect // for hard
{
	if (checkColorText == 1) circle.color = kColorBlue;
	else if (checkColorText == 2) circle.color = kColorGreen;
	else if (checkColorText == 3) circle.color = kColorYellow;
	else if (checkColorText == 4) circle.color = kColorViolet;
    else if (checkColorText == 5) circle.color = kColorOrange;
	else if (checkColorText == 6) circle.color = kColorRed;
	
    start = [NSDate date];
    [kStandartUserDefaults setValue:start forKey:@"timer"];
    
	[self schedule:@selector(stopWatch:)];
}

- (void) changeToSelectNot:(int)color // for insane
{
	checkColorTextPrevious = checkColorText;
	checkColorText = (arc4random() % 6) + 1;
	while (checkColorText == color || checkColorText == checkColorTextPrevious || checkColorText == checkColorRoot) checkColorText = (arc4random() % 6) + 1;
    checkColorTextPrevious = checkColorText;
    
    if (checkColorText == 1) ////////// if text blue
    {
        [colorText setString:[NSString stringWithFormat:@"%@", LGLocalizedString(@"BLUE", nil)]];
        circle.color = kColorBlue;
    }
	else if (checkColorText == 2) ////////// if text green
    {
        [colorText setString:[NSString stringWithFormat:@"%@", LGLocalizedString(@"GREEN", nil)]];
        circle.color = kColorGreen;
    }
	else if (checkColorText == 3) ////////// if text yellow
    {
        [colorText setString:[NSString stringWithFormat:@"%@", LGLocalizedString(@"YELLOW", nil)]];
        circle.color = kColorYellow;
    }
	else if (checkColorText == 4) ////////// if text violet
    {
        [colorText setString:[NSString stringWithFormat:@"%@", LGLocalizedString(@"VIOLET", nil)]];
        circle.color = kColorViolet;
    }
    else if (checkColorText == 5) ////////// if text orange
    {
        [colorText setString:[NSString stringWithFormat:@"%@", LGLocalizedString(@"ORANGE", nil)]];
        circle.color = kColorOrange;
    }
	else if (checkColorText == 6) ////////// if text red
    {
        [colorText setString:[NSString stringWithFormat:@"%@", LGLocalizedString(@"RED", nil)]];
        circle.color = kColorRed;
    }
	
    start = [NSDate date];
    [kStandartUserDefaults setValue:start forKey:@"timer"];
    
	[self schedule:@selector(stopWatch:)];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) changeToNormalNot:(int)color // for normal
{
	numberColor = (arc4random() % 5) + 1;
    while (numberColor == color) numberColor = (arc4random() % 5) + 1;
	
	if (numberColor == 1)
	{
		circle.color = kColorBlue;
		checkColorNew = 1;
	}
	else if (numberColor == 2)
	{
		circle.color = kColorGreen;
		checkColorNew = 2;
	}
	else if (numberColor == 3)
	{
		circle.color = kColorYellow;
		checkColorNew = 3;
	}
	else if (numberColor == 4)
	{
		circle.color = kColorViolet;
		checkColorNew = 4;
	}
    else if (numberColor == 5)
	{
		circle.color = kColorOrange;
		checkColorNew = 5;
	}
	
	number = (arc4random() % 46) + 20;
	number = number / 10;
    
    [self actionWithDelay:number];
}

- (void) changeToHardNot:(int)color
{
	numberColor = (arc4random() % 6) + 1;
    while (numberColor == color || numberColor == checkColorText) numberColor = (arc4random() % 6) + 1;
	
    if (numberColor == 1)
	{
		circle.color = kColorBlue;
		checkColorNew = 1;
	}
	else if (numberColor == 2)
	{
		circle.color = kColorGreen;
		checkColorNew = 2;
	}
	else if (numberColor == 3)
	{
		circle.color = kColorYellow;
		checkColorNew = 3;
	}
	else if (numberColor == 4)
	{
		circle.color = kColorViolet;
		checkColorNew = 4;
	}
    else if (numberColor == 5)
	{
		circle.color = kColorOrange;
		checkColorNew = 5;
	}
    else if (numberColor == 6)
	{
		circle.color = kColorRed;
		checkColorNew = 6;
	}
	
	number = (arc4random() % 46) + 20;
	number = number / 10;
	
	[self actionWithDelay:number];
}

- (void) changeToInsaneNot:(int)color
{
	numberColor = (arc4random() % 6) + 1;
    while (numberColor == color) numberColor = (arc4random() % 6) + 1;
    
	checkColorTextPrevious = checkColorText;
	checkColorText = (arc4random() % 6) + 1;
	while (checkColorText == numberColor || checkColorText == checkColorTextPrevious) checkColorText = (arc4random() % 6) + 1;
    checkColorTextPrevious = checkColorText;
	
    if (numberColor == 1)
	{
		circle.color = kColorBlue;
		checkColorNew = 1;
	}
	else if (numberColor == 2)
	{
		circle.color = kColorGreen;
		checkColorNew = 2;
	}
	else if (numberColor == 3)
	{
		circle.color = kColorYellow;
		checkColorNew = 3;
	}
	else if (numberColor == 4)
	{
		circle.color = kColorViolet;
		checkColorNew = 4;
	}
    else if (numberColor == 5)
	{
		circle.color = kColorOrange;
		checkColorNew = 5;
	}
    else if (numberColor == 6)
	{
		circle.color = kColorRed;
		checkColorNew = 6;
	}
    
    if (checkColorText == 1) [colorText setString:[NSString stringWithFormat:@"%@", LGLocalizedString(@"BLUE", nil)]];
	else if (checkColorText == 2) [colorText setString:[NSString stringWithFormat:@"%@", LGLocalizedString(@"GREEN", nil)]];
	else if (checkColorText == 3) [colorText setString:[NSString stringWithFormat:@"%@", LGLocalizedString(@"YELLOW", nil)]];
	else if (checkColorText == 4) [colorText setString:[NSString stringWithFormat:@"%@", LGLocalizedString(@"VIOLET", nil)]];
    else if (checkColorText == 5) [colorText setString:[NSString stringWithFormat:@"%@", LGLocalizedString(@"ORANGE", nil)]];
	else if (checkColorText == 6) [colorText setString:[NSString stringWithFormat:@"%@", LGLocalizedString(@"RED", nil)]];
	
	number = (arc4random() % 46) + 20;
	number = number / 10;
	
	[self actionWithDelay:number];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) actionWithDelay:(float)delay
{
    id a1 = [CCDelayTime actionWithDuration:delay];
    id a2 = [CCCallFunc actionWithTarget:self selector:@selector(changeLightSprite)];
    action = [CCSequence actions:a1, a2, nil];
    [self runAction:action];
    
    actionRun = 1;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) stopWatch:(ccTime)delta
{
	start = [kStandartUserDefaults objectForKey:@"timer"];
    end = [NSDate date];
    
    time = [end timeIntervalSinceDate:start];
	
	myTimings = [NSArray arrayWithObjects:timing1, timing2, timing3, timing4, timing5, timing6, timing7, timing8, timing9, timing10, nil];
	
    if (difficulty == 1)
    {
        element = [myTimings objectAtIndex:t];
        [element setString:[NSString stringWithFormat:@"%.3f", time]];
    }
	
	if (time >= 3.000)
	{
		[self unschedule:@selector(stopWatch:)];
		[self longReaction];
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) longReaction
{
    [self unschedule:@selector(changeLightSprite)];
    if (actionRun) [self stopAction:action];
    actionRun = 0;
    
    warningOnScreen = 1;
	
	result = result + 3.000;
	
	myTimings = [NSArray arrayWithObjects:timing1, timing2, timing3, timing4, timing5, timing6, timing7, timing8, timing9, timing10, nil];
	
	element = [myTimings objectAtIndex:t];
	element.color = ccc3(230,50,50);
	[element setString:[NSString stringWithFormat:@"3.000"]];
    
	attention.opacity = 255;
    warningLate.opacity = 255;
	
    [self scheduleOnce:@selector(changeLightTimer) delay:3];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) badTouch
{
    [self unschedule:@selector(changeLightSprite)];
    if (actionRun) [self stopAction:action];
    actionRun = 0;
    
	warningOnScreen = 1;
    
    badTouchCount--;
    
    if (badTouchCount < 0)
    {
        badTouchCount = 0;
        result = result + 3.000;
        
        myTimings = [NSArray arrayWithObjects:timing1, timing2, timing3, timing4, timing5, timing6, timing7, timing8, timing9, timing10, nil];
        
        element = [myTimings objectAtIndex:t];
        element.color = ccc3(230,50,50);
        [element setString:[NSString stringWithFormat:@"3.000"]];
    }
    else t--;
    
    attention.opacity = 255;
    
    NSString *warning;
    if (difficulty < 3) warning = [NSString stringWithFormat:@"%@%i", LGLocalizedString(@"earlyWarningEasy", nil), badTouchCount];
    else if (difficulty == 3) warning = [NSString stringWithFormat:@"%@%i", LGLocalizedString(@"earlyWarningHard", nil), badTouchCount];
    else warning = [NSString stringWithFormat:@"%@%i", LGLocalizedString(@"earlyWarningInsane", nil), badTouchCount];
    
    [warningMistake setString:warning];
    warningMistake.opacity = 255;
    
    [self scheduleOnce:@selector(changeLightTimer) delay:3];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) goodTouch
{
	[self unschedule:@selector(stopWatch:)];
    
	start = [kStandartUserDefaults objectForKey:@"timer"];
    end = [NSDate date];
    
    time = [end timeIntervalSinceDate:start];
	
	result = result + time;
	
	myTimings = [NSArray arrayWithObjects:timing1, timing2, timing3, timing4, timing5, timing6, timing7, timing8, timing9, timing10, nil];
	
	element = [myTimings objectAtIndex:t];
	[element setString:[NSString stringWithFormat:@"%.3f", time]];
    
	[self scheduleOnce:@selector(changeLightTimer) delay:0];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) endOfGame
{
    self.isTouchEnabled = NO;
    
    if (score > 0)
    {
        if (difficulty == 1) [kLGGameCenter submitScore:score*1000 forCategory:@"11" withAlert:NO];
        else if (difficulty == 2) [kLGGameCenter submitScore:score*1000 forCategory:@"22" withAlert:NO];
        else if (difficulty == 3) [kLGGameCenter submitScore:score*1000 forCategory:@"33" withAlert:NO];
        else if (difficulty == 4) [kLGGameCenter submitScore:score*1000 forCategory:@"44" withAlert:NO];
    }
    
    if (score <= 0.500) [kLGGameCenter submitAchievement:@"com.ApogeeStudio.CheckYourReactionFree.Dilettante" percentComplete:100]; // дилетант / dilettante
    if (score <= 0.400) [kLGGameCenter submitAchievement:@"com.ApogeeStudio.CheckYourReactionFree.Beginner" percentComplete:100]; // начинающий / beginner
    if (score <= 0.300) [kLGGameCenter submitAchievement:@"com.ApogeeStudio.CheckYourReactionFree.Amateur" percentComplete:100]; // любитель / amateur
    if (score <= 0.280) [kLGGameCenter submitAchievement:@"com.ApogeeStudio.CheckYourReactionFree.Specialist" percentComplete:100]; // специалист / specialist
    if (score <= 0.260) [kLGGameCenter submitAchievement:@"com.ApogeeStudio.CheckYourReactionFree.Professional" percentComplete:100]; // профессионал / professional
    if (score <= 0.250) [kLGGameCenter submitAchievement:@"com.ApogeeStudio.CheckYourReactionFree.Master" percentComplete:100]; // мастер / master
    if (score <= 0.240) [kLGGameCenter submitAchievement:@"com.ApogeeStudio.CheckYourReactionFree.Guru" percentComplete:100]; // гуру / guru
    if (score <= 0.230) [kLGGameCenter submitAchievement:@"com.ApogeeStudio.CheckYourReactionFree.Shark" percentComplete:100]; // пуля / shark
    if (score <= 0.220) [kLGGameCenter submitAchievement:@"com.ApogeeStudio.CheckYourReactionFree.Flash" percentComplete:100]; // молния / flash
    if (score <= 0.200) [kLGGameCenter submitAchievement:@"com.ApogeeStudio.CheckYourReactionFree.Legend" percentComplete:100]; // легенда / legend
    
    [self allSpritesDisappear];
    [self performSelector:@selector(goToHighscores) withObject:nil afterDelay:.2];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) allSpritesAppear
{
    [kLGKit spriteFade:bestScore duration:.2 opacity:255];
	[kLGKit spriteFade:bestScoreValue duration:.2 opacity:255];
	[kLGKit spriteFade:timings duration:.2 opacity:255];
	[kLGKit spriteFade:backButton duration:.2 opacity:255];
    [kLGKit spriteFade:retryButton duration:.2 opacity:255];
    
    myTimings = [NSArray arrayWithObjects:timing1, timing2, timing3, timing4, timing5, timing6, timing7, timing8, timing9, timing10, nil];
    for (i=0; i<10; i++)
	{
        element = [myTimings objectAtIndex:i];
        
        [kLGKit spriteFade:element duration:.2 opacity:255];
    }
    
    [kLGKit spriteFade:circle duration:.2 opacity:200];
    [kLGKit spriteFade:colorText duration:.2 opacity:255];
}

- (void) retryAppear
{
    bestScore.opacity = 255;
	bestScoreValue.opacity = 255;
	backButton.opacity = 255;
	retryButton.opacity = 255;
    
    [kLGKit spriteFade:timings duration:.2 opacity:255];
    
    myTimings = [NSArray arrayWithObjects:timing1, timing2, timing3, timing4, timing5, timing6, timing7, timing8, timing9, timing10, nil];
    for (i=0; i<10; i++)
	{
        element = [myTimings objectAtIndex:i];
        
        [kLGKit spriteFade:element duration:.2 opacity:255];
    }
    
    [kLGKit spriteFade:circle duration:.2 opacity:200];
    [kLGKit spriteFade:colorText duration:.2 opacity:255];
}

- (void) allSpritesDisappear
{
    [kLGKit spriteFade:bestScore duration:.2 opacity:0];
	[kLGKit spriteFade:bestScoreValue duration:.2 opacity:0];
	[kLGKit spriteFade:timings duration:.2 opacity:0];
	[kLGKit spriteFade:backButton duration:.2 opacity:0];
    [kLGKit spriteFade:retryButton duration:.2 opacity:0];
    
    myTimings = [NSArray arrayWithObjects:timing1, timing2, timing3, timing4, timing5, timing6, timing7, timing8, timing9, timing10, nil];
    for (i=0; i<10; i++)
	{
        element = [myTimings objectAtIndex:i];
        
        [kLGKit spriteFade:element duration:.2 opacity:0];
    }
    
    [kLGKit spriteFade:circle duration:.2 opacity:0];
    [kLGKit spriteFade:colorText duration:.2 opacity:0];
    
    if (warningOnScreen)
    {
        [kLGKit spriteFade:warningLate duration:.2 opacity:0];
        [kLGKit spriteFade:warningMistake duration:.2 opacity:0];
        [kLGKit spriteFade:attention duration:.2 opacity:0];
    }
}

- (void) retryDisappear
{
    [kLGKit spriteFade:timings duration:.2 opacity:0];
    
    myTimings = [NSArray arrayWithObjects:timing1, timing2, timing3, timing4, timing5, timing6, timing7, timing8, timing9, timing10, nil];
    for (i=0; i<10; i++)
	{
        element = [myTimings objectAtIndex:i];
        
        [kLGKit spriteFade:element duration:.2 opacity:0];
    }
    
    [kLGKit spriteFade:circle duration:.2 opacity:0];
    [kLGKit spriteFade:colorText duration:.2 opacity:0];
    
    if (warningOnScreen)
    {
        [kLGKit spriteFade:warningLate duration:.2 opacity:0];
        [kLGKit spriteFade:warningMistake duration:.2 opacity:0];
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
	[[CCDirector sharedDirector] replaceScene:[GameLayer1P scene]];
}

- (void) goToHighscores
{
	[[CCDirector sharedDirector] replaceScene:[HighscoresLayer scene]];
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
    touch = [touches anyObject];
	touchPoint = [touch locationInView:[touch view]];
	touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
	
    if (!CGRectContainsPoint(backButton.boundingBox, touchPoint) && !CGRectContainsPoint(retryButton.boundingBox, touchPoint) && !warningOnScreen)
	{
		if (time == 0.000) { [self badTouch]; }
		else { [self goodTouch]; }
        
        [self soundChoose];
	}
    else if (CGRectContainsPoint(backButton.boundingBox, touchPoint)) ////////// backButton //////////
    {
        [backButton setTexture:backButtonT[1]];
        
        z = 1;
    }
    else if (CGRectContainsPoint(retryButton.boundingBox, touchPoint)) ////////// retryButton //////////
    {
        [retryButton setTexture:retryButtonT[1]];
        
        z = 2;
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
