//
//  PlayerOne.h
//  Draughts
//
//  Created by Cyril Savitsky on 8/5/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "PlayerEntity.h"
#import "PlayerTwo.h"
#import "Figure.h"
#import "GameLevelLayer.h"

@interface PlayerOne : PlayerEntity {
    int _score;
    BOOL _yourMove;
    BOOL _anotherMove;
    Figure *_killerFigure;
}

@property(nonatomic,assign) int score;
@property(nonatomic,assign) BOOL yourMove;
@property(nonatomic,assign) BOOL anotherMove;
@property(nonatomic,assign) Figure *killerFigure;

+ (PlayerOne *) sharedFirstPlayer;
- (id) initWithFigures:(NSString *)figureName boardSize:(float) boardSize startPoint:(CGPoint)startPoint
                border:(float)border oneStep:(float)oneStep player:(int)player;

- (void) findPossibleMovesForFigure:(Figure *)figure killingMovesOnly:(BOOL)killingMovesOnly;

@end
