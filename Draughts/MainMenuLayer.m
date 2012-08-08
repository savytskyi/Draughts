#import "MainMenuLayer.h"

@implementation MainMenuLayer

static MainMenuLayer *instanceOfMainMenuLayer;

+ (MainMenuLayer*) sharedMainMenuLayer {
    NSAssert(instanceOfMainMenuLayer != nil,
             @"MainMenuLayer.m: Instance of MainMenuLayer still not initialized");
    return instanceOfMainMenuLayer;
}

+ (id) scene {
    CCScene *scene = [CCScene node];
    MainMenuLayer *menuLayer = [MainMenuLayer node];
    [scene addChild:menuLayer];
    return scene;
}

- (id) init {
    if ((self = [super init])) {
        CCLabelTTF *touchToPlay = [CCLabelTTF labelWithString:@"Touch to play" fontName:@"Helvetica" fontSize:24];
        
        CGSize size = [[CCDirector sharedDirector] winSize];
        touchToPlay.position = CGPointMake(size.width/2, size.height/2);
        [self addChild:touchToPlay];
    }
    return self;
}

- (void) dealloc {
    [super dealloc];
}

@end
