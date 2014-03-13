//
//  TestViewController.m
//  Photos
//
//  Created by Aizawa Takashi on 2014/03/11.
//  Copyright (c) 2014年 相澤 隆志. All rights reserved.
//

#import "TestViewController.h"


@interface TestViewController () <UIGestureRecognizerDelegate, UIScrollViewDelegate>
{
//UIPageControl関係-----------------------------------
    UIScrollView *scrollView;
    UIPageControl *pageControl;
//----------------------------------------------------
    
}
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
    
    //Swipeイベントの取得関係−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−
    // タップジェスチャを認識するリコグナイザを生成、初期化
    UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc]
                                             initWithTarget:self action:@selector(respondToTapGesture:)];
    // シングルタップである旨を指定 tapRecognizer.numberOfTapsRequired = 1;
    swipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft|UISwipeGestureRecognizerDirectionRight;
    
    // ビューに組み込み
    [self.view addGestureRecognizer:swipeRecognizer];
    //---------------------------------------------------
    
    /*
    //UIPageControl関係-----------------------------------
    NSInteger pageSize = 5; // ページ数
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    
    // UIScrollViewのインスタンス化
    scrollView = [[UIScrollView alloc]init];
    scrollView.frame = self.view.bounds;
    
    // 横スクロールのインジケータを非表示にする
    scrollView.showsHorizontalScrollIndicator = NO;
    
    // ページングを有効にする
    scrollView.pagingEnabled = YES;
    
    scrollView.userInteractionEnabled = YES;
    scrollView.delegate = self;
    
    // スクロールの範囲を設定
    [scrollView setContentSize:CGSizeMake((pageSize * width), height)];
    
    // スクロールビューを貼付ける
    [self.view addSubview:scrollView];
    
    // スクロールビューにラベルを貼付ける
    for (int i = 0; i < pageSize; i++) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(i * width, 0, width, height)];
        label.text = [NSString stringWithFormat:@"%d", i + 1];
        label.font = [UIFont fontWithName:@"Arial" size:92];
        label.backgroundColor = [UIColor yellowColor];
        label.textAlignment = UITextAlignmentCenter;
        [scrollView addSubview:label];
    }
    
    // ページコントロールのインスタンス化
    CGFloat x = (width - 300) / 2;
    pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(x, 350, 300, 50)];
    
    // 背景色を設定
    pageControl.backgroundColor = [UIColor blackColor];
    
    // ページ数を設定
    pageControl.numberOfPages = pageSize;
    
    // 現在のページを設定
    pageControl.currentPage = 0;
    
    // ページコントロールをタップされたときに呼ばれるメソッドを設定
    pageControl.userInteractionEnabled = YES;
    [pageControl addTarget:self
                    action:@selector(pageControl_Tapped:)
          forControlEvents:UIControlEventValueChanged];
    
    // ページコントロールを貼付ける
    [self.view addSubview:pageControl];
    */
    
}

/*
- (void)scrollViewDidScroll:(UIScrollView *)_scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    if ((NSInteger)fmod(scrollView.contentOffset.x , pageWidth) == 0) {
        // ページコントロールに現在のページを設定
        pageControl.currentPage = scrollView.contentOffset.x / pageWidth;
    }
}
- (void)pageControl_Tapped:(id)sender
{
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * pageControl.currentPage;
    [scrollView scrollRectToVisible:frame animated:YES];
}
*/
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
