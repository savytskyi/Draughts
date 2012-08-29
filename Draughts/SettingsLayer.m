//
//  SettingsLayer.m
//  Draughts
//
//  Created by Cyril Savitsky on 8/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsLayer.h"


@implementation SettingsLayer

static SettingsLayer *instanceOfSettingsLayer;

+ (id) scene {
    CCScene *settingsScene = [CCScene node];
    SettingsLayer *layer = [SettingsLayer node];
    [settingsScene addChild:layer];
    return settingsScene;
}

+ (SettingsLayer *) sharedSettingsLayer {
    NSAssert(instanceOfSettingsLayer != nil, @"Settings instance still doesn't initialized");
    return instanceOfSettingsLayer;
}

- (id) init {
    if ((self = [super init])) {
        self.isTouchEnabled = YES;
        instanceOfSettingsLayer = self;
        [self drawSettingsMenuBackgound];
        [self addSettiingsMenuItems];
        
    }
    return self;
}

- (void) addSettiingsMenuItems {
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    
    
    //flags
    CCSprite *british = [CCSprite spriteWithSpriteFrameName:@"British.png"];
    CCSprite *eu = [CCSprite spriteWithSpriteFrameName:@"EU.png"];
    CCSprite *soviet = [CCSprite spriteWithSpriteFrameName:@"Soviet.png"];
    
    eu.position = ccp(screenSize.width * 0.5f, upperSettingsBorder - 1.1f/*0.6f*/ * eu.contentSize.height - 0.5f * textureSize);
    british.position = ccp(eu.position.x - 1.7f * eu.contentSize.width, eu.position.y);
    soviet.position = ccp(eu.position.x + 1.7f * eu.contentSize.width, eu.position.y);
    
    [self addChild:british z:zForSettingsFlags tag:tagSettingsBritish];
    [self addChild:soviet z:zForSettingsFlags tag:tagSettingsSoviet];
    [self addChild:eu z:zForSettingsFlags tag:tagSettingsEU];
    
    //
    // Choose game type text
    //
    CCLabelTTF *chooseGameTypeLabel = [CCLabelTTF labelWithString:@"Choose new game type:" fontName:@"Helvetica" fontSize:24];
    chooseGameTypeLabel.position = ccp(screenSize.width * 0.5f,
                                       upperSettingsBorder - 0.25f * chooseGameTypeLabel.contentSize.height - 0.5f * textureSize);
    chooseGameTypeLabel.color = ccc3(228, 244, 221);
    [self addChild:chooseGameTypeLabel z:zForSettingsFlags];
    if (![[GameLevelLayer sharedGameLevelLayer] newGame]) {
        CCLabelTTF *restarted = [CCLabelTTF labelWithString:@"game will be restarted" fontName:@"Helvetica" fontSize:12];
        restarted.position = ccp(chooseGameTypeLabel.position.x, chooseGameTypeLabel.position.y - 1.3f * restarted.contentSize.height);
        restarted.color = ccc3(206, 218, 196);
        [self addChild:restarted z:zForSettingsFlags];
    }
    
    //
    // Game type descriptions
    //
    
    CCLabelTTF *britishLogo = [CCLabelTTF labelWithString:@"British" fontName:@"Helvetica" fontSize:20];
    CCLabelTTF *euLogo = [CCLabelTTF labelWithString:@"International" fontName:@"Helvetica" fontSize:20];
    CCLabelTTF *sovietLogo = [CCLabelTTF labelWithString:@"Soviet" fontName:@"Helvetica" fontSize:20];
    
    britishLogo.position = ccp(british.position.x, british.position.y - 0.8f * british.contentSize.height);
    euLogo.position = ccp(eu.position.x, eu.position.y - 0.8f * eu.contentSize.height);
    sovietLogo.position = ccp(soviet.position.x, soviet.position.y - 0.8f * soviet.contentSize.height);
    
    britishLogo.color = ccc3(206, 218, 196);
    euLogo.color = ccc3(206, 218, 196);
    sovietLogo.color = ccc3(206, 218, 196);
    
    [self addChild:britishLogo z:zForSettingsFlags];
    [self addChild:euLogo z:zForSettingsFlags];
    [self addChild:sovietLogo z:zForSettingsFlags];
    
    NSString *britishDesc = [NSString stringWithFormat:@"8x8 board\nno backward captures\nshort-range kings"];
    NSString *euDesc = [NSString stringWithFormat:@"10x10 board\nbackward captures\nlong-range kings"];
    NSString *sovietDesc = [NSString stringWithFormat:@"8x8 board\nbackward captures\nlong-range kings"];
    
    CCLabelTTF *britishDescLabel = [CCLabelTTF labelWithString:britishDesc fontName:@"Helvetica" fontSize:16];
    CCLabelTTF *euDescLabel = [CCLabelTTF labelWithString:euDesc fontName:@"Helvetica" fontSize:17];
    CCLabelTTF *sovietDescLabel = [CCLabelTTF labelWithString:sovietDesc fontName:@"Helvetica" fontSize:16];
    
    britishDescLabel.color = ccc3(206, 218, 196);
    euDescLabel.color = ccc3(206, 218, 196);
    sovietDescLabel.color = ccc3(206, 218, 196);
    
    britishDescLabel.position = ccp(britishLogo.position.x, britishLogo.position.y - 2 * britishLogo.contentSize.height);
    euDescLabel.position = ccp(euLogo.position.x, euLogo.position.y - 2 * euLogo.contentSize.height);
    sovietDescLabel.position = ccp(sovietLogo.position.x, sovietLogo.position.y - 2 * sovietLogo.contentSize.height);
    
    [self addChild:britishDescLabel z:zForSettingsFlags];
    [self addChild:euDescLabel z:zForSettingsFlags];
    [self addChild:sovietDescLabel z:zForSettingsFlags];
    
    //
    // Board colors
    //
    
    CCLabelTTF *boardColor = [CCLabelTTF labelWithString:@"Choose board color:" fontName:@"Helvetica" fontSize:24];
    boardColor.color = ccc3(228, 244, 221);
    boardColor.position = ccp(screenSize.width * 0.5f, britishDescLabel.position.y - 1.7f * britishDescLabel.contentSize.height);
    [self addChild:boardColor z:zForSettingsFlags];
    
    CCSprite *BrownLight = [CCSprite spriteWithSpriteFrameName:@"BrownLight.png"];
    CCSprite *GreenWhite = [CCSprite spriteWithSpriteFrameName:@"GreenWhite.png"];
    CCSprite *BlackWhite = [CCSprite spriteWithSpriteFrameName:@"BlackWhite.png"];
    
    BrownLight.position = ccp(eu.position.x, boardColor.position.y - 2.3f * boardColor.contentSize.height);
    BlackWhite.position = ccp(british.position.x, BrownLight.position.y);
    GreenWhite.position = ccp(soviet.position.x, BrownLight.position.y);
    
    [self addChild:BrownLight z:zForSettingsFlags tag:tagSettingsBrownLight];
    [self addChild:BlackWhite z:zForSettingsFlags tag:tagSettingsBlackWhite];
    [self addChild:GreenWhite z:zForSettingsFlags tag:tagSettingsGreenWhite];
    
    //game type tick
    CCSprite *tick = [CCSprite spriteWithFile:@"Tick.png"];
    int gameType = [[GameLevelLayer sharedGameLevelLayer] gameType];
    switch (gameType) {
        case 0:
            tick.position = ccp(british.position.x - british.contentSize.width * 0.4f,
                                british.position.y + british.contentSize.height * 0.4f);
            break;
        case 1:
            tick.position = ccp(eu.position.x - eu.contentSize.width * 0.4f,
                                eu.position.y + eu.contentSize.height * 0.4f);
            break;
        case 2:
            tick.position = ccp(soviet.position.x - soviet.contentSize.width * 0.4f,
                                soviet.position.y + soviet.contentSize.height * 0.4f);
            break;
        default:
            tick.visible = NO;
            break;
    }
    
    [self addChild:tick z:zForSettingsFlags];
    
    ////
    /// User vs iPad preferences
    //
    CCLabelTTF *opponentType = [CCLabelTTF labelWithString:@"Your opponent:" fontName:@"Helvetica" fontSize:24];
    opponentType.color = ccc3(228, 244, 221);
    opponentType.position = ccp(screenSize.width * 0.5f, BrownLight.position.y - 1.f * BrownLight.contentSize.height);
    [self addChild:opponentType z:zForSettingsFlags];
    
    CCSprite *user = [CCSprite spriteWithSpriteFrameName:@"user.png"];
    CCSprite *ipad = [CCSprite spriteWithSpriteFrameName:@"ipad.png"];
    CCSprite *ledOn = [CCSprite spriteWithSpriteFrameName:@"blue_led.png"];
    CCSprite *ledOff = [CCSprite spriteWithSpriteFrameName:@"blue_led_off.png"];
    
    CCSprite *ledOnIpad = [CCSprite spriteWithSpriteFrameName:@"blue_led.png"];
    CCSprite *ledOffIpad = [CCSprite spriteWithSpriteFrameName:@"blue_led_off.png"];
    
    BOOL playerVSplayer = [[PlayerTwo sharedSecondPlayer] playVersusUser];
    //user.anchorPoint = ccp(0.5f,0.f);
    //ipad.anchorPoint = ccp(0.5f,0.f);
    ledOff.anchorPoint = ccp(0.5f,0.f);
    ledOff.visible = !playerVSplayer;
    ledOn.visible = playerVSplayer;
    ledOn.anchorPoint = ccp(0.5f,0.f);
    
    ledOffIpad.anchorPoint = ccp(0.5f,0.f);
    ledOffIpad.visible = playerVSplayer;
    ledOnIpad.visible = !playerVSplayer;
    ledOnIpad.anchorPoint = ccp(0.5f,0.f);
    
    //computerVSUser.position = ccp(200.f,screenSize.height - 70.f);
    user.position = ccp(screenSize.width * 0.5f - user.contentSize.width, opponentType.position.y - 2.2f * opponentType.contentSize.height);
    ipad.position = ccp(screenSize.width * 0.5f + ipad.contentSize.width, opponentType.position.y - 2.2f * opponentType.contentSize.height);
    //ipad.position = ccp(rightSettingsBorder - ipad.contentSize.width * 1.3, lowerSettingsBorder + ledOff.contentSize.height * 3);
    ledOff.position = ccp(user.position.x, user.position.y - user.contentSize.height * 0.7f);
    ledOn.position = ccp(user.position.x, user.position.y - user.contentSize.height * 0.7f);
    ledOffIpad.position = ccp(ipad.position.x, ipad.position.y - ipad.contentSize.height * 0.7f);
    ledOnIpad.position = ccp(ipad.position.x, ipad.position.y - ipad.contentSize.height * 0.7f);
    
    [self addChild:ipad z:zForSettingsFlags tag:tagSettingsIpad];
    [self addChild:user z:zForSettingsFlags tag:tagSettingsUser];
    [self addChild:ledOff z:zForSettingsFlags tag:tagSettingsOff];
    [self addChild:ledOn z:zForSettingsFlags tag:tagSettingsOn];
    [self addChild:ledOffIpad z:zForSettingsFlags tag:tagSettingsOffIpad];
    [self addChild:ledOnIpad z:zForSettingsFlags tag:tagSettingsOnIpad];
    
    NSString *playString;
    
    if ([[GameLevelLayer sharedGameLevelLayer] newGame]) {
        playString = [NSString stringWithFormat:@"Play!"];
        CCSprite *play = [CCSprite spriteWithFile:@"play.png"];
        //CCLabelTTF *play = [CCLabelTTF labelWithString:playString fontName:@"Helvetica" fontSize:22];
        //play.color = ccc3(228, 244, 221);
        play.scale = 0.7f;
        play.position = ccp(screenSize.width * 0.5f, ledOn.position.y - 0.8f * play.contentSize.height);
        [self addChild:play z:zForSettingsFlags tag:tagSettingsPlayButton];
    }
}

