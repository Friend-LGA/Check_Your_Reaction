//
//  Created by Grigory Lutkov on 01.10.12.
//  Copyright (c) 2012 Grigory Lutkov. All rights reserved.
//

#import "LGGameCenter.h"
#import "AppController.h"
#import "LGLocalization.h"
#import "LGReachability.h"
#import "LGKit.h"

@implementation LGGameCenter

//Singleton instance
static LGGameCenter *_sharedManager = nil;

@synthesize achievementsDictionaryOnline,
achievementsDictionaryLocal,
window = window_;

#pragma mark - Singleton Methods

+ (LGGameCenter *)sharedManager
{
	@synchronized([LGGameCenter class])
	{
		if (!_sharedManager) _sharedManager = [[self alloc] init];
        
		return _sharedManager;
	}
	// to avoid compiler warning
	return nil;
}

+ (id)alloc
{
	@synchronized([LGGameCenter class])
	{
		NSAssert(_sharedManager == nil, @"Attempted to allocate a second instance of a singleton.");
		_sharedManager = [super alloc];
		return _sharedManager;
	}
	// to avoid compiler warning
	return nil;
}

- (id)init
{
    if ((self = [super init]))
    {
        NSLog(@"LGGameCenter: Initialising...");
        
        achievementsDictionaryOnline = [[NSMutableDictionary alloc] init]; // получаемый онлайн
        
        // хранимый локально
        if ([kLGKit objectForKey:@"achievementsDictionaryLocal"]) achievementsDictionaryLocal = [[NSMutableDictionary alloc] initWithDictionary:[kLGKit objectForKey:@"achievementsDictionaryLocal"]];
        else achievementsDictionaryLocal = [[NSMutableDictionary alloc] init];
        
        [self authenticateLocalPlayer];
    }
	return self;
}

#pragma mark - Init Methods

- (void)authenticateLocalPlayer
{
    GKLocalPlayer *_localPlayer = [GKLocalPlayer localPlayer];
    __weak GKLocalPlayer *localPlayer = _localPlayer;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
    {
        localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error)
        {
            UINavigationController *navigationController = [(AppController *)[[UIApplication sharedApplication] delegate] navigationController];
            
            if (viewController) [navigationController presentModalViewController:viewController animated:YES];
            else if (localPlayer.isAuthenticated)
            {
                NSLog(@"LGGameCenter: Player Authentication Success");
                if (kInternetStatus) [self loadAchievements];
            }
            else NSLog(@"LGGameCenter: Player Authentication Error: %@", error);
        };
    }
    else
    {
        [localPlayer authenticateWithCompletionHandler:^(NSError *error)
         {
             if (localPlayer.isAuthenticated)
             {
                 NSLog(@"LGGameCenter: Player Authentication Success");
                 if (kInternetStatus) [self loadAchievements];
             }
             else NSLog(@"LGGameCenter: Player Authentication Error: %@", error);
         }];
    }
}

- (BOOL)isGameCenterEnable
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    if (localPlayer.isAuthenticated) return YES;
    else return NO;
}

#pragma mark - Leaderboard

- (void)showLeaderboard:(NSString *)category
{
    UINavigationController *navigationController = [(AppController *)[[UIApplication sharedApplication] delegate] navigationController];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
    {
        GKGameCenterViewController *gameCenterVC = [[GKGameCenterViewController alloc] init];
        if (gameCenterVC)
        {
            gameCenterVC.gameCenterDelegate = self;
            gameCenterVC.viewState = GKGameCenterViewControllerStateLeaderboards;
            gameCenterVC.leaderboardCategory = category;
            [navigationController presentViewController:gameCenterVC animated:YES completion:nil];
        }
    }
    else
    {
        GKLeaderboardViewController *leaderboardVC = [[GKLeaderboardViewController alloc] init];
        if (leaderboardVC)
        {
            leaderboardVC.category = category;
            leaderboardVC.timeScope = GKLeaderboardTimeScopeAllTime;
            leaderboardVC.leaderboardDelegate = self;
            [navigationController presentModalViewController:leaderboardVC animated:YES];
        }
    }
}

- (void)submitScore:(int64_t)score forCategory:(NSString *)category withAlert:(BOOL)alert
{
	GKScore *scoreReporter = [[GKScore alloc] initWithCategory:category];
	scoreReporter.value = score;
	[scoreReporter reportScoreWithCompletionHandler: ^(NSError *error)
     {
         if (error)
         {
             NSLog(@"LGGameCenter: Submit Highscore (%lli) for category (%@) Error: %@", score, category, error);
             
             if (alert)
             {
                 NSString *message = [NSString stringWithFormat:@"%@\n%@", LGLocalizedString(@"MCGC_errorMessage", nil), error];
                 
                 [[[UIAlertView alloc] initWithTitle:LGLocalizedString(@"MCGC_errorTitle", nil)
                                             message:message
                                            delegate:self
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil] show];
             }
         }
		 else
         {
             NSLog(@"LGGameCenter: Submit Highscore (%lli) for category (%@) Success", score, category);
             
             if (alert)
             {
                 if (kInternetStatus)
                 {
                     NSString *message = [NSString stringWithFormat:@"%@ (%lli) %@", LGLocalizedString(@"MCGC_highscoreText", nil), score, LGLocalizedString(@"MCGC_successMessage", nil)];
                     
                     [[[UIAlertView alloc] initWithTitle:LGLocalizedString(@"MCGC_successTitle", nil)
                                                 message:message
                                                delegate:self
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil] show];
                 }
                 else [kLGKit createAlertNoInternet];
             }
         }
     }];
}

#pragma mark - Achievements

