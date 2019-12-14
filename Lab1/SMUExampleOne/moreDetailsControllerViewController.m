//
//  moreDetailsControllerViewController.m
//  SMUExampleOne
//
//  Created by Xingming on 9/11/19.
//  Copyright © 2019 Eric Larson. All rights reserved.
//

#import "moreDetailsControllerViewController.h"
#import "BrandsAndHistory.h"
@interface moreDetailsControllerViewController () <UIScrollViewDelegate>

//Segment control outlets and action



@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

- (IBAction)indexChanged:(UISegmentedControl *)sender;
@property (weak, nonatomic) IBOutlet UITextView *specsTextView;

@property(strong, nonatomic) UIView *detailsView;

@property (weak, nonatomic) IBOutlet UIScrollView *segmentScrollView;
@property (strong,nonatomic) BrandsAndHistory* myBrandHistory;
@end

@implementation moreDetailsControllerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    NSLog(@"%@",self.imageName);
    self.specsTextView.hidden = true;
    [self resetSpecs];
    
    //    _imageView = [[UIImageView alloc] initWithImage:[[ImageModel sharedInstance] getImageWithName:self.imageName]];
    _imageView = [[UIImageView alloc] initWithImage:self.image];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
//    _imageView.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
    _imageView.frame = CGRectMake(0, 0, self.segmentScrollView.frame.size.width, UIScreen.mainScreen.bounds.size.height*2);

    //-------------set segmentScrollView parameters---------
    [self.segmentScrollView addSubview:self.imageView];
    self.segmentScrollView.contentSize= self.imageView.frame.size;
    self.segmentScrollView.minimumZoomScale = 0.1;
    self.segmentScrollView.maximumZoomScale = 4;
    self.segmentScrollView.delegate = self;
    
    
    //------------------------------------------------------
    //-------create the view for segmented control----------------
    
    _detailsView = [[UITextView alloc] init];
    [self.segmentScrollView addSubview:self.detailsView];
    [self.segmentScrollView bringSubviewToFront:self.imageView];
    //------------------------------------------------------------
    
    // Do any additional setup after loading the view.
}

//-(void)scrollViewDidScroll:(UIScrollView *)sender{
////    sender.contentOffset.x = 0.0
//}

- (IBAction)indexChanged:(UISegmentedControl *)sender {
    
    switch (self.segmentedControl.selectedSegmentIndex)
    {
        case 0:
            self.specsTextView.hidden = true;
            [self.detailsView setHidden:YES];
            [self.imageView setHidden:NO];
            break;
        case 1:
            self.specsTextView.hidden = false;
            [self.imageView setHidden:YES];
            [self.detailsView setHidden:NO];
//            [self.specsTextView setContentOffset:CGPointMake(0, 0) animated:YES];
//            self.segmentScrollView.scrollsToTop = true;
            [self.segmentScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
            break;
        default:
            
            break;
    }
}

-(void)resetSpecs{
//    NSLog(@"%@",_picIndex);
    self.specsTextView.text = [BrandsAndHistory sharedInstance].Specs[[_picIndex intValue]];

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
