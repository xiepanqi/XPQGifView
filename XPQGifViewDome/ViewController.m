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
    if (self.gifView.gifData == nil) {
        self.gifView.gifData = [NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"test2" ofType:@"gif"]];
    }
    [self.gifView start];
}

- (IBAction)clickSuspend:(id)sender {
    [self.gifView suspend];
}

- (IBAction)clickStop:(id)sender {
    [self.gifView stop];
}

- (IBAction)clickFast:(id)sender {
//    [self.gifView suspend];
    self.gifView.sleep = 0.5;
//    [self.gifView start];
}

- (IBAction)clickNormal:(id)sender {
//    [self.gifView suspend];
    self.gifView.sleep = 1.0;
//    [self.gifView start];
}

- (IBAction)clickSlow:(id)sender {
//    [self.gifView suspend];
    self.gifView.sleep = 2.0;
//    [self.gifView start];
}
@end