- (void) drawSettingsMenuBackgound {
    makeAMoveAfterSettingsClosing = NO;
    
    CCSpriteFrame *settingsWoodTexture = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"settingsTopWood.png"];
    CCSpriteFrame *settingsShadowTexture = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"SettingsShadow.png"];
    CCSpriteFrame *settingsClothTexture = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"ClothTable.png"];
    CCSpriteFrame *settingsClothShadowTexture = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"ClothTableShadow.png"];
    
    CCSpriteBatchNode *upperSettingsWoodNode = [CCSpriteBatchNode batchNodeWithTexture:settingsWoodTexture.texture];
    CCSpriteBatchNode *shadowNode = [CCSpriteBatchNode batchNodeWithTexture:settingsShadowTexture.texture];
    CCSpriteBatchNode *clothNode = [CCSpriteBatchNode batchNodeWithTexture:settingsClothTexture.texture];
    CCSpriteBatchNode *clothShadowNode = [CCSpriteBatchNode batchNodeWithTexture:settingsClothShadowTexture.texture];
    
    [self addChild:upperSettingsWoodNode z:zForSettingsUpperWood tag:tagSettingsUpperWood];
    [self addChild:shadowNode z:zForSettingsLeftShadow tag:tagSettingsLeftShadow];
    [self addChild:clothNode z:zForSettingsCloth tag:tagSettingsCloth];
    [self addChild:clothShadowNode z:zForSettingsClothShadow tag:tagSettingsClothShadow];
    
    CCSprite *clothShadow = [CCSprite spriteWithSpriteFrameName:@"ClothTableShadow.png"];
    CCSprite *lowerShadow = [CCSprite spriteWithSpriteFrameName:@"SettingsShadow.png"];
    
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    
    textureSize = clothShadow.contentSize.width;
    
    leftSettingsBorder = screenSize.width * 0.5f - textureSize *6;
    rightSettingsBorder = screenSize.width * 0.5f + textureSize * 6;
    upperSettingsBorder = screenSize.height * 0.5f + 1.3f * textureSize + textureSize * 5;//3;
    if ([[GameLevelLayer sharedGameLevelLayer] newGame])
        lowerSettingsBorder = screenSize.height * 0.5f + 1.3f * textureSize - textureSize * 8;
    else
        lowerSettingsBorder = screenSize.height * 0.5f + 1.3f * textureSize - textureSize * 7;
    CCLOG(@"%f",lowerSettingsBorder);
    
    float currentXpos = leftSettingsBorder;
    
    float yPosForShadowCloth = upperSettingsBorder - textureSize;
    
    while (currentXpos < rightSettingsBorder) {
        CCSprite *settingsWood = [CCSprite spriteWithSpriteFrameName:@"settingsTopWood.png"];
        clothShadow = [CCSprite spriteWithSpriteFrameName:@"ClothTableShadow.png"];
        
        
        settingsWood.anchorPoint = ccp(0.f,0.f);
        clothShadow.anchorPoint = ccp(0.f,0.f);
        
        
        settingsWood.position = ccp(currentXpos, upperSettingsBorder);
        clothShadow.position = ccp(currentXpos, yPosForShadowCloth);
        float yPosForCloth = yPosForShadowCloth - textureSize;
        
        while (yPosForCloth > lowerSettingsBorder - textureSize) {
            CCSprite *cloth = [CCSprite spriteWithSpriteFrameName:@"ClothTable.png"];
            cloth.anchorPoint = ccp(0.f,0.f);
            cloth.position = ccp(currentXpos,yPosForCloth);
            [clothNode addChild:cloth];
            yPosForCloth -= textureSize;
        }
        float currentXposShadow = currentXpos;
        while (currentXposShadow < currentXpos + textureSize) {
            lowerShadow = [CCSprite spriteWithSpriteFrameName:@"SettingsShadow.png"];
            lowerShadow.rotation = 270.f;
            lowerShadow.anchorPoint = ccp(0.25f,1.f);
            lowerShadow.position = ccp(currentXposShadow,lowerSettingsBorder);
            [shadowNode addChild:lowerShadow];
            currentXposShadow += lowerShadow.contentSize.height;
        }
        
        [upperSettingsWoodNode addChild:settingsWood];
        [clothShadowNode addChild:clothShadow];
        
        
        currentXpos += settingsWood.contentSize.width;
    }
    
    float currentYPos = upperSettingsBorder + 0.5 * textureSize;
    while (currentYPos > lowerSettingsBorder - textureSize * 0.5f) {
        CCSprite *leftShadow = [CCSprite spriteWithSpriteFrameName:@"SettingsShadow.png"];
        CCSprite *rightShadow = [CCSprite spriteWithSpriteFrameName:@"SettingsShadow.png"];
        rightShadow.rotation = 180.f;
        
        leftShadow.anchorPoint = ccp(0.25f,0.f);
        rightShadow.anchorPoint = ccp(0.25f,1.f);
        leftShadow.position = ccp(leftSettingsBorder,currentYPos);
        rightShadow.position = ccp(rightSettingsBorder,currentYPos);
        [shadowNode addChild:rightShadow];
        [shadowNode addChild:leftShadow];
        currentYPos -= lowerShadow.contentSize.height;
        CCLOG(@"%f = %f, %f",currentYPos,lowerSettingsBorder,lowerShadow.contentSize.height);
    }
    
    
    
    CCSprite *NWCorner = [CCSprite spriteWithSpriteFrameName:@"SettingsCornerShadow.png"];
    NWCorner.anchorPoint = ccp(1.f,0.f);
    NWCorner.position = ccp(leftSettingsBorder,upperSettingsBorder + textureSize);
    [self addChild:NWCorner];
    
    CCSprite *SWCorner = [CCSprite spriteWithSpriteFrameName:@"SettingsCornerShadow.png"];
    SWCorner.rotation = 270.f;
    SWCorner.anchorPoint = ccp(1.f,0.f);
    SWCorner.position = ccp(leftSettingsBorder,lowerSettingsBorder);
    [self addChild:SWCorner];
    
    CCSprite *NECorner = [CCSprite spriteWithSpriteFrameName:@"SettingsCornerShadow.png"];
    NECorner.rotation = 90.f;
    NECorner.anchorPoint = ccp(1.f,0.f);
    NECorner.position = ccp(rightSettingsBorder,upperSettingsBorder + textureSize);
    [self addChild:NECorner];
    
    CCSprite *SECorner = [CCSprite spriteWithSpriteFrameName:@"SettingsCornerShadow.png"];
    SECorner.rotation = 180.f;
    SECorner.anchorPoint = ccp(1.f,0.f);
    SECorner.position = ccp(rightSettingsBorder,lowerSettingsBorder);
    [self addChild:SECorner];
    
    
    CCSprite *closeSettings = [CCSprite spriteWithSpriteFrameName:@"CloseSettings.png"];
    closeSettings.anchorPoint = ccp(1.f,0.f);
    closeSettings.position = ccp(rightSettingsBorder - closeSettings.contentSize.width * 0.5,
                                 upperSettingsBorder + closeSettings.contentSize.height * 0.5);
    closeSettings.scale = 1.5f;
    [self addChild:closeSettings z:zForCloseSettingsButton tag:tagSettingsCloseButton];
}

