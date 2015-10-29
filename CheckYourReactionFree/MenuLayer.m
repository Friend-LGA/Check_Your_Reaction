//
//  Created by Grigory Lutkov on 03.03.11.
//  Copyright 2011 Apogee Studio. All rights reserved.
//

#import "MenuLayer.h"
#import "LGReachability.h"
#import "SimpleAudioEngine.h"
#import "LGGameCenter.h"
#import "LGInAppPurchases.h"
#import "LGLocalization.h"
#import "LGKit.h"
#import "GameLayer2P.h"
#import "GameLayer1P.h"
#import "HighscoresLayer.h"
#import "AppController.h"

@implementation MenuLayer

+ (id) scene
{
	CCScene *scene = [CCScene node];
	MenuLayer *layer = [MenuLayer node];
	[scene addChild:layer];
	return scene;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (id) init
{
	if ((self = [super init]))
	{
        defaults = [NSUserDefaults standardUserDefaults];
		winSize = [[CCDirector sharedDirector] winSize];
		
		self.isTouchEnabled = YES;
        
		[self menuItems];
	}
	return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) checkSettings
{
    difficulty = [defaults integerForKey:@"difficulty"];
    colorOfLight = [defaults integerForKey:@"colorOfLight"];
    gameMode = [defaults integerForKey:@"gameMode"];
    bool soundIsOn = [defaults boolForKey:@"soundIsOn"];
    
    if (difficulty == 0) ////////// difficulty //////////
	{
        difficulty = 1;
		[defaults setInteger:difficulty forKey:@"difficulty"];
	}
	if (colorOfLight == 0) ////////// colorOfLight //////////
	{
        colorOfLight = 1;
		[defaults setInteger:colorOfLight forKey:@"colorOfLight"];
	}
    if (gameMode == 0) ////////// gameMode //////////
	{
        gameMode = 1;
		[defaults setInteger:gameMode forKey:@"gameMode"];
	}
	
	if (difficulty == 1) ////////// bestScore && lastScoreReturned //////////
	{
        bestScoreReturned = [defaults floatForKey:@"bestScoreEasy"];
        lastScoreReturned = [defaults floatForKey:@"currentScoreEasy"];
	}
	else if (difficulty == 2)
	{
        bestScoreReturned = [defaults floatForKey:@"bestScoreNormal"];
        lastScoreReturned = [defaults floatForKey:@"currentScoreNormal"];
	}
	else if (difficulty == 3)
	{
        bestScoreReturned = [defaults floatForKey:@"bestScoreHard"];
        lastScoreReturned = [defaults floatForKey:@"currentScoreHard"];
	}
	else if (difficulty == 4)
	{
        bestScoreReturned = [defaults floatForKey:@"bestScoreInsane"];
        lastScoreReturned = [defaults floatForKey:@"currentScoreInsane"];
	}
    
    if (colorOfLight == 1) [blueButton setString:LGLocalizedString(@"blueSel", nil)];
	else if (colorOfLight == 2) [greenButton setString:LGLocalizedString(@"greenSel", nil)];
	else if (colorOfLight == 3) [yellowButton setString:LGLocalizedString(@"yellowSel", nil)];
	else if (colorOfLight == 4) [violetButton setString:LGLocalizedString(@"violetSel", nil)];
	else if (colorOfLight == 5) [orangeButton setString:LGLocalizedString(@"orangeSel", nil)];
    
    if (difficulty == 1) [easyButton setString:LGLocalizedString(@"easySel", nil)];
	else if (difficulty == 2) [normalButton setString:LGLocalizedString(@"normalSel", nil)];
	else if (difficulty == 3) [hardButton setString:LGLocalizedString(@"hardSel", nil)];
	else if (difficulty == 4) [insaneButton setString:LGLocalizedString(@"insaneSel", nil)];
    
    if (gameMode == 1) [onePlayer setString:LGLocalizedString(@"1PlayerSel", nil)];
	else if (gameMode == 2) [twoPlayers setString:LGLocalizedString(@"2PlayersSel", nil)];
    
	if ([LGLocalizationGetPreferredLanguage isEqualToString: @"ru"]) [russianButton setString:LGLocalizedString(@"russianSel", nil)];
    else [englishButton setString:LGLocalizedString(@"englishSel", nil)];
    
    if (soundIsOn == YES) [soundOn setString:LGLocalizedString(@"soundOnSel", nil)];
	if (soundIsOn == NO) [soundOff setString:LGLocalizedString(@"soundOffSel", nil)];
    
    [bestScoreValue setString:[NSString stringWithFormat:@"%.3f", bestScoreReturned]];
    [lastScoreValue setString:[NSString stringWithFormat:@"%.3f", lastScoreReturned]];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) logoBeat
{
    id a1 = [CCScaleTo actionWithDuration:0.05 scale:logo.scale+0.015];
    id a2 = [CCScaleTo actionWithDuration:0.1 scale:logo.scale-0.03];
    id a3 = [CCScaleTo actionWithDuration:0.1 scale:logo.scale+0.015];
    id a4 = [CCScaleTo actionWithDuration:0.05 scale:logo.scale];
    [logo runAction:[CCSequence actions:a1, a2, a3, a4, nil]];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) unselectedColor
{
	[blueButton setString:LGLocalizedString(@"blueUnsel", nil)];
	[greenButton setString:LGLocalizedString(@"greenUnsel", nil)];
	[yellowButton setString:LGLocalizedString(@"yellowUnsel", nil)];
	[violetButton setString:LGLocalizedString(@"violetUnsel", nil)];
	[orangeButton setString:LGLocalizedString(@"orangeUnsel", nil)];
}

- (void) unselectedDifficulty
{
	[easyButton setString:LGLocalizedString(@"easyUnsel", nil)];
	[normalButton setString:LGLocalizedString(@"normalUnsel", nil)];
	[hardButton setString:LGLocalizedString(@"hardUnsel", nil)];
	[insaneButton setString:LGLocalizedString(@"insaneUnsel", nil)];
}

- (void) unselectedGameMode
{
	[onePlayer setString:LGLocalizedString(@"1PlayerUnsel", nil)];
	[twoPlayers setString:LGLocalizedString(@"2PlayersUnsel", nil)];
}

- (void) unselectedLanguage
{
    [englishButton setString:LGLocalizedString(@"englishUnsel", nil)];
	[russianButton setString:LGLocalizedString(@"russianUnsel", nil)];
}

- (void) unselectedSound
{
    [soundOn setString:LGLocalizedString(@"soundOnUnsel", nil)];
	[soundOff setString:LGLocalizedString(@"soundOffUnsel", nil)];
}

//////////////////////////////////////////////////////////////////////////////////////////////////// iPhone //////////

- (void) checkAdsRemoved
{
    if (!kIsGameFull)
    {
        iAdBanner = [CCSprite spriteWithFile:@"adsBannerP.png"];
        iAdBanner.position = ccp(winSize.width/2, winSize.height-iAdBanner.contentSize.height/2);
        [self addChild:iAdBanner z:10];
        
        winSize.height = winSize.height - iAdBanner.contentSize.height;
    }
    
    playButton.position = playPos = ccp(winSize.width*0.5, winSize.height*0.45);
    highscoresButton.position = highscoresPos = ccp(winSize.width*0.5, winSize.height*0.23);
    optionsButton.position = optionsPos = ccp(winSize.width*0.25, winSize.height*0.27);
    gamecenterButton.position = gamecenterPos = ccp(winSize.width*0.75, winSize.height*0.27);
    helpButton.position = helpPos = ccp(winSize.width*0.86, winSize.height*0.41);
    purchasesButton.position = purchasesPos = ccp(winSize.width*0.14, winSize.height*0.41);
    newsButton.position = newsPos = ccp(winSize.width*0.14, winSize.height*0.56);
}

- (void) menuItems
{
    [self checkAdsRemoved];
    
	int buttonsBgFontSize;
    int playButtonBgFontSize;
    int closeButtonFontSize;
    int closeButtonBgFontSize;
    int buttonsTextFontSize;
    int playButtonTextFontSize;
    int aboutButtonFontSize;
    
    if (kDevicePhone)
    {
        buttonsBgFontSize = 44;
        playButtonBgFontSize = 85;
        closeButtonFontSize = 20;
        closeButtonBgFontSize = 25;
        buttonsTextFontSize = 9;
        playButtonTextFontSize = 22;
        aboutButtonFontSize = 37;
        titleFontSize = 26;
        textsFontSize = 22;
        if (kIsGameFull || height(kNavController) == 568) aboutFontSize = 16;
        else aboutFontSize = 15;
        textButtonsFontSize = 17;
        textBorderSize = 20;
    }
    else
    {
        buttonsBgFontSize = 88;
        playButtonBgFontSize = 170;
        closeButtonFontSize = 40;
        closeButtonBgFontSize = 50;
        buttonsTextFontSize = 20;
        playButtonTextFontSize = 44;
        aboutButtonFontSize = 74;
        titleFontSize = 50;
        textsFontSize = 40;
        aboutFontSize = 30;
        textButtonsFontSize = 30;
        textBorderSize = 40;
    }
    
    NSString *buttonsBg = kCircleBgString;
    NSString *buttonsStroke = kCircleStrokeString;
    
    CCTexture2D *playButtonT2D = [[CCTextureCache sharedTextureCache] addImage:@"playButton.png"];
    CCTexture2D *highscoresButtonT2D = [[CCTextureCache sharedTextureCache] addImage:@"highscoresButton.png"];
    CCTexture2D *gamecenterButtonT2D = [[CCTextureCache sharedTextureCache] addImage:@"gamecenterCircleButton.png"];
    CCTexture2D *optionsButtonT2D = [[CCTextureCache sharedTextureCache] addImage:@"optionsButton.png"];
    moreGamesT2D[0] = [[CCTextureCache sharedTextureCache] addImage:LGLocalizedString(@"moreGamesButton", nil)];
    moreGamesT2D[1] = [[CCTextureCache sharedTextureCache] addImage:LGLocalizedString(@"moreGamesButtonTapped", nil)];
    
    light = ccc3(230, 230, 230);
    dark = ccc3(50, 50, 50);
    
	bg = [CCSprite spriteWithFile:@"bg.png"];
	bg.position = ccp(width(kNavController)/2, height(kNavController)/2);
	[self addChild:bg z:-2];
    
    bgSecond = [CCSprite spriteWithFile:@"bgSecond.png"];
    bgSecond.position = ccp(width(kNavController)/2, height(kNavController)/2);
    bgSecond.color = ccc3(50, 50, 50);
    bgSecond.opacity = 0;
    bgSecond.anchorPoint = ccp(0.5, 0.5);
    [self addChild:bgSecond z:2];
    
    logo = [CCSprite spriteWithFile:@"logo.png"];
    logo.position = logoPos = ccp(winSize.width/2, winSize.height-logo.contentSize.height/2);
	logo.opacity = 0;
	[self addChild:logo z:0];
    
    closeButton = [CCLabelTTF labelWithString:@"✕" fontName:@"Arial" fontSize:closeButtonFontSize]; ///// close
    [self addChild:closeButton z:4];
    closeButtonStroke = [CCLabelTTF labelWithString:buttonsStroke fontName:kFontOsakaMono fontSize:closeButtonBgFontSize];
    [self addChild:closeButtonStroke z:4];
    
    [self setPropertiesForButton:closeButton
                        buttonBg:nil
                    buttonStroke:closeButtonStroke
                      buttonText:nil
                        position:ccp(winSize.width-closeButton.contentSize.width*1.2, winSize.height-closeButton.contentSize.height*0.8)
                           color:light];
    
    playButton = [CCSprite spriteWithTexture:playButtonT2D]; ///// play
    [self addChild:playButton z:2];
    playButtonBg = [CCLabelTTF labelWithString:buttonsBg fontName:kFontOsakaMono fontSize:playButtonBgFontSize];
    [self addChild:playButtonBg z:1];
    playButtonStroke = [CCLabelTTF labelWithString:buttonsStroke fontName:kFontOsakaMono fontSize:playButtonBgFontSize];
    [self addChild:playButtonStroke z:2];
    playButtonText = [CCLabelTTF labelWithString:LGLocalizedString(@"playButtonUnsel", nil) fontName:kFontComicSans fontSize:playButtonTextFontSize];
    [self addChild:playButtonText z:1];
    
    [self setPropertiesForButton:playButton
                        buttonBg:playButtonBg
                    buttonStroke:playButtonStroke
                      buttonText:playButtonText
                        position:playPos
                           color:dark];
    
    helpButton = [CCLabelTTF labelWithString:@"?" fontName:kFontPlaytime fontSize:aboutButtonFontSize]; ///// help
    [self addChild:helpButton z:2];
    helpButtonBg = [CCLabelTTF labelWithString:buttonsBg fontName:kFontOsakaMono fontSize:buttonsBgFontSize];
    [self addChild:helpButtonBg z:1];
    helpButtonStroke = [CCLabelTTF labelWithString:buttonsStroke fontName:kFontOsakaMono fontSize:buttonsBgFontSize];
    [self addChild:helpButtonStroke z:2];
    helpButtonText = [CCLabelTTF labelWithString:LGLocalizedString(@"helpButtonUnsel", nil) fontName:kFontComicSans fontSize:buttonsTextFontSize];
    [self addChild:helpButtonText z:1];
    
    [self setPropertiesForButton:helpButton
                        buttonBg:helpButtonBg
                    buttonStroke:helpButtonStroke
                      buttonText:helpButtonText
                        position:helpPos
                           color:dark];
    
    newsButton = [CCLabelTTF labelWithString:@"!" fontName:kFontPlaytime fontSize:aboutButtonFontSize]; ///// news
    [self addChild:newsButton z:2];
    newsButtonBg = [CCLabelTTF labelWithString:buttonsBg fontName:kFontOsakaMono fontSize:buttonsBgFontSize];
    [self addChild:newsButtonBg z:1];
    newsButtonStroke = [CCLabelTTF labelWithString:buttonsStroke fontName:kFontOsakaMono fontSize:buttonsBgFontSize];
    [self addChild:newsButtonStroke z:2];
    newsButtonText = [CCLabelTTF labelWithString:LGLocalizedString(@"newsButtonUnsel", nil) fontName:kFontComicSans fontSize:buttonsTextFontSize];
    [self addChild:newsButtonText z:1];
    
    [self setPropertiesForButton:newsButton
                        buttonBg:newsButtonBg
                    buttonStroke:newsButtonStroke
                      buttonText:newsButtonText
                        position:newsPos
                           color:dark];
    
    purchasesButton = [CCLabelTTF labelWithString:@"$" fontName:kFontPlaytime fontSize:aboutButtonFontSize]; ///// purchases
    [self addChild:purchasesButton z:2];
    purchasesButtonBg = [CCLabelTTF labelWithString:buttonsBg fontName:kFontOsakaMono fontSize:buttonsBgFontSize];
    [self addChild:purchasesButtonBg z:1];
    purchasesButtonStroke = [CCLabelTTF labelWithString:buttonsStroke fontName:kFontOsakaMono fontSize:buttonsBgFontSize];
    [self addChild:purchasesButtonStroke z:2];
    purchasesButtonText = [CCLabelTTF labelWithString:LGLocalizedString(@"purchasesButtonUnsel", nil) fontName:kFontComicSans fontSize:buttonsTextFontSize];
    [self addChild:purchasesButtonText z:1];
    
    [self setPropertiesForButton:purchasesButton
                        buttonBg:purchasesButtonBg
                    buttonStroke:purchasesButtonStroke
                      buttonText:purchasesButtonText
                        position:purchasesPos
                           color:dark];
    
    highscoresButton = [CCSprite spriteWithTexture:highscoresButtonT2D]; ///// highscores
    [self addChild:highscoresButton z:2];
    highscoresButtonBg = [CCLabelTTF labelWithString:buttonsBg fontName:kFontOsakaMono fontSize:buttonsBgFontSize];
    [self addChild:highscoresButtonBg z:1];
    highscoresButtonStroke = [CCLabelTTF labelWithString:buttonsStroke fontName:kFontOsakaMono fontSize:buttonsBgFontSize];
    [self addChild:highscoresButtonStroke z:2];
    highscoresButtonText = [CCLabelTTF labelWithString:LGLocalizedString(@"highscoresButtonUnsel", nil) fontName:kFontComicSans fontSize:buttonsTextFontSize];
    [self addChild:highscoresButtonText z:1];
    
    [self setPropertiesForButton:highscoresButton
                        buttonBg:highscoresButtonBg
                    buttonStroke:highscoresButtonStroke
                      buttonText:highscoresButtonText
                        position:highscoresPos
                           color:dark];
    
    gamecenterButton = [CCSprite spriteWithTexture:gamecenterButtonT2D]; ///// gamecenter
    [self addChild:gamecenterButton z:2];
    gamecenterButtonBg = [CCLabelTTF labelWithString:buttonsBg fontName:kFontOsakaMono fontSize:buttonsBgFontSize];
    [self addChild:gamecenterButtonBg z:1];
    gamecenterButtonStroke = [CCLabelTTF labelWithString:buttonsStroke fontName:kFontOsakaMono fontSize:buttonsBgFontSize];
    [self addChild:gamecenterButtonStroke z:2];
    gamecenterButtonText = [CCLabelTTF labelWithString:LGLocalizedString(@"gamecenterButtonUnsel", nil) fontName:kFontComicSans fontSize:buttonsTextFontSize];
    [self addChild:gamecenterButtonText z:1];
    
    [self setPropertiesForButton:gamecenterButton
                        buttonBg:gamecenterButtonBg
                    buttonStroke:gamecenterButtonStroke
                      buttonText:gamecenterButtonText
                        position:gamecenterPos
                           color:dark];
    
    optionsButton = [CCSprite spriteWithTexture:optionsButtonT2D]; ///// options
    [self addChild:optionsButton z:2];
    optionsButtonBg = [CCLabelTTF labelWithString:buttonsBg fontName:kFontOsakaMono fontSize:buttonsBgFontSize];
    [self addChild:optionsButtonBg z:1];
    optionsButtonStroke = [CCLabelTTF labelWithString:buttonsStroke fontName:kFontOsakaMono fontSize:buttonsBgFontSize];
    [self addChild:optionsButtonStroke z:2];
    optionsButtonText = [CCLabelTTF labelWithString:LGLocalizedString(@"optionsButtonUnsel", nil) fontName:kFontComicSans fontSize:buttonsTextFontSize];
    [self addChild:optionsButtonText z:1];
    
    [self setPropertiesForButton:optionsButton
                        buttonBg:optionsButtonBg
                    buttonStroke:optionsButtonStroke
                      buttonText:optionsButtonText
                        position:optionsPos
                           color:dark];
    
    moreGamesButton = [CCSprite spriteWithTexture:moreGamesT2D[0]];
    moreGamesButton.position = ccp(winSize.width/2, moreGamesButton.contentSize.height/2);
    moreGamesButton.opacity = 0;
    [self addChild:moreGamesButton z:1];
    
    copyrightButton = [CCLabelTTF labelWithString:@"©" fontName:kFontArial fontSize:closeButtonFontSize*1.1]; ///// copyright
    copyrightButton.position = closeButton.position;
    copyrightButton.color = dark;
    copyrightButton.opacity = 0;
    [self addChild:copyrightButton z:-1];
    
    [self schedule:@selector(logoBeat) interval:3];
    [self helpLayer];
    [self optionsLayer];
    [self newsLayer];
    [self purchasesLayer];
    [self moreGamesLayer];
	[self texts];
    [self checkSettings];
	[self allSpritesAppear];
    
    AppController *app = kAppController;
    
    if (!kIsHelpShowed)
    {
        [kStandartUserDefaults setBool:YES forKey:@"isHelpShowed"];
        
        helpOnScreen = 1;
        bgSecondOnScreen = 1;
        
        [self bgSecondAppear];
        [self helpLayerAppear];
        
        app.helpShownCheck = 1;
    }
    else if (!kIsNewsShowed && !app.helpShownCheck)
    {
        [kStandartUserDefaults setBool:YES forKey:@"isNewsShowed"];
        
        newsOnScreen = 1;
        bgSecondOnScreen = 1;
        
        [self bgSecondAppear];
        [self newsLayerAppear];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) setPropertiesForButton:(CCSprite *)button
                       buttonBg:(CCLabelTTF *)buttonBg
                   buttonStroke:(CCLabelTTF *)buttonStroke
                     buttonText:(CCLabelTTF *)buttonText
                       position:(CGPoint)position
                          color:(ccColor3B)color
{
    if (button == newsButton)
        button.position = ccp(position.x, position.y-button.contentSize.height*0.03);
    else if (button == helpButton)
        button.position = ccp(position.x+button.contentSize.width*0.06, position.y-button.contentSize.height*0.03);
    else if (button == purchasesButton)
        button.position = ccp(position.x-button.contentSize.width*0.02, position.y-button.contentSize.height*0.05);
    else if (button == donate1)
        button.position = ccp(position.x-button.contentSize.width*0.08, position.y-button.contentSize.height*0.04);
    else if (button == donate3)
        button.position = ccp(position.x-button.contentSize.width*0.03, position.y-button.contentSize.height*0.04);
    else if (button == donate5)
        button.position = ccp(position.x-button.contentSize.width*0.03, position.y-button.contentSize.height*0.04);
    else if (button == donate10)
        button.position = ccp(position.x-button.contentSize.width*0.03, position.y-button.contentSize.height*0.04);
    else if (button == donate25)
        button.position = ccp(position.x-button.contentSize.width*0.025, position.y-button.contentSize.height*0.04);
    else
        button.position = position;
    button.color = color;
	button.opacity = 0;
    
    buttonBg.position = ccp(position.x, position.y-buttonBg.contentSize.height*0.02);
    if (buttonBg == purchasesButtonBg) buttonBg.color = ccc3(0, 230, 0);
    else buttonBg.color = color;
    buttonBg.opacity = 0;
    
    buttonStroke.position = ccp(position.x, position.y-buttonBg.contentSize.height*0.02);
    buttonStroke.color = color;
    buttonStroke.opacity = 0;
    
    if (buttonText == playButtonText) buttonText.position = ccp(position.x, position.y-buttonBg.contentSize.height*0.25-buttonText.contentSize.height*0.9);
    else buttonText.position = ccp(position.x, position.y-buttonBg.contentSize.height*0.25-buttonText.contentSize.height*1.2);
    buttonText.color = color;
    buttonText.opacity = 0;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) helpLayer
{
    helpTitle = [CCLabelTTF labelWithString:LGLocalizedString(@"helpTitle", nil) fontName:kFontComicSans fontSize:titleFontSize];
    helpTitle.position = ccp(winSize.width/2, winSize.height-helpTitle.contentSize.height);
	helpTitle.color = ccc3(230,230,230);
    helpTitle.opacity = 0;
	[self addChild:helpTitle z:3];
    
    helpAbout = [CCLabelTTF labelWithString:LGLocalizedString(@"helpAbout", nil)
                                   fontName:kFontComicSans
                                   fontSize:aboutFontSize
                                 dimensions:CGSizeMake(winSize.width-textBorderSize, winSize.height)
                                 hAlignment:kCCTextAlignmentLeft];
	helpAbout.position = ccp(winSize.width*0.51, helpTitle.position.y-helpTitle.contentSize.height);
    helpAbout.color = ccc3(230,230,230);
    helpAbout.opacity = 0;
    helpAbout.anchorPoint = ccp(0.5, 1);
	[self addChild:helpAbout z:3];
}

- (void) optionsLayer
{
    optionsTitle = [CCLabelTTF labelWithString:LGLocalizedString(@"optionsTitle", nil) fontName:kFontComicSans fontSize:titleFontSize];
    optionsTitle.position = ccp(winSize.width/2, winSize.height-optionsTitle.contentSize.height);
	optionsTitle.color = ccc3(230,230,230);
    optionsTitle.opacity = 0;
	[self addChild:optionsTitle z:3];
    
	selectColorOfLight = [CCLabelTTF labelWithString:LGLocalizedString(@"selectColorOfLight", nil) fontName:kFontComicSans fontSize:textButtonsFontSize];
	selectColorOfLight.color = ccc3(230,230,230);
	if (kDevicePhone) selectColorOfLight.position = ccp(winSize.width*0.04, optionsTitle.position.y-optionsTitle.contentSize.height-selectColorOfLight.contentSize.height/4);
    else selectColorOfLight.position = ccp(winSize.width*0.15, optionsTitle.position.y-optionsTitle.contentSize.height-selectColorOfLight.contentSize.height/4);
    selectColorOfLight.opacity = 0;
    selectColorOfLight.anchorPoint = ccp(0, 0.5);
	[self addChild:selectColorOfLight z:3];
	
	blueButton = [CCLabelTTF labelWithString:LGLocalizedString(@"blueUnsel", nil) fontName:kFontComicSans fontSize:textButtonsFontSize];
	blueButton.color = kColorBlue;
	blueButton.position = ccp(selectColorOfLight.position.x, selectColorOfLight.position.y-blueButton.contentSize.height);
    blueButton.opacity = 0;
    blueButton.anchorPoint = ccp(0, 0.5);
	[self addChild:blueButton z:3];
	
	greenButton = [CCLabelTTF labelWithString:LGLocalizedString(@"greenUnsel", nil) fontName:kFontComicSans fontSize:textButtonsFontSize];
	greenButton.color = kColorGreen;
	greenButton.position = ccp(selectColorOfLight.position.x, blueButton.position.y-greenButton.contentSize.height);
    greenButton.opacity = 0;
    greenButton.anchorPoint = ccp(0, 0.5);
	[self addChild:greenButton z:3];
	
	yellowButton = [CCLabelTTF labelWithString:LGLocalizedString(@"yellowUnsel", nil) fontName:kFontComicSans fontSize:textButtonsFontSize];
	yellowButton.color = kColorYellow;
	yellowButton.position = ccp(selectColorOfLight.position.x, greenButton.position.y-yellowButton.contentSize.height);
    yellowButton.opacity = 0;
    yellowButton.anchorPoint = ccp(0, 0.5);
	[self addChild:yellowButton z:3];
	
	violetButton = [CCLabelTTF labelWithString:LGLocalizedString(@"violetUnsel", nil) fontName:kFontComicSans fontSize:textButtonsFontSize];
	violetButton.color = kColorViolet;
	violetButton.position = ccp(selectColorOfLight.position.x, yellowButton.position.y-violetButton.contentSize.height);
    violetButton.opacity = 0;
    violetButton.anchorPoint = ccp(0, 0.5);
	[self addChild:violetButton z:3];
	
	orangeButton = [CCLabelTTF labelWithString:LGLocalizedString(@"orangeUnsel", nil) fontName:kFontComicSans fontSize:textButtonsFontSize];
	orangeButton.color = kColorOrange;
	orangeButton.position = ccp(selectColorOfLight.position.x, violetButton.position.y-orangeButton.contentSize.height);
    orangeButton.opacity = 0;
    orangeButton.anchorPoint = ccp(0, 0.5);
	[self addChild:orangeButton z:3];
    
    selectDifficulty = [CCLabelTTF labelWithString:LGLocalizedString(@"selectDifficulty", nil) fontName:kFontComicSans fontSize:textButtonsFontSize];
    selectDifficulty.position = selectDifficultyPos;
	selectDifficulty.color = ccc3(230,230,230);
    selectDifficulty.opacity = 0;
    selectDifficulty.anchorPoint = ccp(0, 0.5);
	[self addChild:selectDifficulty z:3];
    
    if (kIsGameFull || kDevicePad || height(kNavController) == 568)
        selectDifficulty.position = selectDifficultyPos = ccp(selectColorOfLight.position.x, orangeButton.position.y-selectDifficulty.contentSize.height*1.5);
    else selectDifficulty.position = selectDifficultyPos = ccp(selectColorOfLight.position.x, orangeButton.position.y-selectDifficulty.contentSize.height);
	
	easyButton = [CCLabelTTF labelWithString:LGLocalizedString(@"easyUnsel", nil) fontName:kFontComicSans fontSize:textButtonsFontSize];
	easyButton.color = ccc3(230,230,230);
	easyButton.position = ccp(selectColorOfLight.position.x, selectDifficulty.position.y-easyButton.contentSize.height);
    easyButton.opacity = 0;
    easyButton.anchorPoint = ccp(0, 0.5);
	[self addChild:easyButton z:3];
	
	normalButton = [CCLabelTTF labelWithString:LGLocalizedString(@"normalUnsel", nil) fontName:kFontComicSans fontSize:textButtonsFontSize];
	normalButton.color = ccc3(230,230,230);
	normalButton.position = ccp(selectColorOfLight.position.x, easyButton.position.y-normalButton.contentSize.height);
    normalButton.opacity = 0;
    normalButton.anchorPoint = ccp(0, 0.5);
	[self addChild:normalButton z:3];
	
	hardButton = [CCLabelTTF labelWithString:LGLocalizedString(@"hardUnsel", nil) fontName:kFontComicSans fontSize:textButtonsFontSize];
	hardButton.color = ccc3(230,230,230);
	hardButton.position = ccp(selectColorOfLight.position.x, normalButton.position.y-hardButton.contentSize.height);
    hardButton.opacity = 0;
    hardButton.anchorPoint = ccp(0, 0.5);
	[self addChild:hardButton z:3];
	
	insaneButton = [CCLabelTTF labelWithString:LGLocalizedString(@"insaneUnsel", nil) fontName:kFontComicSans fontSize:textButtonsFontSize];
	insaneButton.color = ccc3(230,230,230);
	insaneButton.position = ccp(selectColorOfLight.position.x, hardButton.position.y-insaneButton.contentSize.height);
    insaneButton.opacity = 0;
    insaneButton.anchorPoint = ccp(0, 0.5);
	[self addChild:insaneButton z:3];
    
    selectGameMode = [CCLabelTTF labelWithString:LGLocalizedString(@"selectGameMode", nil) fontName:kFontComicSans fontSize:textButtonsFontSize];
    selectGameMode.position = selectGameModePos;
	selectGameMode.color = ccc3(230,230,230);
    selectGameMode.opacity = 0;
    selectGameMode.anchorPoint = ccp(0, 0.5);
	[self addChild:selectGameMode z:3];
    
    if (kIsGameFull || kDevicePad || height(kNavController) == 568)
        selectGameMode.position = selectGameModePos = ccp(selectColorOfLight.position.x, insaneButton.position.y-selectGameMode.contentSize.height*1.5);
    else selectGameMode.position = selectGameModePos = ccp(selectColorOfLight.position.x, insaneButton.position.y-selectGameMode.contentSize.height);
	
	onePlayer = [CCLabelTTF labelWithString:LGLocalizedString(@"1PlayerUnsel", nil) fontName:kFontComicSans fontSize:textButtonsFontSize];
	onePlayer.color = ccc3(230,230,230);
	onePlayer.position = ccp(selectColorOfLight.position.x, selectGameMode.position.y-onePlayer.contentSize.height);
    onePlayer.opacity = 0;
    onePlayer.anchorPoint = ccp(0, 0.5);
	[self addChild:onePlayer z:3];
	
	twoPlayers = [CCLabelTTF labelWithString:LGLocalizedString(@"2PlayersUnsel", nil) fontName:kFontComicSans fontSize:textButtonsFontSize];
	twoPlayers.color = ccc3(230,230,230);
	twoPlayers.position = ccp(selectColorOfLight.position.x, onePlayer.position.y-twoPlayers.contentSize.height);
    twoPlayers.opacity = 0;
    twoPlayers.anchorPoint = ccp(0, 0.5);
	[self addChild:twoPlayers z:3];
    
    selectLanguage = [CCLabelTTF labelWithString:LGLocalizedString(@"selectLanguage", nil) fontName:kFontComicSans fontSize:textButtonsFontSize];
	selectLanguage.color = ccc3(230,230,230);
	if (kDevicePhone) selectLanguage.position = ccp(winSize.width*0.51, selectColorOfLight.position.y);
    else selectLanguage.position = ccp(winSize.width*0.6, selectColorOfLight.position.y);
    selectLanguage.opacity = 0;
    selectLanguage.anchorPoint = ccp(0, 0.5);
	[self addChild:selectLanguage z:3];
    
    englishButton = [CCLabelTTF labelWithString:LGLocalizedString(@"englishUnsel", nil) fontName:kFontComicSans fontSize:textButtonsFontSize];
	englishButton.color = ccc3(230,230,230);
	englishButton.position = ccp(selectLanguage.position.x, selectLanguage.position.y-englishButton.contentSize.height);
    englishButton.opacity = 0;
    englishButton.anchorPoint = ccp(0, 0.5);
	[self addChild:englishButton z:3];
    
    russianButton = [CCLabelTTF labelWithString:LGLocalizedString(@"russianUnsel", nil) fontName:kFontComicSans fontSize:textButtonsFontSize];
	russianButton.color = ccc3(230,230,230);
	russianButton.position = ccp(selectLanguage.position.x, englishButton.position.y-russianButton.contentSize.height);
    russianButton.opacity = 0;
    russianButton.anchorPoint = ccp(0, 0.5);
	[self addChild:russianButton z:3];
    
    selectSound = [CCLabelTTF labelWithString:LGLocalizedString(@"selectSound", nil) fontName:kFontComicSans fontSize:textButtonsFontSize];
	selectSound.color = ccc3(230,230,230);
	selectSound.position = ccp(selectLanguage.position.x, russianButton.position.y-russianButton.contentSize.height*2);
    selectSound.opacity = 0;
    selectSound.anchorPoint = ccp(0, 0.5);
	[self addChild:selectSound z:3];
    
    soundOn= [CCLabelTTF labelWithString:LGLocalizedString(@"soundOnUnsel", nil) fontName:kFontComicSans fontSize:textButtonsFontSize];
	soundOn.color = ccc3(230,230,230);
	soundOn.position = ccp(selectSound.position.x, selectSound.position.y-russianButton.contentSize.height);
    soundOn.opacity = 0;
    soundOn.anchorPoint = ccp(0, 0.5);
	[self addChild:soundOn z:3];
    
    soundOff = [CCLabelTTF labelWithString:LGLocalizedString(@"soundOffUnsel", nil) fontName:kFontComicSans fontSize:textButtonsFontSize];
	soundOff.color = ccc3(230,230,230);
	soundOff.position = ccp(selectSound.position.x, soundOn.position.y-russianButton.contentSize.height);
    soundOff.opacity = 0;
    soundOff.anchorPoint = ccp(0, 0.5);
	[self addChild:soundOff z:3];
    
    followUs = [CCLabelTTF labelWithString:LGLocalizedString(@"followUs", nil) fontName:kFontComicSans fontSize:textButtonsFontSize];
	followUs.color = ccc3(230,230,230);
	followUs.position = ccp(selectLanguage.position.x, soundOff.position.y-soundOff.contentSize.height*2);
    followUs.opacity = 0;
    followUs.anchorPoint = ccp(0, 0.5);
	[self addChild:followUs z:3];
    
    facebook= [CCLabelTTF labelWithString:LGLocalizedString(@"facebookUnsel", nil) fontName:kFontComicSans fontSize:textButtonsFontSize];
	facebook.color = ccc3(230,230,230);
	facebook.position = ccp(followUs.position.x, followUs.position.y-russianButton.contentSize.height);
    facebook.opacity = 0;
    facebook.anchorPoint = ccp(0, 0.5);
	[self addChild:facebook z:3];
    
    twitter = [CCLabelTTF labelWithString:LGLocalizedString(@"twitterUnsel", nil) fontName:kFontComicSans fontSize:textButtonsFontSize];
	twitter.color = ccc3(230,230,230);
	twitter.position = ccp(followUs.position.x, facebook.position.y-russianButton.contentSize.height);
    twitter.opacity = 0;
    twitter.anchorPoint = ccp(0, 0.5);
	[self addChild:twitter z:3];
    
    vkontakte = [CCLabelTTF labelWithString:LGLocalizedString(@"vkontakteUnsel", nil) fontName:kFontComicSans fontSize:textButtonsFontSize];
	vkontakte.color = ccc3(230,230,230);
	vkontakte.position = ccp(followUs.position.x, twitter.position.y-russianButton.contentSize.height);
    vkontakte.opacity = 0;
    vkontakte.anchorPoint = ccp(0, 0.5);
	[self addChild:vkontakte z:3];
}

- (void) newsLayer
{
    newsTitle = [CCLabelTTF labelWithString:LGLocalizedString(@"newsTitle", nil) fontName:kFontComicSans fontSize:titleFontSize];
    newsTitle.position = ccp(winSize.width/2, winSize.height-newsTitle.contentSize.height);
	newsTitle.color = ccc3(230,230,230);
    newsTitle.opacity = 0;
	[self addChild:newsTitle z:3];
    
    newsAbout = [CCLabelTTF labelWithString:LGLocalizedString(@"newsAbout", nil)
                                   fontName:kFontComicSans
                                   fontSize:aboutFontSize
                                 dimensions:CGSizeMake(winSize.width-textBorderSize,winSize.height)
                                 hAlignment:kCCTextAlignmentLeft];
	newsAbout.position = ccp(winSize.width*0.51, newsTitle.position.y-newsTitle.contentSize.height);
    newsAbout.color = ccc3(230,230,230);
    newsAbout.opacity = 0;
    newsAbout.anchorPoint = ccp(0.5, 1);
	[self addChild:newsAbout z:3];
}

- (void) purchasesLayer
{
    int donateFontSize;
    int donateBgFontSize;
    int donate10FontSize;
    
    if (kDevicePhone)
    {
        donateFontSize = 35;
        donate10FontSize = 25;
        donateBgFontSize = 55;
    }
    else
    {
        donateFontSize = 70;
        donate10FontSize = 53;
        donateBgFontSize = 110;
    }
    
    NSString *buttonsBg = kCircleBgString;
    NSString *buttonsStroke = kCircleStrokeString;
    
    purchasesTitle = [CCLabelTTF labelWithString:LGLocalizedString(@"purchasesTitle", nil) fontName:kFontComicSans fontSize:titleFontSize];
    purchasesTitle.position = ccp(winSize.width/2, winSize.height-purchasesTitle.contentSize.height);
	purchasesTitle.color = ccc3(230,230,230);
    purchasesTitle.opacity = 0;
	[self addChild:purchasesTitle z:3];
    
    removeAdsText = [CCLabelTTF labelWithString:LGLocalizedString(@"removeAdsText", nil) fontName:kFontComicSans fontSize:textButtonsFontSize];
    removeAdsText.position = ccp(winSize.width/2, purchasesTitle.position.y-purchasesTitle.contentSize.height-removeAdsText.contentSize.height/4);
	removeAdsText.color = ccc3(230,230,230);
    removeAdsText.opacity = 0;
	[self addChild:removeAdsText z:3];
    
    if (kIsGameFull == YES)
    {
        removeAdsStatus = [CCLabelTTF labelWithString:LGLocalizedString(@"removeAdsYes", nil) fontName:kFontComicSans fontSize:textButtonsFontSize];
        removeAdsStatus.color = ccc3(0, 230, 0);
    }
    else
    {
        removeAdsStatus = [CCLabelTTF labelWithString:LGLocalizedString(@"removeAdsNo", nil) fontName:kFontComicSans fontSize:textButtonsFontSize];
        removeAdsStatus.color = ccc3(230, 230, 230);
    }
    removeAdsStatus.position = ccp(winSize.width/2, removeAdsText.position.y-removeAdsStatus.contentSize.height);
    removeAdsStatus.opacity = 0;
    [self addChild:removeAdsStatus z:3];
    
    restoreText = [CCLabelTTF labelWithString:LGLocalizedString(@"restoreText", nil) fontName:kFontComicSans fontSize:textButtonsFontSize];
    restoreText.position = ccp(winSize.width/2, removeAdsStatus.position.y-restoreText.contentSize.height);
	restoreText.color = ccc3(230,230,230);
    restoreText.opacity = 0;
	[self addChild:restoreText z:3];
    
    donateTitle = [CCLabelTTF labelWithString:LGLocalizedString(@"donateTitle", nil) fontName:kFontComicSans fontSize:titleFontSize];
	donateTitle.position = ccp(winSize.width/2, winSize.height*0.5);
	donateTitle.color = ccc3(230,230,230);
    donateTitle.opacity = 0;
	[self addChild:donateTitle z:3];
    
    donate1 = [CCLabelTTF labelWithString:@"$1" fontName:kFontPlaytime fontSize:donateFontSize]; ///// donate1
    [self addChild:donate1 z:3];
    donate1Bg = [CCLabelTTF labelWithString:buttonsBg fontName:kFontOsakaMono fontSize:donateBgFontSize];
    [self addChild:donate1Bg z:3];
    donate1Stroke = [CCLabelTTF labelWithString:buttonsStroke fontName:kFontOsakaMono fontSize:donateBgFontSize];
    [self addChild:donate1Stroke z:4];
    
    [self setPropertiesForButton:donate1
                        buttonBg:donate1Bg
                    buttonStroke:donate1Stroke
                      buttonText:nil
                        position:ccp(winSize.width*0.24, donateTitle.position.y-donateTitle.contentSize.height-donate1Bg.contentSize.height*0.4)
                           color:light];
    
    donate3 = [CCLabelTTF labelWithString:@"$3" fontName:kFontPlaytime fontSize:donateFontSize]; ///// donate3
    [self addChild:donate3 z:3];
    donate3Bg = [CCLabelTTF labelWithString:buttonsBg fontName:kFontOsakaMono fontSize:donateBgFontSize];
    [self addChild:donate3Bg z:3];
    donate3Stroke = [CCLabelTTF labelWithString:buttonsStroke fontName:kFontOsakaMono fontSize:donateBgFontSize];
    [self addChild:donate3Stroke z:4];
    
    [self setPropertiesForButton:donate3
                        buttonBg:donate3Bg
                    buttonStroke:donate3Stroke
                      buttonText:nil
                        position:ccp(winSize.width*0.5, donate1.position.y)
                           color:light];
    
    donate5 = [CCLabelTTF labelWithString:@"$5" fontName:kFontPlaytime fontSize:donateFontSize]; ///// donate5
    [self addChild:donate5 z:3];
    donate5Bg = [CCLabelTTF labelWithString:buttonsBg fontName:kFontOsakaMono fontSize:donateBgFontSize];
    [self addChild:donate5Bg z:3];
    donate5Stroke = [CCLabelTTF labelWithString:buttonsStroke fontName:kFontOsakaMono fontSize:donateBgFontSize];
    [self addChild:donate5Stroke z:4];
    
    [self setPropertiesForButton:donate5
                        buttonBg:donate5Bg
                    buttonStroke:donate5Stroke
                      buttonText:nil
                        position:ccp(winSize.width*0.76, donate1.position.y)
                           color:light];
    
    donate10 = [CCLabelTTF labelWithString:@"$10" fontName:kFontPlaytime fontSize:donate10FontSize]; ///// donate10
    [self addChild:donate10 z:3];
    donate10Bg = [CCLabelTTF labelWithString:buttonsBg fontName:kFontOsakaMono fontSize:donateBgFontSize];
    [self addChild:donate10Bg z:3];
    donate10Stroke = [CCLabelTTF labelWithString:buttonsStroke fontName:kFontOsakaMono fontSize:donateBgFontSize];
    [self addChild:donate10Stroke z:4];
    
    [self setPropertiesForButton:donate10
                        buttonBg:donate10Bg
                    buttonStroke:donate10Stroke
                      buttonText:nil
                        position:ccp(winSize.width*0.37, donate1.position.y-donate10Bg.contentSize.height*0.8)
                           color:light];
    
    donate25 = [CCLabelTTF labelWithString:@"$25" fontName:kFontPlaytime fontSize:donate10FontSize]; ///// donate25
    [self addChild:donate25 z:3];
    donate25Bg = [CCLabelTTF labelWithString:buttonsBg fontName:kFontOsakaMono fontSize:donateBgFontSize];
    [self addChild:donate25Bg z:3];
    donate25Stroke = [CCLabelTTF labelWithString:buttonsStroke fontName:kFontOsakaMono fontSize:donateBgFontSize];
    [self addChild:donate25Stroke z:4];
    
    [self setPropertiesForButton:donate25
                        buttonBg:donate25Bg
                    buttonStroke:donate25Stroke
                      buttonText:nil
                        position:ccp(winSize.width*0.63, donate10.position.y)
                           color:light];
    
    internetAvailabilityStatus = [CCLabelTTF labelWithString:@"TEMP" fontName:kFontComicSans fontSize:textButtonsFontSize];
    internetAvailabilityStatus.position = ccp(winSize.width/2, internetAvailabilityStatus.contentSize.height*0.75);
    internetAvailabilityStatus.opacity = 0;
	[self addChild:internetAvailabilityStatus z:3];
    
    kLGReachability.label = internetAvailabilityStatus;
    
    internetAvailabilityTitle = [CCLabelTTF labelWithString:LGLocalizedString(@"internetAvailabilityTitle", nil) fontName:kFontComicSans fontSize:textButtonsFontSize];
    internetAvailabilityTitle.position = ccp(winSize.width/2, internetAvailabilityStatus.position.y+internetAvailabilityTitle.contentSize.height);
	internetAvailabilityTitle.color = light;
    internetAvailabilityTitle.opacity = 0;
	[self addChild:internetAvailabilityTitle z:3];
}

- (void) moreGamesLayer
{
    NSString *separatorString = @"_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _";
    
    int iconTextFontSize;
    if (kDevicePhone) iconTextFontSize = 18;
    else iconTextFontSize = 40;
    
	moreGamesTitle = [CCLabelTTF labelWithString:LGLocalizedString(@"moreGamesTitle", nil) fontName:kFontComicSans fontSize:titleFontSize];
    moreGamesTitle.position = ccp(winSize.width/2, winSize.height-moreGamesTitle.contentSize.height);
	moreGamesTitle.color = light;
    moreGamesTitle.opacity = 0;
	[self addChild:moreGamesTitle z:3];
    
    separatorL[0] = [CCLabelTTF labelWithString:separatorString fontName:kFontComicSans fontSize:iconTextFontSize];
    separatorL[0].position = ccp(winSize.width/2, moreGamesTitle.position.y-moreGamesTitle.contentSize.height-separatorL[0].contentSize.height/2);
    separatorL[0].color = light;
    separatorL[0].opacity = 0;
    separatorL[0].anchorPoint = ccp(0.5, 0);
    [self addChild:separatorL[0] z:3];
    
    iconCYCV = [CCSprite spriteWithFile:@"iconCYCV.png"];
    if (kDevicePhone) iconCYCV.scale = 0.8;
    iconCYCV.position = ccp(iconCYCV.contentSize.width*0.6*iconCYCV.scale, separatorL[0].position.y-separatorL[0].contentSize.height/4-iconCYCV.contentSize.height*0.5*iconCYCV.scale);
    iconCYCV.opacity = 0;
	[self addChild:iconCYCV z:3];
    
    iconCYCVName = [CCLabelTTF labelWithString:@"| Check Your ColorVision" fontName:kFontComicSans fontSize:iconTextFontSize];
    iconCYCVName.position = ccp(iconCYCV.position.x+iconCYCV.contentSize.width*0.58*iconCYCV.scale, iconCYCV.position.y+iconCYCV.contentSize.height*0.35*iconCYCV.scale);
    iconCYCVName.color = light;
    iconCYCVName.anchorPoint = ccp(0, 0.5);
    iconCYCVName.opacity = 0;
	[self addChild:iconCYCVName z:3];
    
    iconCYCVPrice = [CCLabelTTF labelWithString:LGLocalizedString(@"priceFree", nil) fontName:kFontComicSans fontSize:iconTextFontSize];
    iconCYCVPrice.position = ccp(iconCYCV.position.x+iconCYCV.contentSize.width*0.58*iconCYCV.scale, iconCYCV.position.y);
    iconCYCVPrice.color = light;
    iconCYCVPrice.anchorPoint = ccp(0, 0.5);
    iconCYCVPrice.opacity = 0;
	[self addChild:iconCYCVPrice z:3];
    
    iconCYCVDownload = [CCLabelTTF labelWithString:LGLocalizedString(@"download", nil) fontName:kFontComicSans fontSize:iconTextFontSize];
    iconCYCVDownload.position = ccp(iconCYCV.position.x+iconCYCV.contentSize.width*0.58*iconCYCV.scale, iconCYCV.position.y-iconCYCV.contentSize.height*0.35*iconCYCV.scale);
    iconCYCVDownload.color = light;
    iconCYCVDownload.anchorPoint = ccp(0, 0.5);
    iconCYCVDownload.opacity = 0;
	[self addChild:iconCYCVDownload z:3];
    
    separatorL[1] = [CCLabelTTF labelWithString:separatorString fontName:kFontComicSans fontSize:iconTextFontSize];
    separatorL[1].position = ccp(winSize.width/2, iconCYCV.position.y-iconCYCV.contentSize.height*0.5*iconCYCV.scale-separatorL[0].contentSize.height/2);
    separatorL[1].color = light;
    separatorL[1].opacity = 0;
    separatorL[1].anchorPoint = ccp(0.5, 0);
    [self addChild:separatorL[1] z:3];
    
    NSString *goToAddStoreString;
    if (kDevicePhone) goToAddStoreString = LGLocalizedString(@"goToAppStore", nil);
    else goToAddStoreString = LGLocalizedString(@"goToAppStorePad", nil);
    
    goToAppStore = [CCLabelTTF labelWithString:goToAddStoreString fontName:kFontComicSans fontSize:textButtonsFontSize];
    if ([LGLocalizationGetPreferredLanguage isEqualToString:@"ru"]) goToAppStore.position = ccp(winSize.width/2, goToAppStore.contentSize.height*0.6);
    else goToAppStore.position = ccp(winSize.width/2, goToAppStore.contentSize.height*0.75);
	goToAppStore.color = light;
    goToAppStore.opacity = 0;
	[self addChild:goToAppStore z:3];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) texts
{
	bestScoreValue = [CCLabelTTF labelWithString:@"0.000" fontName:kFontComicSans fontSize:textsFontSize];
    bestScoreValue.position = ccp(bestScoreValue.contentSize.height/2*0.8, bestScoreValue.contentSize.height*0.8);
	bestScoreValue.color = ccc3(120,120,120);
	bestScoreValue.opacity = 0;
    bestScoreValue.anchorPoint = ccp(0, 0.5);
	[self addChild:bestScoreValue];
    
    bestScore = [CCLabelTTF labelWithString:LGLocalizedString(@"bestScore", nil) fontName:kFontComicSans fontSize:textsFontSize];
    bestScore.position = ccp(bestScoreValue.position.x, bestScoreValue.position.y+bestScore.contentSize.height*0.8);
	bestScore.color = ccc3(120,120,120);
	bestScore.opacity = 0;
    bestScore.anchorPoint = ccp(0, 0.5);
	[self addChild:bestScore];
	
    lastScoreValue = [CCLabelTTF labelWithString:@"0.000" fontName:kFontComicSans fontSize:textsFontSize];
    lastScoreValue.position = ccp(winSize.width-lastScoreValue.contentSize.height/2*0.8, lastScoreValue.contentSize.height*0.8);
	lastScoreValue.color = ccc3(120,120,120);
	lastScoreValue.opacity = 0;
    lastScoreValue.anchorPoint = ccp(1, 0.5);
	[self addChild:lastScoreValue];
    
	lastScore = [CCLabelTTF labelWithString:LGLocalizedString(@"lastScore", nil) fontName:kFontComicSans fontSize:textsFontSize];
    lastScore.position = ccp(lastScoreValue.position.x, lastScoreValue.position.y+lastScore.contentSize.height*0.8);
	lastScore.color = ccc3(120,120,120);
	lastScore.opacity = 0;
    lastScore.anchorPoint = ccp(1, 0.5);
	[self addChild:lastScore];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) bgSecondAppear
{
    float duration = .3;
    int opacity = 255;
    
    [kLGKit spriteFade:bgSecond duration:duration opacity:230];
    [kLGKit spriteFade:closeButton duration:duration opacity:opacity];
    [kLGKit spriteFade:closeButtonStroke duration:duration opacity:opacity];
}

- (void) helpLayerAppear
{
    float duration = .3;
    int opacity = 255;
    
    [kLGKit spriteFade:helpTitle duration:duration opacity:opacity];
    [kLGKit spriteFade:helpAbout duration:duration opacity:opacity];
}

- (void) optionsLayerAppear
{
    float duration = .3;
    int opacity = 255;
    
    [kLGKit spriteFade:optionsTitle duration:duration opacity:opacity];
    [kLGKit spriteFade:selectColorOfLight duration:duration opacity:opacity];
    [kLGKit spriteFade:blueButton duration:duration opacity:opacity];
    [kLGKit spriteFade:greenButton duration:duration opacity:opacity];
    [kLGKit spriteFade:yellowButton duration:duration opacity:opacity];
    [kLGKit spriteFade:violetButton duration:duration opacity:opacity];
    [kLGKit spriteFade:orangeButton duration:duration opacity:opacity];
    [kLGKit spriteFade:selectDifficulty duration:duration opacity:opacity];
    [kLGKit spriteFade:easyButton duration:duration opacity:opacity];
    [kLGKit spriteFade:normalButton duration:duration opacity:opacity];
    [kLGKit spriteFade:hardButton duration:duration opacity:opacity];
    [kLGKit spriteFade:insaneButton duration:duration opacity:opacity];
    [kLGKit spriteFade:selectGameMode duration:duration opacity:opacity];
    [kLGKit spriteFade:onePlayer duration:duration opacity:opacity];
    [kLGKit spriteFade:twoPlayers duration:duration opacity:opacity];
    [kLGKit spriteFade:selectLanguage duration:duration opacity:opacity];
    [kLGKit spriteFade:englishButton duration:duration opacity:opacity];
    [kLGKit spriteFade:russianButton duration:duration opacity:opacity];
    [kLGKit spriteFade:selectSound duration:duration opacity:opacity];
    [kLGKit spriteFade:soundOn duration:duration opacity:opacity];
    [kLGKit spriteFade:soundOff duration:duration opacity:opacity];
    [kLGKit spriteFade:followUs duration:duration opacity:opacity];
    [kLGKit spriteFade:facebook duration:duration opacity:opacity];
    [kLGKit spriteFade:twitter duration:duration opacity:opacity];
    if ([LGLocalizationGetPreferredLanguage isEqualToString:@"ru"]) [kLGKit spriteFade:vkontakte duration:duration opacity:opacity];
}

- (void) newsLayerAppear
{
    /*
     separatorL[0].position = ccp(winSize.width/2, iconCYCV.contentSize.height*iconCYCV.scale+separatorL[0].contentSize.height/2);
     iconCYCV.position = ccp(iconCYCV.contentSize.width*0.6*iconCYCV.scale, separatorL[0].position.y-separatorL[0].contentSize.height/4-iconCYCV.contentSize.height*0.5*iconCYCV.scale);
     iconCYCVName.position = ccp(iconCYCV.position.x+iconCYCV.contentSize.width*0.58*iconCYCV.scale, iconCYCV.position.y+iconCYCV.contentSize.height*0.35*iconCYCV.scale);
     iconCYCVPrice.position = ccp(iconCYCV.position.x+iconCYCV.contentSize.width*0.58*iconCYCV.scale, iconCYCV.position.y);
     iconCYCVDownload.position = ccp(iconCYCV.position.x+iconCYCV.contentSize.width*0.58*iconCYCV.scale, iconCYCV.position.y-iconCYCV.contentSize.height*0.35*iconCYCV.scale);
     separatorL[1].position = ccp(winSize.width/2, iconCYCV.position.y-iconCYCV.contentSize.height*0.5*iconCYCV.scale-separatorL[0].contentSize.height/2);
     */
    float duration = .3;
    int opacity = 255;
    
    [kLGKit spriteFade:newsTitle duration:duration opacity:opacity];
    [kLGKit spriteFade:newsAbout duration:duration opacity:opacity];
    /*
     [kLGKit spriteFade:separatorL[0] duration:duration opacity:opacity];
     [kLGKit spriteFade:separatorL[1] duration:duration opacity:opacity];
     [kLGKit spriteFade:iconCYCV duration:duration opacity:opacity];
     [kLGKit spriteFade:iconCYCVName duration:duration opacity:opacity];
     [kLGKit spriteFade:iconCYCVPrice duration:duration opacity:opacity];
     [kLGKit spriteFade:iconCYCVDownload duration:duration opacity:opacity];
     */
}

- (void) purchasesLayerAppear
{
    float duration = .3;
    int opacity = 255;
    
    [kLGKit spriteFade:donate1 duration:duration opacity:opacity];
    [kLGKit spriteFade:donate1Stroke duration:duration opacity:opacity];
    [kLGKit spriteFade:donate3 duration:duration opacity:opacity];
    [kLGKit spriteFade:donate3Stroke duration:duration opacity:opacity];
    [kLGKit spriteFade:donate5 duration:duration opacity:opacity];
    [kLGKit spriteFade:donate5Stroke duration:duration opacity:opacity];
    [kLGKit spriteFade:donate10 duration:duration opacity:opacity];
    [kLGKit spriteFade:donate10Stroke duration:duration opacity:opacity];
    [kLGKit spriteFade:donate25 duration:duration opacity:opacity];
    [kLGKit spriteFade:donate25Stroke duration:duration opacity:opacity];
    [kLGKit spriteFade:purchasesTitle duration:duration opacity:opacity];
    [kLGKit spriteFade:removeAdsText duration:duration opacity:opacity];
    if (kIsGameFull == YES) [kLGKit spriteFade:removeAdsStatus duration:duration opacity:opacity];
    else [kLGKit spriteFade:removeAdsStatus duration:duration opacity:100];
    [kLGKit spriteFade:donateTitle duration:duration opacity:opacity];
    [kLGKit spriteFade:internetAvailabilityTitle duration:duration opacity:opacity];
    [kLGKit spriteFade:internetAvailabilityStatus duration:duration opacity:opacity];
    [kLGKit spriteFade:restoreText duration:duration opacity:opacity];
    
    opacity = 30;
    
    [kLGKit spriteFade:donate1Bg duration:duration opacity:opacity];
    [kLGKit spriteFade:donate3Bg duration:duration opacity:opacity];
    [kLGKit spriteFade:donate5Bg duration:duration opacity:opacity];
    [kLGKit spriteFade:donate10Bg duration:duration opacity:opacity];
    [kLGKit spriteFade:donate25Bg duration:duration opacity:opacity];
}

- (void) moreGamesLayerAppear
{
    separatorL[0].position = ccp(winSize.width/2, moreGamesTitle.position.y-moreGamesTitle.contentSize.height-separatorL[0].contentSize.height/2);
    iconCYCV.position = ccp(iconCYCV.contentSize.width*0.6*iconCYCV.scale, separatorL[0].position.y-separatorL[0].contentSize.height/4-iconCYCV.contentSize.height*0.5*iconCYCV.scale);
    iconCYCVName.position = ccp(iconCYCV.position.x+iconCYCV.contentSize.width*0.58*iconCYCV.scale, iconCYCV.position.y+iconCYCV.contentSize.height*0.35*iconCYCV.scale);
    iconCYCVPrice.position = ccp(iconCYCV.position.x+iconCYCV.contentSize.width*0.58*iconCYCV.scale, iconCYCV.position.y);
    iconCYCVDownload.position = ccp(iconCYCV.position.x+iconCYCV.contentSize.width*0.58*iconCYCV.scale, iconCYCV.position.y-iconCYCV.contentSize.height*0.35*iconCYCV.scale);
    separatorL[1].position = ccp(winSize.width/2, iconCYCV.position.y-iconCYCV.contentSize.height*0.5*iconCYCV.scale-separatorL[0].contentSize.height/2);
    
    [self bgSecondAppear];
    
    float duration = .3;
    int opacity = 255;
    
    [kLGKit spriteFade:moreGamesTitle duration:duration opacity:opacity];
    [kLGKit spriteFade:separatorL[0] duration:duration opacity:opacity];
    [kLGKit spriteFade:separatorL[1] duration:duration opacity:opacity];
    [kLGKit spriteFade:iconCYCV duration:duration opacity:opacity];
    [kLGKit spriteFade:iconCYCVName duration:duration opacity:opacity];
    [kLGKit spriteFade:iconCYCVPrice duration:duration opacity:opacity];
    [kLGKit spriteFade:iconCYCVDownload duration:duration opacity:opacity];
    [kLGKit spriteFade:goToAppStore duration:duration opacity:opacity];
}

- (void) bgSecondDisappear
{
    float duration = .3;
    int opacity = 0;
    
    [kLGKit spriteFade:bgSecond duration:duration opacity:opacity];
    [kLGKit spriteFade:closeButton duration:duration opacity:opacity];
    [kLGKit spriteFade:closeButtonStroke duration:duration opacity:opacity];
}

- (void) helpLayerDisappear
{
    [self bgSecondDisappear];
    
    float duration = .3;
    int opacity = 0;
    
    [kLGKit spriteFade:helpTitle duration:duration opacity:opacity];
    [kLGKit spriteFade:helpAbout duration:duration opacity:opacity];
    
    [kLGKit buttonUnselect:helpButtonBg color:kColorDark buttonText:helpButtonText withText:@"helpButtonUnsel"];
}

- (void) optionsLayerDisappear
{
    [self bgSecondDisappear];
    
    float duration = .3;
    int opacity = 0;
    
    [kLGKit spriteFade:optionsTitle duration:duration opacity:opacity];
    [kLGKit spriteFade:selectColorOfLight duration:duration opacity:opacity];
    [kLGKit spriteFade:blueButton duration:duration opacity:opacity];
    [kLGKit spriteFade:greenButton duration:duration opacity:opacity];
    [kLGKit spriteFade:yellowButton duration:duration opacity:opacity];
    [kLGKit spriteFade:violetButton duration:duration opacity:opacity];
    [kLGKit spriteFade:orangeButton duration:duration opacity:opacity];
    [kLGKit spriteFade:selectDifficulty duration:duration opacity:opacity];
    [kLGKit spriteFade:easyButton duration:duration opacity:opacity];
    [kLGKit spriteFade:normalButton duration:duration opacity:opacity];
    [kLGKit spriteFade:hardButton duration:duration opacity:opacity];
    [kLGKit spriteFade:insaneButton duration:duration opacity:opacity];
    [kLGKit spriteFade:selectGameMode duration:duration opacity:opacity];
    [kLGKit spriteFade:onePlayer duration:duration opacity:opacity];
    [kLGKit spriteFade:twoPlayers duration:duration opacity:opacity];
    [kLGKit spriteFade:selectLanguage duration:duration opacity:opacity];
    [kLGKit spriteFade:englishButton duration:duration opacity:opacity];
    [kLGKit spriteFade:russianButton duration:duration opacity:opacity];
    [kLGKit spriteFade:selectSound duration:duration opacity:opacity];
    [kLGKit spriteFade:soundOn duration:duration opacity:opacity];
    [kLGKit spriteFade:soundOff duration:duration opacity:opacity];
    [kLGKit spriteFade:followUs duration:duration opacity:opacity];
    [kLGKit spriteFade:facebook duration:duration opacity:opacity];
    [kLGKit spriteFade:twitter duration:duration opacity:opacity];
    if ([LGLocalizationGetPreferredLanguage isEqualToString:@"ru"]) [kLGKit spriteFade:vkontakte duration:duration opacity:opacity];
    
    [kLGKit buttonUnselect:optionsButtonBg color:kColorDark buttonText:optionsButtonText withText:@"optionsButtonUnsel"];
}

- (void) newsLayerDisappear
{
    [self bgSecondDisappear];
    
    float duration = .3;
    int opacity = 0;
    
    [kLGKit spriteFade:newsTitle duration:duration opacity:opacity];
    [kLGKit spriteFade:newsAbout duration:duration opacity:opacity];
    /*
     [kLGKit spriteFade:separatorL[0] duration:duration opacity:opacity];
     [kLGKit spriteFade:separatorL[1] duration:duration opacity:opacity];
     [kLGKit spriteFade:iconCYCV duration:duration opacity:opacity];
     [kLGKit spriteFade:iconCYCVName duration:duration opacity:opacity];
     [kLGKit spriteFade:iconCYCVPrice duration:duration opacity:opacity];
     [kLGKit spriteFade:iconCYCVDownload duration:duration opacity:opacity];
     */
    [kLGKit buttonUnselect:newsButtonBg color:kColorDark buttonText:newsButtonText withText:@"newsButtonUnsel"];
}

- (void) purchasesLayerDisappear
{
    [self bgSecondDisappear];
    
    float duration = .3;
    int opacity = 0;
    
    [kLGKit spriteFade:donate1 duration:duration opacity:opacity];
    [kLGKit spriteFade:donate1Stroke duration:duration opacity:opacity];
    [kLGKit spriteFade:donate3 duration:duration opacity:opacity];
    [kLGKit spriteFade:donate3Stroke duration:duration opacity:opacity];
    [kLGKit spriteFade:donate5 duration:duration opacity:opacity];
    [kLGKit spriteFade:donate5Stroke duration:duration opacity:opacity];
    [kLGKit spriteFade:donate10 duration:duration opacity:opacity];
    [kLGKit spriteFade:donate10Stroke duration:duration opacity:opacity];
    [kLGKit spriteFade:donate25 duration:duration opacity:opacity];
    [kLGKit spriteFade:donate25Stroke duration:duration opacity:opacity];
    [kLGKit spriteFade:purchasesTitle duration:duration opacity:opacity];
    [kLGKit spriteFade:removeAdsText duration:duration opacity:opacity];
    [kLGKit spriteFade:removeAdsStatus duration:duration opacity:opacity];
    [kLGKit spriteFade:donateTitle duration:duration opacity:opacity];
    [kLGKit spriteFade:internetAvailabilityTitle duration:duration opacity:opacity];
    [kLGKit spriteFade:internetAvailabilityStatus duration:duration opacity:opacity];
    [kLGKit spriteFade:restoreText duration:duration opacity:opacity];
    [kLGKit spriteFade:donate1Bg duration:duration opacity:opacity];
    [kLGKit spriteFade:donate3Bg duration:duration opacity:opacity];
    [kLGKit spriteFade:donate5Bg duration:duration opacity:opacity];
    [kLGKit spriteFade:donate10Bg duration:duration opacity:opacity];
    [kLGKit spriteFade:donate25Bg duration:duration opacity:opacity];
    
    [kLGKit buttonUnselect:purchasesButtonBg color:kColorGreen buttonText:purchasesButtonText withText:@"purchasesButtonUnsel"];
}

- (void) moreGamesLayerDisappear
{
    [self bgSecondDisappear];
    
    float duration = .3;
    int opacity = 0;
    
    [kLGKit spriteFade:moreGamesTitle duration:duration opacity:opacity];
    [kLGKit spriteFade:separatorL[0] duration:duration opacity:opacity];
    [kLGKit spriteFade:separatorL[1] duration:duration opacity:opacity];
    [kLGKit spriteFade:iconCYCV duration:duration opacity:opacity];
    [kLGKit spriteFade:iconCYCVName duration:duration opacity:opacity];
    [kLGKit spriteFade:iconCYCVPrice duration:duration opacity:opacity];
    [kLGKit spriteFade:iconCYCVDownload duration:duration opacity:opacity];
    [kLGKit spriteFade:goToAppStore duration:duration opacity:opacity];
    
    moreGamesButton.texture = moreGamesT2D[0];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) allSpritesAppear
{
	float duration = .2;
    int opacity = 255;
    
    [kLGKit spriteFade:logo duration:duration opacity:opacity];
    [kLGKit spriteFade:playButton duration:duration opacity:opacity];
    [kLGKit spriteFade:gamecenterButton duration:duration opacity:opacity];
    [kLGKit spriteFade:optionsButton duration:duration opacity:opacity];
    [kLGKit spriteFade:highscoresButton duration:duration opacity:opacity];
    [kLGKit spriteFade:helpButton duration:duration opacity:opacity];
    [kLGKit spriteFade:newsButton duration:duration opacity:opacity];
    [kLGKit spriteFade:purchasesButton duration:duration opacity:opacity];
    [kLGKit spriteFade:playButtonText duration:duration opacity:opacity];
    [kLGKit spriteFade:optionsButtonText duration:duration opacity:opacity];
    [kLGKit spriteFade:highscoresButtonText duration:duration opacity:opacity];
    [kLGKit spriteFade:gamecenterButtonText duration:duration opacity:opacity];
    [kLGKit spriteFade:helpButtonText duration:duration opacity:opacity];
    [kLGKit spriteFade:newsButtonText duration:duration opacity:opacity];
    [kLGKit spriteFade:purchasesButtonText duration:duration opacity:opacity];
    [kLGKit spriteFade:playButtonStroke duration:duration opacity:opacity];
    [kLGKit spriteFade:helpButtonStroke duration:duration opacity:opacity];
    [kLGKit spriteFade:newsButtonStroke duration:duration opacity:opacity];
    [kLGKit spriteFade:purchasesButtonStroke duration:duration opacity:opacity];
    [kLGKit spriteFade:highscoresButtonStroke duration:duration opacity:opacity];
    [kLGKit spriteFade:gamecenterButtonStroke duration:duration opacity:opacity];
    [kLGKit spriteFade:optionsButtonStroke duration:duration opacity:opacity];
    [kLGKit spriteFade:bestScore duration:duration opacity:opacity];
    [kLGKit spriteFade:bestScoreValue duration:duration opacity:opacity];
    [kLGKit spriteFade:lastScore duration:duration opacity:opacity];
    [kLGKit spriteFade:lastScoreValue duration:duration opacity:opacity];
    [kLGKit spriteFade:moreGamesButton duration:duration opacity:opacity];
    
    opacity = 30;
    
    [kLGKit spriteFade:playButtonBg duration:duration opacity:opacity];
    [kLGKit spriteFade:optionsButtonBg duration:duration opacity:opacity];
    [kLGKit spriteFade:highscoresButtonBg duration:duration opacity:opacity];
    [kLGKit spriteFade:gamecenterButtonBg duration:duration opacity:opacity];
    [kLGKit spriteFade:helpButtonBg duration:duration opacity:opacity];
    [kLGKit spriteFade:newsButtonBg duration:duration opacity:opacity];
    [kLGKit spriteFade:purchasesButtonBg duration:duration opacity:opacity];
    
    [kLGKit spriteFade:copyrightButton duration:duration opacity:125];
}

- (void) allSpritesDisappear
{
	float duration = .2;
    int opacity = 0;
    
	[kLGKit spriteFade:logo duration:duration opacity:opacity];
    [kLGKit spriteFade:playButton duration:duration opacity:opacity];
    [kLGKit spriteFade:gamecenterButton duration:duration opacity:opacity];
    [kLGKit spriteFade:optionsButton duration:duration opacity:opacity];
    [kLGKit spriteFade:highscoresButton duration:duration opacity:opacity];
    [kLGKit spriteFade:helpButton duration:duration opacity:opacity];
    [kLGKit spriteFade:newsButton duration:duration opacity:opacity];
    [kLGKit spriteFade:purchasesButton duration:duration opacity:opacity];
    [kLGKit spriteFade:playButtonText duration:duration opacity:opacity];
    [kLGKit spriteFade:optionsButtonText duration:duration opacity:opacity];
    [kLGKit spriteFade:highscoresButtonText duration:duration opacity:opacity];
    [kLGKit spriteFade:gamecenterButtonText duration:duration opacity:opacity];
    [kLGKit spriteFade:helpButtonText duration:duration opacity:opacity];
    [kLGKit spriteFade:newsButtonText duration:duration opacity:opacity];
    [kLGKit spriteFade:purchasesButtonText duration:duration opacity:opacity];
    [kLGKit spriteFade:playButtonStroke duration:duration opacity:opacity];
    [kLGKit spriteFade:helpButtonStroke duration:duration opacity:opacity];
    [kLGKit spriteFade:newsButtonStroke duration:duration opacity:opacity];
    [kLGKit spriteFade:purchasesButtonStroke duration:duration opacity:opacity];
    [kLGKit spriteFade:highscoresButtonStroke duration:duration opacity:opacity];
    [kLGKit spriteFade:gamecenterButtonStroke duration:duration opacity:opacity];
    [kLGKit spriteFade:optionsButtonStroke duration:duration opacity:opacity];
    [kLGKit spriteFade:playButtonBg duration:duration opacity:opacity];
    [kLGKit spriteFade:optionsButtonBg duration:duration opacity:opacity];
    [kLGKit spriteFade:highscoresButtonBg duration:duration opacity:opacity];
    [kLGKit spriteFade:gamecenterButtonBg duration:duration opacity:opacity];
    [kLGKit spriteFade:helpButtonBg duration:duration opacity:opacity];
    [kLGKit spriteFade:newsButtonBg duration:duration opacity:opacity];
    [kLGKit spriteFade:purchasesButtonBg duration:duration opacity:opacity];
    [kLGKit spriteFade:bestScore duration:duration opacity:opacity];
    [kLGKit spriteFade:bestScoreValue duration:duration opacity:opacity];
    [kLGKit spriteFade:lastScore duration:duration opacity:opacity];
    [kLGKit spriteFade:lastScoreValue duration:duration opacity:opacity];
    [kLGKit spriteFade:moreGamesButton duration:duration opacity:opacity];
    [kLGKit spriteFade:copyrightButton duration:duration opacity:opacity];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) goToGame2P
{
    [[CCDirector sharedDirector] replaceScene:[GameLayer2P scene]];
}

- (void) goToGame1P
{
    [[CCDirector sharedDirector] replaceScene:[GameLayer1P scene]];
}

- (void) goToHighscores
{
    [[CCDirector sharedDirector] replaceScene:[HighscoresLayer scene]];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) refreshAllStrings
{
    [selectColorOfLight setString:LGLocalizedString(@"selectColorOfLight", nil)];
    [selectDifficulty setString:LGLocalizedString(@"selectDifficulty", nil)];
    [selectGameMode setString:LGLocalizedString(@"selectGameMode", nil)];
    [selectLanguage setString:LGLocalizedString(@"selectLanguage", nil)];
    [selectSound setString:LGLocalizedString(@"selectSound", nil)];
    [followUs setString:LGLocalizedString(@"followUs", nil)];
    
    [self unselectedColor];
    [self unselectedDifficulty];
    [self unselectedGameMode];
    [self unselectedLanguage];
    [self unselectedSound];
    [self checkSettings];
    
    [playButtonText setString:LGLocalizedString(@"playButtonUnsel", nil)];
    [newsButtonText setString:LGLocalizedString(@"newsButtonUnsel", nil)];
    [purchasesButtonText setString:LGLocalizedString(@"purchasesButtonUnsel", nil)];
    [optionsButtonText setString:LGLocalizedString(@"optionsButtonSel", nil)];
    [highscoresButtonText setString:LGLocalizedString(@"highscoresButtonUnsel", nil)];
    [helpButtonText setString:LGLocalizedString(@"helpButtonUnsel", nil)];
    
    [newsTitle setString:LGLocalizedString(@"newsTitle", nil)];
    [purchasesTitle setString:LGLocalizedString(@"purchasesTitle", nil)];
    [optionsTitle setString:LGLocalizedString(@"optionsTitle", nil)];
    [helpTitle setString:LGLocalizedString(@"helpTitle", nil)];
    [moreGamesTitle setString:LGLocalizedString(@"moreGamesTitle", nil)];
    
    [newsAbout setString:LGLocalizedString(@"newsAbout", nil)];
    [helpAbout setString:LGLocalizedString(@"helpAbout", nil)];
    
    [removeAdsText setString:LGLocalizedString(@"removeAdsText", nil)];
    if (kIsGameFull == YES) [removeAdsStatus setString:LGLocalizedString(@"removeAdsYes", nil)];
    else [removeAdsStatus setString:LGLocalizedString(@"removeAdsNo", nil)];
    [restoreText setString:LGLocalizedString(@"restoreText", nil)];
    [donateTitle setString:LGLocalizedString(@"donateTitle", nil)];
    [internetAvailabilityTitle setString:LGLocalizedString(@"internetAvailabilityTitle", nil)];
    
    moreGamesT2D[0] = [[CCTextureCache sharedTextureCache] addImage:LGLocalizedString(@"moreGamesButton", nil)];
    moreGamesT2D[1] = [[CCTextureCache sharedTextureCache] addImage:LGLocalizedString(@"moreGamesButtonTapped", nil)];
    [moreGamesButton setTexture:moreGamesT2D[0]];
    [iconCYCVPrice setString:LGLocalizedString(@"priceFree", nil)];
    [iconCYCVDownload setString:LGLocalizedString(@"download", nil)];
    if (kDevicePhone) [goToAppStore setString:LGLocalizedString(@"goToAppStore", nil)];
    else [goToAppStore setString:LGLocalizedString(@"goToAppStorePad", nil)];
    
    [bestScore setString:LGLocalizedString(@"bestScore", nil)];
    [lastScore setString:LGLocalizedString(@"lastScore", nil)];
    
    
    if ([LGLocalizationGetPreferredLanguage isEqualToString:@"ru"]) goToAppStore.position = ccp(winSize.width/2, goToAppStore.contentSize.height*0.6);
    else goToAppStore.position = ccp(winSize.width/2, goToAppStore.contentSize.height*0.75);
    
    if ([LGLocalizationGetPreferredLanguage isEqualToString:@"ru"]) vkontakte.opacity = 255;
    else vkontakte.opacity = 0;
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
        
        [kLGKit buttonUnselect:gamecenterButtonBg color:kColorDark buttonText:gamecenterButtonText withText:@"gamecenterButtonUnsel"];
    }
    else if (alertView == rateAlert)
    {
        if (buttonIndex == 0)
        {
            // late
        }
        else if (buttonIndex == 1)
        {
            [[UIApplication sharedApplication] openURL:
             [NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", @"515273616"]]];
        }
        else if (buttonIndex == 2)
        {
            
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	touch = [touches anyObject];
	touchPoint = [touch locationInView:[touch view]];
	touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
	
    if (CGRectContainsPoint(playButtonBg.boundingBox, touchPoint) && bgSecondOnScreen == 0) ////////// play //////////
    {
        [kLGKit buttonSelect:playButtonBg color:kColorLight buttonText:playButtonText withText:@"playButtonSel"];
        
        z = 1;
        
        [self soundButton];
    }
    else if (CGRectContainsPoint(gamecenterButtonBg.boundingBox, touchPoint) && bgSecondOnScreen == 0) ////////// gamecenter //////////
    {
        [kLGKit buttonSelect:gamecenterButtonBg color:kColorLight buttonText:gamecenterButtonText withText:@"gamecenterButtonSel"];
        
        z = 2;
        
        [self soundButton];
    }
    else if (CGRectContainsPoint(optionsButtonBg.boundingBox, touchPoint) && bgSecondOnScreen == 0) ////////// options //////////
    {
        [kLGKit buttonSelect:optionsButtonBg color:kColorLight buttonText:optionsButtonText withText:@"optionsButtonSel"];
        
        z = 3;
        
        [self soundButton];
    }
    else if (CGRectContainsPoint(highscoresButtonBg.boundingBox, touchPoint) && bgSecondOnScreen == 0) ////////// highscores //////////
    {
        [kLGKit buttonSelect:highscoresButtonBg color:kColorLight buttonText:highscoresButtonText withText:@"highscoresButtonSel"];
        
        z = 4;
        
        [self soundButton];
    }
    else if (CGRectContainsPoint(helpButtonBg.boundingBox, touchPoint) && bgSecondOnScreen == 0) ////////// help //////////
    {
        [kLGKit buttonSelect:helpButtonBg color:kColorLight buttonText:helpButtonText withText:@"helpButtonSel"];
        
        z = 5;
        
        [self soundButton];
    }
    else if (CGRectContainsPoint(newsButtonBg.boundingBox, touchPoint) && bgSecondOnScreen == 0) ////////// news //////////
    {
        [kLGKit buttonSelect:newsButtonBg color:kColorLight buttonText:newsButtonText withText:@"newsButtonSel"];
        
        z = 6;
        
        [self soundButton];
    }
    else if (CGRectContainsPoint(purchasesButtonBg.boundingBox, touchPoint) && bgSecondOnScreen == 0) ////////// purchases //////////
    {
        [kLGKit buttonSelect:purchasesButtonBg color:kColorGreen buttonText:purchasesButtonText withText:@"purchasesButtonSel"];
        
        z = 7;
        
        [self soundButton];
    }
    else if (CGRectContainsPoint(moreGamesButton.boundingBox, touchPoint) && bgSecondOnScreen == 0) ////////// moreGames //////////
    {
        moreGamesButton.texture = moreGamesT2D[1];
        
        z = 8;
        
        [self soundButton];
    }
    else if (CGRectContainsPoint(closeButtonStroke.boundingBox, touchPoint) && bgSecondOnScreen == 1) ////////// close //////////
    {
        if (helpOnScreen) [self helpLayerDisappear];
        if (optionsOnScreen)
        {
            [self optionsLayerDisappear];
            [self checkSettings];
        }
        if (newsOnScreen) [self newsLayerDisappear];
        if (purchasesOnScreen) [self purchasesLayerDisappear];
        if (moreGamesOnScreen) [self moreGamesLayerDisappear];
        
        helpOnScreen = 0;
        optionsOnScreen = 0;
        newsOnScreen = 0;
        purchasesOnScreen = 0;
        moreGamesOnScreen = 0;
        bgSecondOnScreen = 0;
        
        [self soundButton];
    }
    else if (CGRectContainsPoint(blueButton.boundingBox, touchPoint) && optionsOnScreen == 1) ////////// blue //////////
	{
		[self unselectedColor];
		
		[blueButton setString:LGLocalizedString(@"blueSel", nil)];
		
		colorOfLight = 1;
		[defaults setInteger:colorOfLight forKey:@"colorOfLight"];
        
        [self soundChoose];
	}
	else if (CGRectContainsPoint(greenButton.boundingBox, touchPoint) && optionsOnScreen == 1) ////////// green //////////
	{
		[self unselectedColor];
		
		[greenButton setString:LGLocalizedString(@"greenSel", nil)];
		
		colorOfLight = 2;
		[defaults setInteger:colorOfLight forKey:@"colorOfLight"];
        
        [self soundChoose];
	}
	else if (CGRectContainsPoint(yellowButton.boundingBox, touchPoint) && optionsOnScreen == 1) ////////// yellow //////////
	{
		[self unselectedColor];
		
		[yellowButton setString:LGLocalizedString(@"yellowSel", nil)];
		
		colorOfLight = 3;
		[defaults setInteger:colorOfLight forKey:@"colorOfLight"];
        
        [self soundChoose];
	}
	else if (CGRectContainsPoint(violetButton.boundingBox, touchPoint) && optionsOnScreen == 1) ////////// violet //////////
	{
		[self unselectedColor];
		
		[violetButton setString:LGLocalizedString(@"violetSel", nil)];
		
		colorOfLight = 4;
		[defaults setInteger:colorOfLight forKey:@"colorOfLight"];
        
        [self soundChoose];
	}
	else if (CGRectContainsPoint(orangeButton.boundingBox, touchPoint) && optionsOnScreen == 1) ////////// orange //////////
	{
		[self unselectedColor];
		
		[orangeButton setString:LGLocalizedString(@"orangeSel", nil)];
		
		colorOfLight = 5;
		[defaults setInteger:colorOfLight forKey:@"colorOfLight"];
        
        [self soundChoose];
	}
	else if (CGRectContainsPoint(easyButton.boundingBox, touchPoint) && optionsOnScreen == 1) ////////// easy //////////
	{
		[self unselectedDifficulty];
		
		[easyButton setString:LGLocalizedString(@"easySel", nil)];
        
		difficulty = 1;
		[defaults setInteger:difficulty forKey:@"difficulty"];
        
        [self soundChoose];
	}
	else if (CGRectContainsPoint(normalButton.boundingBox, touchPoint) && optionsOnScreen == 1) ////////// normal //////////
	{
		[self unselectedDifficulty];
		
		[normalButton setString:LGLocalizedString(@"normalSel", nil)];
		
		difficulty = 2;
		[defaults setInteger:difficulty forKey:@"difficulty"];
        
        [self soundChoose];
	}
	else if (CGRectContainsPoint(hardButton.boundingBox, touchPoint) && optionsOnScreen == 1) ////////// hard //////////
	{
		[self unselectedDifficulty];
		
		[hardButton setString:LGLocalizedString(@"hardSel", nil)];
		
		difficulty = 3;
		[defaults setInteger:difficulty forKey:@"difficulty"];
        
        [self soundChoose];
	}
	else if (CGRectContainsPoint(insaneButton.boundingBox, touchPoint) && optionsOnScreen == 1) ////////// insane //////////
	{
		[self unselectedDifficulty];
		
		[insaneButton setString:LGLocalizedString(@"insaneSel", nil)];
		
		difficulty = 4;
		[defaults setInteger:difficulty forKey:@"difficulty"];
        
        [self soundChoose];
	}
    else if (CGRectContainsPoint(onePlayer.boundingBox, touchPoint) && optionsOnScreen == 1) ////////// 1 Player //////////
	{
		[self unselectedGameMode];
		
		[onePlayer setString:LGLocalizedString(@"1PlayerSel", nil)];
		
		gameMode = 1;
		[defaults setInteger:gameMode forKey:@"gameMode"];
        
        [self soundChoose];
	}
    else if (CGRectContainsPoint(twoPlayers.boundingBox, touchPoint) && optionsOnScreen == 1) ////////// 2 Players //////////
	{
		[self unselectedGameMode];
		
		[twoPlayers setString:LGLocalizedString(@"2PlayersSel", nil)];
		
		gameMode = 2;
		[defaults setInteger:gameMode forKey:@"gameMode"];
        
        [self soundChoose];
	}
    else if (CGRectContainsPoint(englishButton.boundingBox, touchPoint) && optionsOnScreen == 1) ////////// English //////////
	{
        LGLocalizationSetLanguage(@"en");
        
		[self unselectedLanguage];
		
		[englishButton setString:LGLocalizedString(@"englishSel", nil)];
        
        [self soundChoose];
        
        [self refreshAllStrings];
	}
    else if (CGRectContainsPoint(russianButton.boundingBox, touchPoint) && optionsOnScreen == 1) ////////// Russian //////////
	{
        LGLocalizationSetLanguage(@"ru");
		
		[russianButton setString:LGLocalizedString(@"russianSel", nil)];
        
        [self soundChoose];
        
        [self refreshAllStrings];
	}
    else if (CGRectContainsPoint(soundOn.boundingBox, touchPoint) && optionsOnScreen == 1) ////////// Sound On //////////
	{
        [SimpleAudioEngine sharedEngine].effectsVolume = 1;
        
        [self unselectedSound];
		
		[soundOn setString:LGLocalizedString(@"soundOnSel", nil)];
        
        [defaults setBool:YES forKey:@"soundIsOn"];
        
        [self soundChoose];
	}
    else if (CGRectContainsPoint(soundOff.boundingBox, touchPoint) && optionsOnScreen == 1) ////////// Sound Off //////////
	{
        [SimpleAudioEngine sharedEngine].effectsVolume = 0;
        
        [self unselectedSound];
		
		[soundOff setString:LGLocalizedString(@"soundOffSel", nil)];
        
        [defaults setBool:NO forKey:@"soundIsOn"];
        
        [self soundChoose];
	}
    else if (CGRectContainsPoint(goToAppStore.boundingBox, touchPoint) && moreGamesOnScreen == 1) ////////// Перейти в аппстор на мою стр
	{
        [self soundChoose];
        
        if (kInternetStatus) [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.com/apps/ApogeeStudio"]];
        else [kLGKit createAlertNoInternet];
	}
    else if (touchPoint.y < separatorL[0].position.y && touchPoint.y > separatorL[1].position.y && (moreGamesOnScreen || newsOnScreen)) ////////// Перейти на стр CheckYourCV
	{
        [self soundChoose];
        
        if (kInternetStatus) [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.com/apps/apogeeStudio/CheckYourColorVision"]];
        else [kLGKit createAlertNoInternet];
	}
    else if ((CGRectContainsPoint(removeAdsText.boundingBox, touchPoint) || CGRectContainsPoint(removeAdsStatus.boundingBox, touchPoint)) && purchasesOnScreen == 1) ////////// Remove Ads
	{
        [self soundChoose];
        
        if ([kLGInAppPurchases canMakePurchases] && [kLGInAppPurchases storeLoaded]) [kLGInAppPurchases purchaseProduct:@"com.ApogeeStudio.CheckYourReactionFree.RemoveAds"];
	}
    else if (CGRectContainsPoint(restoreText.boundingBox, touchPoint) && purchasesOnScreen == 1) ////////// restore
	{
        [self soundChoose];
        
        if ([kLGInAppPurchases canMakePurchases] && [kLGInAppPurchases storeLoaded]) [kLGInAppPurchases restoreCompletedTransactions];
	}
    else if (CGRectContainsPoint(donate1Bg.boundingBox, touchPoint) && purchasesOnScreen == 1) ////////// Donate $1
	{
        [self soundChoose];
        
        if ([kLGInAppPurchases canMakePurchases] && [kLGInAppPurchases storeLoaded]) [kLGInAppPurchases purchaseProduct:@"com.ApogeeStudio.CheckYourReactionFree.Donate1"];
	}
    else if (CGRectContainsPoint(donate3Bg.boundingBox, touchPoint) && purchasesOnScreen == 1) ////////// Donate $3
	{
        [self soundChoose];
        
        if ([kLGInAppPurchases canMakePurchases] && [kLGInAppPurchases storeLoaded]) [kLGInAppPurchases purchaseProduct:@"com.ApogeeStudio.CheckYourReactionFree.Donate3"];
	}
    else if (CGRectContainsPoint(donate5Bg.boundingBox, touchPoint) && purchasesOnScreen == 1) ////////// Donate $5
	{
        [self soundChoose];
        
        if ([kLGInAppPurchases canMakePurchases] && [kLGInAppPurchases storeLoaded]) [kLGInAppPurchases purchaseProduct:@"com.ApogeeStudio.CheckYourReactionFree.Donate5"];
	}
    else if (CGRectContainsPoint(donate10Bg.boundingBox, touchPoint) && purchasesOnScreen == 1) ////////// Donate $10
	{
        [self soundChoose];
        
        if ([kLGInAppPurchases canMakePurchases] && [kLGInAppPurchases storeLoaded]) [kLGInAppPurchases purchaseProduct:@"com.ApogeeStudio.CheckYourReactionFree.Donate10"];
	}
    else if (CGRectContainsPoint(donate25Bg.boundingBox, touchPoint) && purchasesOnScreen == 1) ////////// Donate $25
	{
        [self soundChoose];
        
        if ([kLGInAppPurchases canMakePurchases] && [kLGInAppPurchases storeLoaded]) [kLGInAppPurchases purchaseProduct:@"com.ApogeeStudio.CheckYourReactionFree.Donate25"];
	}
    else if (CGRectContainsPoint(copyrightButton.boundingBox, touchPoint) && !bgSecondOnScreen) ////////// Copyright
	{
        NSString *gameName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
        NSString *gameVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        NSString *title = [NSString stringWithFormat:@"%@ %@", gameName, gameVersion];
        
        NSString *message = [NSString stringWithFormat:@"%@: %@\n\n%@: Cocos2d\n\n%@: www.freesound.org",
                             LGLocalizedString(@"developer", nil), LGLocalizedString(@"myName", nil),
                             LGLocalizedString(@"engine", nil), LGLocalizedString(@"sounds", nil)];
        
        [[[UIAlertView alloc] initWithTitle:title
                                    message:message
                                   delegate:self
                          cancelButtonTitle:LGLocalizedString(@"close", nil)
                          otherButtonTitles:nil] show];
	}
    else if (CGRectContainsPoint(facebook.boundingBox, touchPoint) && optionsOnScreen == 1) ////////// FacebookFollow
	{
        if (kInternetStatus)
        {
            if ([LGLocalizationGetPreferredLanguage isEqualToString:@"ru"])
            {
                NSURL *url = [NSURL URLWithString:@"fb://profile/484109101637910"];
                if ([[UIApplication sharedApplication] canOpenURL:url]) [[UIApplication sharedApplication] openURL:url];
                else [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.facebook.com/484109101637910"]];
            }
            else
            {
                NSURL *url = [NSURL URLWithString:@"fb://profile/142385912600384"];
                if ([[UIApplication sharedApplication] canOpenURL:url]) [[UIApplication sharedApplication] openURL:url];
                else [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.facebook.com/ApogeeStudio.en"]];
            }
        }
        else [kLGKit createAlertNoInternet];
	}
    else if (CGRectContainsPoint(twitter.boundingBox, touchPoint) && optionsOnScreen == 1) ////////// TwitterFollow
	{
        if (kInternetStatus)
        {
            if ([LGLocalizationGetPreferredLanguage isEqualToString:@"ru"])
            {
                NSURL *url = [NSURL URLWithString:@"twitter://user?screen_name=ApogeeStudioRu"];
                if ([[UIApplication sharedApplication] canOpenURL:url]) [[UIApplication sharedApplication] openURL:url];
                else [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/ApogeeStudioRu"]];
            }
            else
            {
                NSURL *url = [NSURL URLWithString:@"twitter://user?screen_name=ApogeeStudioEn"];
                if ([[UIApplication sharedApplication] canOpenURL:url]) [[UIApplication sharedApplication] openURL:url];
                else [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/ApogeeStudioEn"]];
            }
        }
        else [kLGKit createAlertNoInternet];
	}
    else if (CGRectContainsPoint(vkontakte.boundingBox, touchPoint) && [LGLocalizationGetPreferredLanguage isEqualToString:@"ru"] && optionsOnScreen == 1) ////////// ВКонтактеFollow
	{
        if (kInternetStatus) [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://vk.com/apogeestudio"]];
        else [kLGKit createAlertNoInternet];
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	touch = [touches anyObject];
	touchPoint = [touch locationInView:[touch view]];
	touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
	
    if (CGRectContainsPoint(playButtonBg.boundingBox, touchPoint) && z == 1) ////////// play //////////
    {
        self.isTouchEnabled = NO;
        [self allSpritesDisappear];
        
        if (gameMode == 1) [self performSelector:@selector(goToGame1P) withObject:nil afterDelay:.2];
        else if (gameMode == 2) [self performSelector:@selector(goToGame2P) withObject:nil afterDelay:.2];
    }
    else if (z == 1) [kLGKit buttonUnselect:playButtonBg color:kColorDark buttonText:playButtonText withText:@"playButtonUnsel"];
    
    if (CGRectContainsPoint(gamecenterButtonBg.boundingBox, touchPoint) && z == 2) ////////// gamecenter //////////
    {
        alertGC = [[UIAlertView alloc] initWithTitle:nil
                                             message:nil
                                            delegate:self
                                   cancelButtonTitle:LGLocalizedString(@"cancel", nil)
                                   otherButtonTitles:LGLocalizedString(@"leaderboards", nil), LGLocalizedString(@"achievements", nil), nil];
        [alertGC show];
    }
    else if (z == 2) [kLGKit buttonUnselect:gamecenterButtonBg color:kColorDark buttonText:gamecenterButtonText withText:@"gamecenterButtonUnsel"];
    
    if (CGRectContainsPoint(optionsButtonBg.boundingBox, touchPoint) && z == 3) ////////// options //////////
    {
        self.isTouchEnabled = NO;
        
        optionsOnScreen = 1;
        bgSecondOnScreen = 1;
        
        [self bgSecondAppear];
        [self optionsLayerAppear];
        
        [kLGKit performSelector:@selector(touchEnableWithTarget:) withObject:self afterDelay:0.3];
    }
    else if (z == 3 && bgSecondOnScreen == 0) [kLGKit buttonUnselect:optionsButtonBg color:kColorDark buttonText:optionsButtonText withText:@"optionsButtonUnsel"];
    
    if (CGRectContainsPoint(highscoresButtonBg.boundingBox, touchPoint) && z == 4) ////////// highscores //////////
    {
        self.isTouchEnabled = NO;
        
        [self allSpritesDisappear];
        [self performSelector:@selector(goToHighscores) withObject:nil afterDelay:.2];
    }
    else if (z == 4) [kLGKit buttonUnselect:highscoresButtonBg color:kColorDark buttonText:highscoresButtonText withText:@"highscoresButtonUnsel"];
    
    if (CGRectContainsPoint(helpButtonBg.boundingBox, touchPoint) && z == 5) ////////// help //////////
    {
        self.isTouchEnabled = NO;
        
        helpOnScreen = 1;
        bgSecondOnScreen = 1;
        
        [self bgSecondAppear];
        [self helpLayerAppear];
        
        [kLGKit performSelector:@selector(touchEnableWithTarget:) withObject:self afterDelay:0.3];
    }
    else if (z == 5 && bgSecondOnScreen == 0) [kLGKit buttonUnselect:helpButtonBg color:kColorDark buttonText:helpButtonText withText:@"helpButtonUnsel"];
    
    if (CGRectContainsPoint(newsButtonBg.boundingBox, touchPoint) && z == 6) ////////// news //////////
    {
        self.isTouchEnabled = NO;
        
        newsOnScreen = 1;
        bgSecondOnScreen = 1;
        
        [self bgSecondAppear];
        [self newsLayerAppear];
        
        [kLGKit performSelector:@selector(touchEnableWithTarget:) withObject:self afterDelay:0.3];
    }
    else if (z == 6 && bgSecondOnScreen == 0) [kLGKit buttonUnselect:newsButtonBg color:kColorDark buttonText:newsButtonText withText:@"newsButtonUnsel"];
    
    if (CGRectContainsPoint(purchasesButtonBg.boundingBox, touchPoint) && z == 7) ////////// purchases //////////
    {
        self.isTouchEnabled = NO;
        
        purchasesOnScreen = 1;
        bgSecondOnScreen = 1;
        
        kInternetStatus;
        
        [self bgSecondAppear];
        [self purchasesLayerAppear];
        
        [kLGKit performSelector:@selector(touchEnableWithTarget:) withObject:self afterDelay:0.3];
    }
    else if (z == 7 && bgSecondOnScreen == 0) [kLGKit buttonUnselect:purchasesButtonBg color:kColorGreen buttonText:purchasesButtonText withText:@"purchasesButtonUnsel"];
    
    if (CGRectContainsPoint(moreGamesButton.boundingBox, touchPoint) && z == 8) ////////// moreGames //////////
    {
        self.isTouchEnabled = NO;
        
        moreGamesOnScreen = 1;
        bgSecondOnScreen = 1;
        
        [self bgSecondAppear];
        [self moreGamesLayerAppear];
        
        [kLGKit performSelector:@selector(touchEnableWithTarget:) withObject:self afterDelay:0.3];
    }
    else if (z == 8 && bgSecondOnScreen == 0) moreGamesButton.texture = moreGamesT2D[0];
    
    z = 0;
}

@end
