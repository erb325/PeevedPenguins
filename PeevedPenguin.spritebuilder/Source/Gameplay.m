//
//  Gameplay.m
//  PeevedPenguin
//
//  Created by Ember Baker on 6/4/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Gameplay.h"

@implementation Gameplay {

    CCPhysicsNode *_physicsNode;
    
    CCPhysicsJoint *_catapultJoint;
    CCPhysicsJoint *_pullBackJoint;
    CCPhysicsJoint *_mouseJoint;
    CCPhysicsJoint *_penguinCatapultJoint;
    
    CCNode *_catapultArm;
    CCNode *_levelNodes;
    CCNode *_contentNode;
    CCNode *_catapult;
    CCNode *_pullBackNode;
    CCNode *_mouseJointNode;
    CCNode *_currentPenguin;
    
}

//called when ccb file has loaded
//this method tells the scene to accept touch

    -(void)didLoadFromCCB {
        self.userInteractionEnabled = TRUE;
       
        CCScene *level =[CCBReader loadAsScene:@"Levels/level1"];   //load levels
        [_levelNodes addChild:level];
        
        
    //catapult Joint
        _physicsNode.debugDraw =TRUE;                               //visuliza joints and bodies
        
        [_catapultArm.physicsBody setCollisionGroup:_catapult];     //catapult and catapult arm should not collide
        [_catapult.physicsBody setCollisionGroup:_catapult];
        
        _catapultJoint = [CCPhysicsJoint connectedPivotJointWithBodyA:_catapultArm.physicsBody bodyB:_catapult.physicsBody anchorA:_catapultArm.anchorPointInPoints];
        
     //pullbackJoint
        _pullBackNode.physicsBody.collisionMask = @[];              //nothing shall collide with invisable node
        
        _pullBackJoint =[CCPhysicsJoint connectedSpringJointWithBodyA:_pullBackNode.physicsBody bodyB:_catapultArm.physicsBody anchorA:ccp(0,0) anchorB:ccp(34,138) restLength:60.f stiffness:500.f damping:40.f];
        
    //MouseJoint
        _mouseJointNode.physicsBody.collisionMask =@[];
        
        
    }

//called on every touhc of the screen

    -(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
        
        CGPoint touchLocation = [touch locationInNode:_contentNode];
                                                                    //start catapult by dragginf when the outside is touched
        if(CGRectContainsPoint([_catapultArm boundingBox], touchLocation)){
            
            _mouseJointNode.position = touchLocation;               //setup spring
            _mouseJoint = [CCPhysicsJoint connectedSpringJointWithBodyA:_mouseJointNode.physicsBody bodyB:_catapultArm.physicsBody anchorA:ccp(0,0) anchorB:ccp(34,138) restLength:0.f stiffness:3000.f damping:150.f];
            
            _currentPenguin = [CCBReader load:@"penguin"];          //spawn penguin and postion it in the catapult
            CGPoint penguinPosition = [_catapultArm convertToWorldSpace:ccp(34,138)];
                                                                    //take world space to node space
            _currentPenguin.position = [_physicsNode convertToNodeSpace:penguinPosition];
            [_physicsNode addChild:_currentPenguin];                //add to physicsNode
            _currentPenguin.physicsBody.allowsRotation = FALSE;     //the penguin wont rotate in the catapult
            
            _penguinCatapultJoint = [CCPhysicsJoint connectedPivotJointWithBodyA:_currentPenguin.physicsBody bodyB:_catapultArm.physicsBody anchorA:_currentPenguin.anchorPointInPoints];
            
            
        }
    }

    -(void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
        
        CGPoint toughLocation = [touch locationInNode:_contentNode];    //whenever touch moves, update location
        _mouseJointNode.position = toughLocation;
    
    }

    -(void)releaseCatapult {
        
        if (_mouseJoint != nil) {
            
            [_mouseJoint invalidate];                                   //releases the joint and lets the catapult snap
            _mouseJoint = nil;
            
            [_penguinCatapultJoint invalidate];                         //release penguin
            _penguinCatapultJoint = nil;
            
            _currentPenguin.physicsBody.allowsRotation =TRUE;           //after realeased rotaiton is fine
            
            CCActionFollow *follow = [CCActionFollow actionWithTarget:_currentPenguin worldBoundary:self.boundingBox];
            [_contentNode runAction:follow];
            
        }
    }

    -(void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event{
        
        [self releaseCatapult];                                         //calles releaseCatapult when touch ends
    
    }

    -(void) touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
        
        [self releaseCatapult];
    
    }

    -(void)launchPenguin {
        
        CCNode* penguin = [CCBReader load:@"penguin"];                  //loads the penguin
        penguin.position = ccpAdd(_catapultArm.position, ccp(16,50));   //postions penguin into bowl
        
        [_physicsNode addChild:penguin];                                //add the penguin to physics node
        
        CGPoint lauchDirection = ccp(1,0);                              //launches penguin with physics
        CGPoint force = ccpMult(lauchDirection, 8000);
        [penguin.physicsBody applyForce:force];
        
        self.position = ccp(0,0);                                       //moves the scene to follow the penguin
        CCActionFollow *follow = [CCActionFollow actionWithTarget:penguin worldBoundary:self.boundingBox];
        [_contentNode runAction:follow];
    
    }

    -(void)retry {
        
        //retry button
        [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"Gameplay"]];
    
    }



@end
