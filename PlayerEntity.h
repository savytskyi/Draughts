//
//  PlayerEntity.h
//  Draughts
//
//  Created by Cyril Savitsky on 8/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class Figure;
@class GameLevelLayer;
@class SettingsLayer;
@class CongratulationsLayer;

typedef enum {
    tagMovingSprite,
    tagMovingCrownSprite,
} TagsForFirstPlayerObjects;

@interface PlayerEntity : CCLayer {
    CCSpriteBatchNode *_playerBatch;
    CCSpriteBatchNode *_playerKingsBatch;
    
    int _gameType;
    NSString *defaultFigureTexture;
    Figure *activeFigure;
    float oneCellWidth;
    CCArray *possibleCells;
    CCArray *killingPositions;
    
    CGPoint lastTouchLocation;
    CGPoint firstLocation;
    
    Figure *killedFigure;
    int maxScore;
    
    float kingsYForPlayerOne;
    float kingsYForPlayerTwo;
}

@property(readwrite,assign) CCSpriteBatchNode *playerBatch;

+ (id) createWithFigures:(NSString *)figureName boardSize:(float) boardSize startPoint:(CGPoint)startPoint
               border:(float)border oneStep:(float)oneStep player:(int)player gameType:(int)gameType playerTwo:(BOOL)playerTwo;

- (id) initWithFigures:(NSString *)figureName boardSize:(float) boardSize startPoint:(CGPoint)startPoint
                        border:(float)border oneStep:(float)oneStep player:(int)player gameType:(int)gameType playerTwo:(BOOL)playerTwo;

- (void) markPossibleCell:(CGPoint)point;
- (void) cleanAllPossibleCells;
- (BOOL) checkForPlayerFigures:(CCSpriteBatchNode *)playerBatchNode
            andOpponentFigures:(CCSpriteBatchNode *)opponentBatchNode
                          near:(CGPoint)point player:(int) player
              killingMovesOnly:(BOOL)killingMovesOnly
                        isKing:(BOOL)king
                          from:(CGPoint)from;

- (BOOL) checkForAnyFigureAt:(CGPoint) point;

- (int) isItPossibleToMoveThere:(CGPoint)possiblePoint opponentFigure:(CCSpriteBatchNode *)opponent player:(int)player killingMovesOnly:(BOOL)killingMovesOnly isKing:(BOOL)king;

- (BOOL) continueKillingLine:(CCSpriteBatchNode *)opponent from:(CGPoint)point previousPoint:(CGPoint)previousPoint;
- (BOOL) killActionsAt:(CGPoint)possibleCell;
- (void) findKingSpriteWithPosition:(CGPoint)oldPosition changeItTo:(CGPoint)newPosition command:(NSString *)command;
- (void) endGame;
- (CGRect) getBoardRect;
- (CGPoint) findMultiplierWithLastLocation:(CGPoint)finish startLocation:(CGPoint)start;
- (BOOL) didFigureStoppedBefore:(CGPoint)killedCell from:(CGPoint)firstLocation to:(CGPoint)stopLocation;


@end

