//
//  PlayerTwo.m
//  Draughts
//
//  Created by Cyril Savitsky on 8/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PlayerTwo.h"

@implementation PlayerTwo

static PlayerEntity *instanceOfSecondPlayer;

- (void) registerWithTouchDispatcher {
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:-2 swallowsTouches:YES];
}

- (void) dealloc {
    [super dealloc];
}

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    killedFigure = nil;
    [self cleanAllPossibleCells];
    CGPoint touchLocation = [GameLevelLayer locationFromTouch:touch];
    lastTouchLocation = touchLocation;
    
    BOOL isTouchHandled = NO;
    Figure *figure;
    
    if (_anotherMove == YES && _killerFigure != nil && CGRectContainsPoint([_killerFigure boundingBox], touchLocation)) {
        firstLocation = _killerFigure.position;
        [self findPossibleMovesForFigure:_killerFigure killingMovesOnly:YES];
        isTouchHandled = YES;
        //break;
    }
    if (_yourMove && !_anotherMove)
        CCARRAY_FOREACH([_playerBatch children], figure) {
            if (figure.dead == NO && CGRectContainsPoint([figure boundingBox], touchLocation)) {
                firstLocation = figure.position;
                [self findPossibleMovesForFigure:figure killingMovesOnly:NO];
                isTouchHandled = YES;
                break;
            }
        }
    return isTouchHandled;
}

+ (PlayerEntity *) sharedSecondPlayer {
    NSAssert(instanceOfSecondPlayer != nil, @"PlayerOne instance still doesn't initialized");
    return instanceOfSecondPlayer;
}

- (id) initWithFigures:(NSString *)figureName boardSize:(float)boardSize startPoint:(CGPoint)startPoint border:(float)border oneStep:(float)oneStep player:(int)player gameType:(int)gameType playerTwo:(BOOL)playerTwo {
    if ((self = [super initWithFigures:figureName boardSize:boardSize startPoint:startPoint border:border oneStep:oneStep player:player gameType:gameType playerTwo:playerTwo])) {
        instanceOfSecondPlayer = self;
        _yourMove = NO;
        _anotherMove = NO;
        _score = 0;
        _killerFigure = nil;
        _playVersusUser = playerTwo;
    }
    return self;
}

- (void) findPossibleMovesForFigure:(Figure *)figure killingMovesOnly:(BOOL)killingMovesOnly {
    activeFigure = figure;
    CCSprite *movingImage;
    if ([figure king] == NO)
        movingImage = (CCSprite*)[self getChildByTag:tagMovingSprite];
    else {
        movingImage = (CCSprite *)[self getChildByTag:tagMovingCrownSprite];
        [self findKingSpriteWithPosition:figure.position changeItTo:figure.position command:@"hide"];
    }
    movingImage.position = figure.position;
    movingImage.visible = YES;
    figure.visible = NO;
    
    CGPoint possibleCellPoint = ccp(figure.position.x - oneCellWidth, figure.position.y - oneCellWidth);
    [self isItPossibleToMoveThere:possibleCellPoint opponentFigure:[[PlayerOne sharedFirstPlayer] playerBatch] player:YES killingMovesOnly:killingMovesOnly isKing:[figure king]];
    
    possibleCellPoint = ccp(figure.position.x + oneCellWidth, figure.position.y - oneCellWidth);
    [self isItPossibleToMoveThere:possibleCellPoint opponentFigure:[[PlayerOne sharedFirstPlayer] playerBatch] player:YES killingMovesOnly:killingMovesOnly isKing:[figure king]];
    
    if ((_gameType == 0 && figure.king == YES) || _gameType != 0) {
    //if (figure.king == YES) {
        //In soviet mode game pieces can move backwards ONLY TO KILL OPPONENT
        if ((_gameType == 2 || _gameType == 1) && figure.king == NO) {
        //if (_gameType == 2 && figure.king == NO) {
            killingMovesOnly = YES;
        }
        possibleCellPoint = ccp(figure.position.x - oneCellWidth,figure.position.y + oneCellWidth);
        [self isItPossibleToMoveThere:possibleCellPoint opponentFigure:[[PlayerOne sharedFirstPlayer] playerBatch] player:YES killingMovesOnly:killingMovesOnly isKing:[figure king]];
        
        possibleCellPoint = ccp(figure.position.x + oneCellWidth, figure.position.y + oneCellWidth);
        [self isItPossibleToMoveThere:possibleCellPoint opponentFigure:[[PlayerOne sharedFirstPlayer] playerBatch] player:YES killingMovesOnly:killingMovesOnly isKing:[figure king]];
    }
}
 
@end
