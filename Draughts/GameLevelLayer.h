#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "SettingsLayer.h"
#import "PlayerOne.h"
#import "PlayerTwo.h"
#import "UserControls.h"

typedef enum {
    zForGameTable,
    zForBackgroundBoard,
    zForSettingsLayerButton,
    zForMoveLed,
    zForFigures,
    zForPossibleCells,
    zForPlayerTwoLayer,
    zForPlayerOneLayer,
    zForScores,
    
    zForMovingFigures,
    zForUserControlsLayer,
    zForSettingsLayer,
    zForSettingsCloth,
    zForSettingsClothShadow,
    zForSettingsLeftShadow,
    zForSettingsRightShadow,
    zForSettingsLowerShadow,
    zForSettingsUpperWood,
    zForCloseSettingsButton,
    zForSettingsFlags,
    zForIpadAndUser,
    zForCongrats,
} ZForObjects;

typedef enum {
    tagBackgroundBoard,
    tagPlayerOneLayer,
    tagPlayerTwoLayer,
    tagSettingsButton,
    tagSettingsLayer,
    tagGameTable,
    tagSettingsCloth,
    tagSettingsClothShadow,
    tagSettingsLeftShadow,
    tagSettingsRightShadow,
    tagSettingsLowerShadow,
    tagSettingsUpperWood,
    tagNewGame,
    tagSettingsCloseButton,
    tagSettingsBritish,
    tagSettingsEU,
    tagSettingsSoviet,
    tagLedYourMove,
    tagLedOpponentsMove,
    tagSettingsUser,
    tagSettingsIpad,
    tagSettingsOff,
    tagSettingsOn,
    tagSettingsOffIpad,
    tagSettingsOnIpad,
    tagSettingsBrownLight,
    tagSettingsBlackWhite,
    tagSettingsGreenWhite,
    tagScoresP1_1,
    tagScoresP1_2,
    tagScoresP2_1,
    tagScoresP2_2,
    tagNewGameName,
    tagNewGameReason,
    tagSettingsPlayButton,
} ObjectTags;

@interface GameLevelLayer : CCLayer {
    float _boardSize;
    CCSpriteBatchNode *_possibleMoveCells;
    
    int _gameType;
    CGPoint yourMovePosition;
    CGPoint opponentsMovePosition;
    CCSprite *yourMove;
    CCSprite *opponentsMove;
    BOOL _newGame;
}

@property(readwrite,nonatomic,assign) CCSpriteBatchNode *possibleMoveCells;
@property(readwrite,nonatomic,assign) BOOL newGame;
@property(readonly,nonatomic) float boardSize;
@property(readonly,nonatomic) int gameType;


+ (id) sceneWithGameType:(int) gameType playerTwo:(BOOL)playerTwo;
+ (GameLevelLayer *) sharedGameLevelLayer;
- (void) createFieldWith:(NSString *)black and:(NSString *)white;
- (void) createBackground;

+ (CGPoint) locationFromTouches:(NSSet*)touches;
+ (CGPoint) locationFromTouch:(UITouch*)touch;
- (void) changeYourMoveLed:(BOOL)yourMoveLed;
- (void) drawCells:(NSString *)black and:(NSString *)white;
- (void) removeCells;
- (void) addPoint:(int)player;

@end