- (void)showAchievements
{
    UINavigationController *navigationController = [(AppController *)[[UIApplication sharedApplication] delegate] navigationController];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
    {
        GKGameCenterViewController *gameCenterVC = [[GKGameCenterViewController alloc] init];
        if (gameCenterVC)
        {
            gameCenterVC.gameCenterDelegate = self;
            gameCenterVC.viewState = GKGameCenterViewControllerStateAchievements;
            [navigationController presentViewController:gameCenterVC animated:YES completion:nil];
        }
    }
    else
    {
        GKAchievementViewController *achivementVC = [[GKAchievementViewController alloc] init];
        if (achivementVC)
        {
            achivementVC.achievementDelegate = self;
            [navigationController presentModalViewController:achivementVC animated:YES];
        }
    }
}

- (void)submitAchievement:(NSString *)identifier percentComplete:(float)percent
{
    if (!isAchievementsLoaded && kInternetStatus) [self loadAchievements];
    
    if (!kIsAchievementEarned(identifier) || (kIsAchievementEarned(identifier) == 2 && isAchievementsLoaded))
    {
        GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier:identifier];
        
        achievement.percentComplete = percent;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0 && ![achievementsDictionaryLocal objectForKey:achievement.identifier]) achievement.showsCompletionBanner = YES;
        
        [achievementsDictionaryOnline setObject:achievement forKey:achievement.identifier];
        [achievementsDictionaryLocal setObject:achievement forKey:achievement.identifier];
        [kLGKit setObject:achievementsDictionaryLocal forKey:@"achievementsDictionaryLocal"];
        
        [achievement reportAchievementWithCompletionHandler:^(NSError *error)
         {
             if (error != nil)
                 NSLog(@"LGGameCenter: Submit Achievement (%@) Error: %@", achievement.identifier, error.localizedDescription);
             else
                 NSLog(@"LGGameCenter: Submit Achievement (%@) Success", achievement.identifier);
         }];
    }
    else
    {
        GKAchievement *achievement = [achievementsDictionaryLocal objectForKey:identifier];
        NSLog(@"LGGameCenter: Achievement (%@) already Earned", achievement.identifier);
    }
}

- (void)loadAchievements
{
    [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error)
     {
         if (error)
         {
             NSLog(@"LGGameCenter: Load Achievements Error: %@", error.localizedDescription);
         }
         else
         {
             // получаем список ачивок из инета
             for (GKAchievement *achievement in achievements)
             {
                 [achievementsDictionaryOnline setObject:achievement forKey:achievement.identifier];
                 
                 NSString *percentCompleteString = [NSString stringWithFormat:@"%.0f", achievement.percentComplete];
                 NSLog(@"Achievement: %@|  Percent complete: %@|  Online",
                       [achievement.identifier stringByAppendingString:[@"                                                                      " substringFromIndex:[achievement.identifier length]]],
                       [percentCompleteString stringByAppendingString:[@"     " substringFromIndex:[percentCompleteString length]]]);
             }
             
             NSMutableArray *achievementsArray = [NSMutableArray array];
             
             // получаем локальный список ачивок и сверяем его с онлайновым
             for (id key in achievementsDictionaryLocal)
             {
                 GKAchievement *achievement = [achievementsDictionaryLocal objectForKey:key];
                 
                 NSString *percentCompleteString = [NSString stringWithFormat:@"%.0f", achievement.percentComplete];
                 NSLog(@"Achievement: %@|  Percent complete: %@|  Local",
                       [achievement.identifier stringByAppendingString:[@"                                                                      " substringFromIndex:[achievement.identifier length]]],
                       [percentCompleteString stringByAppendingString:[@"     " substringFromIndex:[percentCompleteString length]]]);
                 
                 if (![achievementsDictionaryOnline objectForKey:key]) [achievementsArray addObject:achievement];
             }
             
             isAchievementsLoaded = YES;
             NSLog(@"LGGameCenter: Load Achievements Success");
             
             // синхронизируем недостающие ачивки с GC
             for (GKAchievement *achievement in achievementsArray)
             {
                 [self submitAchievement:achievement.identifier percentComplete:100];
             }
         }
     }];
}

- (void)resetAchievementsWithAlert:(BOOL)alert
{
    if (kInternetStatus)
    {
        // Clear all locally saved achievement objects.
        achievementsDictionaryOnline = nil;
        achievementsDictionaryLocal = nil;
        [kStandartUserDefaults setObject:nil forKey:@"achievementsDictionaryLocal"];
        
        // Clear all progress saved on Game Center.
        [GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error)
         {
             if (error)
                 NSLog(@"LGGameCenter: Reset Achievements Error: %@", error.localizedDescription);
             else
                 NSLog(@"LGGameCenter: Reset Achievements Success");
         }];
    }
    else if (alert) [kLGKit createAlertNoInternet];
}

- (int)isAchievementEarned:(NSString *)identifier
{
    if (![achievementsDictionaryLocal objectForKey:identifier] && ![achievementsDictionaryOnline objectForKey:identifier])
        return 0; // ачивка не заработана
    else if ([achievementsDictionaryLocal objectForKey:identifier] && [achievementsDictionaryOnline objectForKey:identifier])
        return 1; // ачивка заработана
    else if ([achievementsDictionaryLocal objectForKey:identifier] && ![achievementsDictionaryOnline objectForKey:identifier])
        return 2; // ачивка заработана только оффлайн
    else
        return 3; // ачивка заработана только онлайн - невозможно
}

#pragma mark - Delegates

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	[kNavController dismissModalViewControllerAnimated:YES];
}

- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	[kNavController dismissModalViewControllerAnimated:YES];
}

- (void)gameCenterViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	[kNavController dismissModalViewControllerAnimated:YES];
}

@end
