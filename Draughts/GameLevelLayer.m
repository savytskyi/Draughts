#import "GameLevelLayer.h"

@implementation GameLevelLayer

static GameLevelLayer *gameLevelLayerInstance;

+ (id) sceneWithGameType:(int) gameType playerTwo:(BOOL)playerTwo{
    CCScene *scene = [CCScene node];
    GameLevelLayer *layer = [[[GameLevelLayer alloc] initWithGameType:gameType playerTwo:playerTwo] autorelease];
    [scene addChild:layer];
    return scene;
}

- (id) initWithGameType:(int) gameType playerTwo:(BOOL)playerTwo {
    if ((self = [super init])) {
        gameLevelLayerInstance = self;
        
        _gameType = gameType;
        
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        CCSpriteFrameCache *frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        [frameCache addSpriteFramesWithFile:@"DraughtsSheet.plist"];
        
        yourMovePosition = ccp( screenSize.width - screenSize.width * 0.05f, 0 + screenSize.height * 0.03f );
        opponentsMovePosition = ccp( 0 + screenSize.width * 0.05f, screenSize.height - screenSize.height * 0.03f );
        
        [self createFieldWith:@"BrownTexture" and:@"LightTexture"];
        
        [self createBackground];
        
        float oneCellWidth;
        if (_gameType == 1)
            oneCellWidth = (int)_boardSize * 0.1f;
        else
            oneCellWidth = _boardSize * 0.125f;
        
        float startXPoint = (screenSize.width - _boardSize) * 0.5 + 1 + (oneCellWidth - 2) * 0.5f;
        float startYPoint = (screenSize.height - _boardSize) * 0.5 + 1 + (oneCellWidth - 2) * 0.5f;
        float border = (screenSize.width - ((screenSize.width - _boardSize) * 0.5)) - 1 - (oneCellWidth - 2) * 0.5f;
        float oneStep = oneCellWidth;
        PlayerOne *playerOneLayer = [PlayerOne createWithFigures:@"RedPiece.png" boardSize:_boardSize startPoint:ccp(startXPoint,startYPoint) border:border oneStep:oneStep player:1 gameType:gameType playerTwo:YES];
        [self addChild:playerOneLayer z:zForPlayerOneLayer tag:tagPlayerOneLayer];
        
        startXPoint = screenSize.width - (oneCellWidth - 2) * 0.5f - 1 - (screenSize.width - _boardSize) * 0.5f;
        startYPoint = screenSize.height - (screenSize.height - _boardSize) * 0.5f - 1 - (oneCellWidth - 2) * 0.5f;
        border = (screenSize.width - _boardSize) * 0.5 + 1 + (oneCellWidth - 2) * 0.5f;
        oneStep = -oneCellWidth;
        PlayerTwo *playerTwoLayer = [PlayerTwo createWithFigures:@"WhitePiece.png" boardSize:_boardSize startPoint:ccp(startXPoint,startYPoint) border:border oneStep:oneStep player:2 gameType:gameType playerTwo:playerTwo];
        [self addChild:playerTwoLayer z:zForPlayerTwoLayer tag:tagPlayerTwoLayer];
        
        UserControls *userControls = [UserControls node];
        [self addChild:userControls z:zForUserControlsLayer];
        
        NSString *player1Score = [NSString stringWithFormat:@"Your score: %i",[[PlayerOne sharedFirstPlayer] score]];
        NSString *player2Score = [NSString stringWithFormat:@"Your score: %i",[[PlayerTwo sharedSecondPlayer] score]];
        if (![[PlayerTwo sharedSecondPlayer] playVersusUser]) {
            player2Score = [NSString stringWithFormat:@"iPad's score: %i",[[PlayerTwo sharedSecondPlayer] score]];
            
        }
        
        CCLabelTTF *scoreP1 = [CCLabelTTF labelWithString:player1Score fontName:@"Helvetica" fontSize:16];
        CCLabelTTF *scoreP2 = [CCLabelTTF labelWithString:player2Score fontName:@"Helvetica" fontSize:16];

        if ([[PlayerTwo sharedSecondPlayer] playVersusUser]) {
            scoreP2.rotation = 180.f;
        }
        
        float scoreY = oneCellWidth * 0.2f;
        
        scoreP1.position = ccp(screenSize.width * 0.5, 0 + scoreY);
        scoreP2.position = ccp(screenSize.width * 0.5, screenSize.height - scoreY);
        
        scoreP1.color = ccc3(219, 201, 188);
        scoreP2.color = ccc3(219, 201, 188);
        
        [self addChild:scoreP1 z:zForScores tag:tagScoresP1_1];
        [self addChild:scoreP2 z:zForScores tag:tagScoresP2_1];
        _newGame = YES;
        SettingsLayer *settings = [SettingsLayer node];
        [self addChild:settings z:zForSettingsLayer tag:tagSettingsLayer];
        _newGame = NO;
    }
    return self;
}

