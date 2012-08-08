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

typedef enum {
    tagSettings,
    tagNewGame,
}settingsLayerObjects;

@interface SettingsLayer : CCLayer {
    
}

+ (SettingsLayer *) sharedSettingsLayer;
- (void) showCongratulationsFor:(NSString *)winner;

@end
