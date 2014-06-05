//
//  Gameplay.m
//  PeevedPenguins
//
//  Created by Ember Baker on 6/5/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//
#import "Penguin.h"
#import "Gameplay.h"

@implementation Gameplay {
    
    CCPhysicsNode *_physicsNode;
    
    CCPhysicsJoint *_catapultJoint;
    CCPhysicsJoint *_pullbackJoint;
    CCPhysicsJoint *_mouseJoint;
    CCPhysicsJoint *_penguinCatapultJoint;
    
    CCNode *_catapultArm;
    CCNode *_catapult;
    CCNode *_levelNode;
    CCNode *_contentNode;
    CCNode *_pullbackNode;
    CCNode *_mouseJointNode;
    
    Penguin *_currentPenguin;
    
    CCAction *_followPenguin;
    
    
}
    static const float MIN_SPEED = 5.f;

-(void)didLoadFromCCB {
    
    self.userInteractionEnabled =TRUE;                              //tell this scene to accept touch
    CCScene *level = [CCBReader loadAsScene:@"Levels/Level1"];
    [_levelNode addChild:level];
    
    //_physicsNode.debugDraw = TRUE;                                  //visulaize the physics
    [_catapultArm.physicsBody setCollisionGroup:_catapult];         //catapult and arm shall not collide
    [_catapult.physicsBody setCollisionGroup:_catapult];
    _catapultJoint = [CCPhysicsJoint connectedPivotJointWithBodyA:_catapultArm.physicsBody bodyB:_catapult.physicsBody anchorA:_catapultArm.anchorPointInPoints];
    
    _pullbackNode.physicsBody.collisionMask = @[];
    _pullbackJoint = [CCPhysicsJoint connectedSpringJointWithBodyA:_pullbackNode.physicsBody bodyB:_catapultArm.physicsBody anchorA:ccp(0,0) anchorB:ccp(34,138) restLength:60.f stiffness:500.f damping:40.f];
    
    _mouseJointNode.physicsBody.collisionMask = @[];
    
    _physicsNode.collisionDelegate =self;
    
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{      //called every touch of this scene
    
    CGPoint touchLocation = [touch locationInNode:_contentNode];
    
    if(CGRectContainsPoint([_catapultArm boundingBox], touchLocation)){
        
        _mouseJointNode.position = touchLocation;
        _mouseJoint = [CCPhysicsJoint connectedSpringJointWithBodyA:_mouseJointNode.physicsBody bodyB:_catapultArm.physicsBody anchorA:ccp(0,0) anchorB:ccp(34,138) restLength:0.f stiffness:3000.f damping:150.f];
        
        _currentPenguin = (Penguin*) [CCBReader load:@"Penguin"];
        CGPoint penguinPosition = [_catapultArm convertToWorldSpace:ccp(34,138)];
        _currentPenguin.position = [_physicsNode convertToNodeSpace:penguinPosition];
        [_physicsNode addChild:_currentPenguin];
        _currentPenguin.physicsBody.allowsRotation =FALSE;
        _penguinCatapultJoint = [CCPhysicsJoint connectedPivotJointWithBodyA:_currentPenguin.physicsBody bodyB:_catapultArm.physicsBody anchorA:_currentPenguin.anchorPointInPoints];
    }
}

-(void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event{
    
    CGPoint touchLocation = [touch locationInNode:_contentNode];
    _mouseJointNode.position = touchLocation;
}

-(void)releaseCatapult{
    
    if(_mouseJoint != nil){
        
        [_mouseJoint invalidate];
        _mouseJoint = nil;
        
        [_penguinCatapultJoint invalidate];
        _penguinCatapultJoint = nil;
        _followPenguin = [CCActionFollow actionWithTarget:_currentPenguin worldBoundary:self.boundingBox];
        [_contentNode runAction:_followPenguin];
        
        _currentPenguin.launched =TRUE;
        
    }
}

-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    [self releaseCatapult];
}

-(void)touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    [self releaseCatapult];
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
    [_contentNode runAction:follow];
}





-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair seal:(CCNode *)nodeA wildcard:(CCNode *)nodeB{
    
    float engery = [pair totalKineticEnergy];
    
    if (engery > 5000.f) {
        [self sealRemoved:nodeA];
    }
}

-(void)sealRemoved:(CCNode *)seal {
    CCParticleSystem *explosion = (CCParticleSystem *) [CCBReader load:@"SealExplosion"];
    explosion.autoRemoveOnFinish = TRUE;
    explosion.position = seal.position;
    [seal.parent addChild:explosion];
    
    [seal removeFromParent];
}

-(void)retry{
    
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"Gameplay"]];
}

-(void)update:(CCTime)delta{
    
    if(_currentPenguin.launched){
        
        if (ccpLength(_currentPenguin.physicsBody.velocity) < MIN_SPEED){
            
            [self nextAttempt];
            return;
        }
        
        int xMin = xMin + _currentPenguin.boundingBox.size.width;
    
        if (xMin > (self.boundingBox.origin.x + self.boundingBox.size.width)){
            
            [self nextAttempt];
            return;
        }
    }
}

-(void)nextAttempt{
    _currentPenguin = nil;
    [_contentNode stopAction:_followPenguin];
    
    CCActionMoveTo *actionMoveTo = [CCActionMoveTo actionWithDuration:1.f position:ccp(0,0)];
    [_contentNode runAction:actionMoveTo];
}

@end