- (void) createBackground {
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    
    //coordinates of background board
    CGPoint coordinateForBG = ccp(0.f,
                                  screenSize.height - (screenSize.height - _boardSize) * 0.5f);
    
    CCSprite *bgTop = [CCSprite spriteWithSpriteFrameName:@"bgTop.png"];
    bgTop.anchorPoint = ccp(0.f,0.f);
    bgTop.position = coordinateForBG;
    [self addChild:bgTop z:-1];
    
    coordinateForBG = ccp(0.f, coordinateForBG.y);
    CCSprite *bgLeft = [CCSprite spriteWithSpriteFrameName:@"bgLeft.png"];
    bgLeft.anchorPoint = ccp(0.f,1.f);
    bgLeft.position = coordinateForBG;
    [self addChild:bgLeft z:-1];
    
    coordinateForBG = ccp(screenSize.width, screenSize.height - (screenSize.height - _boardSize) * 0.5f);
    CCSprite *bgRight = [CCSprite spriteWithSpriteFrameName:@"bgRight.png"];
    bgRight.anchorPoint = ccp(1.f,1.f);
    bgRight.position = coordinateForBG;
    [self addChild:bgRight z:-1];
    
    
    CCSprite *bgBottom = [CCSprite spriteWithSpriteFrameName:@"bgBottom.png"];
    coordinateForBG = ccp(0.f, (screenSize.height - _boardSize) * 0.5f - bgBottom.contentSize.height);
    bgBottom.anchorPoint = ccp(0.f,0.f);
    bgBottom.position = coordinateForBG;
    [self addChild:bgBottom z:-1];
}

- (void) createFieldWith:(NSString *)black and:(NSString *)white {
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    NSString *cellName = [NSString stringWithFormat:@"%@1.png",black];
    CCSprite *cell = [CCSprite spriteWithSpriteFrameName:cellName];
    
    float cellWidth = cell.contentSize.width;
    int cellsInRow = 8;
    if (_gameType == 1) {
        cellsInRow = 10;
        cell.scale = 0.8f;
        cellWidth = (int)cell.contentSize.width * 0.8;
    }
    
    _boardSize = (cellWidth + 2) * cellsInRow;
    CCSpriteFrame *tableFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"table.png"];
    CCSpriteBatchNode *gameTableNode = [CCSpriteBatchNode batchNodeWithTexture:tableFrame.texture];
    
    [self addChild:gameTableNode z:zForGameTable tag:tagGameTable];
    int positionX = 0;
    
    //create table
    while (positionX < screenSize.width) {
        CCSprite *tableSprite = [CCSprite spriteWithSpriteFrameName:@"table.png"];
        tableSprite.anchorPoint = ccp(0.f,0.f);
        tableSprite.position = ccp(positionX, 0);
        [gameTableNode addChild:tableSprite];
        
        CCSprite *rotatedTableSprite = [CCSprite spriteWithSpriteFrameName:@"table.png"];
        rotatedTableSprite.rotation = 180.f;
        rotatedTableSprite.anchorPoint = ccp(1.f,0.f);
        rotatedTableSprite.position = ccp(positionX, screenSize.height);
        [gameTableNode addChild:rotatedTableSprite];
        positionX += tableSprite.contentSize.width;

    }
    
    
    
    CCSpriteFrame *possibleCellsFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PossibleMoveCell.png"];
    _possibleMoveCells = [CCSpriteBatchNode batchNodeWithTexture:possibleCellsFrame.texture];
    [self addChild:_possibleMoveCells z:zForPossibleCells];
    for (int i = 0; i < 15; i++) {
        CCSprite *possibleMoveCell = [CCSprite spriteWithSpriteFrameName:@"PossibleMoveCell.png"];
        possibleMoveCell.visible = NO;
        if (_gameType == 1)
            possibleMoveCell.scale = 0.8f;
        possibleMoveCell.position = ccp(10.f,10.f);
        [_possibleMoveCells addChild:possibleMoveCell z:zForPossibleCells];
    }
    
    [self drawCells:black and:white];
    
    yourMove = [CCSprite spriteWithSpriteFrameName:@"blue_led.png"];
    opponentsMove = [CCSprite spriteWithSpriteFrameName:@"blue_led_off.png"];
    opponentsMove.position = opponentsMovePosition;
    yourMove.position = yourMovePosition;
    [self addChild:opponentsMove z:zForMoveLed tag:tagLedOpponentsMove];
    [self addChild:yourMove z:zForMoveLed tag:tagLedYourMove];
}

