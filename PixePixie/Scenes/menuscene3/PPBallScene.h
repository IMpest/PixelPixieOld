#import "PPSkillNode.h"
@interface PPBallScene : PPBasicScene<SkillShowEndDelegate>
{
    int currentEnemyIndex;
}
@property (nonatomic,retain)NSArray *choosedEnemys;
-(id)initWithSize:(CGSize)size
           PixieA:(PPPixie *)pixieA
           PixieB:(NSArray *)enemyS;

@end
