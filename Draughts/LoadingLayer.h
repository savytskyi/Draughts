#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "MainMenuLayer.h"
#import "GameLevelLayer.h"

typedef enum {
    TargetSceneFalse,
    TargetSceneMainMenu,
    TargetSceneFirstLevel,
    TargetSceneSecondLevel,
    TargetSceneMax,
} TargetScenes;

@interface LoadingLayer : CCLayer {
    TargetScenes targetScene;
    int newGameType;
    BOOL newPlayerTwo;
}

+ (id) loadTargetScene:(TargetScenes)loadScene withGameType:(int)gameType playerTwo:(BOOL)playerTwo;
- (id) initWithScene:(TargetScenes)loadScene withGameType:(int)gameType playerTwo:(BOOL)playerTwo;

@end