- (void) registerWithTouchDispatcher {
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:-3 swallowsTouches:YES];
}

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [GameLevelLayer locationFromTouch:touch];
    if (CGRectContainsPoint([[self getChildByTag:tagSettingsCloseButton] boundingBox], location) ||
        CGRectContainsPoint([[self getChildByTag:tagSettingsPlayButton] boundingBox], location)) {
        //[[CCDirector sharedDirector] popScene];
        [self.parent removeChildByTag:tagSettingsLayer cleanup:YES];
        return YES;
    }
    
    if (CGRectContainsPoint([[self getChildByTag:tagSettingsEU] boundingBox], location)) {
        [[CCDirector sharedDirector] replaceScene:[LoadingLayer loadTargetScene:TargetSceneFirstLevel withGameType:1 playerTwo:YES]];
    }
    
    if (CGRectContainsPoint([[self getChildByTag:tagSettingsBritish] boundingBox], location)) {
        [[CCDirector sharedDirector] replaceScene:[LoadingLayer loadTargetScene:TargetSceneFirstLevel withGameType:0 playerTwo:YES]];
    }
    
    if (CGRectContainsPoint([[self getChildByTag:tagSettingsSoviet] boundingBox], location)) {
        [[CCDirector sharedDirector] replaceScene:[LoadingLayer loadTargetScene:TargetSceneFirstLevel withGameType:2 playerTwo:YES]];
    }
    
    if (CGRectContainsPoint([[self getChildByTag:tagSettingsBlackWhite] boundingBox], location)) {
        [[GameLevelLayer sharedGameLevelLayer] removeCells];
        [[GameLevelLayer sharedGameLevelLayer] drawCells:@"DarkTexture" and:@"WhiteTexture"];
    }
    
    if (CGRectContainsPoint([[self getChildByTag:tagSettingsBrownLight] boundingBox], location)) {
        [[GameLevelLayer sharedGameLevelLayer] removeCells];
        [[GameLevelLayer sharedGameLevelLayer] drawCells:@"BrownTexture" and:@"LightTexture"];
    }
    
    if (CGRectContainsPoint([[self getChildByTag:tagSettingsGreenWhite] boundingBox], location)) {
        [[GameLevelLayer sharedGameLevelLayer] removeCells];
        [[GameLevelLayer sharedGameLevelLayer] drawCells:@"GreenTexture" and:@"WhiteTexture"];
    }
    
    if (CGRectContainsPoint([[self getChildByTag:tagSettingsUser] boundingBox], location)) {
        BOOL playerVSPlayer = [[PlayerTwo sharedSecondPlayer] playVersusUser];
        
        if (!playerVSPlayer) {
            CCLabelTTF *own = (CCLabelTTF *)[[GameLevelLayer sharedGameLevelLayer] getChildByTag:tagScoresP2_1];
            own.rotation = 180.f;
            [own setString:[NSString stringWithFormat:@"Your score: %i",[[PlayerTwo sharedSecondPlayer] score]]];
            [PlayerTwo sharedSecondPlayer].isTouchEnabled = YES;
            [self getChildByTag:tagSettingsOn].visible = YES;
            [self getChildByTag:tagSettingsOffIpad].visible = YES;
            
            [self getChildByTag:tagSettingsOnIpad].visible = NO;
            [self getChildByTag:tagSettingsOff].visible = NO;
            [PlayerTwo sharedSecondPlayer].playVersusUser = YES;
            
            
        }
    }
    
    if (CGRectContainsPoint([[self getChildByTag:tagSettingsIpad] boundingBox], location)) {
        BOOL playerVSPlayer = [[PlayerTwo sharedSecondPlayer] playVersusUser];
        if (playerVSPlayer) {
                    
            [PlayerTwo sharedSecondPlayer].isTouchEnabled = NO;
            if (([PlayerTwo sharedSecondPlayer].yourMove == YES && [[PlayerTwo sharedSecondPlayer] playVersusUser] == YES) || ([PlayerTwo sharedSecondPlayer].anotherMove == YES && [[PlayerTwo sharedSecondPlayer] playVersusUser] == YES)) {
                //[[PlayerTwo sharedSecondPlayer] makeAMove];
                makeAMoveAfterSettingsClosing = YES;  
            }
            CCLabelTTF *own = (CCLabelTTF *)[[GameLevelLayer sharedGameLevelLayer] getChildByTag:tagScoresP2_1];
            own.rotation = 0.f;
            [own setString:[NSString stringWithFormat:@"iPad's score: %i",[[PlayerTwo sharedSecondPlayer] score]]];
            [self getChildByTag:tagSettingsOn].visible = NO;
            [self getChildByTag:tagSettingsOffIpad].visible = NO;
            
            [self getChildByTag:tagSettingsOnIpad].visible = YES;
            [self getChildByTag:tagSettingsOff].visible = YES;
            [PlayerTwo sharedSecondPlayer].playVersusUser = NO;
        }
    }
    
    return YES;
    
}

- (void) dealloc {
    [super dealloc];
}

@end
