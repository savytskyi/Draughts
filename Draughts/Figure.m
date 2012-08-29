//
//  Figure.m
//  Draughts
//
//  Created by Cyril Savitsky on 8/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Figure.h"


@implementation Figure

+ (id) createFigureWithImage:(NSString *)image {

    return [[[self alloc] initFigureWithImage:image] autorelease];
}

- (id) initFigureWithImage:(NSString *)image {
    if ((self = [super initWithSpriteFrameName:image])) {
        _king = NO;
        _dead = NO;
    }
    return self;
}

@end
