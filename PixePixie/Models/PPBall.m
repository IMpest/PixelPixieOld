
#import "PPPixie.h"



@interface PPBall ()
@property (nonatomic) SKTexture * defaultTexture;
@end



@implementation PPBall
@synthesize sustainRounds,pixie, ballElementType, pixieEnemy, ballStatus, comboBallTexture, comboBallSprite,ballBuffs;

#pragma mark Factory Method

// 创建玩家宠物的球
+(PPBall *)ballWithPixie:(PPPixie *)pixie
{
    if (pixie == nil) return nil;
    NSString * imageName = [NSString stringWithFormat:@"%@%d_ball.png",
                            kElementTypeString[pixie.pixieElement],pixie.pixieGeneration];
    PPBall * tBall = [PPBall spriteNodeWithTexture:[SKTexture textureWithImageNamed:imageName]];
    
    if (tBall){
        tBall.ballType = PPBallTypePlayer;
        tBall.ballElementType = pixie.pixieElement;
        tBall.size = CGSizeMake(kBallSizePixie, kBallSizePixie);
        [PPBall defaultBallPhysicsBody:tBall];
        tBall.pixie = pixie;
    }
    
    return tBall;
    
}

// 创建敌人宠物的球
+(PPBall *)ballWithPixieEnemy:(PPPixie *)pixieEnemy;
{
    if (pixieEnemy == nil) return nil;
    NSString * imageName = [NSString stringWithFormat:@"%@%d_ball.png",
                            kElementTypeString[pixieEnemy.pixieElement],pixieEnemy.pixieGeneration];
    PPBall * tBall = [PPBall spriteNodeWithTexture:[SKTexture textureWithImageNamed:imageName]];
 
    tBall.ballBuffs = [[NSMutableArray alloc] init];

    if (tBall){
        tBall.ballType = PPBallTypeEnemy;
        tBall.ballElementType = pixieEnemy.pixieElement;
        tBall.size = CGSizeMake(kBallSizePixie, kBallSizePixie);
        [PPBall defaultBallPhysicsBody:tBall];
        tBall.pixieEnemy = pixieEnemy;
    }
    return tBall;
}

// 创建元素球
+(PPBall *)ballWithElement:(PPElementType) elementType{
    
    NSString * imageName = [NSString stringWithFormat:@"%@_ball.png", kElementTypeString[elementType]];
    SKTexture * tTexture = [SKTexture textureWithImageNamed:imageName];
    
    PPBall * tBall = [PPBall spriteNodeWithTexture:tTexture];
    
    if (tBall)
    {
        tBall.ballType = PPBallTypeElement;
        tBall.defaultTexture = tTexture;
        tBall.name = [NSString stringWithFormat:@"ball_%@", kElementTypeString[elementType]];
        tBall.ballElementType = elementType;
        tBall.size = CGSizeMake(kBallSize, kBallSize);
        [PPBall defaultBallPhysicsBody:tBall];
        tBall.pixie = nil;
        
    }
    
    PPBasicLabelNode * roundsLabel = [[PPBasicLabelNode alloc] init];
    roundsLabel.name = @"roundsLabel";
    roundsLabel.fontColor = [UIColor redColor];
    roundsLabel.position = CGPointMake(10, 10);
    [roundsLabel setText:@"0"];
    roundsLabel.fontSize = 15;
    
    
    [tBall addChild:roundsLabel];
    return tBall;
    
}

// 创建连击球
+(PPBall *)ballWithCombo
{
    NSString * imageName = @"combo_ball.png";
    SKTexture * tTexture = [SKTexture textureWithImageNamed:imageName];
    PPBall * tBall = [PPBall spriteNodeWithTexture:tTexture];
     
    if (tBall)
    {
        tBall.ballType = PPBallTypeCombo;
        tBall.ballElementType = PPElementTypeNone;
        tBall.defaultTexture = tTexture;
        tBall.name = @"combo";
        tBall.size = CGSizeMake(kBallSize, kBallSize);
        [PPBall defaultBallPhysicsBody:tBall];
        tBall.pixie = nil;
    }
    return tBall;
}

// 设置元素球的持续回合
-(void)setRoundsLabel:(int)rounds
{
    PPBasicLabelNode * roundsLabel = (PPBasicLabelNode *)[self childNodeWithName:@"roundsLabel"];
    [roundsLabel setText:[NSString stringWithFormat:@"%d",rounds]];
}

