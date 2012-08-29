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

- (void) registerWithTouchDispatcher {
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:-1 swallowsTouches:YES];
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
        //In soviet mode game pieces can move backwards ONLY TO KILL OPPONENT
        if (_gameType == 2 && figure.king == NO) {
            killingMovesOnly = YES;
        }
        possibleCellPoint = ccp(figure.position.x - oneCellWidth,figure.position.y + oneCellWidth);
        [self isItPossibleToMoveThere:possibleCellPoint opponentFigure:[[PlayerOne sharedFirstPlayer] playerBatch] player:YES killingMovesOnly:killingMovesOnly isKing:[figure king]];
        
        possibleCellPoint = ccp(figure.position.x + oneCellWidth, figure.position.y + oneCellWidth);
        [self isItPossibleToMoveThere:possibleCellPoint opponentFigure:[[PlayerOne sharedFirstPlayer] playerBatch] player:YES killingMovesOnly:killingMovesOnly isKing:[figure king]];
    }    
}

- (void) makeAMove {
    //searching for a figures that can move
    Figure *figure;
    CCArray *moveFigures = [[CCArray alloc] init];
    CCArray *maxKiller = [[CCArray alloc] init];
    CCArray *currentKiller = [[CCArray alloc] init];
    //trying to find figures that can move
    CCARRAY_FOREACH([_playerBatch children], figure) {
        
        if (figure.dead == NO) {
            int moveDirections;
            if (_gameType != 0 || (_gameType == 0 && figure.king == YES))
                moveDirections = 4;
            else
                moveDirections = 2;
            int endPoint = 0;
            if ((_gameType == 0 && figure.king == YES) || _gameType != 0) {
                endPoint = 1;
            }
            for (int i = -1; i <= 1; i+=2) {
                for (int j= -1; j <= endPoint; j +=2) {
                    [currentKiller removeAllObjects];
                    CGPoint point = ccp(figure.position.x + i * oneCellWidth, figure.position.y + j * oneCellWidth);
                    CGRect rect = CGRectMake(point.x - oneCellWidth * 0.4f, point.y - oneCellWidth * 0.4f, oneCellWidth * 0.8f, oneCellWidth * 0.8f);
                    
                    
                    //check for own figures at this point
                    if (![self isCellFree:rect figuresOfPlayer:[_playerBatch children]]) {
                        moveDirections--;
                    }
                    
                    //check for opponents figures
                    Figure *otherFigure;
                    CCARRAY_FOREACH([[[PlayerOne sharedFirstPlayer] playerBatch] children], otherFigure) {
                        if (CGRectContainsPoint(rect, otherFigure.position)) {
                            CGPoint destinationCell = ccpSub(otherFigure.position, figure.position);
                            destinationCell = ccpAdd(otherFigure.position, destinationCell);
                            CGRect destinationRect = CGRectMake(destinationCell.x - oneCellWidth * 0.4f, destinationCell.y - 0.4f * oneCellWidth, oneCellWidth * 0.8f, oneCellWidth * 0.8f);
                            //if destination cell is busy, minus direction;
                            
                            if ([self isCellFree:destinationRect figuresOfPlayer:[[[PlayerOne sharedFirstPlayer] playerBatch] children]] && [self isCellFree:destinationRect figuresOfPlayer:[_playerBatch children]]) {
                                [currentKiller addObject:figure];
                                [currentKiller addObject:otherFigure];
                                
                                
                                CGPoint previousPoint = otherFigure.position;
                                CGPoint currentPoint = destinationCell;
                                CGPoint resultPoint = [self checkFiguresToKillFrom:currentPoint previousPoint:previousPoint with:figure];
                                
                                CCArray *points = [[CCArray alloc] init];
                                while (!CGPointEqualToPoint(resultPoint, CGPointZero)) {
                                    [currentKiller addObject:figure];
                                    [currentKiller addObject:otherFigure];
                                    [points addObject:[NSValue valueWithCGPoint:previousPoint]];
                                    //CGPoint temp = possiblePoint;
                                    previousPoint = ccpSub(resultPoint, currentPoint);
                                    previousPoint = ccpMult(previousPoint, 0.5f);
                                    previousPoint = ccpAdd(currentPoint, previousPoint);
                                    currentPoint = resultPoint;
                                                                        
                                    resultPoint = [self checkFiguresToKillFrom:currentPoint previousPoint:previousPoint with:figure];
                                    
                                    id pointTmp;
                                    CCARRAY_FOREACH(points, pointTmp) {
                                        CGPoint killedPoint = [pointTmp CGPointValue];
                                        if (CGPointEqualToPoint(killedPoint, previousPoint) && !CGPointEqualToPoint(resultPoint, CGPointZero)) {
                                            resultPoint = CGPointZero;
                                            break;
                                        }
                                    }
                                }
                                
                                if ([currentKiller count] > [maxKiller count]) {
                                    [maxKiller removeAllObjects];
                                    [maxKiller addObjectsFromArray:currentKiller];
                                }
                                
                                break;
                            } else {
                                moveDirections--;
                                break;
                            }
                        }
                    }
                }
            }
            if (moveDirections > 0) {
                [moveFigures addObject:figure];
            }
        } //if (figure.dead == NO)
    }
    if ([maxKiller count] > 0) {
        //actions to kill
        Figure *killer = [maxKiller objectAtIndex:0];
        Figure *killIt = [maxKiller objectAtIndex:1];
        [self killFigure:killIt with:killer];
        
    } else if ([moveFigures count] > 0) {
        BOOL finished = NO;
        BOOL safe = YES;
        while (!finished) {
            int randomFigure = arc4random() % [moveFigures count];
            Figure *figure = [moveFigures objectAtIndex:randomFigure];
            
            CGPoint newPoint = CGPointZero;
            for (int i = -1; i <= 1; i += 2) {
                for (int j= -1; j <= 1; j += 2) {
                    if (j >= 0 && (_gameType == 0 && figure.king == NO)) {
                        break;
                    }
                    CGPoint point = ccp(figure.position.x + i * oneCellWidth, figure.position.y + j * oneCellWidth);
                    CGRect cell = CGRectMake(point.x - 0.4f * oneCellWidth, point.y - 0.4f * oneCellWidth, oneCellWidth * 0.8f, oneCellWidth * 0.8f);
                    
                    if ([self isCellFree:cell figuresOfPlayer:[_playerBatch children]] && [self isCellFree:cell figuresOfPlayer:[[[PlayerOne sharedFirstPlayer] playerBatch] children]]) {
                        if (safe) {
                            if (![self canFigure:figure beKilledAt:point]) {
                        
                                newPoint = point;
                                finished = YES;
                                break;
                            }
                        }
                        else {
                            newPoint = point;
                            finished = YES;
                            break;
                        }
                    }
                }
                if (finished) break;
            }
            if (!CGPointEqualToPoint(CGPointZero, newPoint)) {
                CCLOG(@"%f x %f", newPoint.x, newPoint.y);
                [self moveFigure:figure to:newPoint];
            } else {
                CCLOG(@"shitty cycle. NO MOVE");
                safe = NO;
            }  
        }
    }
}

