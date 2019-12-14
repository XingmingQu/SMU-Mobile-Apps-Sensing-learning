//
//  collectionViewPopUpModelViewController.m
//  labOneCode
//
//  Created by Xingming on 9/15/19.
//  Copyright © 2019 Eric Larson. All rights reserved.
//

#import "collectionViewPopUpModelViewController.h"
#import "ImageModel.h"

@interface collectionViewPopUpModelViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *popUpImage;


@end

@implementation collectionViewPopUpModelViewController

-(NSString*)imageIndex{
    
    if(!_imageIndex)
        _imageIndex = @"0";
    
    return _imageIndex;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *imageName = [NSString stringWithFormat:@"%@", [ImageModel sharedInstance].CollectionimageNames[[_imageIndex intValue]]];

    
    _popUpImage.image = [UIImage imageNamed:imageName];
//    NSLog(@"imname%@",imageName);
    // Do any additional setup after loading the view.
    
}
- (IBAction)closePopUp:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
