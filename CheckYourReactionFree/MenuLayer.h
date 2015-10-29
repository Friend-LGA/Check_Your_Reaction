//
//  Created by Grigory Lutkov on 03.03.11.
//  Copyright 2011 Apogee Studio. All rights reserved.
//

#import "cocos2d.h"
#import "Reachability.h"

@interface MenuLayer : CCLayer
{
	float           lastScoreReturned;
    float           bestScoreReturned;
    int             z;
    int             colorOfLight;
    int             difficulty;
    int             gameMode;
    int             bgSecondOnScreen;
    int             helpOnScreen;
    int             optionsOnScreen;
    int             newsOnScreen;
    int             purchasesOnScreen;
    int             moreGamesOnScreen;
    int             aboutFontSize;
    int             titleFontSize;
    int             textsFontSize;
    int             textButtonsFontSize;
    int             textBorderSize;
    
    ccColor3B       light;
    ccColor3B       dark;
    
    CCTexture2D     *moreGamesT2D[2];
    CCSprite        *moreGamesButton;
	
    CCSprite        *iAdBanner;
	CCSprite        *bg;
    CCSprite        *bgSecond;
    CCSprite        *logo;
    
	CCLabelTTF      *closeButton;
    CCLabelTTF      *closeButtonStroke;
    
    CCLabelTTF      *copyrightButton;
    
    CCSprite        *playButton;
    CCLabelTTF      *playButtonBg;
    CCLabelTTF      *playButtonStroke;
    CCLabelTTF      *playButtonText;
    CCLabelTTF      *helpButton;
    CCLabelTTF      *helpButtonBg;
    CCLabelTTF      *helpButtonStroke;
    CCLabelTTF      *helpButtonText;
    CCLabelTTF      *newsButton;
    CCLabelTTF      *newsButtonBg;
    CCLabelTTF      *newsButtonStroke;
    CCLabelTTF      *newsButtonText;
    CCLabelTTF      *purchasesButton;
    CCLabelTTF      *purchasesButtonBg;
    CCLabelTTF      *purchasesButtonStroke;
    CCLabelTTF      *purchasesButtonText;
    CCSprite        *highscoresButton;
    CCLabelTTF      *highscoresButtonBg;
    CCLabelTTF      *highscoresButtonStroke;
    CCLabelTTF      *highscoresButtonText;
    CCSprite        *gamecenterButton;
    CCLabelTTF      *gamecenterButtonBg;
    CCLabelTTF      *gamecenterButtonStroke;
    CCLabelTTF      *gamecenterButtonText;
    CCSprite        *optionsButton;
    CCLabelTTF      *optionsButtonBg;
    CCLabelTTF      *optionsButtonStroke;
    CCLabelTTF      *optionsButtonText;
    
	CCLabelTTF      *bestScore;
	CCLabelTTF      *bestScoreValue;
	CCLabelTTF      *lastScore;
	CCLabelTTF      *lastScoreValue;
    
    CCLabelTTF      *newsTitle;
    CCLabelTTF      *newsAbout;
    
    CCLabelTTF      *purchasesTitle;
    CCLabelTTF      *removeAdsText;
    CCLabelTTF      *removeAdsStatus;
    CCLabelTTF      *restoreText;
    CCLabelTTF      *donateTitle;
    CCLabelTTF      *donate1;
    CCLabelTTF      *donate1Bg;
    CCLabelTTF      *donate1Stroke;
    CCLabelTTF      *donate3;
    CCLabelTTF      *donate3Bg;
    CCLabelTTF      *donate3Stroke;
    CCLabelTTF      *donate5;
    CCLabelTTF      *donate5Bg;
    CCLabelTTF      *donate5Stroke;
    CCLabelTTF      *donate10;
    CCLabelTTF      *donate10Bg;
    CCLabelTTF      *donate10Stroke;
    CCLabelTTF      *donate25;
    CCLabelTTF      *donate25Bg;
    CCLabelTTF      *donate25Stroke;
    CCLabelTTF      *internetAvailabilityTitle;
    CCLabelTTF      *internetAvailabilityStatus;
    
    CCLabelTTF      *moreGamesTitle;
    CCLabelTTF      *separatorL[2];
    
    CCLabelTTF      *helpTitle;
    CCLabelTTF      *helpAbout;
    CCSprite        *iconCYCV;
    CCLabelTTF      *iconCYCVName;
    CCLabelTTF      *iconCYCVPrice;
    CCLabelTTF      *iconCYCVDownload;
    CCLabelTTF      *goToAppStore;
    
    CCLabelTTF      *optionsTitle;
    CCLabelTTF      *blueButton;
	CCLabelTTF      *greenButton;
	CCLabelTTF      *yellowButton;
	CCLabelTTF      *violetButton;
	CCLabelTTF      *orangeButton;
	CCLabelTTF      *easyButton;
	CCLabelTTF      *normalButton;
	CCLabelTTF      *hardButton;
	CCLabelTTF      *insaneButton;
    CCLabelTTF      *onePlayer;
    CCLabelTTF      *twoPlayers;
    CCLabelTTF      *selectColorOfLight;
	CCLabelTTF      *selectDifficulty;
    CCLabelTTF      *selectGameMode;
    CCLabelTTF      *selectLanguage;
    CCLabelTTF      *englishButton;
    CCLabelTTF      *russianButton;
    CCLabelTTF      *selectSound;
    CCLabelTTF      *soundOn;
    CCLabelTTF      *soundOff;
    CCLabelTTF      *followUs;
    CCLabelTTF      *facebook;
    CCLabelTTF      *twitter;
    CCLabelTTF      *vkontakte;
    
    Reachability    *internetReach;
    
    UIAlertView     *alertGC;
    UIAlertView     *rateAlert;
	
	NSUserDefaults      *defaults;
	CGSize              winSize;
	UITouch             *touch;
	CGPoint             touchPoint;
    
    CGPoint         closeButtonPos;
    CGPoint         logoPos;
    CGPoint         playPos;
    CGPoint         highscoresPos;
    CGPoint         optionsPos;
    CGPoint         gamecenterPos;
    CGPoint         helpPos;
    CGPoint         purchasesPos;
    CGPoint         newsPos;
    CGPoint         helpTitlePos;
    CGPoint         optionsTitlePos;
    CGPoint         newsTitlePos;
    CGPoint         purchasesTitlePos;
    CGPoint         selectDifficultyPos;
    CGPoint         selectGameModePos;
}

+ (id) scene;

@end
