//
//  PlayerEntity.m
//  Draughts
//
//  Created by Cyril Savitsky on 8/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PlayerEntity.h"
#import "Figure.h"
#import "GameLevelLayer.h"
#import "SettingsLayer.h"
#import "CongratulationsLayer.h"

@implementation PlayerEntity

+ (id) newWithFigures:(NSString *)figureName boardSize:(float) boardSize startPoint:(CGPoint)startPoint
border:(float)border oneStep:(float)oneStep player:(int)player{
    return [[[self alloc] initWithFigures:figureName boardSize:boardSize startPoint:startPoint border:border oneStep:oneStep player:player] autorelease];
}

- (id) initWithFigures:(NSString *)figureName boardSize:(float) boardSize startPoint:(CGPoint)startPoint
                border:(float)border oneStep:(float)oneStep player:(int)player{
    if ((self = [super init])) {
        
        self.isTouchEnabled = YES;
        possibleCells = [[CCArray alloc] initWithCapacity:13];
        killingPositions = [[CCArray alloc] initWithCapacity:4];
        maxScore = 12;
        
        NSString *kingTexture = [NSString stringWithFormat:@"%@Crown.png",
                                 [figureName substringToIndex:[figureName length]-4]];
        CCSpriteFrame *figureFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:figureName];
        CCSpriteFrame *kingFigureFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:kingTexture];
        
        //Adding sprites for moving figures to reduce waiting time during playing
        NSString *movingSprite = [NSString stringWithFormat:@"%@Selected.png",
                                  [figureName substringToIndex:[figureName length]-4]];
        CCSprite *temporaryMovingSprite = [CCSprite spriteWithSpriteFrameName:movingSprite];
        temporaryMovingSprite.visible = NO;
        [self addChild:temporaryMovingSprite z:1 tag:tagMovingSprite];
        
        NSString *movingCrownSprite = [NSString stringWithFormat:@"%@CrownSelected.png",
                                       [figureName substringToIndex:[figureName length]-4]];
        CCSprite *temporaryMovingCrownSprite = [CCSprite spriteWithSpriteFrameName:movingCrownSprite];
        temporaryMovingCrownSprite.visible = NO;
        [self addChild:temporaryMovingCrownSprite z:1 tag:tagMovingCrownSprite];
        
        oneCellWidth = boardSize * 0.125;
        
        int cellsCount = 0;
        BOOL oddRow = YES;
        _playerBatch = [CCSpriteBatchNode batchNodeWithTexture:figureFrame.texture];
        _playerKingsBatch = [CCSpriteBatchNode batchNodeWithTexture:kingFigureFrame.texture];
        [self addChild:_playerBatch];
        [self addChild:_playerKingsBatch];
        defaultFigureTexture = figureName;        
        CGPoint currentCell = startPoint;
        
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        kingsYForPlayerOne = screenSize.height - (screenSize.height - boardSize) * 0.5f - oneCellWidth * 0.5;
        kingsYForPlayerTwo = (screenSize.height - boardSize) * 0.5f + oneCellWidth * 0.5;
        
        for (int i = 0; i < maxScore; i++) {
            Figure *figure = [Figure newFigureWithImage:figureName];
            figure.player = player;
            figure.position = currentCell;
            [_playerBatch addChild:figure];
            currentCell.x += 2 * oneStep;
            cellsCount++;
            if (cellsCount == 4) {
                if (oddRow)
                    currentCell.x = startPoint.x + oneStep;
                else
                    currentCell.x = startPoint.x;
                oddRow = !oddRow;
                currentCell.y += oneStep;
                cellsCount = 0;
            }
            //create kings spites
            CCSprite *king = [CCSprite spriteWithSpriteFrameName:kingTexture];
            king.visible = NO;
            king.position = ccp(0.f,0.f);
            [_playerKingsBatch addChild:king];
        }
    }
    return self;
}

- (void) findKingSpriteWithPosition:(CGPoint)oldPosition changeItTo:(CGPoint)newPosition command:(NSString *)command{
    CCSprite *king;
    CCARRAY_FOREACH([_playerKingsBatch children], king) {
        if ([command isEqualToString:@"dead"]) {
            if (king.visible == YES && CGPointEqualToPoint(king.position, oldPosition)) {
                king.position = newPosition;
                king.visible = NO;
                break;
            }
        } else if ([command isEqualToString:@"showOld"]) {
            if (king.visible == NO && CGPointEqualToPoint(king.position, oldPosition)) {
                //old position = 0x0
                king.position = newPosition;
                king.visible = YES;
                break;
            }
        } else if ([command isEqualToString:@"newKing"]) {
            if (king.visible == NO && CGPointEqualToPoint(king.position, ccp(0.f,0.f))) {
                king.position = newPosition;
                king.visible = YES;
                break;
            }
        } else if([command isEqualToString:@"hide"]) {
            if (king.visible == YES && CGPointEqualToPoint(king.position, oldPosition)) {
                king.visible = NO;
                break;
            }
        }
    }
}