- (CGRect) killNextWith:(Figure *)figure {
    int endPoint = 0;
    if ((_gameType == 0 && figure.king == YES) || _gameType != 0) {
        endPoint = 1;
    }
    for (int i = -1; i <= 1; i+=2) {
        for (int j= -1; j <= endPoint; j +=2) {
            CGPoint point = ccp(figure.position.x + i * oneCellWidth, figure.position.y + j * oneCellWidth);
            CGRect cell = CGRectMake(point.x - 0.4f * oneCellWidth, point.y - 0.4f * oneCellWidth, oneCellWidth * 0.8f, oneCellWidth * 0.8f);
            Figure *opponent;
            CCARRAY_FOREACH([[[PlayerOne sharedFirstPlayer] playerBatch] children], opponent) {
                if (opponent.dead == NO && CGRectContainsPoint(cell, opponent.position)) {
                    //we have another figure around. so, let's check whether next point is free
                    CGPoint nextCell = ccpSub(opponent.position, figure.position);
                    CGPoint cellAfterCell = ccpAdd(opponent.position, nextCell);
                    CGRect cellAfterCellRect = CGRectMake(cellAfterCell.x - oneCellWidth * 0.4f, cellAfterCell.y - oneCellWidth * 0.4f, oneCellWidth * 0.8f, oneCellWidth * 0.8f);
                    if ([self isCellFree:cellAfterCellRect figuresOfPlayer:[_playerBatch children]]) {
                        if ([self isCellFree:cellAfterCellRect figuresOfPlayer:[[[PlayerOne sharedFirstPlayer] playerBatch] children]]) {
                            CGRect opponentRect = CGRectMake(opponent.position.x - oneCellWidth * 0.4f, opponent.position.y - oneCellWidth * 0.4f, oneCellWidth * 0.8f, oneCellWidth * 0.8f);
                            if (CGRectContainsRect([self getBoardRect], opponentRect))
                                return opponentRect;
                        }
                    }
                }
            }
        }
    }
    return CGRectZero;
}

