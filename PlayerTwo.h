//
//  PlayerTwo.h
//  Draughts
//
//  Created by Cyril Savitsky on 8/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "PlayerEntity.h"
#import "PlayerOne.h"
#import "Figure.h"
#import "GameLevelLayer.h"

@interface PlayerTwo : PlayerEntity {
    int _score;
    BOOL _yourMove;
    BOOL _anotherMove;
    Figure *_killerFigure;
    BOOL _playVersusUser;
}

@property(nonatomic,assign) int score;
@property(nonatomic,assign) BOOL yourMove;
@property(nonatomic,assign) BOOL anotherMove;
@property(nonatomic,assign) BOOL playVersusUser;
@property(nonatomic,assign) Figure *killerFigure;

+ (PlayerTwo *) sharedSecondPlayer;
- (id) initWithFigures:(NSString *)figureName boardSize:(float) boardSize startPoint:(CGPoint)startPoint
                border:(float)border oneStep:(float)oneStep player:(int)player gameType:(int)gameType playerTwo:(BOOL)playerTwo;

- (void) findPossibleMovesForFigure:(Figure *)figure killingMovesOnly:(BOOL)killingMovesOnly option:(NSString *)option;
- (BOOL) canFigure:(Figure *)figure beKilledAt:(CGPoint)point;

- (void) makeAMove;
- (void) moveFigure:(Figure *)figure to:(CGPoint)point;
- (CGPoint) checkFiguresToKillFrom:(CGPoint)point previousPoint:(CGPoint)previousPoint with:(Figure *)figure;
- (void) killFigure:(Figure *)killIt with:(Figure *)killer;
- (CGRect) killNextWith:(Figure *)figure;
- (CGPoint) findNearestOpponentTo:(Figure *)figure;
- (float) pathToOpponentFrom:(Figure *)figure;
- (void) checkForKingsPositionFor:(Figure *)figure;
- (void) checkForKingsPosition:(id)sender data:(Figure *)figure;

@end
