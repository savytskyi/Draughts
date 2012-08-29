//
//  CongratulationsLayer.m
//  Draughts
//
//  Created by Cyril Savitsky on 8/8/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CongratulationsLayer.h"


@implementation CongratulationsLayer

+ (id) createCongratsWith:(NSString *)winner {
    return [[[self alloc] initWith:winner] autorelease];
}

- (id) initWith:(NSString *)winner {
    if ((self = [super init])) {
        self.isTouchEnabled = YES;
        CCLabelTTF *congrats = [CCLabelTTF labelWithString:@"Congratulations," fontName:@"Helvetica" fontSize:82];
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        congrats.position = ccp(screenSize.width * 0.5f, screenSize.height * 0.5f);
        [self addChild:congrats z:5 tag:tagNewGame];
        CCLabelTTF *name = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@!", winner] fontName:@"Helvetica" fontSize:32];
        name.position = ccp(congrats.position.x, congrats.position.y - 2.f * name.contentSize.height);
        [self addChild:name z:5 tag:tagNewGameName];

    }
    return self;
}

- (void) registerWithTouchDispatcher {
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:-1 swallowsTouches:YES];
}

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [GameLevelLayer locationFromTouch:touch];
    if (CGRectContainsPoint([[self getChildByTag:tagNewGame] boundingBox], location) ||
        CGRectContainsPoint([[self getChildByTag:tagNewGameName] boundingBox], location) ||
        CGRectContainsPoint([[self getChildByTag:tagNewGameReason] boundingBox], location)) {
        [[CCDirector sharedDirector] replaceScene:[LoadingLayer loadTargetScene:TargetSceneFirstLevel withGameType:0 playerTwo:YES]];
        return YES;
    }
    return NO;
}

@end
