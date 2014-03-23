//
//  AuthViewController.m
//  Photos
//
//  Created by 相澤 隆志 on 2014/03/23.
//  Copyright (c) 2014年 相澤 隆志. All rights reserved.
//

#import "AuthViewController.h"
#import "FlickrMngr.h"

#define kCallbackUrlString @"photosapp://auth"


@interface AuthViewController ()
@property (nonatomic, retain) FlickrMngr* flickrMngr;
@end

@implementation AuthViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        CGRect rect = [[UIScreen mainScreen] bounds];
        //self.view.frame = CGRectMake(20, 30, rect.size.width -40, rect.size.height - 60);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    NSString* callbakckURLString = kCallbackUrlString;
    
	// This must be defined in your Info.plist
	// See FlickrKitDemo-Info.plist
	// Flickr will call this back. Ensure you configure your flickr app as a web app
   
    self.flickrMngr = [FlickrMngr sharedFlkckrMngr];
    [self.flickrMngr beginWebAuth:callbakckURLString load:^(NSMutableURLRequest* request){
        [self.webView loadRequest:request];
    }];
 
}

- (void) viewWillDisappear:(BOOL)animated {
    [self.flickrMngr cancelAuthOperation];
    [super viewWillDisappear:animated];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    //If they click NO DONT AUTHORIZE, this is where it takes you by default... maybe take them to my own web site, or show something else
	
    NSURL *url = [request URL];
    
	// If it's the callback url, then lets trigger that
    if (![url.scheme isEqual:@"http"] && ![url.scheme isEqual:@"https"]) {
        if ([[UIApplication sharedApplication]canOpenURL:url]) {
            [[UIApplication sharedApplication]openURL:url];
            return NO;
        }
    }
	
    return YES;
	
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

@end