// 改为默认皮肤
-(void)setToDefaultTexture
{
    [self runAction:[SKAction setTexture:_defaultTexture]];
}
#pragma mark buff manage

-(void)addBuffWithName:(NSString *)buffName andRoundNum:(int)continueRound
{
    PPBuff *buff=[[PPBuff alloc] init];
    buff.buffName = buffName;
    buff.continueRound = continueRound;
    buff.buffId = @"1";
    
    [self.ballBuffs addObject:buff];
    
}
-(void)changeBuffRound
{

    for (int i=0;i<[self.ballBuffs count]; i++) {
        PPBuff *buff = [self.ballBuffs objectAtIndex:i];
        buff.continueRound--;
        NSLog(@"continueRound =%d",buff.continueRound);
        
        if (buff.continueRound<0) {
            [self removeBuff:buff];
            
        }
    }
}

-(void)removeBuff:(PPBuff *)buff
{
    switch ([buff.buffId intValue]) {
        case 1:
        {
            self.physicsBody.PPBallSkillStatus=0;
            [self startPlantrootAppearOrDisappear:NO];
            self.physicsBody.dynamic = YES;
        }
            break;
            
        default:
            break;
    }
    
    [self.ballBuffs removeObject:buff];

}
#pragma mark Animation  球体各种动画

-(void)startElementBallHitAnimation:(NSMutableArray *)ballArray isNeedRemove:(BOOL)isNeed andScene:(PPBasicScene *)battleScene
{
    
    // 创建元素撞击动画
//    NSMutableArray * textureArray = [[NSMutableArray alloc] init];
//    for (int i = 0; i >= 0; i--) {
//        SKTexture * textureCombo = [[TextureManager ball_table] textureNamed:[NSString stringWithFormat:@"element_birth_00%02d",i]];
//
//        [textureArray addObject:textureCombo];
//    }
//    for (int i = 0; i < 10; i++) {
//        SKTexture * textureCombo = [[TextureManager ball_elements] textureNamed:[NSString stringWithFormat:@"%@_hit_00%02d",kElementTypeString[self.ballElementType],i]];
//        NSLog(@"textureName=%@",[NSString stringWithFormat:@"%@_hit_00%02d",kElementTypeString[self.ballElementType],i]);
//        
//        [textureArray addObject:textureCombo];
//    }
//    self.comboBallTexture = textureArray;
    
    SKAction *actionHit=[[TextureManager ball_elements] getAnimation:[NSString stringWithFormat:@"%@_hit",kElementTypeString[self.ballElementType]]];
    
    if (self.comboBallSprite != nil) {
        [self.comboBallSprite removeFromParent];
        self.comboBallSprite = nil;
    }
    
    
    self.comboBallSprite =[[PPBasicSpriteNode alloc] init];
    self.comboBallSprite.size = CGSizeMake(50.0f, 50.0f);
    [self.comboBallSprite setPosition:CGPointMake(0.0f, 0.0f)];
    if (isNeed) {
        [self.comboBallSprite setPosition:self.position];
        [battleScene addChild:self.comboBallSprite];
        [self removeFromParent];
        [ballArray removeObject:self];

        
    }else
    {
        [self addChild:self.comboBallSprite];

    }
    
    [self.comboBallSprite runAction:actionHit
                         completion:^{
                             if (isNeed) {
                                 
                                 [self.comboBallSprite removeFromParent];

                             }else
                             {
                                 [self startAuraAnimation];

                             }

    }];
    
    
}
-(void)startRemoveAnimation:(NSMutableArray *)ballArray  andScene:(PPBasicScene *)battleScene
{
    
      NSMutableArray * textureArray = [[NSMutableArray alloc] init];
    for (int i = 23; i >= 0; i--) {
        
        SKTexture * textureCombo = [[TextureManager ball_table] textureNamed:[NSString stringWithFormat:@"element_birth_00%02d",i]];
        [textureArray addObject:textureCombo];
        
    }
    
//    if (self.comboBallSprite != nil) {
//        [self.comboBallSprite removeFromParent];
//        self.comboBallSprite = nil;
//    }
//    
//    self.comboBallSprite =[[PPBasicSpriteNode alloc] init];
//    self.comboBallSprite.size = CGSizeMake(50.0f, 50.0f);
//    
//    [self.comboBallSprite setPosition:self.position];
//    [battleScene addChild:self.comboBallSprite];
//    [self removeFromParent];
    
    [ballArray removeObject:self];
    [self runAction:[SKAction animateWithTextures:textureArray timePerFrame:0.05]
                         completion:^{
                             [self removeFromParent];
                         }];
}

