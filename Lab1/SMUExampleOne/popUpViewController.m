//
//  popUpViewController.m
//  SMUExampleOne
//
//  Created by Xingming on 9/11/19.
//  Copyright © 2019 Eric Larson. All rights reserved.
//

#import "popUpViewController.h"

@interface popUpViewController ()

@property (weak, nonatomic) IBOutlet UITextField *enterZipTextField;

@end

@implementation popUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)closePopUp:(UIButton *)sender {
    
    [self.delegate sendZipBack:_enterZipTextField.text];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
