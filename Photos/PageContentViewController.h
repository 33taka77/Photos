//
//  PageContentViewController.h
//  Photos
//
//  Created by Aizawa Takashi on 2014/04/03.
//  Copyright (c) 2014年 相澤 隆志. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageContentViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property NSInteger pageIndex;
@property NSInteger sectionIndex;
@end
