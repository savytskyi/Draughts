#import "LoadingLayer.h"

@implementation LoadingLayer

+ (id) loadTargetScene:(TargetScenes)loadScene {
    return [[[self alloc] initWithScene:loadScene] autorelease];
}

- (id) initWithScene:(TargetScenes)loadScene {
    if ( (self = [super init]) ) {
        targetScene = loadScene;
        CCLabelTTF *loadingLabel = [CCLabelTTF labelWithString:@"Loading..." fontName:@"Helvetica" fontSize:24];
        
        CGSize size = [[CCDirector sharedDirector] winSize];
        loadingLabel.position = CGPointMake(size.width/2, size.height/2);
        [self addChild:loadingLabel];
        
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
            [[CCDirector sharedDirector] replaceScene:[GameLevelLayer scene]];
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
