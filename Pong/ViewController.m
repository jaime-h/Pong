//
//  ViewController.m
//  Pong
//
//  Created by Jaime Hernandez on 3/20/14.
//  Copyright (c) 2014 Jaime Hernandez. All rights reserved.
//

#import "ViewController.h"
#import "BlockView.h"
#import "PaddleView.h"
#import "BlockView.h"
#import "BallView.h"

@interface ViewController () <UICollisionBehaviorDelegate, UIAlertViewDelegate>
{


    __weak IBOutlet BallView   *ballView;
    __weak IBOutlet PaddleView *paddleView;
    __weak IBOutlet BlockView  *blockView;
    

  
    UIDynamicAnimator     *dynamicAnimator;
    UIPushBehavior        *pushBehavior;
    UICollisionBehavior   *collisionBehavior;
    UIDynamicItemBehavior *ballDynamicItemBehavior;
    UIDynamicItemBehavior *paddleDynamicItemBehavior;
    UIDynamicItemBehavior *blockViewDynamicItemBehavior;
    
    int blocksInCurrentGame;
    int blockCounter;
    bool newGameReturn;
    
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initGameBehavior];
    [self drawNewBlocks];
    
}

-(IBAction)dragPaddle:(UIPanGestureRecognizer *)panGestureRecognizer
{
    paddleView.center = CGPointMake([panGestureRecognizer locationInView:self.view].x, paddleView.center.y);
    [dynamicAnimator updateItemUsingCurrentState:paddleView];
    
}

-(void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p
{
    
    // Checking for the position of the ball and if dips below the y of the paddle then
    // set it to the origin of where it started at
    
    if (ballView.frame.origin.y >= (self.view.frame.size.height-(ballView.frame.size.height*2)))
    {
        ballView.center = self.view.center;
        [dynamicAnimator updateItemUsingCurrentState:ballView];
    }
}

-(void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item1 withItem:(id<UIDynamicItem>)item2 atPoint:(CGPoint)p
{
    if ([item2 isKindOfClass:[BlockView class]])
    {
        // remove item1 which is a block then cast it from generic item1 to Blockview
       
        [collisionBehavior removeItem:item2];
        [(BlockView *)item2 removeFromSuperview];
        [dynamicAnimator updateItemUsingCurrentState:item2];
      
        // Decrement the blockcounter and check if we should start agiain...
        --blockCounter;
    
       bool checkGame = [self shouldStartAgain];
        
        // Below checks the bool condition with ternary condition
        // http://stackoverflow.com/questions/6358349/how-to-print-boolean-flag-in-nslog
        // NSLog(checkGame ? @"Yes" : @"No");
 
        if (checkGame == YES)
        {
            UIAlertView *alertViewMessage = [[UIAlertView alloc] initWithTitle:@"Game Over" message:@"All your Bricks Belong to Me!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            
            [alertViewMessage show];
            
            ballView.center = self.view.center;
            [dynamicAnimator updateItemUsingCurrentState:ballView];

        }
        
    }
}

-(void)drawNewBlocks
{
    
    float rectXCreationPoint = 00.0;
    float rectYCreationPoint = 20.0;
    
    for (int i = 1; i < 21; i++)
    {
        
        BlockView *generateNewBlock = [[BlockView alloc] initWithFrame:CGRectMake(rectXCreationPoint, rectYCreationPoint, blockView.frame.size.width, blockView.frame.size.height)];
        
        generateNewBlock.backgroundColor = [UIColor redColor];
        [self.view addSubview:generateNewBlock];
        [dynamicAnimator updateItemUsingCurrentState:generateNewBlock];
        [collisionBehavior addItem:generateNewBlock];
        
        rectXCreationPoint = rectXCreationPoint + 65.0;
        
        blockCounter++;
        
        // Draw the rows 5 blocks per row 4 rows below sets the starting points....
        
        switch (blockCounter) {
            case 6:
                rectYCreationPoint = rectYCreationPoint + 25.0;
                rectXCreationPoint = 0.0;
                break;
            case 11:
                rectYCreationPoint = rectYCreationPoint + 25.0;
                rectXCreationPoint = 0.0;
                break;
            case 16:
                rectYCreationPoint = rectYCreationPoint + 25.0;
                rectXCreationPoint = 0.0;
                break;
            
            default:
                break;
        }
    }
}

-(void)initGameBehavior
{
    dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    pushBehavior    = [[UIPushBehavior alloc] initWithItems:@[ballView] mode:UIPushBehaviorModeContinuous];
    collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[ballView, paddleView, blockView]];
    ballDynamicItemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[ballView]];
    paddleDynamicItemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[paddleView]];
    
    paddleDynamicItemBehavior.allowsRotation = NO;
    paddleDynamicItemBehavior.density = 1000;
    [dynamicAnimator addBehavior:paddleDynamicItemBehavior];
    
    ballDynamicItemBehavior.allowsRotation = NO;
    ballDynamicItemBehavior.elasticity = 1.0;
    ballDynamicItemBehavior.friction = 0.0;
    ballDynamicItemBehavior.resistance = 0.0;
    [dynamicAnimator addBehavior:ballDynamicItemBehavior];
    
    blockViewDynamicItemBehavior.density = -10000;
    blockViewDynamicItemBehavior.elasticity = 1.0;
    blockViewDynamicItemBehavior.allowsRotation = NO;
    blockViewDynamicItemBehavior.resistance = 0.0;
    [dynamicAnimator addBehavior:blockViewDynamicItemBehavior];
    
    
    collisionBehavior.collisionMode = UICollisionBehaviorModeEverything; //UICollisionBehaviorModeEverything
    collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
    collisionBehavior.collisionDelegate = self;
    [dynamicAnimator addBehavior:collisionBehavior];
    
    pushBehavior.pushDirection = CGVectorMake(0.5, 1.0);
    pushBehavior.active = YES;
    pushBehavior.magnitude = 0.5;
    [dynamicAnimator addBehavior:pushBehavior];
    
    blockCounter = 1;
}

-(bool)shouldStartAgain
{
    if (blockCounter <= 0)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        [self initGameBehavior];
        [self drawNewBlocks];
    }else{
        [self initGameBehavior];
        [self drawNewBlocks];
    }
}

@end
