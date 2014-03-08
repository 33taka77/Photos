//
//  GroupCell.h
//  Photos
//
//  Created by 相澤 隆志 on 2014/03/07.
//  Copyright (c) 2014年 相澤 隆志. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *groupName;
@property (weak, nonatomic) IBOutlet UILabel *groupCont;
@property (weak, nonatomic) IBOutlet UIImageView *groupImagebase1;
@property (weak, nonatomic) IBOutlet UIImageView *groupImage1;
@property (weak, nonatomic) IBOutlet UIImageView *groupImagebase2;
@property (weak, nonatomic) IBOutlet UIImageView *groupImage2;
@property (weak, nonatomic) IBOutlet UIImageView *groupImagebase3;
@property (weak, nonatomic) IBOutlet UIImageView *groupImage3;

@end