// 添加效果
-(void)startPixieAccelerateAnimation:(CGVector)velocity andType:(NSString *)pose
{
    if (sqrt(velocity.dx * velocity.dx + velocity.dy * velocity.dy ) < kBallAccelerateMin) return;
        
    double rotation = atan(velocity.dy/velocity.dx);
    rotation = velocity.dx > 0 ? rotation : rotation + 3.1415926;
    
    // 这里还需要优化
    if (self.comboBallSprite != nil) {
        [self.comboBallSprite removeFromParent];
        self.comboBallSprite = nil;
    }
    
    self.comboBallSprite =[[PPBasicSpriteNode alloc] init];
    self.comboBallSprite.size = CGSizeMake(100.0f, 100.0f);
    self.comboBallSprite.zRotation = rotation;
    [self.comboBallSprite setPosition:CGPointMake(0.0f, 0.0f)];
    [self addChild:self.comboBallSprite];
    
    [self.comboBallSprite runAction:[[TextureManager ball_elements] getAnimation:
                                     [NSString stringWithFormat:@"%@_%@", kElementTypeString[self.ballElementType], pose]]
                         completion:^{
                             [self.comboBallSprite removeFromParent];
                         }];
}

// 治疗动画
-(void)startPixieHealAnimation
{
    NSMutableArray * textureArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < 15; i++) {
        SKTexture * textureCombo = [[TextureManager ball_table] textureNamed:[NSString stringWithFormat:@"pixie_heal_00%02d",i]];
        [textureArray addObject:textureCombo];
    }
    self.comboBallTexture = textureArray;
    
    
    if (self.comboBallSprite != nil) {
        [self.comboBallSprite removeFromParent];
        self.comboBallSprite = nil;
    }
    
    self.comboBallSprite =[[PPBasicSpriteNode alloc] init];
    self.comboBallSprite.size = CGSizeMake(50.0f, 50.0f);
    [self.comboBallSprite setPosition:CGPointMake(0.0f, 0.0f)];
    [self addChild:self.comboBallSprite];
    
    [self.comboBallSprite runAction:[SKAction animateWithTextures:self.comboBallTexture timePerFrame:kFrameInterval]
                         completion:^{
                             [self.comboBallSprite removeFromParent];
                         }];
}

// 连击能量动画
-(void)startComboAnimation
{
    if (self.comboBallSprite != nil) {
        [self.comboBallSprite removeFromParent];
        self.comboBallSprite = nil;
    }
    
    self.comboBallSprite =[[PPBasicSpriteNode alloc] init];
    self.comboBallSprite.size = CGSizeMake(50.0f, 50.0f);
    [self.comboBallSprite setPosition:CGPointMake(0.0f, 0.0f)];
    [self addChild:self.comboBallSprite];
    
    [self.comboBallSprite runAction:[[TextureManager ball_table] getAnimation:@"combo_ball"]
                         completion:^{[self.comboBallSprite removeFromParent];}];
}


// 变身陷阱动画
-(void)startMagicballAnimation
{
    
    if (self.comboBallSprite != nil) {
        [self.comboBallSprite removeFromParent];
        self.comboBallSprite = nil;
    }
    
    self.comboBallSprite =[[PPBasicSpriteNode alloc] init];
    self.comboBallSprite.size = CGSizeMake(50.0f, 50.0f);
    [self.comboBallSprite setPosition:CGPointMake(0.0f, 0.0f)];
    [self addChild:self.comboBallSprite];
    
    
//    [self.comboBallSprite runAction:[[TextureManager ball_magic] getAnimation:@"magic_ball"]
//                         completion:^{[self.comboBallSprite removeFromParent];}];
    
    
    
    [self runAction:[[TextureManager ball_magic] getAnimation:@"magic_ball"]
                         completion:^{
                             [self.comboBallSprite removeFromParent];
                             [self addStatusBall:@"plant"];

      }];
    
}
-(void)addStatusBall:(NSString *)type
{
    
    if (self.comboBallSprite != nil) {
        [self.comboBallSprite removeFromParent];
        self.comboBallSprite = nil;
    }
    
    self.comboBallSprite =[[PPBasicSpriteNode alloc] initWithTexture:[[TextureManager ball_magic] textureNamed:@"plant_root"]];
    self.comboBallSprite.size = CGSizeMake(50.0f, 50.0f);
    [self.comboBallSprite setPosition:CGPointMake(0.0f, 0.0f)];
    [self addChild:self.comboBallSprite];
    
}
// 创建被缠绕动画
-(void)startPlantrootAppearOrDisappear:(BOOL)appearOrDisappear
{
    
    if (self.comboBallSprite != nil) {
        [self.comboBallSprite removeFromParent];
        self.comboBallSprite = nil;
    }

        self.comboBallSprite =[[PPBasicSpriteNode alloc] init];
        self.comboBallSprite.size = CGSizeMake(50.0f, 50.0f);
        [self.comboBallSprite setPosition:CGPointMake(0.0f, 0.0f)];
        [self addChild:self.comboBallSprite];
        
        SKAction *action=nil;
        
        //yes为appear动画
        if (appearOrDisappear) {
            action= [[TextureManager ball_buff] getAnimation:@"plant_root_appear"];
            [self.comboBallSprite runAction:action
                                 completion:^{
                                 }];
        }else
        {
            action= [[TextureManager ball_buff] getAnimation:@"plant_root_disappear"];
            [self.comboBallSprite runAction:action
                                 completion:^{
                                     [self.comboBallSprite removeFromParent];
                                     self.comboBallSprite = nil;
                                 }];
        }
    
   
}

