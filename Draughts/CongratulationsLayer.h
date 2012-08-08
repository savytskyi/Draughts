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

typedef enum {
    tagNewGame1,
}congratsLayerObjects;

@interface CongratulationsLayer : CCLayer {
    
}

+ (id) sceneWith:(NSString *)winner;
- (id) initWith:(NSString *)winner;

@end
