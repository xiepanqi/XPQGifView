//
//  ViewController.m
//  XPQGifViewDome
//
//  Created by 谢攀琪 on 16/3/19.
//  Copyright © 2016年 谢攀琪. All rights reserved.
//

#import "ViewController.h"
#import "XPQGifView.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet XPQGifView *gifView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickStart:(id)sender {
//    self.gifView.loopCount = 2;
    NSData *gifData = [NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"test2" ofType:@"gif"]];
    [self.gifView loadGifData:gifData];
}
- (IBAction)clickStop:(id)sender {
//    [self.gifView stop];
    [self.gifView removeFromSuperview];
}
@end