- (BOOL) checkForPlayerFigures:(CCSpriteBatchNode *)playerBatchNode
            andOpponentFigures:(CCSpriteBatchNode *)opponentBatchNode
                          near:(CGPoint)point
                        player:(int)player
              killingMovesOnly:(BOOL)killingMovesOnly
                        isKing:(BOOL)king
                          from:(CGPoint)from;{
    
    CGRect cell = CGRectMake(point.x - oneCellWidth * 0.5, point.y - oneCellWidth * 0.5, oneCellWidth, oneCellWidth);
    Figure *figure;
    CGRect board = [self getBoardRect];

    
        
    CCARRAY_FOREACH([opponentBatchNode children], figure) {
        if (figure.dead == NO && CGRectContainsPoint(cell, figure.position)) {
            //KILL THAT BITCH!
            CGPoint nextPoint = ccpSub(figure.position, from);//firstLocation);
            nextPoint = ccpAdd(figure.position, nextPoint);
            if (![self checkForAnyFigureAt:nextPoint]) {
                CGRect nextCell = CGRectMake(nextPoint.x - oneCellWidth * 0.5, nextPoint.y - oneCellWidth * 0.5, oneCellWidth, oneCellWidth);
                if (CGRectContainsRect(board, nextCell)) {
                    [killingPositions addObject:[NSValue valueWithCGPoint:nextPoint]];
                    [self markPossibleCell:nextPoint];
                    [possibleCells addObject:[NSValue valueWithCGPoint:nextPoint]];
                    
                    //add king test for nextpoint
                    if (king) {
                        CGPoint pointAfterNextPoint = ccpSub(nextPoint, figure.position);
                        pointAfterNextPoint = ccpAdd(nextPoint, pointAfterNextPoint);
                        if (![self checkForAnyFigureAt:pointAfterNextPoint]) {
                            [self markPossibleCell:pointAfterNextPoint];
                            [self checkForPlayerFigures:playerBatchNode andOpponentFigures:opponentBatchNode near:pointAfterNextPoint player:player killingMovesOnly:NO isKing:king from:nextPoint];
                        }
                    }
                    
                    
                    return YES;
                }
            } else {
                    return YES;
            }
            
            
                
        }
    }
    if (!killingMovesOnly) {
        CCARRAY_FOREACH([playerBatchNode children], figure)
            if (figure.dead == NO && CGRectContainsPoint(cell, figure.position))
                return YES;
                //means that we should finish killing line, because there is nothing to kill
    
    
        [self markPossibleCell:point];
        [possibleCells addObject:[NSValue valueWithCGPoint:point]];
        
        //continue checking if this is a KING figure's move
        if (king) {
            CGPoint nextCell = ccpSub(point, from);
            nextCell = ccpAdd(point, nextCell);
            if (![self checkForAnyFigureAt:nextCell])
                [self checkForPlayerFigures:playerBatchNode andOpponentFigures:opponentBatchNode near:nextCell player:player killingMovesOnly:killingMovesOnly isKing:king from:point];
            else
                [self checkForPlayerFigures:playerBatchNode andOpponentFigures:opponentBatchNode near:nextCell player:player killingMovesOnly:YES isKing:king from:point];
        }
        return NO;
    } else
        return YES;
}

- (BOOL) checkForAnyFigureAt:(CGPoint) point {
    //return YES if cell is busy or doesn't exists;
    
    CGRect board = [self getBoardRect];
    CGRect cell = CGRectMake(point.x - oneCellWidth * 0.5, point.y - oneCellWidth * 0.5, oneCellWidth, oneCellWidth);
    if (CGRectContainsRect(board, cell)) {
        Figure *figure;
        CGRect cell = CGRectMake(point.x - oneCellWidth * 0.5, point.y - oneCellWidth * 0.5, oneCellWidth, oneCellWidth);
        CCARRAY_FOREACH([[[PlayerOne sharedFirstPlayer] playerBatch] children], figure) {
            if (figure.dead == NO && CGRectContainsPoint(cell, figure.position)) {
                return YES;
            }
        }
        CCARRAY_FOREACH([[[PlayerTwo sharedSecondPlayer] playerBatch] children], figure) {
            if (figure.dead == NO && CGRectContainsPoint(cell, figure.position)) {
                return YES;
            }
        }
    } else
        return YES;
    return NO;
}

