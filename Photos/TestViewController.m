//
//  TestViewController.m
//  Photos
//
//  Created by Aizawa Takashi on 2014/03/11.
//  Copyright (c) 2014年 相澤 隆志. All rights reserved.
//

#import "TestViewController.h"


@interface TestViewController () <UIGestureRecognizerDelegate>
- (IBAction)CloseButtonClicked:(id)sender;
- (IBAction)showGestureForSwipeRecognizer:(UISwipeGestureRecognizer *)recognizer;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation TestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    // タップジェスチャを認識するリコグナイザを生成、初期化
    UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc]
                                             initWithTarget:self action:@selector(respondToTapGesture:)];
    // シングルタップである旨を指定 tapRecognizer.numberOfTapsRequired = 1;
    swipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft|UISwipeGestureRecognizerDirectionRight;
    
    // ビューに組み込み
    [self.view addGestureRecognizer:swipeRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)CloseButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)respondToTapGesture:(UISwipeGestureRecognizer *)recognizer
{
     NSLog(@"swipe!");
}
- (IBAction)showGestureForSwipeRecognizer:(UISwipeGestureRecognizer *)recognizer
{
    // ジェスチャの位置を取得
    //CGPoint location = [recognizer locationInView:self.view];
    // その位置に画像ビューを表示
    //[self drawImageForGestureRecognizer:recognizer atPoint:location];
    // 左向きのスワイプであれば、終了位置として、
    // 現在の位置よりも左側を指定
    //if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
    //    location.x -= 220.0;
    //} else {
    //    location.x += 220.0;
    //}
    //[UIView animateWithDuration:0.5 animations:^{
    //    self.imageView.alpha = 0.0;
    //    self.imageView.center = location;
    //}];
    NSLog(@"swipe!");
}

@end