- (void) killFigure:(Figure *)killIt with:(Figure *)killer {
    CGPoint newCell = ccpSub(killIt.position, killer.position);
    newCell = ccpAdd(killIt.position, newCell);
    [killer stopAllActions];
    
    
    
    
    if (killer.king == YES) {
        [self findKingSpriteWithPosition:killer.position changeItTo:newCell command:@"move"];
    } else {
        /*CCSequence *seq = [CCSequence actions:
         [CCMoveTo actionWithDuration:0.3f position:newCell],
         [CCCallFuncND actionWithTarget:self selector:@selector(checkForKingsPosition:data:) data:killer], nil];
         [killer runAction:seq];*/
       [killer runAction:[CCMoveTo actionWithDuration:0.3f position:newCell]];
    }
    killer.position = newCell;
    [self checkForKingsPositionFor:killer];
    
    killIt.dead = YES;
    
    if (killIt.king == YES)
        [[PlayerOne sharedFirstPlayer] findKingSpriteWithPosition:killIt.position
                                                           changeItTo:ccp(0.f,0.f) command:@"dead"];
    
    int oldScore = [[PlayerTwo sharedSecondPlayer] score] + 1;
    [PlayerTwo sharedSecondPlayer].score = oldScore;
    
    //placing killed figure somewher
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    float score = [[PlayerTwo sharedSecondPlayer] score];
    score *= 50;
    CGPoint killedFiguresPlace = ccp(100 + score,screenSize.height - (screenSize.height - oneCellWidth * 8) * 0.2f);
    if (killIt.king) {
        [[PlayerOne sharedFirstPlayer] findKingSpriteWithPosition:ccp(0.f,0.f) changeItTo:killedFiguresPlace command:@"newKing"];
    } else {
        CCAction *seq = [CCSequence actions:[CCDelayTime actionWithDuration:0],[CCMoveTo actionWithDuration:0.3f position:killedFiguresPlace], nil];
        [killIt runAction:seq];
    }
    CGRect possibleRect = [self killNextWith:killer];
    
    //check for other figures to kill
    int durationForKilledFigure = 1;
    while (!CGRectEqualToRect(possibleRect, CGRectZero)) {
        CCARRAY_FOREACH([[[PlayerOne sharedFirstPlayer] playerBatch] children], killIt) {
            if (killIt.dead == NO && CGRectContainsPoint(possibleRect, killIt.position)) {
                CGPoint cellAfterCell = ccpSub(killIt.position, killer.position);
                cellAfterCell = ccpAdd(killIt.position, cellAfterCell);
                CGRect cellAfterCellRect = CGRectMake(cellAfterCell.x - oneCellWidth * 0.4f, cellAfterCell.y - oneCellWidth * 0.4f, oneCellWidth * 0.8f, oneCellWidth * 0.8f);
                
                if ([self isCellFree:cellAfterCellRect figuresOfPlayer:[_playerBatch children]] && [self isCellFree:cellAfterCellRect figuresOfPlayer:[[[PlayerOne sharedFirstPlayer] playerBatch] children]]) {
                    CCAction *seq = [CCSequence actions:[CCDelayTime actionWithDuration:1],[CCMoveTo actionWithDuration:0.3f position:cellAfterCell], nil];
                    
                    if (killer.king == YES) {
                        [self findKingSpriteWithPosition:killer.position changeItTo:cellAfterCell command:@"move"];
                    } else {
                        [killer runAction:seq];
                    }
                    killer.position = cellAfterCell;
                    
                    if (killer.king == NO)
                        [self checkForKingsPositionFor:killer];
                    
                    killIt.dead = YES;
                    if (killIt.king == YES)
                        [[PlayerOne sharedFirstPlayer] findKingSpriteWithPosition:killIt.position
                                                                       changeItTo:ccp(0.f,0.f) command:@"dead"];
                    
                    int oldScore = [[PlayerTwo sharedSecondPlayer] score] + 1;
                    [PlayerTwo sharedSecondPlayer].score = oldScore;
                    
                    //placing killed figure somewher
                    CGSize screenSize = [[CCDirector sharedDirector] winSize];
                    float score = [[PlayerTwo sharedSecondPlayer] score];
                    score *= 50;
                    CGPoint killedFiguresPlace = ccp(100 + score,screenSize.height - (screenSize.height - oneCellWidth * 8) * 0.2f);
                    if (killIt.king) {
                        
                        [[PlayerOne sharedFirstPlayer] findKingSpriteWithPosition:ccp(0.f,0.f) changeItTo:killedFiguresPlace command:@"newKing"];
                    } else {
                        
                        CCAction *seq = [CCSequence actions:[CCDelayTime actionWithDuration:durationForKilledFigure],[CCMoveTo actionWithDuration:0.3f position:killedFiguresPlace], nil];
                        [killIt runAction:seq];
                        durationForKilledFigure++;
                    }
                    possibleRect = [self killNextWith:killer];
                    break;
                }
                
            }
        }
    }
    self.yourMove = NO;
    self.anotherMove = NO;
    self.killerFigure = nil;
    [PlayerOne sharedFirstPlayer].yourMove = YES;
    [[GameLevelLayer sharedGameLevelLayer] changeYourMoveLed:YES];
}