- (BOOL) continueKillingLine:(CCSpriteBatchNode *)opponent from:(CGPoint)point previousPoint:(CGPoint)previousPoint {
    //return YES if there are some additional figures to kill
    //return NO if there is no figure to kill anymore
    BOOL continueLine = NO;
    
    CGRect board = [self getBoardRect];
    
        
    for (int i = -1; i < 2; i += 2)
        for (int j = -1; j < 2; j += 2) {
            //check whether opponent still has some figures around. Check all 4 directions
            CGPoint possiblePoint = ccpAdd(point, ccp(i * oneCellWidth, j * oneCellWidth));
            
            CGRect cell = CGRectMake(possiblePoint.x - oneCellWidth * 0.5, possiblePoint.y - oneCellWidth * 0.5, oneCellWidth, oneCellWidth);
            if (CGRectContainsRect(board, cell)) {
            
                if (!CGPointEqualToPoint(possiblePoint, previousPoint)) {
                    Figure *figure;
                    CCARRAY_FOREACH([opponent children], figure) {
                        if (figure.dead == NO && CGRectContainsPoint(cell, figure.position)) {

                            
                            CGPoint nextCell = ccpSub(figure.position, point);
                            nextCell = ccpAdd(figure.position,nextCell);
                            if (![self checkForAnyFigureAt:nextCell])
                                return YES;
                        }
                    }
                }
            }

        }
    return continueLine;
    
}

- (void) markPossibleCell:(CGPoint)point {
    CCSprite *marker;
    CCARRAY_FOREACH([[[GameLevelLayer sharedGameLevelLayer] possibleMoveCells] children], marker)
    if (marker.visible == NO) {
        marker.visible = YES;
        marker.position = point;
        break;
    }
}

- (void) cleanAllPossibleCells {
    CCSprite *marker;
    CCARRAY_FOREACH([[[GameLevelLayer sharedGameLevelLayer] possibleMoveCells] children], marker)
    if (marker.visible == YES) {
        marker.visible = NO;
        marker.position = ccp(0,0);
    }
    [possibleCells removeAllObjects];
}

- (void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CCSprite *movingImage;
    if ([activeFigure king] == NO)
        movingImage = (CCSprite*)[self getChildByTag:tagMovingSprite];
    else
        movingImage = (CCSprite *)[self getChildByTag:tagMovingCrownSprite];
    
    CGPoint currentTouchLocation = [GameLevelLayer locationFromTouch:touch];
    CGPoint moveTo = ccpSub(lastTouchLocation, currentTouchLocation);
    moveTo = ccpMult(moveTo, -1);
    
    lastTouchLocation = currentTouchLocation;
    
    CGPoint newLocation = ccpAdd(movingImage.position, moveTo);
    movingImage.position = newLocation;
}

