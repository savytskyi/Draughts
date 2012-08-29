//
//  UserControls.m
//  Draughts
//
//  Created by Cyril Savitsky on 8/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "UserControls.h"


@implementation UserControls

static UserControls *instanceOfUserControlsLayer;

+ (UserControls *) sharedUserControls {
    NSAssert(instanceOfUserControlsLayer != nil, @"UserControls instance still doesn't initialized");
    return instanceOfUserControlsLayer;
}

- (id) init {
    if ((self = [super init])) {
        self.isTouchEnabled = YES;
        instanceOfUserControlsLayer = self;
        
        CCSprite *settingsIcon = [CCSprite spriteWithSpriteFrameName:@"Gear.png"];
        settingsIcon.position = ccp(settingsIcon.contentSize.width, settingsIcon.contentSize.width);
        settingsIcon.scale = 1.2f;
        [self addChild:settingsIcon z:zForSettingsLayerButton tag:tagSettingsButton];
    }
    return self;
}

- (void) registerWithTouchDispatcher {
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [GameLevelLayer locationFromTouch:touch];
    if (CGRectContainsPoint([[self getChildByTag:tagSettingsButton] boundingBox], location)) {
        CCLOG(@"settings");
        //[[CCDirector sharedDirector] pushScene:[SettingsLayer scene]];
        SettingsLayer *settings = [SettingsLayer node];
        [self addChild:settings z:zForSettingsLayer tag:tagSettingsLayer];
        return YES;
    }
    
    
    return YES;
    
}

- (void) dealloc {
    [super dealloc];
}

@end
