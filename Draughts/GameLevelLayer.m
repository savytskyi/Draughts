#import "GameLevelLayer.h"

@implementation GameLevelLayer

static GameLevelLayer *gameLevelLayerInstance;

+ (id) scene {
    CCScene *scene = [CCScene node];
    GameLevelLayer *layer = [GameLevelLayer node];
    [scene addChild:layer];
    return scene;
}

- (id) init {
    if ((self = [super init])) {
        NSAssert(gameLevelLayerInstance == nil, @"Another instance of GameLevelLayer is already in use");
        gameLevelLayerInstance = self;
        
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        CCSpriteFrameCache *frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        [frameCache addSpriteFramesWithFile:@"DraughtsSheet.plist"];
        
        CCSprite *backgroundBoard = [CCSprite spriteWithSpriteFrameName:@"Background.png"];
        backgroundBoard.position = ccp(screenSize.width * 0.5f, screenSize.height * 0.5f);
        [self addChild:backgroundBoard z:-1 tag:tagBackgroundBoard];
        
        [self createFieldWith:@"BrownTexture" and:@"LightTexture"];
        
        
        float oneCellWidth = _boardSize * 0.125;
        float startXPoint = (screenSize.width - _boardSize) * 0.5 + 1 + (oneCellWidth - 2) * 0.5f;
        float startYPoint = (screenSize.height - _boardSize) * 0.5 + 1 + (oneCellWidth - 2) * 0.5f;
        float border = (screenSize.width - ((screenSize.width - _boardSize) * 0.5)) - 1 - (oneCellWidth - 2) * 0.5f;
        float oneStep = oneCellWidth;
        PlayerOne *playerOneLayer = [PlayerOne newWithFigures:@"RedPiece.png" boardSize:_boardSize startPoint:ccp(startXPoint,startYPoint) border:border oneStep:oneStep player:1];
        [self addChild:playerOneLayer z:zForPlayerOneLayer tag:tagPlayerOneLayer];
        
        startXPoint = screenSize.width - (oneCellWidth - 2) * 0.5f - 1 - (screenSize.width - _boardSize) * 0.5f;
        startYPoint = screenSize.height - (screenSize.height - _boardSize) * 0.5f - 1 - (oneCellWidth - 2) * 0.5f;
        border = (screenSize.width - _boardSize) * 0.5 + 1 + (oneCellWidth - 2) * 0.5f;
        oneStep = -oneCellWidth;
        PlayerTwo *playerTwoLayer = [PlayerTwo newWithFigures:@"WhitePiece.png" boardSize:_boardSize startPoint:ccp(startXPoint,startYPoint) border:border oneStep:oneStep player:2];
        [self addChild:playerTwoLayer z:zForPlayerTwoLayer tag:tagPlayerTwoLayer];
        
        SettingsLayer *settings = [SettingsLayer node];
        [self addChild:settings];
    }
    return self;
}

- (void) createFieldWith:(NSString *)black and:(NSString *)white {
    

    
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    NSString *cellName = [NSString stringWithFormat:@"%@1.png",black];
    CCSprite *cell = [CCSprite spriteWithSpriteFrameName:cellName];
    _boardSize = (cell.contentSize.width + 2) * 8;
    
    CCSpriteFrame *tableFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"table.png"];
    CCSpriteBatchNode *gameTableNode = [CCSpriteBatchNode batchNodeWithTexture:tableFrame.texture];
    [self addChild:gameTableNode z:zForGameTable tag:tagGameTable];
    int positionX = 0;
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
    [self addChild:_possibleMoveCells z:1];
    for (int i = 0; i < 15; i++) {
        CCSprite *possibleMoveCell = [CCSprite spriteWithSpriteFrameName:@"PossibleMoveCell.png"];
        possibleMoveCell.visible = NO;
        possibleMoveCell.position = ccp(10.f,10.f);
        [_possibleMoveCells addChild:possibleMoveCell];
    }
    
    CGPoint currentCell = ccp((screenSize.width - _boardSize) / 2 + 1,
                              (screenSize.height - _boardSize) / 2 + 1);
    float rightBorder = (screenSize.width - (screenSize.width - _boardSize) / 2) - 1;
    int row = 0;
    for (int i = 1; i <= 32; i++) {
        if (i % 8 == 0) row++;
        int randomNumber = 1 + arc4random() % 4;
        randomNumber += row;
        
        cellName = [NSString stringWithFormat:@"%@%i.png",black,randomNumber];
        cell = [CCSprite spriteWithSpriteFrameName:cellName];
        cell.anchorPoint = ccp(0.f,0.f);
        cell.position = currentCell;
        [self addChild:cell];
        currentCell.x += cell.contentSize.width + 2;
        
        cellName = [NSString stringWithFormat:@"%@%i.png",white,randomNumber];
        cell = [CCSprite spriteWithSpriteFrameName:cellName];
        cell.anchorPoint = ccp(0.f,0.f);
        cell.position = currentCell;
        [self addChild:cell];
        currentCell.x += cell.contentSize.width + 2;
        
        if (currentCell.x > rightBorder) {
            currentCell.x = (screenSize.width - _boardSize) / 2 + 1;
            currentCell.y += cell.contentSize.height + 2;
            NSString * temp = black;
            black = white;
            white = temp;
        }
    }
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

- (void) dealloc {
    gameLevelLayerInstance = nil;
    [super dealloc];
}

@end
