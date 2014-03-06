//
//  AppDelegate.h
//  Photos
//
//  Created by Aizawa Takashi on 2014/03/05.
//  Copyright (c) 2014年 Aizawa Takashi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageLibrary.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, ImageLibraryDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) ImageLibrary* m_imageLibrary;

@end