-(void)startElementBirthAnimation
{
    
    if (self.comboBallSprite != nil) {
        [self.comboBallSprite removeFromParent];
        self.comboBallSprite = nil;
    }
    
    self.comboBallSprite =[[PPBasicSpriteNode alloc] init];
    self.comboBallSprite.size = CGSizeMake(50.0f, 50.0f);
    [self.comboBallSprite setPosition:CGPointMake(0.0f, 0.0f)];
    [self addChild:self.comboBallSprite];
    
    
    [self.comboBallSprite runAction:[[TextureManager ball_table] getAnimation:@"element_birth"]
                         completion:^{
                             [self.comboBallSprite removeFromParent];
                             [self startAuraAnimation];
                             
                             
    }];
}
-(void)startAuraAnimation
{
    
    if (self.comboBallSprite != nil) {
        [self.comboBallSprite removeFromParent];
        self.comboBallSprite = nil;
    }
    
    self.comboBallSprite =[[PPBasicSpriteNode alloc] init];
    self.comboBallSprite.size = CGSizeMake(50.0f, 50.0f);
    [self.comboBallSprite setPosition:CGPointMake(0.0f, 0.0f)];
    [self addChild:self.comboBallSprite];
    
    
    PPBasicSpriteNode *textureNode=[PPBasicSpriteNode spriteNodeWithTexture:self.texture];
    textureNode.size= CGSizeMake(kBallSize, kBallSize);
    [self.comboBallSprite addChild:textureNode];
    
    SKAction *actionAura=[[TextureManager ball_elements] getAnimation:[NSString stringWithFormat:@"%@_aura",kElementTypeString[self.ballElementType]]];
    SKAction *actionAuraContray = [[TextureManager ball_elements] getAnimationContrary:[NSString stringWithFormat:@"%@_aura",kElementTypeString[self.ballElementType]]];
    NSArray *arrayAnimation = [NSArray arrayWithObjects:actionAura,actionAuraContray, nil];
    SKAction *actionSqueues=[SKAction sequence:arrayAnimation];
  
    
    
    
    [self.comboBallSprite runAction:[SKAction repeatActionForever:actionSqueues]
                         completion:^{
                             
                             [self.comboBallSprite removeFromParent];
                             
    }];
    
}

// 默认的球的物理属性
+(void)defaultBallPhysicsBody:(PPBall *)ball{
    
    if (ball.ballType == PPBallTypePlayer || ball.ballType == PPBallTypeEnemy){
        ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:kBallSizePixie / 2];
    } else {
        ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:kBallSize / 2];
    }
    
    ball.physicsBody.linearDamping = kBallLinearDamping;    // 线阻尼系数
    ball.physicsBody.angularDamping = kBallAngularDamping;  // 角阻尼系数
    ball.physicsBody.friction = kBallFriction;              // 表面摩擦力
    ball.physicsBody.restitution = kBallRestitution;        // 弹性恢复系数
    
    ball.physicsBody.dynamic = YES;                         // 说明物体是动态的
    ball.physicsBody.usesPreciseCollisionDetection = YES;   // 使用快速运动检测碰撞
}

@end