- (CGPoint) checkFiguresToKillFrom:(CGPoint)figurePoint previousPoint:(CGPoint)previousPoint with:(Figure *)figure {
    //previousPoint - point of first killed figure
    //YES - if there are some figures to kill
    //NO - if there is no figures anymore

    
    int endPoint = 0;
    if ((_gameType == 0 && figure.king == YES) || _gameType != 0) {
        endPoint = 1;
    }
    for (int i = -1; i <= 1; i+=2) {
        for (int j= -1; j <= endPoint; j +=2) {
            CGPoint point = ccp(figurePoint.x + i * oneCellWidth, figurePoint.y + j * oneCellWidth);
            CGRect cell = CGRectMake(point.x - 0.4f * oneCellWidth, point.y - 0.4f * oneCellWidth, oneCellWidth * 0.8f, oneCellWidth * 0.8f);
            if (!CGPointEqualToPoint(point, previousPoint)) {
                Figure *opponentFigure;
                CCARRAY_FOREACH([[[PlayerOne sharedFirstPlayer] playerBatch] children], opponentFigure) {
                    if (opponentFigure.dead == NO && CGRectContainsPoint(cell, opponentFigure.position)) {
                        //another figure to kill! check whether next cell is free, so we can kill him!
                        CGPoint cellAfterCell = ccpSub(opponentFigure.position, figurePoint);
                        cellAfterCell = ccpAdd(opponentFigure.position, cellAfterCell);
                        CGRect cellAfterCellRect = CGRectMake(cellAfterCell.x - oneCellWidth * 0.4f, cellAfterCell.y - oneCellWidth * 0.4f, oneCellWidth * 0.8f, oneCellWidth * 0.8f);
                        //if cellAfterCell is clear, we can kill a figure!
                        if ([self isCellFree:cellAfterCellRect figuresOfPlayer:[[[PlayerOne sharedFirstPlayer] playerBatch] children]] && [self isCellFree:cellAfterCellRect figuresOfPlayer:[_playerBatch children]]) {
                            return cellAfterCell;
                            //break;
                        }
                    }
                }
            }
        }
    }
    return CGPointZero;
}

- (BOOL) isCellFree:(CGRect)cell figuresOfPlayer:(CCArray*)figures {
    //return No if busy, YES if free
    if (CGRectContainsRect([self getBoardRect], cell)) {
        Figure *figure;
        CCARRAY_FOREACH(figures, figure) {
            if (CGRectContainsPoint(cell, figure.position)) {
                return NO;
                break;
            }
        }
        return YES;
    }
    return NO;
}

