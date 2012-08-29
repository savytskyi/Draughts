#import "LoadingLayer.h"

@implementation LoadingLayer

+ (id) loadTargetScene:(TargetScenes)loadScene withGameType:(int)gameType playerTwo:(BOOL)playerTwo {
    return [[[self alloc] initWithScene:loadScene withGameType:gameType playerTwo:playerTwo] autorelease];
}

- (id) initWithScene:(TargetScenes)loadScene withGameType:(int)gameType playerTwo:(BOOL)playerTwo {
    if ( (self = [super init]) ) {
        targetScene = loadScene;
        //CCLabelTTF *loadingLabel = [CCLabelTTF labelWithString:@"Loading..." fontName:@"Helvetica" fontSize:24];
        CCSprite *loading = [CCSprite spriteWithFile:@"loading.png"];
        newGameType = gameType;
        newPlayerTwo = playerTwo;
        
        CGSize size = [[CCDirector sharedDirector] winSize];
        loading.position = ccp(size.width * 0.5f, size.height * 0.5f);
        //loadingLabel.position = CGPointMake(size.width/2, size.height/2);
        [self addChild:loading];
        
        [self scheduleUpdate];
    }
    return self;
}

- (void) update: (ccTime) delta {
    [self unscheduleAllSelectors];
    
    //remove unused textures
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    
    switch (targetScene) {
        case TargetSceneMainMenu:
            [[CCDirector sharedDirector] replaceScene:[MainMenuLayer scene]];
            break;
            
        case TargetSceneFirstLevel:
            [[CCDirector sharedDirector] replaceScene:[GameLevelLayer sceneWithGameType:newGameType playerTwo:newPlayerTwo]];
            break;
            
        case TargetSceneSecondLevel:
            //second scene
            break;
            
        default:
            //[NSString stringWithFormat:@"LoadingLayer.m: there is no game scene with this targetScene: %i",targetScene];
            NSAssert(nil,@"LoadingLayer.m: there is no game scene with this targetScene.");
            break;
    }
}

- (void) dealloc {
    [super dealloc];
}


@end
