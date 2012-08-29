//
//  SettingsLayer.h
//  Draughts
//
//  Created by Cyril Savitsky on 8/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameLevelLayer.h"
#import "PlayerEntity.h"
#import "PlayerOne.h"
#import "PlayerTwo.h"
#import "LoadingLayer.h"
#import "UserControls.h"

@interface SettingsLayer : CCLayer {
    float rightSettingsBorder;
    float leftSettingsBorder;
    float upperSettingsBorder;
    float lowerSettingsBorder;
    float textureSize;
    BOOL makeAMoveAfterSettingsClosing;
}

+ (id) scene;
+ (SettingsLayer *) sharedSettingsLayer;

- (void) drawSettingsMenuBackgound;
- (void) addSettiingsMenuItems;

@end