- (void) moveFigure:(Figure *)figure to:(CGPoint)point {
    [figure stopAllActions];
    if (figure.king == YES) {
        [self findKingSpriteWithPosition:figure.position changeItTo:point command:@"move"];
    }
    CCSequence *move = [CCSequence actions:[CCMoveTo actionWithDuration:0.3f position:point], nil];
    /*CCSequence *move = [CCSequence actions:[CCMoveTo actionWithDuration:0.3f position:point],
                        [CCCallFuncND actionWithTarget:self selector:@selector(checkForKingsPosition:data:) data:figure], nil];*/
    [figure runAction:move];
    figure.position = point;
    
    [self checkForKingsPositionFor:figure];
    
    [PlayerOne sharedFirstPlayer].yourMove = YES;
    self.yourMove = NO;
    self.anotherMove = NO;
    self.killerFigure = nil;
    [[GameLevelLayer sharedGameLevelLayer] changeYourMoveLed:YES];
}


- (BOOL) canFigure:(Figure *)figure beKilledAt:(CGPoint) point{
    //YES - if figure will be killed in this cell
    // NO - if it's safe to move there
    
    BOOL can = NO;
    //CCArray *directions = [[CCArray alloc] initWithCapacity:3];
    Figure *opponentFigure;
    
    
    CGRect NWAttackPoint = CGRectMake(point.x - oneCellWidth * 1.4f, point.y + oneCellWidth * 0.6f, oneCellWidth * 0.8f, oneCellWidth * 0.8f);
    CGRect NEAttackPoint = CGRectMake(point.x + oneCellWidth * 0.6f, point.y + oneCellWidth * 0.6f, oneCellWidth * 0.8f, oneCellWidth * 0.8f);
    CGRect SWAttackPoint = CGRectMake(point.x - oneCellWidth * 1.4f, point.y - oneCellWidth * 1.4f, oneCellWidth * 0.8f, oneCellWidth * 0.8f);
    CGRect SEAttackPoint = CGRectMake(point.x + oneCellWidth * 0.6f,
                                      point.y - oneCellWidth * 1.4f,
                                      oneCellWidth * 0.8f,
                                      oneCellWidth * 0.8f);
        
    CCARRAY_FOREACH([[[PlayerOne sharedFirstPlayer] playerBatch] children], opponentFigure) {
        CGPoint newOpponentsPoint;
        CGRect newOpponentsPointRect = CGRectZero;
        if (opponentFigure.dead == NO && CGRectContainsPoint(NWAttackPoint, opponentFigure.position)) {
            //check if opponent figure can kill this figure.
            newOpponentsPoint = ccpSub(point, opponentFigure.position);
            newOpponentsPoint = ccpAdd(point, newOpponentsPoint);
            newOpponentsPointRect = CGRectMake(newOpponentsPoint.x - oneCellWidth * 0.4f, newOpponentsPoint.y - oneCellWidth * 0.4f, oneCellWidth * 0.8f, oneCellWidth * 0.8f);
        } else if (opponentFigure.dead == NO && CGRectContainsPoint(SWAttackPoint, opponentFigure.position)) {
            //check if opponent figure can kill this figure.
            newOpponentsPoint = ccpSub(point, opponentFigure.position);
            newOpponentsPoint = ccpAdd(point, newOpponentsPoint);
            newOpponentsPointRect = CGRectMake(newOpponentsPoint.x - oneCellWidth * 0.4f, newOpponentsPoint.y - oneCellWidth * 0.4f, oneCellWidth * 0.8f, oneCellWidth * 0.8f);
        } else if (opponentFigure.dead == NO && CGRectContainsPoint(NEAttackPoint, opponentFigure.position)) {
            //check if opponent figure can kill this figure.
            newOpponentsPoint = ccpSub(point, opponentFigure.position);
            newOpponentsPoint = ccpAdd(point, newOpponentsPoint);
            newOpponentsPointRect = CGRectMake(newOpponentsPoint.x - oneCellWidth * 0.4f, newOpponentsPoint.y - oneCellWidth * 0.4f, oneCellWidth * 0.8f, oneCellWidth * 0.8f);
        } else if (opponentFigure.dead == NO && CGRectContainsPoint(SEAttackPoint, opponentFigure.position)) {
            //check if opponent figure can kill this figure.
            newOpponentsPoint = ccpSub(point, opponentFigure.position);
            newOpponentsPoint = ccpAdd(point, newOpponentsPoint);
            newOpponentsPointRect = CGRectMake(newOpponentsPoint.x - oneCellWidth * 0.4f, newOpponentsPoint.y - oneCellWidth * 0.4f,    oneCellWidth * 0.8f, oneCellWidth * 0.8f);
        }

        if (!CGRectEqualToRect(CGRectZero, newOpponentsPointRect)) {
            if (CGRectContainsRect([self getBoardRect], newOpponentsPointRect))
                if (CGPointEqualToPoint(newOpponentsPoint, figure.position))
                    return YES;
                else {
                    Figure *anotherFigure;
                    CCARRAY_FOREACH([_playerBatch children], anotherFigure) {
                        if (CGRectContainsPoint(newOpponentsPointRect, anotherFigure.position)) {
                            can = NO;
                            break;
                        }
                        else
                            return YES;
                    }
                }
            else
                can = NO;
        }
    }
    return can;
}

