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

+ (id) createWithFigures:(NSString *)figureName boardSize:(float) boardSize startPoint:(CGPoint)startPoint
border:(float)border oneStep:(float)oneStep player:(int)player gameType:(int)gameType playerTwo:(BOOL)playerTwo {
    return [[[self alloc] initWithFigures:figureName boardSize:boardSize startPoint:startPoint border:border oneStep:oneStep player:player gameType:gameType playerTwo:playerTwo] autorelease];
}

- (id) initWithFigures:(NSString *)figureName boardSize:(float) boardSize startPoint:(CGPoint)startPoint
                border:(float)border oneStep:(float)oneStep player:(int)player gameType:(int)gameType playerTwo:(BOOL)playerTwo {
    if ((self = [super init])) {
        
        
        
        _gameType = gameType;
        if (player != 2 || (player == 2 && playerTwo == YES))
            self.isTouchEnabled = YES;
        possibleCells = [[CCArray alloc] initWithCapacity:13];
        killingPositions = [[CCArray alloc] initWithCapacity:4];
        if (_gameType == 1)
            maxScore = 20;
        else
            maxScore = 6;//12;
        
        NSString *kingTexture = [NSString stringWithFormat:@"%@Crown.png",
                                 [figureName substringToIndex:[figureName length]-4]];
        CCSpriteFrame *figureFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:figureName];
        CCSpriteFrame *kingFigureFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:kingTexture];
        
        //Adding sprites for moving figures to reduce waiting time during playing
        NSString *movingSprite = [NSString stringWithFormat:@"%@Selected.png",
                                  [figureName substringToIndex:[figureName length]-4]];
        CCSprite *temporaryMovingSprite = [CCSprite spriteWithSpriteFrameName:movingSprite];
        temporaryMovingSprite.visible = NO;
        if (_gameType == 1)
            temporaryMovingSprite.scale = 0.8f;
        [self addChild:temporaryMovingSprite z:zForMovingFigures tag:tagMovingSprite];
        
        NSString *movingCrownSprite = [NSString stringWithFormat:@"%@CrownSelected.png",
                                       [figureName substringToIndex:[figureName length]-4]];
        CCSprite *temporaryMovingCrownSprite = [CCSprite spriteWithSpriteFrameName:movingCrownSprite];
        if (_gameType == 1)
            temporaryMovingCrownSprite.scale = 0.8f;
        temporaryMovingCrownSprite.visible = NO;
        [self addChild:temporaryMovingCrownSprite z:zForMovingFigures tag:tagMovingCrownSprite];
        int figuresPerRow;
        if (_gameType == 1) {
            oneCellWidth = boardSize * 0.1f;
            figuresPerRow = 5;
        } else {
            oneCellWidth = boardSize * 0.125f;
            figuresPerRow = 4;
        }
        
        
        int cellsCount = 0;
        BOOL oddRow = YES;
        _playerBatch = [CCSpriteBatchNode batchNodeWithTexture:figureFrame.texture];
        _playerKingsBatch = [CCSpriteBatchNode batchNodeWithTexture:kingFigureFrame.texture];
        [self addChild:_playerBatch z:zForFigures];
        [self addChild:_playerKingsBatch z:zForFigures];
        defaultFigureTexture = figureName;        
        CGPoint currentCell = startPoint;
        
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        kingsYForPlayerOne = screenSize.height - (screenSize.height - boardSize) * 0.5f - oneCellWidth * 0.5f;
        kingsYForPlayerTwo = (screenSize.height - boardSize) * 0.5f + oneCellWidth * 0.5f;
        
        for (int i = 0; i < maxScore; i++) {
            Figure *figure = [Figure createFigureWithImage:figureName];
            figure.player = player;
            figure.position = currentCell;
            if (_gameType == 1)
                figure.scale = 0.8f;
            [_playerBatch addChild:figure];
            
            cellsCount++;
            currentCell.x += 2 * oneStep;
            
            if (cellsCount == figuresPerRow) {
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
            if (_gameType == 1)
                king.scale = 0.8;
            [_playerKingsBatch addChild:king];
        }
    }
    return self;
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
                /*if ([[PlayerTwo sharedSecondPlayer] playVersusUser] == NO) {
                    king.scale = 0.1f;
                    CCSequence *show = [CCSequence actions:[CCShow action], [CCScaleBy actionWithDuration:1.f scale:10.f], nil];
                    [king runAction:show];
                } else {*/
                    king.visible = YES;
                //}
                break;
            }
        } else if([command isEqualToString:@"hide"]) {
            if (king.visible == YES && CGPointEqualToPoint(king.position, oldPosition)) {
                king.visible = NO;
                break;
            }
        } else if ([command isEqualToString:@"move"]) {
            if (king.visible == YES && CGPointEqualToPoint(king.position, oldPosition)) {
                /*CCSequence *move = [CCSequence actions:[CCShow action],
                                    [CCMoveTo actionWithDuration:0.3f position:newPosition],
                                    nil];
                [king runAction:move];*/
                king.position = newPosition;
                king.visible = YES;
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
                CGRect nextCell = CGRectMake(nextPoint.x - oneCellWidth * 0.4f, nextPoint.y - oneCellWidth * 0.4f, oneCellWidth * 0.8f, oneCellWidth * 0.8f);
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
        //if we didn't find anything on this cell, let's try again with next cell
        if (activeFigure.king == YES) {
            CGPoint nextCell = ccpSub(point, from);
            nextCell = ccpAdd(point, nextCell);
            if (CGRectContainsPoint(board, nextCell))
                [self checkForPlayerFigures:playerBatchNode andOpponentFigures:opponentBatchNode near:nextCell player:player killingMovesOnly:killingMovesOnly isKing:king from:point];
            
        } else 
            return YES;
    return YES;
}

- (BOOL) checkForAnyFigureAt:(CGPoint) point {
    //return YES if cell is busy or doesn't exists;
    
    CGRect board = [self getBoardRect];
    
    //to undo change to 0.5 and remove 0.8
    CGRect cell = CGRectMake(point.x - oneCellWidth * 0.4f, point.y - oneCellWidth * 0.4f, oneCellWidth * 0.8f, oneCellWidth * 0.8f);
    if (CGRectContainsRect(board, cell)) {
        Figure *figure;
        CGRect cell = CGRectMake(point.x - oneCellWidth * 0.5f, point.y - oneCellWidth * 0.5f, oneCellWidth, oneCellWidth);
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
            if (_gameType == 0) {
                if (activeFigure.player == 1 && j < 0 && activeFigure.king == NO) {
                    continue;
                } else if (activeFigure.player == 2 && j > 0 && activeFigure.king == NO) {
                    continue;
                }
            }
            
            //check whether opponent still has some figures around. Check all 4 directions
            
            CGPoint possiblePoint = ccpAdd(point, ccp(i * oneCellWidth, j * oneCellWidth));
            
            //to UNDO change to 0.5f and remove 0.8
            CGRect cell = CGRectMake(possiblePoint.x - oneCellWidth * 0.4f, possiblePoint.y - oneCellWidth * 0.4f, oneCellWidth * 0.8f, oneCellWidth * 0.8f);
            if (CGRectContainsRect(board, cell)) {
            
                //if current cell is not previous cell (we don't need to check cell where we from
                if (!CGPointEqualToPoint(possiblePoint, previousPoint)) {
                    Figure *figure;
                    
                    //check every opponent's figure
                    CCARRAY_FOREACH([opponent children], figure) {
                        
                        if (activeFigure.king == YES && _gameType != 0) {
                            CGPoint previousCell = point;
                            CGPoint currentCell = possiblePoint;
                            while (CGRectContainsPoint(board, currentCell)) {
                                CGRect currentCellRect = CGRectMake(currentCell.x - oneCellWidth * 0.5f, currentCell.y - oneCellWidth * 0.5f, oneCellWidth, oneCellWidth);
                                
                                if (figure.dead == NO && CGRectContainsPoint(currentCellRect, figure.position)) {
                                    //if there is a figure in this cell
                                    //checking cell after current cell to see whether it's free and we can kill
                                    //this figure
                                    CGPoint cellAfternextCell = ccpSub(figure.position, previousCell);
                                    cellAfternextCell = ccpAdd(figure.position,cellAfternextCell);
                                    if (![self checkForAnyFigureAt:cellAfternextCell]) {
                                        return YES;
                                    }
                                }
                                //if there is no figure, checking next cell
                                
                                //finding next step cootdinates
                                previousCell = currentCell;
                                currentCell = ccpAdd(currentCell, ccp(i * oneCellWidth, j * oneCellWidth));
                            }
                        }
                        else {
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

- (void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    BOOL changeMove = YES;
    CCSprite *movingImage;
    if ([activeFigure king] == NO)
        movingImage = (CCSprite*)[self getChildByTag:tagMovingSprite];
    else
        movingImage = (CCSprite *)[self getChildByTag:tagMovingCrownSprite];
    
    if ([possibleCells count] == 0) {
        if (activeFigure.king == YES) {
            [self findKingSpriteWithPosition:activeFigure.position changeItTo:activeFigure.position command:@"showOld"];
            activeFigure.visible = NO;
        } else {
            activeFigure.visible = YES;
        }
    } 
    
    
    for (int i = 0; i < [possibleCells count]; i++) {
        //check, whether position of Moving image inside of one of Posiible cells
        
        CGPoint possibleCell = [[possibleCells objectAtIndex:i] CGPointValue];
        CGRect cell = CGRectMake(possibleCell.x - oneCellWidth * 0.5f, possibleCell.y - oneCellWidth * 0.5f, oneCellWidth, oneCellWidth);
        if (CGRectContainsPoint(cell, movingImage.position)) {
            
            //if new position of moving image inside of possible cell
            
            activeFigure.position = possibleCell;
            
            for (int j = 0; j < [killingPositions count]; j++) {
                CGPoint possibleKilledCell = [[killingPositions objectAtIndex:j] CGPointValue];
                
                //check whether we killed a figure, or we stopped before it
                if (![self didFigureStoppedBefore:possibleKilledCell from:firstLocation to:activeFigure.position] ) {
                
                
                    CGPoint multiplier = [self findMultiplierWithLastLocation:possibleCell startLocation:firstLocation];
                
                    CGPoint nextCell = CGPointMake(oneCellWidth * multiplier.x, oneCellWidth * multiplier.y);
                    CGPoint previousCell = firstLocation;
                    CGPoint currentCell = previousCell;
                    CGRect board = [self getBoardRect];
                
                    //creating a half-cell
                
                    CGRect possibleCellOfKilledFigure = CGRectMake(possibleKilledCell.x - oneCellWidth * 0.25f, possibleKilledCell.y - oneCellWidth * 0.25f, oneCellWidth * 0.5f, oneCellWidth * 0.5f);
                    while (CGRectContainsPoint(board, currentCell)) {
                        currentCell = ccpAdd(previousCell, nextCell);
                                                        
                            //delete between here and previous comments to undo
                    
                        if (CGRectContainsPoint(possibleCellOfKilledFigure, currentCell) ) {
                            changeMove = [self killActionsAt:activeFigure.position];// currentCell];
                            break;
                        }
                        previousCell = currentCell;
                    }
                }
            }
            
            CGRect halfPossibleCellRect = CGRectMake(possibleCell.x - 0.25f * oneCellWidth,
                                                     possibleCell.y - 0.25f * oneCellWidth,
                                                     0.5f * oneCellWidth, 0.5f * oneCellWidth);
            //possibleCell.y == kingsYForPlayerOne
            if (activeFigure.king == YES) {
                //if figure was a king, show king image
                [self findKingSpriteWithPosition:firstLocation changeItTo:possibleCell command:@"showOld"];
            } else if ((activeFigure.player == 1 &&
                        CGRectContainsPoint(halfPossibleCellRect, ccp(possibleCell.x, kingsYForPlayerOne))
                        && activeFigure.king == NO) ||
                       (activeFigure.player == 2 &&
                        CGRectContainsPoint(halfPossibleCellRect, ccp(possibleCell.x, kingsYForPlayerTwo)) &&
                        activeFigure.king == NO)) {
                //if figure is a new king, change sprite and make it a KING!
                activeFigure.king = YES;
                [self findKingSpriteWithPosition:ccp(0.f,0.f) changeItTo:possibleCell command:@"newKing"];
            } else if (activeFigure.king == NO) {
                
                //if figure isn't a king, just show common image
                activeFigure.visible = YES;
            }
            
            
            
            if (changeMove) {
                if (activeFigure.player == 1) {
                    [PlayerTwo sharedSecondPlayer].yourMove = YES;
                    [PlayerOne sharedFirstPlayer].yourMove = NO;
                    [PlayerOne sharedFirstPlayer].anotherMove = NO;
                    [PlayerOne sharedFirstPlayer].killerFigure = nil;
                    [[GameLevelLayer sharedGameLevelLayer] changeYourMoveLed:NO];
                    
                    if ([[PlayerTwo sharedSecondPlayer] playVersusUser] == NO)
                        //if playerOne plays versus computer, we should tell computer to make a move
                        [[PlayerTwo sharedSecondPlayer] makeAMove];
                } else {
                    [PlayerOne sharedFirstPlayer].yourMove = YES;
                    [PlayerTwo sharedSecondPlayer].yourMove = NO;
                    [PlayerTwo sharedSecondPlayer].anotherMove = NO;
                    [PlayerTwo sharedSecondPlayer].killerFigure = nil;
                    [[GameLevelLayer sharedGameLevelLayer] changeYourMoveLed:YES];
                }
            } else {
                if (activeFigure.player == 1) {
                    [PlayerOne sharedFirstPlayer].anotherMove = YES;
                    [PlayerOne sharedFirstPlayer].killerFigure = activeFigure;
                } else {
                    [PlayerTwo sharedSecondPlayer].anotherMove = YES;
                    [PlayerTwo sharedSecondPlayer].killerFigure = activeFigure;
                }
            }
            
            activeFigure = nil;
            movingImage.visible = NO;
            break;
        }
        if (CGPointEqualToPoint([[possibleCells objectAtIndex:i] CGPointValue], [[possibleCells lastObject] CGPointValue])) {
            if (activeFigure.king == YES) {
                [self findKingSpriteWithPosition:activeFigure.position changeItTo:activeFigure.position command:@"showOld"];
                activeFigure.visible = NO;
            } else {
                activeFigure.visible = YES;
            }
            break;
        }
    }
    [killingPositions removeAllObjects];
    [self cleanAllPossibleCells];
    activeFigure.position = firstLocation;
    //activeFigure.visible = YES;
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
    //creating a half-cell

    
    CGRect killedFigureRect = CGRectMake(killedFigurePosition.x - oneCellWidth * 0.25f, killedFigurePosition.y - oneCellWidth * 0.25f, oneCellWidth * 0.5f, oneCellWidth * 0.5f);
    CCARRAY_FOREACH([arr children], figure) {
        if (CGRectContainsPoint(killedFigureRect, figure.position) ) {
            killedFigure = figure;
            break;
        }
        if (activeFigure.king == YES) {
            CGPoint multiplier = [self findMultiplierWithLastLocation:possibleCell startLocation:firstLocation];
            
            CGPoint nextCell = CGPointMake(oneCellWidth * multiplier.x, oneCellWidth * multiplier.y);
            CGPoint previousCell = firstLocation;
            CGPoint currentCell = previousCell;
            CGRect board = [self getBoardRect];
            while (CGRectContainsPoint(board, currentCell)) {
                currentCell = ccpAdd(previousCell, nextCell);
                
                //creating a half-cell
                CGRect halfCurrentCell = CGRectMake(currentCell.x - oneCellWidth * 0.25f, currentCell.y - oneCellWidth * 0.25f, oneCellWidth * 0.5f, oneCellWidth * 0.5f);
                if (CGRectContainsPoint(halfCurrentCell, figure.position)) {
                    killedFigure = figure;
                    break;
                }
                previousCell = currentCell;
            }
        }
    }
    killedFigure.dead = YES;
    if (killedFigure.king == YES) {
        killedFigure.visible = NO;
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
        
        float score = [[PlayerTwo sharedSecondPlayer] score];
        score *= 50;
        CGPoint killedFiguresPlace = ccp(100 + score,screenSize.height - (screenSize.height - oneCellWidth * 8) * 0.2f);
        if (killedFigure.king) {
            [[PlayerOne sharedFirstPlayer] findKingSpriteWithPosition:ccp(0.f,0.f) changeItTo:killedFiguresPlace command:@"newKing"];
        } else {
            killedFigure.position = killedFiguresPlace;
        }
        
        //if player has other other figures to kill, we can't change MOVE property
        
        CGPoint prevoiusPosition = activeFigure.position;
        
        if ([self continueKillingLine:[[PlayerOne sharedFirstPlayer] playerBatch]
                                 from:possibleCell
                        previousPoint:prevoiusPosition])
            changeMove = NO;
        
    } else if (killedFigure.player == 2) {
        //if we killed figure of Player 2
        int oldScore = [[PlayerOne sharedFirstPlayer] score] + 1;
        [PlayerOne sharedFirstPlayer].score = oldScore;
        
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        float score = [[PlayerOne sharedFirstPlayer] score];
        score *= 50;
        CGPoint killedFiguresPlace = ccp(100 + score,(screenSize.height - oneCellWidth * 8) * 0.2f);
        if (killedFigure.king) {
            [[PlayerTwo sharedSecondPlayer] findKingSpriteWithPosition:ccp(0.f,0.f) changeItTo:killedFiguresPlace command:@"newKing"];
        } else {
            killedFigure.position = killedFiguresPlace;
        }
        
        //if player has other other figures to kill, we can't change MOVE property
        
        CGPoint prevoiusPosition = activeFigure.position;
        
        if ([self continueKillingLine:[[PlayerTwo sharedSecondPlayer] playerBatch]
                                 from:possibleCell
                        previousPoint:prevoiusPosition])
            changeMove = NO;
    }
    killedFigure = nil;
    return changeMove;
}

- (int) isItPossibleToMoveThere:(CGPoint)possiblePoint opponentFigure:(CCSpriteBatchNode *)opponent player:(int)player killingMovesOnly:(BOOL)killingMovesOnly isKing:(BOOL)king {
    //returns YES if it's possible to move somewhere
    
    CGRect board = [self getBoardRect];
     //to undo change to 0.5 and remove 0.8
    CGRect cell = CGRectMake(possiblePoint.x - oneCellWidth * 0.4f,
                             possiblePoint.y - oneCellWidth * 0.4f, oneCellWidth * 0.8f, oneCellWidth * 0.8f);
        
    if (CGRectContainsRect(board, cell)) {
        if (_gameType == 0 && king == YES) {
            return ![self checkForPlayerFigures:_playerBatch andOpponentFigures:opponent near:possiblePoint player:player killingMovesOnly:killingMovesOnly isKing:!king from:firstLocation];
        }
        else {
            return ![self checkForPlayerFigures:_playerBatch andOpponentFigures:opponent near:possiblePoint player:player killingMovesOnly:killingMovesOnly isKing:king from:firstLocation];
        }
    }
    return 0;
}

- (CGRect) getBoardRect {
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    int cellsPerRow;
    if (_gameType == 1)
        cellsPerRow = 10;
    else
        cellsPerRow = 8;
    float borderY = (screenSize.height - oneCellWidth * cellsPerRow) * 0.5f;
    float borderX = (screenSize.width - oneCellWidth * cellsPerRow) * 0.5f;
    CGRect board = CGRectMake(borderX, borderY, oneCellWidth * cellsPerRow, oneCellWidth * cellsPerRow);
    return board;
}

- (void) endGame {
    NSString *winner;
    if ([[PlayerOne sharedFirstPlayer] score] == maxScore) {
        winner = [NSString stringWithFormat:@"Player One"];
    } else {
        winner = [NSString stringWithFormat:@"Player Two"];
    }
    [[CCDirector sharedDirector] replaceScene:[CongratulationsLayer sceneWith:winner]];
}

- (BOOL) didFigureStoppedBefore:(CGPoint)killedCell from:(CGPoint)startLocation to:(CGPoint)stopLocation {
    //return YES if we didnt kill a figure and stopped before
    
    CGRect board = [self getBoardRect];
    BOOL stoppedBefore = NO;
    
    if (!CGPointEqualToPoint(stopLocation, killedCell)) {
        CGPoint multiplier = [self findMultiplierWithLastLocation:stopLocation startLocation:startLocation];

        CGPoint nextCell = stopLocation;

        while (CGRectContainsPoint(board, nextCell)) {
            nextCell = ccpAdd(nextCell, ccp( multiplier.x * oneCellWidth, multiplier.y * oneCellWidth ));
            CGRect nextCellRect = CGRectMake(nextCell.x - 0.4f * oneCellWidth, nextCell.y - 0.4f * oneCellWidth, 0.8f * oneCellWidth, 0.8f * oneCellWidth);
            if (CGRectContainsPoint(nextCellRect, killedCell)) {
                stoppedBefore = YES;
                break;
            }
        }
    }
    return stoppedBefore; 
}

- (CGPoint) findMultiplierWithLastLocation:(CGPoint)finish startLocation:(CGPoint)start {
    CGPoint multiplier = ccpSub(finish, start);
    if (multiplier.x > 0)
        multiplier.x = multiplier.x - (multiplier.x - 1);
    else
        multiplier.x = -multiplier.x + (multiplier.x - 1);
    
    if (multiplier.y > 0)
        multiplier.y = multiplier.y - (multiplier.y - 1);
    else
        multiplier.y = -multiplier.y + (multiplier.y - 1);
    return multiplier;
}

@end
