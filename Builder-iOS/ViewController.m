//
//  ViewController.m
//  Builder-iOS
//
//  Created by niezhiqiang on 2022/1/26.
//

#import "ViewController.h"
#import "AttributeStringBuilder.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    AttributeStringBuilder *builder = AttributeStringBuilder.new;
    builder.text(@"我是").color(UIColor.greenColor).font([UIFont systemFontOfSize:20]).commit();
    builder.text(@"构造器模式").color(UIColor.redColor).font([UIFont systemFontOfSize:30]).commit();
    builder.text(@"的演示").color(UIColor.blueColor).font([UIFont systemFontOfSize:20]).commit();

    UILabel *label = [[UILabel alloc] init];
    label.attributedText = builder.result;
    [self.view addSubview:label];
    [label sizeToFit];
    label.center = CGPointMake([UIScreen mainScreen].bounds.size.width * 0.5, 100);
}


@end
