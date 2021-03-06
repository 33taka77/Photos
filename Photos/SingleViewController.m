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
    
    //UIPageControl関係-----------------------------------
    UIScrollView *scrollView;
    UIPageControl *pageControl;
    NSInteger currentPageIndex;
    NSInteger munOfPage;
    BOOL rotating;
    //----------------------------------------------------

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
 //   self.fullImageView.image = nil;
    for( int i = 0; i < munOfPage; i++ )
    {
        UIImageView* imageView = (UIImageView*)scrollView.subviews[ i ];
        imageView.image = nil;
    }
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
   // UIImage* image = [self.m_appDelegate.m_imageLibrary getFullSreenViewImageAtSectionByIndex:self.sectionIndex index:self.index];
    //self.fullImageView.contentMode = UIViewContentModeScaleAspectFit;
    //self.fullImageView.image = image;
    [self initializeSingleScollView];
    
}

- (void)initializeSingleScollView
{
    NSInteger numOfsectionItems = [self.m_appDelegate.m_imageLibrary getNumOfImagesInSectionBySectonIndex:self.sectionIndex];
    //UIPageControl関係-----------------------------------
    //NSInteger pageSize = numOfsectionItems; // ページ数
    munOfPage = numOfsectionItems;
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    
    //BOOL isDevicePortrait = UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]);
    BOOL isDevicelandscape = UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]);
    if( isDevicelandscape )
    {
        CGFloat temp = width;
        width = height;
        height = temp;
    }
    // UIScrollViewのインスタンス化
    scrollView = [[UIScrollView alloc]init];
    CGRect frameRect = CGRectMake(0, 0, width, height);
    scrollView.frame = frameRect;//self.view.bounds;
    
    // 横スクロールのインジケータを非表示にする
    scrollView.showsHorizontalScrollIndicator = NO;
    
    // ページングを有効にする
    scrollView.pagingEnabled = YES;
    
    scrollView.userInteractionEnabled = YES;
    scrollView.delegate = self;
    
    // スクロールの範囲を設定
    [scrollView setContentSize:CGSizeMake((munOfPage * width), height)];
    
    // スクロールビューを貼付ける
    [self.view addSubview:scrollView];
    
    // スクロールビューにラベルを貼付ける
    @autoreleasepool {
        for (int i = 0; i < numOfsectionItems; i++) {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(i * width, 0, width, height)];
            //imageView.image = [self.m_appDelegate.m_imageLibrary getFullSreenViewImageAtSectionByIndex:self.sectionIndex index:i];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            [scrollView addSubview:imageView];
        }
    }
    NSInteger num = self.index;
    
    @autoreleasepool {
        UIImageView* imageView = (UIImageView*)scrollView.subviews[ self.index ];
        imageView.image = [self.m_appDelegate.m_imageLibrary getFullSreenViewImageAtSectionByIndex:self.sectionIndex index:self.index];
        if( self.index > 0 )
        {
            imageView = (UIImageView*)scrollView.subviews[ self.index -1];
            imageView.image = [self.m_appDelegate.m_imageLibrary getFullSreenViewImageAtSectionByIndex:self.sectionIndex index:self.index-1];
        }
        if( self.index < scrollView.subviews.count -1 )
        {
            imageView = (UIImageView*)scrollView.subviews[ self.index +1];
            imageView.image = [self.m_appDelegate.m_imageLibrary getFullSreenViewImageAtSectionByIndex:self.sectionIndex index:self.index+1];
        }
    }
    // ページコントロールのインスタンス化
    CGFloat x = (width - (width-20)) / 2;
    pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(x, height-70, width-20, 50)];
    
    // 背景色を設定
    pageControl.backgroundColor = [UIColor clearColor];
    
    // ページ数を設定
    pageControl.numberOfPages = numOfsectionItems;
    
    // 現在のページを設定
    pageControl.currentPage = self.index;
    currentPageIndex = self.index;
    
    // ページコントロールをタップされたときに呼ばれるメソッドを設定
    pageControl.userInteractionEnabled = YES;
    [pageControl addTarget:self
                    action:@selector(pageControl_Tapped:)
          forControlEvents:UIControlEventValueChanged];
    
    // ページコントロールを貼付ける
    [self.view addSubview:pageControl];
    
    // 指定されたページに移動させる
    CGFloat pageWidth = scrollView.frame.size.width;
    /*
    if ((NSInteger)fmod(scrollView.contentOffset.x , pageWidth) == 0) {
        // ページコントロールに現在のページを設定
        pageControl.currentPage = scrollView.contentOffset.x / pageWidth;
    }
    */
    pageControl.currentPage = self.index;
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * pageControl.currentPage;
    [scrollView scrollRectToVisible:frame animated:YES];
}
- (void)scrollViewDidScroll:(UIScrollView *)_scrollView
{
    if(rotating == YES ){
        return;
    }
    CGFloat pageWidth = scrollView.bounds.size.width;
    if ((NSInteger)fmod(scrollView.contentOffset.x , pageWidth) == 0) {
        // ページコントロールに現在のページを設定
        pageControl.currentPage = scrollView.contentOffset.x / pageWidth;
        self.index = pageControl.currentPage;
        NSInteger page = pageControl.currentPage;
        NSLog(@"CurrentPage:%d",page);
        @autoreleasepool {
            if( pageControl.currentPage != currentPageIndex )
            {
                if( pageControl.currentPage == currentPageIndex-1)
                {
                    if( pageControl.currentPage >= 1 )
                    {
                        UIImageView* imageView = (UIImageView*)scrollView.subviews[ pageControl.currentPage -1];
                        //imageView.image = nil;
                        imageView.image = [self.m_appDelegate.m_imageLibrary getFullSreenViewImageAtSectionByIndex:self.sectionIndex index:pageControl.currentPage-1];
                    }
               
                }else if(pageControl.currentPage == currentPageIndex+1 )
                {
                    if( pageControl.currentPage < munOfPage-1 )
                    {
                        UIImageView* imageView = (UIImageView*)scrollView.subviews[ pageControl.currentPage+1];
                        //imageView.image = nil;
                        imageView.image = [self.m_appDelegate.m_imageLibrary getFullSreenViewImageAtSectionByIndex:self.sectionIndex index:pageControl.currentPage+1];
                    }
                
                }
                currentPageIndex = pageControl.currentPage;
            }
        }
    }
}

/* 横向き対応のため追加 */
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    rotating = YES;
    
    [scrollView setScrollEnabled:NO];
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [scrollView setScrollEnabled:YES];
    scrollView.frame = self.view.bounds;
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    [scrollView setContentSize:CGSizeMake((munOfPage * width), height)];

    rotating = NO;
    for( int i = 0; i < munOfPage; i++ )
    {
        UIImageView* imageView = (UIImageView*)scrollView.subviews[ i ];
        CGRect rect = CGRectMake(i * width, 0, width, height);
        imageView.frame = rect;
        
    }
    CGFloat x = (width - (width-20)) / 2;
    [pageControl setFrame:CGRectMake(x, height-70, width-20, 50)];
    //pageControl.currentPage = self.index
    CGRect frame = scrollView.frame;
    NSInteger page = pageControl.currentPage;
    NSLog(@" rotate page:%d",page);                                                                                                                                                            
    frame.origin.x = width * pageControl.currentPage;
    [scrollView scrollRectToVisible:frame animated:NO];
}

- (void)pageControl_Tapped:(id)sender
{
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * pageControl.currentPage;
    [scrollView scrollRectToVisible:frame animated:YES];
}
/*
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
*/
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
