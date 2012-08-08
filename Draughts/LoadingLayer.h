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
}

+ (id) loadTargetScene:(TargetScenes)loadScene;
- (id) initWithScene:(TargetScenes)loadScene;

@end