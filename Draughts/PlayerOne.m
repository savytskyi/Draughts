//
//  PlayerOne.m
//  Draughts
//
//  Created by Cyril Savitsky on 8/5/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PlayerOne.h"

@implementation PlayerOne

static PlayerEntity *instanceOfFirstPlayer;

+ (PlayerEntity *) sharedFirstPlayer {
    NSAssert(instanceOfFirstPlayer != nil, @"PlayerOne instance still doesn't initialized");
    return instanceOfFirstPlayer;
}

- (id) initWithFigures:(NSString *)figureName boardSize:(float) boardSize startPoint:(CGPoint)startPoint
                border:(float)border oneStep:(float)oneStep player:(int)player {
    if ((self = [super initWithFigures:figureName boardSize:boardSize startPoint:startPoint border:border oneStep:oneStep player:player])) {
        _yourMove = YES;
        instanceOfFirstPlayer = self;
        _anotherMove = NO;
        _score = 0;
        _killerFigure = nil;
    }
    return self;
}

- (void) registerWithTouchDispatcher {
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:-2 swallowsTouches:YES];
}

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    [self cleanAllPossibleCells];
    killedFigure = nil;
    CGPoint touchLocation = [GameLevelLayer locationFromTouch:touch];
    lastTouchLocation = touchLocation;
    BOOL isTouchHandled = NO;
    Figure *figure;
    
    CCARRAY_FOREACH([_playerBatch children], figure) {
        if (figure.dead == NO && CGRectContainsPoint([figure boundingBox], touchLocation)) {
            if (_anotherMove == YES && CGPointEqualToPoint(_killerFigure.position,figure.position) && _yourMove == NO) {
                firstLocation = figure.position;
                [self findPossibleMovesForFigure:figure killingMovesOnly:YES];
                isTouchHandled = YES;
            }
            if (_yourMove) {
                firstLocation = figure.position;
                [self findPossibleMovesForFigure:figure killingMovesOnly:NO];
                isTouchHandled = YES;
            }
            
            break;
        }
    }
    return isTouchHandled;
}

- (void) findPossibleMovesForFigure:(Figure *)figure killingMovesOnly:(BOOL)killingMovesOnly{
    CCSprite *movingImage;
    if ([figure king] == NO)
        movingImage = (CCSprite*)[self getChildByTag:tagMovingSprite];
    else {
        movingImage = (CCSprite *)[self getChildByTag:tagMovingCrownSprite];
        [self findKingSpriteWithPosition:figure.position changeItTo:figure.position command:@"hide"];
    }
    

    activeFigure = figure;
    movingImage.position = figure.position;
    movingImage.visible = YES;
    figure.visible = NO;
            
    //add checking for a possible move
    //float oneDiagonalMove = sqrtf(pow(oneCellWidth*oneCellWidth,2.f)+pow(oneCellWidth, 2.f));
            
    CGPoint possibleCellPoint = ccp(figure.position.x - oneCellWidth,figure.position.y + oneCellWidth);
    [self isItPossibleToMoveThere:possibleCellPoint opponentFigure:[[PlayerTwo sharedSecondPlayer] playerBatch] player:YES killingMovesOnly:killingMovesOnly isKing:[figure king]];
    
    possibleCellPoint = ccp(figure.position.x + oneCellWidth, figure.position.y + oneCellWidth);
    [self isItPossibleToMoveThere:possibleCellPoint opponentFigure:[[PlayerTwo sharedSecondPlayer] playerBatch] player:YES killingMovesOnly:killingMovesOnly isKing:[figure king]];
    
    possibleCellPoint = ccp(figure.position.x - oneCellWidth, figure.position.y - oneCellWidth);
    [self isItPossibleToMoveThere:possibleCellPoint opponentFigure:[[PlayerTwo sharedSecondPlayer] playerBatch] player:YES killingMovesOnly:killingMovesOnly isKing:[figure king]];
    
    possibleCellPoint = ccp(figure.position.x + oneCellWidth, figure.position.y - oneCellWidth);
    [self isItPossibleToMoveThere:possibleCellPoint opponentFigure:[[PlayerTwo sharedSecondPlayer] playerBatch] player:YES killingMovesOnly:killingMovesOnly isKing:[figure king]];
}

@end