//
//  SettingsLayer.m
//  Draughts
//
//  Created by Cyril Savitsky on 8/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsLayer.h"


@implementation SettingsLayer

static SettingsLayer *instanceOfSettingsLayer;

+ (SettingsLayer *) sharedSettingsLayer {
    NSAssert(instanceOfSettingsLayer != nil, @"Settings instance still doesn't initialized");
    return instanceOfSettingsLayer;
}


- (id) init {
    if ((self = [super init])) {
        self.isTouchEnabled = YES;
        instanceOfSettingsLayer = self;
        CCLabelTTF *temp = [CCLabelTTF labelWithString:@"Settings" fontName:@"Helvetica" fontSize:32];
        temp.position = ccp(200,32);
        [self addChild:temp z:0 tag:tagSettings];
        
        CCSprite *user = [CCSprite spriteWithSpriteFrameName:@"user.png"];
        CCSprite *ipad = [CCSprite spriteWithSpriteFrameName:@"ipad.png"];
        CCSprite *ledOn = [CCSprite spriteWithSpriteFrameName:@"blue_led.png"];
        CCSprite *ledOff = [CCSprite spriteWithSpriteFrameName:@"blue_led_off.png"];
        //computerVSUser.rotation = 180.0f;
        //computerVSUserButton.rotation = 180.0f;
        user.anchorPoint = ccp(0.5f,0.f);
        ipad.anchorPoint = ccp(0.5f,0.f);
        ledOff.anchorPoint = ccp(0.5f,0.f);
        ledOn.anchorPoint = ccp(0.5f,0.f);
        
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        
        //computerVSUser.position = ccp(200.f,screenSize.height - 70.f);
        user.position = ccp(screenSize.width - user.contentSize.width - 100, 30.f);
        ipad.position = ccp(screenSize.width - user.contentSize.width - 10, 30.f);
        ledOff.position = ccp(screenSize.width - user.contentSize.width - 10, 3.f);
        ledOn.position = ccp(screenSize.width - user.contentSize.width - 100, 3.f);
        [self addChild:ipad];
        [self addChild:user];
        [self addChild:ledOff];
        [self addChild:ledOn];
    }
    return self;
}

- (void) registerWithTouchDispatcher {
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [GameLevelLayer locationFromTouch:touch];
    if (CGRectContainsPoint([[self getChildByTag:tagSettings] boundingBox], location)) {
        CCLOG(@"Settings");
        return YES;
    }
    if (CGRectContainsPoint([[self getChildByTag:tagNewGame] boundingBox], location)) {
        //[[PlayerTwo sharedSecondPlayer] dealloc];
        //[[PlayerOne sharedFirstPlayer] dealloc];
        //        [[CCDirector sharedDirector] pushScene:[LoadingLayer loadTargetScene:TargetSceneFirstLevel]];
        //[[GameLevelLayer sharedGameLevelLayer] init];
        //        [[CCDirector sharedDirector] pushScene:[GameLevelLayer scene]];
        //        [[CCDirector sharedDirector] popScene];
        
        
        //[[CCDirector sharedDirector] removeFromParentViewController];
        [[CCDirector sharedDirector] replaceScene:[LoadingLayer loadTargetScene:TargetSceneFirstLevel]];
        return YES;
    }
    return YES;
    
}

- (void) showCongratulationsFor:(NSString *)winner {
    CCLabelTTF *congrats = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Congratulations, %@", winner] fontName:@"Helvetica" fontSize:64];
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    congrats.position = ccp(screenSize.width * 0.5f, screenSize.height * 0.5f);
    [self addChild:congrats z:5 tag:tagNewGame];
}

@end
