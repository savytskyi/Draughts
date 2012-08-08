#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "SettingsLayer.h"
#import "PlayerOne.h"
#import "PlayerTwo.h"

typedef enum {
    zForGameTable,
    zForBackgroundBoard,
    zForSettingsLayer,
    zForPlayerTwoLayer,
    zForPlayerOneLayer,
} ZForObjects;

typedef enum {
    tagBackgroundBoard,
    tagPlayerOneLayer,
    tagPlayerTwoLayer,
    tagSettingsLayer,
    tagGameTable,
} ObjectTags;

@interface GameLevelLayer : CCLayer {
    float _boardSize;
    CCSpriteBatchNode *_possibleMoveCells;
}

@property(readwrite,nonatomic,assign) CCSpriteBatchNode *possibleMoveCells;
@property(readonly,nonatomic) float boardSize;

+ (id) scene;
+ (GameLevelLayer *) sharedGameLevelLayer;
- (void) createFieldWith:(NSString *)black and:(NSString *)white;

+ (CGPoint) locationFromTouches:(NSSet*)touches;
+ (CGPoint) locationFromTouch:(UITouch*)touch;

@end
