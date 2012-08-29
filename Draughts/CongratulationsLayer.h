//
//  CongratulationsLayer.h
//  Draughts
//
//  Created by Cyril Savitsky on 8/8/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameLevelLayer.h"
#import "LoadingLayer.h"

@interface CongratulationsLayer : CCLayer {
    
}

+ (id) createCongratsWith:(NSString *)winner;
- (id) initWith:(NSString *)winner;

@end
