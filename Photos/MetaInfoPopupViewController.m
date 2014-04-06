//
//  MetaInfoPopupViewController.m
//  Photos
//
//  Created by 相澤 隆志 on 2014/04/04.
//  Copyright (c) 2014年 相澤 隆志. All rights reserved.
//

#import "MetaInfoPopupViewController.h"
#import "AppDelegate.h"

@interface MetaInfoPopupViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *makerLabel;
@property (weak, nonatomic) IBOutlet UILabel *modelLabel;
@property (weak, nonatomic) IBOutlet UILabel *ArtistLabel;
@property (weak, nonatomic) IBOutlet UILabel *fnumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *isoLabel;
@property (weak, nonatomic) IBOutlet UILabel *exposerTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *forcalLengthLabel;
@property (weak, nonatomic) IBOutlet UILabel *flashLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateTimeLabel;
- (IBAction)closeButtonClicked:(id)sender;

@end

@implementation MetaInfoPopupViewController

@synthesize metaDataDictionary;
@synthesize sectionIndex;
@synthesize index;

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
    [self displayMetaDatas];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeMetaPopupView:) name:@"metaInfoPopupChanged" object:nil];

}

- (void)displayMetaDatas
{
    AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    NSDictionary* dict = [appDelegate.m_imageLibrary getMetaDataBySectionIndex:self.sectionIndex index:self.index];
    
    self.imageView.image = [appDelegate.m_imageLibrary getAspectThumbnailAtSectionByIndex:self.sectionIndex index:self.index];
    NSString* maker = [dict valueForKey:@"Maker"];
    self.makerLabel.text = [dict valueForKey:@"Maker"];
    self.modelLabel.text = [dict valueForKey:@"Model"];
    self.ArtistLabel.text = [dict valueForKey:@"Artist"];
    NSString* str = [dict valueForKey:@"FNumber"];
    self.fnumberLabel.text = [dict valueForKey:@"FNumber"];
    
    self.isoLabel.text = [dict valueForKey:@"ISO"];
    self.exposerTimeLabel.text = [dict valueForKey:@"ExposureTime"];
    self.forcalLengthLabel.text = [dict valueForKey:@"FocalLength"];
    self.flashLabel.text = [dict valueForKey:@"Flash"];
    self.dateTimeLabel.text = [dict valueForKey:@"DateTimeOriginal"];
    
}
- (void)changeMetaPopupView:(NSNotification*)notification
{
    NSNumber* changeSectionIndex = [notification.userInfo objectForKey:@"SectionIndex"];
    NSNumber* changeIndex = [notification.userInfo objectForKey:@"index"];
    NSInteger indexOf = [changeIndex intValue];
    NSInteger sectionIndexOf = [changeSectionIndex intValue];
    self.sectionIndex = sectionIndexOf;
    self.index = indexOf;
    [self displayMetaDatas];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)closeButtonClicked:(id)sender {
     [[NSNotificationCenter defaultCenter] postNotificationName:@"metaInfoPopupClosed" object:self userInfo:nil];
}
@end
