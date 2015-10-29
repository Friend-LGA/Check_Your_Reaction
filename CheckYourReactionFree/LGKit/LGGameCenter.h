//
//  Created by Grigory Lutkov on 01.10.12.
//  Copyright (c) 2012 Grigory Lutkov. All rights reserved.
//

#import <GameKit/GameKit.h>
#import "AppController.h"

@interface LGGameCenter : NSObject <GKGameCenterControllerDelegate, GKLeaderboardViewControllerDelegate, GKAchievementViewControllerDelegate>
{
    NSMutableDictionary     *achievementsDictionaryOnline;
    NSMutableDictionary     *achievementsDictionaryLocal;
    UIWindow                *window_;
    
    BOOL isAchievementsLoaded;
}

@property (nonatomic, retain) NSMutableDictionary *achievementsDictionaryOnline;
@property (nonatomic, retain) NSMutableDictionary *achievementsDictionaryLocal;
@property (nonatomic, retain) UIWindow *window;

+ (LGGameCenter *)sharedManager;
- (void)authenticateLocalPlayer;
- (void)showLeaderboard:(NSString *)category;
- (void)submitScore:(int64_t)score forCategory:(NSString*)category withAlert:(BOOL)alert;
- (void)showAchievements;
- (void)submitAchievement:(NSString *)identifier percentComplete:(float)percent;
- (void)loadAchievements;
- (void)resetAchievementsWithAlert:(BOOL)alert;
- (int)isAchievementEarned:(NSString *)key;
- (BOOL)isGameCenterEnable;

@end
