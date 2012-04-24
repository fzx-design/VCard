//
//  CastViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-4-18.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "CastViewController.h"
#import "ResourceList.h"

#define MaxCardSize CGSizeMake(345,9999)

@interface CastViewController ()

@end

@implementation CastViewController

@synthesize waterflowView = _waterflowView;

#pragma mark - LifeCycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:kRLCastViewBGUnit]];
    [self setUpWaterflowView];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Initializing Methods
- (void)setUpWaterflowView
{
    self.waterflowView.flowdatasource = self;
    self.waterflowView.flowdelegate = self;
    
    [self.waterflowView reloadData];
}

#pragma mark - WaterflowDataSource

- (NSInteger)numberOfColumnsInFlowView:(WaterflowView *)flowView
{
    return 2;
}

- (NSInteger)flowView:(WaterflowView *)flowView numberOfRowsInColumn:(NSInteger)column
{
    return 6;
}

- (WaterflowCell*)flowView:(WaterflowView *)flowView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
	WaterflowCell *cell = [flowView_ dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if(cell == nil)
	{
        
		cell  = [[WaterflowCell alloc] initWithReuseIdentifier:CellIdentifier currentUser:self.currentUser];
		cell.cardViewController.currentUser = self.currentUser;
//		AsyncImageView *imageView = [[AsyncImageView alloc] initWithFrame:CGRectZero];
//		[cell addSubview:imageView];
//        imageView.contentMode = UIViewContentModeScaleToFill;
//		imageView.layer.borderColor = [[UIColor whiteColor] CGColor];
//		imageView.layer.borderWidth = 1;
//		[imageView release];
//		imageView.tag = 1001;
	}
	
//	float height = [self flowView:nil heightForRowAtIndexPath:indexPath];
    CGRect frame = cell.frame;
    frame.size.height = 800;
    cell.frame = frame;
	
//	AsyncImageView *imageView  = (AsyncImageView *)[cell viewWithTag:1001];
//	imageView.frame = CGRectMake(0, 0, self.view.frame.size.width / 3, height);
//    [imageView loadImage:[self.imageUrls objectAtIndex:(indexPath.row + indexPath.section) % 5]];
//	
	return cell;
    
}

- (int)numberOfObjectsInSection
{
#warning Remained to be resolved
    return 20;
}

- (CGFloat)heightForObjectAtIndex:(int)index_ withImageHeight:(ImageHeight)imageHeight_
{
    NSString *string = [self randomString:index_];
    CGSize expectedLabelSize = [string sizeWithFont:[UIFont boldSystemFontOfSize:17.0f]                       
                                  constrainedToSize:MaxCardSize 
                                      lineBreakMode:UILineBreakModeCharacterWrap];
    return expectedLabelSize.height + 400;
}

- (NSString*)randomString:(int)index
{
    NSString *string = nil;
    switch (index  % 6) {
		case 0:
            string = [NSString stringWithString:@"#北京美食#老北京的炒肝，连续百年全国销售领先，一年卖出6亿多碗，连起来可绕地球三圈。一位大妈买了十碗炒肝，正准备离开，卖炒肝的大爷喊到：唉，你的炒肝。大妈回眸一笑，不，那是你的炒肝。老北京的炒肝，真的地道。不是所有的炒肝都叫老北京炒肝，老北京炒肝，你值得拥有！"];
			break;
		case 1:
            string = [NSString stringWithString:@"恩，我觉得可以认真考虑一下。喜欢就请猛击→ http://t.cn/adm3hr"];
			break;
		case 2:
            string = [NSString stringWithString:@"还记得《丹顶鹤的故事》吗？那么真挚动人的歌曲似乎越发少见，放耳尽是《最炫民族风》之流...如今的音乐是怎么了？网络在这中间起到了什么作用？盗版问题如何解决？流行就是通俗么？带着一系列的问题，我们的作者和一位作曲家展开了一席深刻的对话。请看断章系列之《歌》 http://t.cn/zOWlLpf"];
			break;
		case 3:
            string = [NSString stringWithString:@"七彩玫瑰，在花茎不同部分注射不同颜色和剂量的鲜花染色剂，控制每个花瓣的颜色，最终呈现出绚丽的彩色花瓣。~更多创意内容，关注@全球创意梦工场"];
			break;
		case 4:
            string = [NSString stringWithString:@"第十二届 #北京车展# ，作为一个纯Geek，小爱保证只看车不看妞，乃们呢？要看车模直播么"];
			break;
		case 5:
            string = [NSString stringWithString:@"苹果推出iPad和iPhone商务专区，发力企业级市场 | 近日，苹果在其官方网站推出了iPhone和iPad商务专区，开始针对企业级市场做资源整合，再一次走在了Android和Windows Phone前面。而这对于四面楚歌的黑莓制造商RIM来说，则可能是致命一击。 http://t.cn/zOWE8LN by @JohnTian"];
			break;
		default:
			break;
	}
    
    return string;
}

#pragma mark-
#pragma mark- WaterflowDelegate

-(CGFloat)flowView:(WaterflowView *)flowView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
	float height = 0;
	switch ((indexPath.row + indexPath.section )  % 5) {
		case 0:
			height = 127;
			break;
		case 1:
			height = 100;
			break;
		case 2:
			height = 87;
			break;
		case 3:
			height = 114;
			break;
		case 4:
			height = 140;
			break;
		case 5:
			height = 158;
			break;
		default:
			break;
	}
	
	height += indexPath.row + indexPath.section;
	
	return 600;
    
}

- (void)flowView:(WaterflowView *)flowView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"did select at %@",indexPath);
}

@end
