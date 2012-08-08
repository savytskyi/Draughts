//
//  CongratulationsLayer.m
//  Draughts
//
//  Created by Cyril Savitsky on 8/8/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CongratulationsLayer.h"


@implementation CongratulationsLayer

+ (id) sceneWith:(NSString *)winner {
    CCScene *scene = [CCScene node];
    CongratulationsLayer *layer = [[[CongratulationsLayer alloc] initWithPlayer:winner] autorelease];
    [scene addChild:layer];
    return scene;
}

- (id) initWithPlayer:(NSString *)winner {
    if ((self = [super init])) {
        self.isTouchEnabled = YES;
        CCLabelTTF *congrats = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Congratulations, %@", winner] fontName:@"Helvetica" fontSize:64];
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        congrats.position = ccp(screenSize.width * 0.5f, screenSize.height * 0.5f);
        [self addChild:congrats z:5 tag:tagNewGame];

    }
    return self;
}

- (void) registerWithTouchDispatcher {
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CCLOG(@"CONTROLLING TOUCHES");
    CGPoint location = [GameLevelLayer locationFromTouch:touch];
    if (CGRectContainsPoint([[self getChildByTag:tagSettings] boundingBox], location)) {
        CCLOG(@"Settings");
        return YES;
    }
    if (CGRectContainsPoint([[self getChildByTag:tagNewGame] boundingBox], location)) {
        //[[PlayerTwo sharedSecondPlayer] dealloc];
        //[[PlayerOne sharedFirstPlayer] dealloc];
        //        [[CCDirector sharedDirector] pushScene:[LoadingLayer loadTargetScene:TargetSceneFirstLevel]];
        [[GameLevelLayer sharedGameLevelLayer] init];
        //        [[CCDirector sharedDirector] pushScene:[GameLevelLayer scene]];
        //        [[CCDirector sharedDirector] popScene];
        
        
        //[[CCDirector sharedDirector] removeFromParentViewController];
        //[[CCDirector sharedDirector] replaceScene:[LoadingLayer loadTargetScene:TargetSceneFirstLevel]];
        return YES;
    }
    return YES;
}

@end
