//
//  LibrayViewController.h
//  Photos
//
//  Created by 相澤 隆志 on 2014/03/08.
//  Copyright (c) 2014年 相澤 隆志. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LibrayViewController : UIViewController < UICollectionViewDataSource, UICollectionViewDelegateFlowLayout >
//@property (weak, nonatomic) IBOutlet UITabBarItem *tabBarItem;
@property (weak, nonatomic) IBOutlet UICollectionView *closeBaseCollectionView;
- (IBAction)testNext:(id)sender;

@end
