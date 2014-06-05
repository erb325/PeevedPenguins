//
//  Gameplay.m
//  PeevedPenguins
//
//  Created by Ember Baker on 6/5/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Gameplay.h"

@implementation Gameplay {
    
    CCPhysicsNode *_physicsNode;
    
    CCNode *_catapultArm;
    CCNode *_levelNode;
}

-(void)didLoadFromCCB {
    
    self.userInteractionEnabled =TRUE;                              //tell this scene to accept touch
    CCScene *level = [CCBReader loadAsScene:@"Levels/Level1"];
    [_levelNode addChild:level];
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{      //called every touch of this scene
    
    [self lauchPenguin];
}

-(void)lauchPenguin {
    
    CCNode* penguin = [CCBReader load:@"Penguin"];
    penguin.position = ccpAdd(_catapultArm.position, ccp(16,50));
    
    [_physicsNode addChild:penguin];                                //physics
    CGPoint launchDirection = ccp(1,0);
    CGPoint force = ccpMult(launchDirection, 8000);
    [penguin.physicsBody applyForce:force];
    
    self.position = ccp(0,0);                                       //follow the penguin
    CCActionFollow *follow = [CCActionFollow actionWithTarget:penguin worldBoundary:self.boundingBox];
    [self runAction:follow];
}

@end
