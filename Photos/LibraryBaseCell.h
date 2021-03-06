//
//  LibraryBaseCell.h
//  Photos
//
//  Created by 相澤 隆志 on 2014/03/08.
//  Copyright (c) 2014年 相澤 隆志. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LibraryBaseCell : UICollectionViewCell < UICollectionViewDelegateFlowLayout, UICollectionViewDataSource >
@property (weak, nonatomic) IBOutlet UICollectionView *itemThumbnailCollection;
@property (nonatomic, retain) NSArray* items;
@property  NSInteger sectionIndex;
@end
