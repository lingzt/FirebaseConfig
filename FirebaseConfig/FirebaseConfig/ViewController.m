//
//  ViewController.m
//  FirebaseConfig
//
//  Created by ling toby on 7/4/16.
//  Copyright © 2016 Detroit Labs. All rights reserved.
//

#import "ViewController.h"
@import Firebase;


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintToTop;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupRemoteConfig];
    [self fetchRemoteConfig];

    // Do any additional setup after loading the view, typically from a nib.
}


-(void)updateView{
    FIRRemoteConfig *rc = [FIRRemoteConfig remoteConfig];
    NSString *labelString = [[rc configValueForKey:@"labelText"] stringValue];
    [self.label setText:labelString];
    CGFloat constraintValue = [[[rc configValueForKey:@"constrainToTop"] numberValue] floatValue];
    self.constraintToTop.constant = constraintValue;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupRemoteConfig{
    NSDictionary *defaultValue = @{
                                   @"labelText" :@"Defalut Text!",
                                   @"constraintToTop" : @200
                                   };
    [[FIRRemoteConfig remoteConfig] setDefaults:defaultValue];
    [self updateView];
}


//正式版不是用，否则 remoteConfig 会失效
-(void)enableDeveloperMode{
    FIRRemoteConfigSettings *devModeSettings = [[FIRRemoteConfigSettings alloc]initWithDeveloperModeEnabled:YES];
    [FIRRemoteConfig remoteConfig].configSettings = devModeSettings;
}

-(void)fetchRemoteConfig{
    NSTimeInterval expirationTime;
    
//开发版本不间断检查新版本
#ifdef DEBUG
    expirationTime = 0.0;
    [self enableDeveloperMode];
    
    //正式版，每24小时检查新版本
#else
    expirationTime = 43200.0
#endif
   
    //避免retain
    ViewController *__weak weakSelf = self;
    //expirationTime 的秒间隔查询新版本
    [[FIRRemoteConfig remoteConfig] fetchWithExpirationDuration:0 completionHandler:^(FIRRemoteConfigFetchStatus status, NSError * _Nullable error) {
        if (error == nil) {
            NSLog(@"Hooray! Config completed with status %ld",(long)status);
            [[FIRRemoteConfig remoteConfig]activateFetched];
            [weakSelf updateView];
        } else {
            NSLog(@"oh noes! Got an error! %@",[error localizedDescription]);
        }
        
    }];

}

@end