+ (GameLevelLayer *) sharedGameLevelLayer {
    NSAssert(gameLevelLayerInstance != nil,
             @"Instance of GameLevelLayer does not initialized yet");
    return gameLevelLayerInstance;
}

+ (CGPoint) locationFromTouch:(UITouch*)touch {
	CGPoint touchLocation = [touch locationInView: [touch view]];
	return [[CCDirector sharedDirector] convertToGL:touchLocation];
}

+ (CGPoint) locationFromTouches:(NSSet*)touches {
	return [self locationFromTouch:[touches anyObject]];
}

- (void) changeYourMoveLed:(BOOL)yourMoveLed {
    if (yourMoveLed) {
        yourMove.position = yourMovePosition;
        opponentsMove.position = opponentsMovePosition;
    } else {
        yourMove.position = opponentsMovePosition;
        opponentsMove.position = yourMovePosition;
    }
}

- (void) dealloc {
    gameLevelLayerInstance = nil;
    [super dealloc];
}

- (void) drawCells:(NSString *)black and:(NSString *)white {
    int cellsCount = 32;
    if (_gameType == 1)
        cellsCount = 50;
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    
    CGPoint currentCell = ccp((screenSize.width - _boardSize) * 0.5 + 1,
                              (screenSize.height - _boardSize) * 0.5 + 1);
    float rightBorder = (screenSize.width - (screenSize.width - _boardSize) * 0.5) - 1;
    
    //tag for every cell. we need it because we will remove this cells sometimes
    int tagBlack = 100;
    int tagWhite = 200;
    
    float oneCellWidth;
    if (_gameType == 1)
        oneCellWidth = _boardSize * 0.1f;
    else
        oneCellWidth = _boardSize * 0.125f;
    
    for (int i = 1; i <= cellsCount; i++) {
        int randomNumber = 1 + arc4random() % 5;
        
        NSString *cellName = [NSString stringWithFormat:@"%@%i.png",black,randomNumber];
        CCSprite *cell = [CCSprite spriteWithSpriteFrameName:cellName];
        cell.anchorPoint = ccp(0.f,0.f);
        cell.position = currentCell;
        if (_gameType == 1)
            cell.scale = 0.8f;
        [self addChild:cell z:zForBackgroundBoard tag:tagBlack + i];
        currentCell.x += oneCellWidth;//cell.contentSize.width + 2;
        
        cellName = [NSString stringWithFormat:@"%@%i.png",white,randomNumber];
        cell = [CCSprite spriteWithSpriteFrameName:cellName];
        cell.anchorPoint = ccp(0.f,0.f);
        cell.position = currentCell;
        if (_gameType == 1)
            cell.scale = 0.8f;
        [self addChild:cell z:zForBackgroundBoard tag:tagWhite + i];
        currentCell.x += oneCellWidth; //cell.contentSize.width + 2;
        
        if (currentCell.x > rightBorder) {
            currentCell.x = (screenSize.width - _boardSize) / 2 + 1;
            currentCell.y += oneCellWidth; //cell.contentSize.height + 2;
            NSString * temp = black;
            black = white;
            white = temp;
        }
    }
}

- (void) removeCells {
    int cellsCount = 32;
    if (_gameType == 1)
        cellsCount = 50;
    int tagBlack = 100;
    int tagWhite = 200;
    for (int i = 1; i <= cellsCount; i++) {
        [self removeChildByTag:tagBlack + i cleanup:YES];
        [self removeChildByTag:tagWhite + i cleanup:YES];
    }
}

- (void) addPoint:(int)player {
    CCLabelTTF *own = [CCLabelTTF node];
    int oldScore;
    
    if (player == 1) {
        [PlayerOne sharedFirstPlayer].score++;
        oldScore = [[PlayerOne sharedFirstPlayer] score];
        own = (CCLabelTTF *)[self getChildByTag:tagScoresP1_1];
        
    } else {
        [PlayerTwo sharedSecondPlayer].score++;
        oldScore = [[PlayerTwo sharedSecondPlayer] score];
        own = (CCLabelTTF *)[self getChildByTag:tagScoresP2_1];
    }
    NSString *score = [NSString stringWithFormat:@"Your score: %i",oldScore];
    if (![[PlayerTwo sharedSecondPlayer] playVersusUser] && player == 2) {
        score = [NSString stringWithFormat:@"iPad's score: %i",oldScore];
    }
    [own setString:score];
}

@end
