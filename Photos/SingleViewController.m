//
//  SingleViewController.m
//  Photos
//
//  Created by 相澤 隆志 on 2014/03/09.
//  Copyright (c) 2014年 相澤 隆志. All rights reserved.
//

#import "SingleViewController.h"
#import "AppDelegate.h"

@interface SingleViewController ()  <UIScrollViewDelegate>
{
    int currentPage;
}
@property (weak, nonatomic) IBOutlet UIImageView *fullImageView;
@property (weak, nonatomic) IBOutlet UIScrollView *singleScrollView;
@property (nonatomic, retain) AppDelegate* m_appDelegate;


@end

@implementation SingleViewController

@synthesize index;
@synthesize sectionIndex;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated
{
 //   sectionIndex = 0;
 //   index = 0;
    self.fullImageView.image = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    self.m_appDelegate = appDelegate;
    NSInteger section = self.sectionIndex;
    NSInteger index = self.index;
    NSLog(@"SingleView section:%ld index:%ld",(long)section, (long)index);
    UIImage* image = [self.m_appDelegate.m_imageLibrary getFullSreenViewImageAtSectionByIndex:self.sectionIndex index:self.index];
    self.fullImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.fullImageView.image = image;
    // [self initializeSingleScollView];
    
}

- (void)initializeSingleScollView
{
    NSInteger numOfsectionItems = [self.m_appDelegate.m_imageLibrary getNumOfImagesInSectionBySectonIndex:self.sectionIndex];
    CGSize s = self.singleScrollView.frame.size;
    CGRect contentRect = CGRectMake(0, 0, s.width * numOfsectionItems, s.height);
    UIView *contentView = [[UIView alloc] initWithFrame:contentRect];

    for( int i = 0; i < numOfsectionItems; i++ )
    {
        UIImageView *subContentView = [[UIImageView alloc] initWithFrame:CGRectMake(320 * i, 0, s.width, s.height)];
        subContentView.image = [self.m_appDelegate.m_imageLibrary getFullSreenViewImageAtSectionByIndex:self.sectionIndex index:i];
        subContentView.contentMode = UIViewContentModeScaleAspectFit;
        [contentView addSubview:subContentView];
    }
    // スクロールViewにコンテンツViewを追加する。
    [self.singleScrollView addSubview:contentView];
    
    self.singleScrollView.pagingEnabled = YES;
    //self.scrollview.contentSize = self.view.bounds.size;
    self.singleScrollView.contentSize = contentView.frame.size;
    self.singleScrollView.contentOffset = CGPointMake(0, 0);
    self.singleScrollView.showsHorizontalScrollIndicator = NO;// 横スクロールバー非表示
    self.singleScrollView.showsVerticalScrollIndicator = NO; // 縦スクロールバー非表示
    self.singleScrollView.scrollsToTop = NO; // ステータスバーのタップによるトップ移動禁止
    
    self.singleScrollView.delegate = self;
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    // 現在の表示位置（左上）のx座標とUIScrollViewの表示幅(320px)を
    // 用いて現在のページ番号を計算します。
    CGPoint offset = scrollView.contentOffset;
    int page = (offset.x + 160)/320;
    
    // 現在表示しているページ番号と異なる場合には、
    // ページ切り替わりと判断し、処理を呼び出します。
    // currentPageは、現在ページ数を保持するフィールド変数。
    if (currentPage != page) {
        //doSomethingWhenPagingOccurred();
        currentPage = page;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
