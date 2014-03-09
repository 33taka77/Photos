//
//  ItemThumbnailCollectionView.h
//  Photos
//
//  Created by 相澤 隆志 on 2014/03/08.
//  Copyright (c) 2014年 相澤 隆志. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemThumbnailCollectionView : UICollectionView
{
    NSInteger identifier;
}
@property   NSInteger identifier;

- (id)initWithIndex:(NSInteger)index;

@end
