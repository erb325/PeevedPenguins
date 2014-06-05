//
//  Seal.m
//  PeevedPenguin
//
//  Created by Ember Baker on 6/4/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Seal.h"

@implementation Seal

-(void)didLoadFromCCB{
    self.physicsBody.collisionType = @"seal";
}

@end
