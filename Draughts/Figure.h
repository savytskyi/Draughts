//
//  Figure.h
//  Draughts
//
//  Created by Cyril Savitsky on 8/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Figure : CCSprite {
    BOOL _king;
    BOOL _dead;
    int _player;
}

@property(readwrite,nonatomic) BOOL king;
@property(readwrite,nonatomic) BOOL dead;
@property(readwrite,nonatomic) int player;

+ (id) createFigureWithImage: (NSString *)image;
- (id) initFigureWithImage: (NSString *)image;

@end
