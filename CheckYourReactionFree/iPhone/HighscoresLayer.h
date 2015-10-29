//
//  Created by Grigory Lutkov on 24.03.11.
//  Copyright 2011 Apogee Studio. All rights reserved.
//

#import "cocos2d.h"
#import "Vkontakte.h"

@interface HighscoresLayer : CCLayer <VkontakteDelegate>
{
	int                 currentScorePosition;
	int                 i;
    int                 z;
    int                 changer;
    int                 difficulty;
    int                 stripeHeight;
    int                 gamecenterButtonBgFontSize;
    int                 scoreFontSize;
    int                 gcButtonPosY;
    int                 count;
    int                 socialFontSize;
	float               score;
	float               currentScore;
    float               bestScore;
	
    CCSprite            *iAdBanner;
    CCSprite            *strips;
    CCSprite            *backButton;
    CCSprite            *playButton;
	CCSprite            *gamecenterButton;
    CCLabelTTF          *gamecenterButtonBg;
    CCLabelTTF          *gamecenterButtonStroke;
    CCLabelTTF          *facebookButton;
    CCLabelTTF          *facebookButtonBg;
    CCLabelTTF          *facebookButtonStroke;
    CCLabelTTF          *twitterButton;
    CCLabelTTF          *twitterButtonBg;
    CCLabelTTF          *twitterButtonStroke;
    CCLabelTTF          *vkontakteButton;
    CCLabelTTF          *vkontakteButtonBg;
    CCLabelTTF          *vkontakteButtonStroke;
    CCLabelTTF          *synchronizeGC;
	CCSprite            *easyButton;
	CCSprite            *normalButton;
	CCSprite            *hardButton;
    CCSprite            *insaneButton;
    
    CCTexture2D         *backButtonT[2];
    CCTexture2D         *playButtonT[2];
    CCTexture2D         *easyButtonT[2];
    CCTexture2D         *normalButtonT[2];
    CCTexture2D         *hardButtonT[2];
    CCTexture2D         *insaneButtonT[2];
    
	CCLabelTTF          *number[15];
	CCLabelTTF          *timing[15];
	CCLabelTTF          *currentScoreText;
	CCLabelTTF          *currentScoreLabel;
	
	NSMutableArray      *highscores;
	NSArray             *highscore;
	CGSize              winSize;
    UITouch             *touch;
	CGPoint             touchPoint;
    
    UIAlertView         *alertGC;
    UIAlertView         *alertVK;
}

+ (id) scene;

@end