- (void) checkForKingsPosition:(id)sender data:(Figure *)figure {
    CGRect figureRect = CGRectMake(figure.position.x - oneCellWidth * 0.4f, figure.position.y - oneCellWidth * 0.4f, oneCellWidth * 0.8f, oneCellWidth * 0.8f);
    if (CGRectContainsPoint(figureRect, ccp(figure.position.x, kingsYForPlayerTwo)) && figure.king == NO) {
        figure.king = YES;
        
        figure.visible = NO;
        [self findKingSpriteWithPosition:ccp(0.f,0.f) changeItTo:figure.position command:@"newKing"];
    }
}

- (void) checkForKingsPositionFor:(Figure *)figure {
    CGRect figureRect = CGRectMake(figure.position.x - oneCellWidth * 0.4f, figure.position.y - oneCellWidth * 0.4f, oneCellWidth * 0.8f, oneCellWidth * 0.8f);
    if (CGRectContainsPoint(figureRect, ccp(figure.position.x, kingsYForPlayerTwo)) && figure.king == NO) {
        figure.king = YES;
        
        figure.visible = NO;
        [self findKingSpriteWithPosition:ccp(0.f,0.f) changeItTo:figure.position command:@"newKing"];
    }
}

- (CGPoint) findNearestOpponentTo:(Figure *)figure {
    float y = 0;
    float x = 0;
    int i = 0;
    Figure *opponent;
    while (y == 0 || x == 0) {
        y = [[[[[PlayerOne sharedFirstPlayer] playerBatch] children] objectAtIndex:i] position].y - figure.position.y;
        x = [[[[[PlayerOne sharedFirstPlayer] playerBatch] children] objectAtIndex:i] position].x - figure.position.x;
        i++;
    }
    y = abs(y);
    x = abs(x);
    CCARRAY_FOREACH([[[PlayerOne sharedFirstPlayer] playerBatch] children], opponent) {
        float currentY = opponent.position.y - figure.position.y;
        float currentX = opponent.position.x - figure.position.x;
        if (abs(currentY) < abs(y) && currentY != 0)
            y = currentY;
        if (abs(currentX) < abs(x) && currentX != 0)
            x = currentX;
    }
    if (x > 0)
        x = 1;
    else if (x < 0)
        x = -1;
    if (y > 0)
        y = 1;
    else if (y < 0)
        y = -1;
    
    return ccp(x, y);
}

- (float) pathToOpponentFrom:(Figure *)figure {
    Figure *opponent;
    float min = ccpDistance([[[[[PlayerOne sharedFirstPlayer] playerBatch] children] objectAtIndex:0] position], figure.position);
    CCARRAY_FOREACH([[[PlayerOne sharedFirstPlayer] playerBatch] children], opponent) {
        if (ccpDistance(opponent.position, figure.position) < min) {
            min = ccpDistance(opponent.position, figure.position);
        }
    }
    return min;
}
 
@end