- (void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {

    BOOL changeMove = YES;
    CCSprite *movingImage;
    if ([activeFigure king] == NO)
        movingImage = (CCSprite*)[self getChildByTag:tagMovingSprite];
    else
        movingImage = (CCSprite *)[self getChildByTag:tagMovingCrownSprite];
    
    for (int i = 0; i < [possibleCells count]; i++) {
        //check, whether position of Moving image inside of one of Posiible cells
        
        CGPoint possibleCell = [[possibleCells objectAtIndex:i] CGPointValue];
        CGRect cell = CGRectMake(possibleCell.x - oneCellWidth * 0.5, possibleCell.y - oneCellWidth * 0.5, oneCellWidth, oneCellWidth);
        if (CGRectContainsPoint(cell, movingImage.position)) {
            
            //if new position of moving image inside of possible cell

            for (int i = 0; i < [killingPositions count]; i++) {
                CGPoint multiplier = ccpSub(possibleCell, firstLocation);
                if (multiplier.x > 0)
                    multiplier.x = multiplier.x - (multiplier.x - 1);
                else
                    multiplier.x = -multiplier.x + (multiplier.x - 1);
                
                if (multiplier.y > 0)
                    multiplier.y = multiplier.y - (multiplier.y - 1);
                else
                    multiplier.y = -multiplier.y + (multiplier.y - 1);
                CGPoint nextCell = CGPointMake(oneCellWidth * multiplier.x, oneCellWidth * multiplier.y);
                CGPoint previousCell = firstLocation;
                CGPoint currentCell = previousCell;
                CGRect board = [self getBoardRect];
                while (CGRectContainsPoint(board, currentCell)) {
                    currentCell = ccpAdd(previousCell, nextCell);
                    if (CGPointEqualToPoint(currentCell, [[killingPositions objectAtIndex:i] CGPointValue])) {
                        changeMove = [self killActionsAt:currentCell];
                        break;
                    }
                    previousCell = currentCell;
                }
            
                
                /*
                if ( CGPointEqualToPoint([[killingPositions objectAtIndex:i] CGPointValue],possibleCell)) {
                    
                    //if we just killed opponent's figure
                    changeMove = [self killActionsAt:possibleCell];
                    
                }*/
            }
            if (changeMove) {
                if (activeFigure.player == 1) {
                    [PlayerOne sharedFirstPlayer].yourMove = NO;
                    [PlayerTwo sharedSecondPlayer].yourMove = YES;
                    [PlayerOne sharedFirstPlayer].killerFigure = nil;
                } else {
                    [PlayerOne sharedFirstPlayer].yourMove = YES;
                    [PlayerTwo sharedSecondPlayer].yourMove = NO;
                    [PlayerTwo sharedSecondPlayer].killerFigure = nil;
                }
            } else {
                if (activeFigure.player == 1) {
                    [PlayerOne sharedFirstPlayer].anotherMove = YES;
                    [PlayerTwo sharedSecondPlayer].killerFigure = activeFigure;;
                } else {
                    [PlayerTwo sharedSecondPlayer].anotherMove = YES;
                    [PlayerTwo sharedSecondPlayer].killerFigure = activeFigure;
                }
            }
            activeFigure.position = possibleCell;
            if (activeFigure.king == YES) {
                //if figure was a king, show king image
                [self findKingSpriteWithPosition:firstLocation changeItTo:possibleCell command:@"showOld"];
            } else if ((activeFigure.player == 1 &&  possibleCell.y == kingsYForPlayerOne && activeFigure.king == NO) ||
                       (activeFigure.player == 2 && possibleCell.y == kingsYForPlayerTwo && activeFigure.king == NO)) {
                //if figure is a new king, change sprite and make it a KING!
                activeFigure.king = YES;
                [self findKingSpriteWithPosition:ccp(0.f,0.f) changeItTo:possibleCell command:@"newKing"];
            } else if (activeFigure.king == NO) {
                
                //if figure isn't a king, just show common image
                activeFigure.visible = YES;
            }
            
            activeFigure = nil;
            movingImage.visible = NO;
            
            break;
        }
        if (CGPointEqualToPoint([[possibleCells objectAtIndex:i] CGPointValue], [[possibleCells lastObject] CGPointValue])) {
            if (activeFigure.king == YES) {
                [self findKingSpriteWithPosition:activeFigure.position changeItTo:activeFigure.position command:@"showOld"];
                activeFigure.visible = NO;
            }
            break;
        }
    }
    [killingPositions removeAllObjects];
    [self cleanAllPossibleCells];
    activeFigure.position = firstLocation;
    activeFigure.visible = YES;
    movingImage.visible = NO;
    activeFigure = nil;
    
    if ([[PlayerOne sharedFirstPlayer] score] == maxScore || [[PlayerTwo sharedSecondPlayer] score] == maxScore) {
        [self endGame];
    }

}

- (BOOL) killActionsAt:(CGPoint)possibleCell {
    BOOL changeMove = YES;
    Figure *figure;
    CCSpriteBatchNode *arr;
    if (activeFigure.player == 1)
        arr = [[PlayerTwo sharedSecondPlayer] playerBatch];
    else
        arr = [[PlayerOne sharedFirstPlayer] playerBatch];
    
    CGPoint killedFigurePosition = ccpMidpoint(possibleCell, firstLocation);
    CCARRAY_FOREACH([arr children], figure) {
        if (CGPointEqualToPoint(figure.position, killedFigurePosition)) {
            killedFigure = figure;
            break;
        }
        if (activeFigure.king == YES) {
            CGPoint multiplier = ccpSub(possibleCell, firstLocation);
            if (multiplier.x > 0)
                multiplier.x = multiplier.x - (multiplier.x - 1);
            else
                multiplier.x = -multiplier.x + (multiplier.x - 1);
            
            if (multiplier.y > 0)
                multiplier.y = multiplier.y - (multiplier.y - 1);
            else
                multiplier.y = -multiplier.y + (multiplier.y - 1);
            CGPoint nextCell = CGPointMake(oneCellWidth * multiplier.x, oneCellWidth * multiplier.y);
            CGPoint previousCell = firstLocation;
            CGPoint currentCell = previousCell;
            CGRect board = [self getBoardRect];
            while (CGRectContainsPoint(board, currentCell)) {
                currentCell = ccpAdd(previousCell, nextCell);
                if (CGPointEqualToPoint(currentCell, figure.position)) {
                    killedFigure = figure;
                    break;
                }
                previousCell = currentCell;
            }
        }
    }
    killedFigure.dead = YES;
    if (killedFigure.king == YES) {
        if (killedFigure.player == 1)
            [[PlayerOne sharedFirstPlayer] findKingSpriteWithPosition:killedFigure.position
                                                           changeItTo:ccp(0.f,0.f) command:@"dead"];
        else if (killedFigure.player == 2)
            [[PlayerTwo sharedSecondPlayer] findKingSpriteWithPosition:killedFigure.position
                                                            changeItTo:ccp(0.f,0.f) command:@"dead"];
    }
    if (killedFigure.player == 1) {
        //if we killed figure of Player 1
        
        int oldScore = [[PlayerTwo sharedSecondPlayer] score] + 1;
        [PlayerTwo sharedSecondPlayer].score = oldScore;
        
        //placing killed figure somewher
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        CGPoint killedFiguresPlace = ccp(100,screenSize.height - (screenSize.height - oneCellWidth * 8) * 0.25f);
        killedFigure.position = killedFiguresPlace;
        
        //if player has other other figures to kill, we can't change MOVE property
        if ([self continueKillingLine:[[PlayerOne sharedFirstPlayer] playerBatch]
                                 from:possibleCell
                        previousPoint:activeFigure.position])
            changeMove = NO;
        
    } else if (killedFigure.player == 2) {
        //if we killed figure of Player 2
        int oldScore = [[PlayerOne sharedFirstPlayer] score] + 1;
        [PlayerOne sharedFirstPlayer].score = oldScore;
        
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        CGPoint killedFiguresPlace = ccp(100,(screenSize.height - oneCellWidth * 8) * 0.25f);
        killedFigure.position = killedFiguresPlace;
        if ([self continueKillingLine:[[PlayerTwo sharedSecondPlayer] playerBatch]
                                 from:possibleCell
                        previousPoint:activeFigure.position])
            changeMove = NO;
    }
    killedFigure = nil;
    return changeMove;
}

- (void) isItPossibleToMoveThere:(CGPoint)possiblePoint opponentFigure:(CCSpriteBatchNode *)opponent player:(int)player killingMovesOnly:(BOOL)killingMovesOnly isKing:(BOOL)king {
    
    CGRect board = [self getBoardRect];
    CGRect cell = CGRectMake(possiblePoint.x - oneCellWidth * 0.5,
                             possiblePoint.y - oneCellWidth * 0.5, oneCellWidth, oneCellWidth);
    
        
    if (CGRectContainsRect(board, cell))
        [self checkForPlayerFigures:_playerBatch andOpponentFigures:opponent near:possiblePoint player:player killingMovesOnly:killingMovesOnly isKing:king from:firstLocation];
}

- (CGRect) getBoardRect {
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    float boarderY = (screenSize.height - oneCellWidth * 8) * 0.5;
    float boarderX = (screenSize.width - oneCellWidth * 8) * 0.5;
    CGRect board = CGRectMake(boarderX, boarderY, oneCellWidth * 8, oneCellWidth * 8);
    return board;
}

- (void) endGame {
    NSString *winner;
    if ([[PlayerOne sharedFirstPlayer] score] == maxScore) {
        winner = [NSString stringWithFormat:@"Player One"];
    } else {
        winner = [NSString stringWithFormat:@"Player Two"];
    }
    //[[CCDirector sharedDirector] replaceScene:[CongratulationsLayer sceneWith:winner]];
    [[SettingsLayer sharedSettingsLayer] showCongratulationsFor:winner];
}

- (void) dealloc {
    [super dealloc];
}

@end
