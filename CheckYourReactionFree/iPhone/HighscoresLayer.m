//
//  Created by Grigory Lutkov on 24.03.11.
//  Copyright 2011 Apogee Studio. All rights reserved.
//

#import "HighscoresLayer.h"
#import "SimpleAudioEngine.h"
#import "LGGameCenter.h"
#import "MenuLayer.h"
#import "GameLayer1P.h"
#import "LGKit.h"
#import "LGLocalization.h"
#import "LGReachability.h"
#import <Social/Social.h>
#import <Twitter/Twitter.h>
#import "DEFacebookComposeViewController.h"

@implementation HighscoresLayer

+ (id) scene
{
	CCScene *scene = [CCScene node];
	HighscoresLayer *layer = [HighscoresLayer node];
	[scene addChild:layer];
	return scene;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (id) init
{
	if ((self = [super init]))
	{
        self.isTouchEnabled = YES;
        
        changer = [kStandartUserDefaults integerForKey:@"highscoresChanger"];
        
		winSize = [[CCDirector sharedDirector] winSize];
        
        difficulty = [kStandartUserDefaults integerForKey:@"difficulty"];
        
        [self checkAdsRemoved];
		[self highscoresMenu];
		[self loadHighscores];
		[self updateHighscores];
		[self currentScore];
		[self texts];
		[self saveHighscores];
        if (changer == 0) { [self allSpritesAppear]; }
        if (changer == 1) { [self textsAppear]; }
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

- (void) highscoresMenu
{
	[kStandartUserDefaults setInteger:1 forKey:@"highscoresChanger"];
    
    if (kDevicePhone)
    {
        stripeHeight = 30;
        gamecenterButtonBgFontSize = 44;
        scoreFontSize = 24;
        socialFontSize = 34;
        if (height(kNavController) == 568)
        {
            if (kIsGameFull) gcButtonPosY = winSize.height-stripeHeight*18;
            else gcButtonPosY = winSize.height-stripeHeight*16;
        }
        else
        {
            if (kIsGameFull) gcButtonPosY = winSize.height-stripeHeight*15;
            else gcButtonPosY = winSize.height-stripeHeight*13;
        }
        if (kIsGameFull && height(kNavController) == 568) count = 11;
        else if (!kIsGameFull && height(kNavController) == 568) count = 9;
        else if (kIsGameFull) count = 8;
        else if (!kIsGameFull) count = 6;
    }
    else
    {
        stripeHeight = 64;
        gamecenterButtonBgFontSize = 88;
        scoreFontSize = 50;
        socialFontSize = 68;
        if (kIsGameFull)
        {
            gcButtonPosY = winSize.height-stripeHeight*15;
            count = 8;
        }
        else
        {
            gcButtonPosY = winSize.height-stripeHeight*14;
            count = 7;
        }
    }
    
    backButtonT[0] = [[CCTextureCache sharedTextureCache] addImage:@"backBottom.png"];
	backButtonT[1] = [[CCTextureCache sharedTextureCache] addImage:@"backBottomTapped.png"];
    
    playButtonT[0] = [[CCTextureCache sharedTextureCache] addImage:LGLocalizedString(@"playButtonBottom", nil)];
	playButtonT[1] = [[CCTextureCache sharedTextureCache] addImage:LGLocalizedString(@"playButtonBottomTapped", nil)];
    
    easyButtonT[0] = [[CCTextureCache sharedTextureCache] addImage:LGLocalizedString(@"easyButton", nil)];
	easyButtonT[1] = [[CCTextureCache sharedTextureCache] addImage:LGLocalizedString(@"easyButtonTapped", nil)];
    
    normalButtonT[0] = [[CCTextureCache sharedTextureCache] addImage:LGLocalizedString(@"normalButton", nil)];
	normalButtonT[1] = [[CCTextureCache sharedTextureCache] addImage:LGLocalizedString(@"normalButtonTapped", nil)];
    
    hardButtonT[0] = [[CCTextureCache sharedTextureCache] addImage:LGLocalizedString(@"hardButton", nil)];
	hardButtonT[1] = [[CCTextureCache sharedTextureCache] addImage:LGLocalizedString(@"hardButtonTapped", nil)];
    
    insaneButtonT[0] = [[CCTextureCache sharedTextureCache] addImage:LGLocalizedString(@"insaneButton", nil)];
	insaneButtonT[1] = [[CCTextureCache sharedTextureCache] addImage:LGLocalizedString(@"insaneButtonTapped", nil)];
    
    CCTexture2D *gamecenterButtonT2D = [[CCTextureCache sharedTextureCache] addImage:@"gamecenterCircleButton.png"];
    
    bg = [CCSprite spriteWithFile:@"bg.png"];
    bg.position = ccp(width(kNavController)/2, height(kNavController)/2);
    [self addChild:bg z:-1];
    
    strips = [CCSprite spriteWithFile:@"bgHighscores.png"];
    strips.position = ccp(winSize.width/2, winSize.height);
    strips.opacity = 0;
    strips.anchorPoint = ccp(0.5, 1);
    [self addChild:strips z:0];
    
    ///// gamecenter
    gamecenterButton = [CCSprite spriteWithTexture:gamecenterButtonT2D];
    if ([LGLocalizationGetPreferredLanguage isEqualToString:@"ru"]) gamecenterButton.position = ccp(winSize.width*0.58, gcButtonPosY);
    else gamecenterButton.position = ccp(winSize.width*0.5, gcButtonPosY);
    gamecenterButton.color = ccc3(80, 80, 80);
	gamecenterButton.opacity = 0;
    [self addChild:gamecenterButton z:2];
    
    gamecenterButtonBg = [CCLabelTTF labelWithString:kCircleBgString fontName:kFontOsakaMono fontSize:gamecenterButtonBgFontSize];
    gamecenterButtonBg.position = ccp(gamecenterButton.position.x, gamecenterButton.position.y-gamecenterButtonBg.contentSize.height*0.02);
    gamecenterButtonBg.color = ccc3(80, 80, 80);
    gamecenterButtonBg.opacity = 0;
    [self addChild:gamecenterButtonBg z:1];
    
    gamecenterButtonStroke = [CCLabelTTF labelWithString:kCircleStrokeString fontName:kFontOsakaMono fontSize:gamecenterButtonBgFontSize];
    gamecenterButtonStroke.position = gamecenterButtonBg.position;
    gamecenterButtonStroke.color = ccc3(80, 80, 80);
    gamecenterButtonStroke.opacity = 0;
    [self addChild:gamecenterButtonStroke z:2];
    
    ///// facebook
    facebookButton = [CCLabelTTF labelWithString:@"f" fontName:kFontArialBlack fontSize:socialFontSize];
    if ([LGLocalizationGetPreferredLanguage isEqualToString:@"ru"]) facebookButton.position = ccp(winSize.width*0.26, gcButtonPosY+gamecenterButtonBg.contentSize.height*0.03);
    else facebookButton.position = ccp(winSize.width*0.3, gcButtonPosY+gamecenterButtonBg.contentSize.height*0.03);
    facebookButton.color = ccc3(80, 80, 80);
	facebookButton.opacity = 0;
    [self addChild:facebookButton z:2];
    
    facebookButtonBg = [CCLabelTTF labelWithString:kCircleBgString fontName:kFontOsakaMono fontSize:gamecenterButtonBgFontSize];
    facebookButtonBg.position = ccp(facebookButton.position.x+facebookButtonBg.contentSize.width*0.02, gamecenterButtonBg.position.y);
    facebookButtonBg.color = ccc3(80, 80, 80);
    facebookButtonBg.opacity = 0;
    [self addChild:facebookButtonBg z:1];
    
    facebookButtonStroke = [CCLabelTTF labelWithString:kCircleStrokeString fontName:kFontOsakaMono fontSize:gamecenterButtonBgFontSize];
    facebookButtonStroke.position = facebookButtonBg.position;
    facebookButtonStroke.color = ccc3(80, 80, 80);
    facebookButtonStroke.opacity = 0;
    [self addChild:facebookButtonStroke z:2];
    
    if ([LGLocalizationGetPreferredLanguage isEqualToString:@"ru"])
    {
        int minus;
        if (kDevicePhone) minus = 4;
        else minus = 8;
        
        ///// vkontakte
        vkontakteButton = [CCLabelTTF labelWithString:@"В" fontName:kFontArialBlack fontSize:socialFontSize-minus];
        vkontakteButton.position = ccp(winSize.width*0.42+vkontakteButton.contentSize.width*0.06, gcButtonPosY+gamecenterButtonBg.contentSize.height*0.03);
        vkontakteButton.color = ccc3(80, 80, 80);
        vkontakteButton.opacity = 0;
        [self addChild:vkontakteButton z:2];
        
        vkontakteButtonBg = [CCLabelTTF labelWithString:kCircleBgString fontName:kFontOsakaMono fontSize:gamecenterButtonBgFontSize];
        vkontakteButtonBg.position = ccp(vkontakteButton.position.x+vkontakteButtonBg.contentSize.width*0.02-vkontakteButton.contentSize.width*0.06, gamecenterButtonBg.position.y);
        vkontakteButtonBg.color = ccc3(80, 80, 80);
        vkontakteButtonBg.opacity = 0;
        [self addChild:vkontakteButtonBg z:1];
        
        vkontakteButtonStroke = [CCLabelTTF labelWithString:kCircleStrokeString fontName:kFontOsakaMono fontSize:gamecenterButtonBgFontSize];
        vkontakteButtonStroke.position = vkontakteButtonBg.position;
        vkontakteButtonStroke.color = ccc3(80, 80, 80);
        vkontakteButtonStroke.opacity = 0;
        [self addChild:vkontakteButtonStroke z:2];
    }
    
    ///// twitter
    twitterButton = [CCLabelTTF labelWithString:@"t" fontName:kFontArialBlack fontSize:socialFontSize];
    if ([LGLocalizationGetPreferredLanguage isEqualToString:@"ru"]) twitterButton.position = ccp(winSize.width*0.74, gcButtonPosY+gamecenterButtonBg.contentSize.height*0.04);
    else twitterButton.position = ccp(winSize.width*0.7, gcButtonPosY+gamecenterButtonBg.contentSize.height*0.04);
    twitterButton.color = ccc3(80, 80, 80);
	twitterButton.opacity = 0;
    [self addChild:twitterButton z:2];
    
    twitterButtonBg = [CCLabelTTF labelWithString:kCircleBgString fontName:kFontOsakaMono fontSize:gamecenterButtonBgFontSize];
    twitterButtonBg.position = ccp(twitterButton.position.x+twitterButtonBg.contentSize.width*0.02, gamecenterButtonBg.position.y);
    twitterButtonBg.color = ccc3(80, 80, 80);
    twitterButtonBg.opacity = 0;
    [self addChild:twitterButtonBg z:1];
    
    twitterButtonStroke = [CCLabelTTF labelWithString:kCircleStrokeString fontName:kFontOsakaMono fontSize:gamecenterButtonBgFontSize];
    twitterButtonStroke.position = twitterButtonBg.position;
    twitterButtonStroke.color = ccc3(80, 80, 80);
    twitterButtonStroke.opacity = 0;
    [self addChild:twitterButtonStroke z:2];
    
	backButton = [CCSprite spriteWithTexture:backButtonT[0]];
	backButton.position = ccp(backButton.contentSize.width/2, backButton.contentSize.height/2);
    backButton.opacity = 0;
    [self addChild:backButton z:1];
    
    playButton = [CCSprite spriteWithTexture:playButtonT[0]];
	playButton.position = ccp(winSize.width-playButton.contentSize.width/2, playButton.contentSize.height/2);
    playButton.opacity = 0;
    [self addChild:playButton z:1];
    
    synchronizeGC = [CCLabelTTF labelWithString:LGLocalizedString(@"synchronizeGC", nil) fontName:kFontComicSans fontSize:scoreFontSize];
    synchronizeGC.position = ccp(winSize.width/2, gcButtonPosY+stripeHeight*1.5);
	synchronizeGC.color = ccc3(100,100,100);
    synchronizeGC.opacity = 0;
	[self addChild:synchronizeGC z:1];
    
    if (difficulty == 1) easyButton = [CCSprite spriteWithTexture:easyButtonT[1]];
    else easyButton = [CCSprite spriteWithTexture:easyButtonT[0]];
	easyButton.position = ccp(easyButton.contentSize.width/2, winSize.height-easyButton.contentSize.height/2);
    easyButton.opacity = 0;
	[self addChild:easyButton z:1];
    
	if (difficulty == 2) normalButton = [CCSprite spriteWithTexture:normalButtonT[1]];
    else normalButton = [CCSprite spriteWithTexture:normalButtonT[0]];
	if (kDevicePhone) normalButton.position = ccp(easyButton.position.x+easyButton.contentSize.width/2+normalButton.contentSize.width/2, winSize.height-normalButton.contentSize.height/2);
    else normalButton.position = ccp((easyButton.position.x+easyButton.contentSize.width/2+winSize.width/2)/2, winSize.height-normalButton.contentSize.height/2);
    normalButton.opacity = 0;
    [self addChild:normalButton z:1];
    
    if (difficulty == 4) insaneButton = [CCSprite spriteWithTexture:insaneButtonT[1]];
    else insaneButton = [CCSprite spriteWithTexture:insaneButtonT[0]];
	insaneButton.position = ccp(winSize.width-insaneButton.contentSize.width/2, winSize.height-insaneButton.contentSize.height/2);
    insaneButton.opacity = 0;
    [self addChild:insaneButton z:1];
    
    if (difficulty == 3) hardButton = [CCSprite spriteWithTexture:hardButtonT[1]];
    else hardButton = [CCSprite spriteWithTexture:hardButtonT[0]];
	if (kDevicePhone) hardButton.position = ccp(insaneButton.position.x-insaneButton.contentSize.width/2-hardButton.contentSize.width/2, winSize.height-hardButton.contentSize.height/2);
    else hardButton.position = ccp((insaneButton.position.x-insaneButton.contentSize.width/2+winSize.width/2)/2, winSize.height-hardButton.contentSize.height/2);
    hardButton.opacity = 0;
    [self addChild:hardButton z:1];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) loadHighscores
{
	if (difficulty == 1) highscore = [kStandartUserDefaults arrayForKey:@"highscoresEasy"];
    else if (difficulty == 2) highscore = [kStandartUserDefaults arrayForKey:@"highscoresNormal"];
    else if (difficulty == 3) highscore = [kStandartUserDefaults arrayForKey:@"highscoresHard"];
    else if (difficulty == 4) highscore = [kStandartUserDefaults arrayForKey:@"highscoresInsane"];
	
	highscores = [NSMutableArray arrayWithArray:highscore];
	
	if ([highscores count] == 0)
	{
		for (i=0; i<15; i++)
		{
			[highscores addObject:[NSNumber numberWithFloat:0]];
		}
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) updateHighscores
{
	currentScorePosition = -1;
	if (difficulty == 1) currentScore = [kStandartUserDefaults floatForKey:@"currentScoreEasy"];
    else if (difficulty == 2) currentScore = [kStandartUserDefaults floatForKey:@"currentScoreNormal"];
    else if (difficulty == 3) currentScore = [kStandartUserDefaults floatForKey:@"currentScoreHard"];
    else if (difficulty == 4) currentScore = [kStandartUserDefaults floatForKey:@"currentScoreInsane"];
	
    if (currentScore > 0)
    {
        for (i=0; i<15; i++)
        {
            score = [[highscores objectAtIndex:i] floatValue];
            
            if (currentScore == score)
            {
                break;
            }
            if (score == 0)
            {
                currentScorePosition = i;
                break;
            }
            if (currentScore < score)
            {
                currentScorePosition = i;
                break;
            }
        }
    }
	
	if (currentScorePosition >= 0)
	{
		[highscores insertObject:[NSNumber numberWithFloat:currentScore] atIndex:currentScorePosition];
		[highscores removeLastObject];
	}
	
	bestScore = [[highscores objectAtIndex:0] floatValue];
    if (difficulty == 1) [kStandartUserDefaults setFloat:bestScore forKey:@"bestScoreEasy"];
    else if (difficulty == 2) [kStandartUserDefaults setFloat:bestScore forKey:@"bestScoreNormal"];
    else if (difficulty == 3) [kStandartUserDefaults setFloat:bestScore forKey:@"bestScoreHard"];
    else if (difficulty == 4) [kStandartUserDefaults setFloat:bestScore forKey:@"bestScoreInsane"];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) currentScore
{
	if (currentScore != 0)
	{
		if (difficulty == 1) [kStandartUserDefaults setFloat:currentScore forKey:@"currentScoreEasy"];
        else if (difficulty == 2) [kStandartUserDefaults setFloat:currentScore forKey:@"currentScoreNormal"];
        else if (difficulty == 3) [kStandartUserDefaults setFloat:currentScore forKey:@"currentScoreHard"];
        else if (difficulty == 4) [kStandartUserDefaults setFloat:currentScore forKey:@"currentScoreInsane"];
	}
	else
	{
		if (difficulty == 1) currentScore = [kStandartUserDefaults floatForKey:@"currentScoreEasy"];
        else if (difficulty == 2) currentScore = [kStandartUserDefaults floatForKey:@"currentScoreNormal"];
        else if (difficulty == 3) currentScore = [kStandartUserDefaults floatForKey:@"currentScoreHard"];
        else if (difficulty == 4) currentScore = [kStandartUserDefaults floatForKey:@"currentScoreInsane"];
	}
	
	currentScoreText = [CCLabelTTF labelWithString:LGLocalizedString(@"currentReaction", nil) fontName:kFontComicSans fontSize:scoreFontSize];
	currentScoreText.position = ccp(winSize.width/2, winSize.height-stripeHeight*2.5);
	currentScoreText.color = ccc3(100,100,100);
    currentScoreText.opacity = 0;
	[self addChild:currentScoreText];
	
	currentScoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%.3f", currentScore] fontName:kFontComicSans fontSize:scoreFontSize];
	currentScoreLabel.position = ccp(winSize.width/2, winSize.height-stripeHeight*3.5);
	currentScoreLabel.color = ccc3(230,50,50);
    currentScoreLabel.opacity = 0;
	[self addChild:currentScoreLabel];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) texts
{
	for (i=0; i<count; i++)
	{
		score = [[highscores objectAtIndex:i] floatValue];
		
		number[i] = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d >", i+1] fontName:kFontComicSans fontSize:scoreFontSize];
		number[i].position = ccp(winSize.width*0.25, winSize.height-stripeHeight*(i+4.5));
		number[i].color = ccc3(100,100,100);
        number[i].opacity = 0;
        number[i].anchorPoint = ccp(1, 0.5);
		[self addChild:number[i]];
		
		timing[i] = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%.3f", score] fontName:kFontComicSans fontSize:scoreFontSize];
		timing[i].position = ccp(winSize.width*0.9, winSize.height-stripeHeight*(i+4.5));
		if (score == currentScore && score != 0) timing[i].color = ccc3(230,50,50);
		else timing[i].color = ccc3(100,100,100);
        timing[i].opacity = 0;
        timing[i].anchorPoint = ccp(1, 0.5);
		[self addChild:timing[i]];
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) saveHighscores
{
	if (difficulty == 1) [kStandartUserDefaults setObject:highscores forKey:@"highscoresEasy"];
    else if (difficulty == 2) [kStandartUserDefaults setObject:highscores forKey:@"highscoresNormal"];
    else if (difficulty == 3) [kStandartUserDefaults setObject:highscores forKey:@"highscoresHard"];
    else if (difficulty == 4) [kStandartUserDefaults setObject:highscores forKey:@"highscoresInsane"];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) allSpritesAppear
{
	[kLGKit spriteFade:strips duration:.2 opacity:255];
	[kLGKit spriteFade:backButton duration:.2 opacity:255];
	[kLGKit spriteFade:playButton duration:.2 opacity:255];
	[kLGKit spriteFade:gamecenterButton duration:.2 opacity:255];
    [kLGKit spriteFade:gamecenterButtonBg duration:.2 opacity:30];
    [kLGKit spriteFade:gamecenterButtonStroke duration:.2 opacity:255];
    [kLGKit spriteFade:facebookButton duration:.2 opacity:255];
    [kLGKit spriteFade:facebookButtonBg duration:.2 opacity:30];
    [kLGKit spriteFade:facebookButtonStroke duration:.2 opacity:255];
    [kLGKit spriteFade:twitterButton duration:.2 opacity:255];
    [kLGKit spriteFade:twitterButtonBg duration:.2 opacity:30];
    [kLGKit spriteFade:twitterButtonStroke duration:.2 opacity:255];
	[kLGKit spriteFade:easyButton duration:.2 opacity:255];
	[kLGKit spriteFade:normalButton duration:.2 opacity:255];
	[kLGKit spriteFade:hardButton duration:.2 opacity:255];
    [kLGKit spriteFade:insaneButton duration:.2 opacity:255];
	[kLGKit spriteFade:currentScoreText duration:.2 opacity:255];
	[kLGKit spriteFade:currentScoreLabel duration:.2 opacity:255];
    [kLGKit spriteFade:synchronizeGC duration:.2 opacity:255];
    
    if ([LGLocalizationGetPreferredLanguage isEqualToString:@"ru"])
    {
        [kLGKit spriteFade:vkontakteButton duration:.2 opacity:255];
        [kLGKit spriteFade:vkontakteButtonBg duration:.2 opacity:30];
        [kLGKit spriteFade:vkontakteButtonStroke duration:.2 opacity:255];
    }
	
    for (i=0; i<15; i++)
	{
        [kLGKit spriteFade:number[i] duration:.2 opacity:255];
        [kLGKit spriteFade:timing[i] duration:.2 opacity:255];
    }
}

- (void) textsAppear
{
	strips.opacity = 255;
	backButton.opacity = 255;
	playButton.opacity = 255;
	gamecenterButton.opacity = 255;
    gamecenterButtonBg.opacity = 30;
    gamecenterButtonStroke.opacity = 255;
    facebookButton.opacity = 255;
    facebookButtonBg.opacity = 30;
    facebookButtonStroke.opacity = 255;
    twitterButton.opacity = 255;
    twitterButtonBg.opacity = 30;
    twitterButtonStroke.opacity = 255;
	easyButton.opacity = 255;
	normalButton.opacity = 255;
	hardButton.opacity = 255;
	insaneButton.opacity = 255;
    synchronizeGC.opacity = 255;
    
    if ([LGLocalizationGetPreferredLanguage isEqualToString:@"ru"])
    {
        vkontakteButton.opacity = 255;
        vkontakteButtonBg.opacity = 30;
        vkontakteButtonStroke.opacity = 255;
    }
	
	[kLGKit spriteFade:currentScoreText duration:.2 opacity:255];
	[kLGKit spriteFade:currentScoreLabel duration:.2 opacity:255];
	
    for (i=0; i<15; i++)
	{
        [kLGKit spriteFade:number[i] duration:.2 opacity:255];
        [kLGKit spriteFade:timing[i] duration:.2 opacity:255];
    }
}

- (void) allSpritesDisappear
{
	[kLGKit spriteFade:strips duration:.2 opacity:0];
	[kLGKit spriteFade:backButton duration:.2 opacity:0];
	[kLGKit spriteFade:playButton duration:.2 opacity:0];
	[kLGKit spriteFade:gamecenterButton duration:.2 opacity:0];
    [kLGKit spriteFade:gamecenterButtonBg duration:.2 opacity:0];
    [kLGKit spriteFade:gamecenterButtonStroke duration:.2 opacity:0];
    [kLGKit spriteFade:facebookButton duration:.2 opacity:0];
    [kLGKit spriteFade:facebookButtonBg duration:.2 opacity:0];
    [kLGKit spriteFade:facebookButtonStroke duration:.2 opacity:0];
    [kLGKit spriteFade:twitterButton duration:.2 opacity:0];
    [kLGKit spriteFade:twitterButtonBg duration:.2 opacity:0];
    [kLGKit spriteFade:twitterButtonStroke duration:.2 opacity:0];
	[kLGKit spriteFade:easyButton duration:.2 opacity:0];
	[kLGKit spriteFade:normalButton duration:.2 opacity:0];
	[kLGKit spriteFade:hardButton duration:.2 opacity:0];
    [kLGKit spriteFade:insaneButton duration:.2 opacity:0];
	[kLGKit spriteFade:currentScoreText duration:.2 opacity:0];
	[kLGKit spriteFade:currentScoreLabel duration:.2 opacity:0];
    [kLGKit spriteFade:synchronizeGC duration:.2 opacity:0];
    
    if ([LGLocalizationGetPreferredLanguage isEqualToString:@"ru"])
    {
        [kLGKit spriteFade:vkontakteButton duration:.2 opacity:0];
        [kLGKit spriteFade:vkontakteButtonBg duration:.2 opacity:0];
        [kLGKit spriteFade:vkontakteButtonStroke duration:.2 opacity:0];
    }
	
    for (i=0; i<15; i++)
	{
        [kLGKit spriteFade:number[i] duration:.2 opacity:0];
        [kLGKit spriteFade:timing[i] duration:.2 opacity:0];
    }
}

- (void) textsDisappear
{
	[kLGKit spriteFade:currentScoreText duration:.2 opacity:0];
	[kLGKit spriteFade:currentScoreLabel duration:.2 opacity:0];
	
    for (i=0; i<15; i++)
	{
        [kLGKit spriteFade:number[i] duration:.2 opacity:0];
        [kLGKit spriteFade:timing[i] duration:.2 opacity:0];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) goToMainMenu
{
	[[CCDirector sharedDirector] replaceScene:[MenuLayer scene]];
}

- (void) goToGame
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

//////////////////////////////////////////////////////////////////////////////////////////////////// Alerts

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == alertGC)
    {
        if (buttonIndex == 1)
        {
            NSString *leaderboard;
            if (difficulty == 1) leaderboard = @"11";
            else if (difficulty == 2) leaderboard = @"22";
            else if (difficulty == 3) leaderboard = @"33";
            else leaderboard = @"44";
            
            [kLGGameCenter showLeaderboard:leaderboard];
        }
        else if (buttonIndex == 2) [kLGGameCenter showAchievements];
        
        gamecenterButtonBg.color = ccc3(80, 80, 80);
        gamecenterButtonBg.opacity = 30;
        
        gamecenterButton.color = ccc3(80, 80, 80);
        gamecenterButtonStroke.color = ccc3(80, 80, 80);
    }
    else if (alertView == alertVK)
    {
        Vkontakte *vk = kVkontakte;
        vk.delegate = self;
        
        if (buttonIndex == 1)
        {
             CCScene *scene = [[CCDirector sharedDirector] runningScene];
             
             [vk postImageToWall:[self screenshotWithScene:scene]
             text:[NSString stringWithFormat:@"%@ %.3fс!\n%@", LGLocalizedString(@"postText", nil), bestScore, LGLocalizedString(@"postEnd", nil)]
             link:[NSURL URLWithString:@"http://j.mp/Xqoljw"]];
        }
        else if (buttonIndex == 2) [vk logout];
    }
}

- (void) firstPlayAlert
{
    [[[UIAlertView alloc] initWithTitle:LGLocalizedString(@"error", nil)
                                message:LGLocalizedString(@"firstPlay", nil)
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

- (UIImage *) screenshotWithScene:(CCScene *)scene
{
    [CCDirector sharedDirector].nextDeltaTimeZero = YES;
    
    CCNode *node = [scene.children objectAtIndex:0];
    CCRenderTexture *rtx = [CCRenderTexture renderTextureWithWidth:winSize.width height:winSize.height];

    [rtx begin];
    [node visit];
    [rtx end];
    
    return [rtx getUIImage];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	touch = [touches anyObject];
	touchPoint = [touch locationInView:[touch view]];
	touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
	
    if (CGRectContainsPoint(backButton.boundingBox, touchPoint)) ////////// backButton //////////
    {
        [backButton setTexture:backButtonT[1]];
        
        z = 1;
        
        [self soundButton];
    }
    else if (CGRectContainsPoint(playButton.boundingBox, touchPoint)) ////////// playButton //////////
    {
        [playButton setTexture:playButtonT[1]];
        
        z = 2;
        
        [self soundButton];
    }
    else if (CGRectContainsPoint(gamecenterButtonBg.boundingBox, touchPoint)) ////////// gameCenterButton //////////
    {
        gamecenterButtonBg.color = ccc3(230, 230, 230);
        gamecenterButtonBg.opacity = 150;
        
        gamecenterButton.color = ccc3(50, 50, 50);
        gamecenterButtonStroke.color = ccc3(50, 50, 50);
        
        z = 3;
        
        [self soundChoose];
    }
    else if (CGRectContainsPoint(facebookButtonBg.boundingBox, touchPoint)) ////////// facebook
    {
        facebookButtonBg.color = ccc3(230, 230, 230);
        facebookButtonBg.opacity = 150;
        
        facebookButton.color = ccc3(50, 50, 50);
        facebookButtonStroke.color = ccc3(50, 50, 50);
        
        [self soundChoose];
        
        if (bestScore > 0)
        {
            if (kInternetStatus)
            {
                //if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
                
                UINavigationController *navigationController = [(AppController *)[[UIApplication sharedApplication] delegate] navigationController];
                
                NSString *secondText = [NSString new];
                if ([LGLocalizationGetPreferredLanguage isEqualToString:@"ru"]) secondText = @"с";
                else secondText = @"s";
                
                if (kOSVersion >= 6)
                {
                    SLComposeViewController *facebookVC = [SLComposeViewController new];
                    
                    facebookVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
                    
                    [facebookVC setCompletionHandler:^(SLComposeViewControllerResult result)
                     {
                         switch (result)
                         {
                             case SLComposeViewControllerResultCancelled:
                                 NSLog(@"Facebook Post Cancelled");
                                 break;
                             case SLComposeViewControllerResultDone:
                                 NSLog(@"Facebook Post Sucessful");
                                 break;
                             default:
                                 break;
                         }
                         
                         [navigationController dismissModalViewControllerAnimated:YES];
                     }];
                    
                    [facebookVC setInitialText:[NSString stringWithFormat:@"%@ %.3f%@!\n%@", LGLocalizedString(@"postText", nil), bestScore, secondText, LGLocalizedString(@"postEnd", nil)]];
                    if ([LGLocalizationGetPreferredLanguage isEqualToString:@"ru"]) [facebookVC addURL:[NSURL URLWithString:@"http://bit.ly/Xqoljw"]];
                    else [facebookVC addURL:[NSURL URLWithString:@"http://bit.ly/YOZPKB"]];
                    //[facebookVC addURL:[NSURL URLWithString:LGLocalizedString(@"postURL", nil)]];
                    [facebookVC addImage:nil];
                    
                    [navigationController presentViewController:facebookVC animated:YES completion:nil];
                }
                else
                {
                    DEFacebookComposeViewController *facebookVC = [DEFacebookComposeViewController new];
                    
                    [facebookVC setCompletionHandler:^(DEFacebookComposeViewControllerResult result)
                     {
                         switch (result)
                         {
                             case DEFacebookComposeViewControllerResultCancelled:
                                 NSLog(@"Facebook Post Cancelled");
                                 break;
                             case DEFacebookComposeViewControllerResultDone:
                                 NSLog(@"Facebook Post Sucessful");
                                 break;
                             default:
                                 break;
                         }
                         
                         [navigationController dismissModalViewControllerAnimated:YES];
                     }];
                    
                    [facebookVC setInitialText:[NSString stringWithFormat:@"%@ %.3f%@!\n%@", LGLocalizedString(@"postText", nil), bestScore, secondText, LGLocalizedString(@"postEnd", nil)]];
                    if ([LGLocalizationGetPreferredLanguage isEqualToString:@"ru"]) [facebookVC addURL:[NSURL URLWithString:@"http://bit.ly/Xqoljw"]];
                    else [facebookVC addURL:[NSURL URLWithString:@"http://bit.ly/YOZPKB"]];
                    //[facebookVC addURL:[NSURL URLWithString:LGLocalizedString(@"postURL", nil)]];
                    [facebookVC addImage:nil];
                    
                    navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
                    [navigationController presentViewController:facebookVC animated:YES completion:nil];
                }
            }
            else [kLGKit createAlertNoInternet];
        }
        else [self firstPlayAlert];
        
        facebookButtonBg.color = ccc3(80, 80, 80);
        facebookButtonBg.opacity = 30;
        
        facebookButton.color = ccc3(80, 80, 80);
        facebookButtonStroke.color = ccc3(80, 80, 80);
    }
    else if (CGRectContainsPoint(twitterButtonBg.boundingBox, touchPoint)) ////////// twitter
    {
        twitterButtonBg.color = ccc3(230, 230, 230);
        twitterButtonBg.opacity = 150;
        
        twitterButton.color = ccc3(50, 50, 50);
        twitterButtonStroke.color = ccc3(50, 50, 50);
        
        [self soundChoose];
        
        if (bestScore > 0)
        {
            if (kInternetStatus)
            {
                //if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
                
                UINavigationController *navigationController = [(AppController *)[[UIApplication sharedApplication] delegate] navigationController];
                
                NSString *secondText = [NSString new];
                if ([LGLocalizationGetPreferredLanguage isEqualToString:@"ru"]) secondText = @"с";
                else secondText = @"s";
                
                if (kOSVersion >= 6)
                {
                    SLComposeViewController *twitterVC = [SLComposeViewController new];
                    
                    twitterVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                    
                    [twitterVC setCompletionHandler:^(SLComposeViewControllerResult result)
                     {
                         switch (result)
                         {
                             case SLComposeViewControllerResultCancelled:
                                 NSLog(@"Twitter Post Cancelled");
                                 break;
                             case SLComposeViewControllerResultDone:
                                 NSLog(@"Twitter Post Sucessful");
                                 break;
                             default:
                                 break;
                         }
                         
                         [navigationController dismissModalViewControllerAnimated:YES];
                     }];
                    
                    [twitterVC setInitialText:[NSString stringWithFormat:@"#CheckYourReaction\n%@ %.3f%@!\n%@\n", LGLocalizedString(@"postText", nil), bestScore, secondText, LGLocalizedString(@"postEnd", nil)]];
                    
                    CCScene *scene = [[CCDirector sharedDirector] runningScene];
                    [twitterVC addImage:[self screenshotWithScene:scene]];
                    
                    if ([LGLocalizationGetPreferredLanguage isEqualToString:@"ru"]) [twitterVC addURL:[NSURL URLWithString:@"j.mp/Xqoljw"]];
                    else [twitterVC addURL:[NSURL URLWithString:@"j.mp/YOZPKB"]];
                    
                    [navigationController presentViewController:twitterVC animated:YES completion:nil];
                }
                else
                {
                    TWTweetComposeViewController *twitterVC = [TWTweetComposeViewController new];
                    
                    [twitterVC setCompletionHandler:^(TWTweetComposeViewControllerResult result)
                     {
                         switch (result)
                         {
                             case TWTweetComposeViewControllerResultCancelled:
                                 NSLog(@"Twitter Post Cancelled");
                                 break;
                             case TWTweetComposeViewControllerResultDone:
                                 NSLog(@"Twitter Post Sucessful");
                                 break;
                             default:
                                 break;
                         }
                         
                         [navigationController dismissModalViewControllerAnimated:YES];
                     }];
                    
                    [twitterVC setInitialText:[NSString stringWithFormat:@"#CheckYourReaction\n%@ %.3f%@!\n%@\n", LGLocalizedString(@"postText", nil), bestScore, secondText, LGLocalizedString(@"postEnd", nil)]];
                    
                    CCScene *scene = [[CCDirector sharedDirector] runningScene];
                    [twitterVC addImage:[self screenshotWithScene:scene]];
                    
                    if ([LGLocalizationGetPreferredLanguage isEqualToString:@"ru"]) [twitterVC addURL:[NSURL URLWithString:@"j.mp/Xqoljw"]];
                    else [twitterVC addURL:[NSURL URLWithString:@"j.mp/YOZPKB"]];
                    
                    [navigationController presentViewController:twitterVC animated:YES completion:nil];
                }
            }
            else [kLGKit createAlertNoInternet];
        }
        else [self firstPlayAlert];
        
        twitterButtonBg.color = ccc3(80, 80, 80);
        twitterButtonBg.opacity = 30;
        
        twitterButton.color = ccc3(80, 80, 80);
        twitterButtonStroke.color = ccc3(80, 80, 80);
    }
    else if (CGRectContainsPoint(vkontakteButtonBg.boundingBox, touchPoint) && [LGLocalizationGetPreferredLanguage isEqualToString:@"ru"]) ////////// vkontakte
    {
        vkontakteButtonBg.color = ccc3(230, 230, 230);
        vkontakteButtonBg.opacity = 150;
        
        vkontakteButton.color = ccc3(50, 50, 50);
        vkontakteButtonStroke.color = ccc3(50, 50, 50);
        
        [self soundChoose];
        
        if (bestScore > 0)
        {
            if (kInternetStatus)
            {
                Vkontakte *vk = kVkontakte;
                vk.delegate = self;
                
                if (![vk isAuthorized]) [vk authenticate];
                else
                {
                    alertVK = [[UIAlertView alloc] initWithTitle:nil
                                                         message:nil
                                                        delegate:self
                                               cancelButtonTitle:@"Закрыть"
                                               otherButtonTitles:@"Запостить результат", @"Выйти из аккаунта", nil];
                    [alertVK show];
                }
            }
            else [kLGKit createAlertNoInternet];
        }
        else [self firstPlayAlert];
        
        vkontakteButtonBg.color = ccc3(80, 80, 80);
        vkontakteButtonBg.opacity = 30;
        
        vkontakteButton.color = ccc3(80, 80, 80);
        vkontakteButtonStroke.color = ccc3(80, 80, 80);
    }
    else if (CGRectContainsPoint(easyButton.boundingBox, touchPoint) && difficulty != 1) ////////// easyButton //////////
    {
        self.isTouchEnabled = NO;
        [easyButton setTexture:easyButtonT[1]];
        [normalButton setTexture:normalButtonT[0]];
        [hardButton setTexture:hardButtonT[0]];
        [insaneButton setTexture:insaneButtonT[0]];
        [self textsDisappear];
        [kStandartUserDefaults setInteger:1 forKey:@"difficulty"];
        [self performSelector:@selector(goToHighscores) withObject:nil afterDelay:.2];
        
        [self soundChoose];
    }
    else if (CGRectContainsPoint(normalButton.boundingBox, touchPoint) && difficulty != 2) ////////// normalButton //////////
    {
        self.isTouchEnabled = NO;
        [easyButton setTexture:easyButtonT[0]];
        [normalButton setTexture:normalButtonT[1]];
        [hardButton setTexture:hardButtonT[0]];
        [insaneButton setTexture:insaneButtonT[0]];
        [self textsDisappear];
        [kStandartUserDefaults setInteger:2 forKey:@"difficulty"];
        [self performSelector:@selector(goToHighscores) withObject:nil afterDelay:.2];
        
        [self soundChoose];
    }
    else if (CGRectContainsPoint(hardButton.boundingBox, touchPoint) && difficulty != 3) ////////// hardButton //////////
    {
        self.isTouchEnabled = NO;
        [easyButton setTexture:easyButtonT[0]];
        [normalButton setTexture:normalButtonT[0]];
        [hardButton setTexture:hardButtonT[1]];
        [insaneButton setTexture:insaneButtonT[0]];
        [self textsDisappear];
        [kStandartUserDefaults setInteger:3 forKey:@"difficulty"];
        [self performSelector:@selector(goToHighscores) withObject:nil afterDelay:.2];
        
        [self soundChoose];
    }
    else if (CGRectContainsPoint(insaneButton.boundingBox, touchPoint) && difficulty != 4) ////////// insaneButton //////////
    {
        self.isTouchEnabled = NO;
        [easyButton setTexture:easyButtonT[0]];
        [normalButton setTexture:normalButtonT[0]];
        [hardButton setTexture:hardButtonT[0]];
        [insaneButton setTexture:insaneButtonT[1]];
        [self textsDisappear];
        [kStandartUserDefaults setInteger:4 forKey:@"difficulty"];
        [self performSelector:@selector(goToHighscores) withObject:nil afterDelay:.2];
        
        [self soundChoose];
    }
    else if (CGRectContainsPoint(synchronizeGC.boundingBox, touchPoint)) ////////// synchronize //////////
    {
        synchronizeGC.color = ccc3(50, 50, 50);
        
        [self soundChoose];
        
        z = 6;
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
        
        [kStandartUserDefaults setInteger:0 forKey:@"highscoresChanger"];
    }
    else if (z == 1)
    {
        [backButton setTexture:backButtonT[0]];
    }
    else if (CGRectContainsPoint(playButton.boundingBox, touchPoint) && z == 2) ////////// playButton //////////
    {
        self.isTouchEnabled = NO;
        
        [self allSpritesDisappear];
        
        [self performSelector:@selector(goToGame) withObject:nil afterDelay:.2];
        
        [kStandartUserDefaults setInteger:0 forKey:@"highscoresChanger"];
    }
    else if (z == 2)
    {
        [playButton setTexture:playButtonT[0]];
    }
    else if (CGRectContainsPoint(gamecenterButtonBg.boundingBox, touchPoint) && z == 3) ////////// gamecenter //////////
    {
        alertGC = [[UIAlertView alloc] initWithTitle:nil
                                             message:nil
                                            delegate:self
                                   cancelButtonTitle:LGLocalizedString(@"cancel", nil)
                                   otherButtonTitles:LGLocalizedString(@"leaderboards", nil), LGLocalizedString(@"achievements", nil), nil];
        [alertGC show];
    }
    else if (z == 3)
    {
        gamecenterButtonBg.color = ccc3(80, 80, 80);
        gamecenterButtonBg.opacity = 30;
        
        gamecenterButton.color = ccc3(80, 80, 80);
        gamecenterButtonStroke.color = ccc3(80, 80, 80);
    }
    else if (CGRectContainsPoint(synchronizeGC.boundingBox, touchPoint) && z == 6) ////////// synchronize //////////
    {
        if (bestScore > 0)
        {
            if ([kLGGameCenter isGameCenterEnable])
            {
                if (difficulty == 1) [kLGGameCenter submitScore:bestScore*1000 forCategory:@"11" withAlert:YES];
                else if (difficulty == 2) [kLGGameCenter submitScore:bestScore*1000 forCategory:@"22" withAlert:YES];
                else if (difficulty == 3) [kLGGameCenter submitScore:bestScore*1000 forCategory:@"33" withAlert:YES];
                else if (difficulty == 4) [kLGGameCenter submitScore:bestScore*1000 forCategory:@"44" withAlert:YES];
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:LGLocalizedString(@"GCErrorTitle", nil)
                                            message:LGLocalizedString(@"GCErrorMessage", nil)
                                           delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
            }
        }
        else [self firstPlayAlert];
        
        synchronizeGC.color = ccc3(100, 100, 100);
    }
    else if (z == 6)
    {
        synchronizeGC.color = ccc3(100, 100, 100);
    }
}

#pragma mark - VkontakteDelegate

- (void)vkontakteDidFailedWithError:(NSError *)error
{
    [kNavController dismissModalViewControllerAnimated:YES];
    
    [[[UIAlertView alloc] initWithTitle:@"Ошибка"
                                message:@"Произошла ошибка. Повторите попытку позже."
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

- (void)showVkontakteAuthController:(UIViewController *)controller
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        controller.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [kNavController presentModalViewController:controller animated:YES];
}

- (void)vkontakteAuthControllerDidCancelled
{
    [kNavController dismissModalViewControllerAnimated:YES];
}

- (void)vkontakteDidFinishLogin:(Vkontakte *)vkontakte
{
    [kNavController dismissModalViewControllerAnimated:YES];
    
    alertVK = [[UIAlertView alloc] initWithTitle:nil
                                message:nil
                               delegate:self
                      cancelButtonTitle:@"Закрыть"
                      otherButtonTitles:@"Запостить результат", @"Выйти из аккаунта", nil];
    [alertVK show];
}

- (void)vkontakteDidFinishGettinUserInfo:(NSDictionary *)info
{
    NSLog(@"VK Info: %@", info);
}

- (void)vkontakteDidFinishPostingToWall:(NSDictionary *)responce
{
    [[[UIAlertView alloc] initWithTitle:@"Готово"
                                message:@"Вы успешно отправили результат на стену."
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
    
    NSLog(@"VK finish posting to wall: %@", responce);
}

@end
