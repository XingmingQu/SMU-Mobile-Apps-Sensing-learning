//
//  ViewController.m
//  SMUExampleOne
//
//  Created by Eric Larson on 1/21/15.
//  Copyright (c) 2015 Eric Larson. All rights reserved.
//

#import "ViewController.h"
#import "ImageModel.h"
#import "Cars.h"
#import "moreDetailsControllerViewController.h"
#import "popUpViewController.h"

@interface ViewController () <UIScrollViewDelegate,popUpViewControllerDelegate>

@property (strong, nonatomic) UIImageView* imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *allPageScrollView;
@property (weak, nonatomic) IBOutlet UIStackView *allStackView;

@property (weak, nonatomic) IBOutlet UILabel *modelLabel;
@property (weak, nonatomic) IBOutlet UILabel *MakeLabel;
@property (weak, nonatomic) IBOutlet UILabel *PriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *ColorLabel;
@property (weak, nonatomic) IBOutlet UIButton *inputZipButton;
@property (weak, nonatomic) IBOutlet UIButton *jumpToWebButton;

- (IBAction)JumpToWeb:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIStepper *monthSteper;

//- (IBAction)JumpToWeb:(UIButton *)sender;
- (IBAction)stepperValueChanged:(UIStepper *)sender;

@property (weak, nonatomic) IBOutlet UILabel *ARPLabel;
@property (weak, nonatomic) IBOutlet UILabel *LoanTermLabel;
@property (weak, nonatomic) IBOutlet UISlider *APRslider;
@property (weak, nonatomic) IBOutlet UILabel *EMPLabel;

-(void)setEMPlabelValue;

- (IBAction)sliderValueChanged:(UISlider *)sender;


@property (strong,nonatomic) ImageModel* myImageModel;
@property (strong,nonatomic) Cars* myCarModel;

@end

@implementation ViewController

-(void)sendZipBack:(NSString *)message{
    self.jumpToWebButton.hidden = false;
//    NSLog(@"%@",message);
    _zipCode = message;
    [_jumpToWebButton setTitle:[NSString stringWithFormat:@"Search Dealers near %@",message] forState:(UIControlStateNormal)];
//    [self.jumpToWebButton setTitle:[NSString stringWithFormat:@"Search Dealers near %@",message]];
}

- (IBAction)goToPopUpVC:(id)sender {
    popUpViewController *popUpVC = [self.storyboard instantiateViewControllerWithIdentifier:@"popUpViewController"];
    popUpVC.delegate = self;
    [self presentViewController:popUpVC animated:YES completion:nil];
}

-(void)setEMPlabelValue{
    
    // calculate EMP by its math formula
    double ARP = self.APRslider.value /12/100;
    double months =self.monthSteper.value;
    double carPrice = [[Cars sharedInstance].CarPrices[[_imageIndex intValue]] intValue] ;
    int EMP = (carPrice* ARP)/ (1-pow(1+ARP, -months));
    NSString *EMPValue = [NSString stringWithFormat:@"$%d", EMP];
    self.EMPLabel.text = EMPValue;
    //    NSLog(@"%.5f",ARP);
    //    NSLog(@"%.5f",months);
    //    NSLog(@"%f",carPrice);
    //    NSLog(@"%d",EMP);
}



- (IBAction)JumpToWeb:(UIButton *)sender {
    NSString *Make = [Cars sharedInstance].CarBrands[[_imageIndex intValue]];
    NSString *URL = [NSString stringWithFormat:@"https://www.google.com/maps/search/%@+%@", _zipCode,Make];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL]];
//    NSLog(@"%@",URL);
//    NSLog(@"%@",Make);
}

- (IBAction)sliderValueChanged:(UISlider *)sender {
    NSString *sliderValue = [NSString stringWithFormat:@"%.2f%%", sender.value];
    self.ARPLabel.text = sliderValue;
//    NSLog(@"%d",[[Cars sharedInstance].CarPrices[[_imageIndex intValue]] intValue] );
    
    [self setEMPlabelValue];
}

-(ImageModel*)myImageModel{
    
    if(!_myImageModel)
        _myImageModel =[ImageModel sharedInstance];
    
    return _myImageModel;
}

-(Cars*)myCarModel{
    
    if(!_myCarModel)
        _myCarModel =[Cars sharedInstance];
    
    return _myCarModel;
}


-(NSString*)imageName{
    
    if(!_imageName)
        _imageName = @"bmw";
    
    return _imageName;
}

-(NSString*)imageIndex{
    
    if(!_imageIndex)
        _imageIndex = @"0";
    
    return _imageIndex;
}

-(UIImageView*)imageView{
    
    if(!_imageView)
        _imageView = [[UIImageView alloc] initWithImage:[[ImageModel sharedInstance] getImageWithName:self.imageName]];
    
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
//    _imageView.frame = CGRectMake(0, 380, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
    _imageView.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, UIScreen.mainScreen.bounds.size.height*2);
    return _imageView;
}

-(void)changeLabelColor{
    // use random color to set label's txt
    CGFloat red = (CGFloat)random()/(CGFloat)RAND_MAX;
    CGFloat green = (CGFloat)random()/(CGFloat)RAND_MAX;
    CGFloat blue = (CGFloat)random()/(CGFloat)RAND_MAX;
    [_ColorLabel setTextColor:[UIColor colorWithRed:red green:green blue:blue alpha:1]];
    
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    [_allPageScrollView addSubview:_allStackView];
    [_allStackView addSubview:_APRslider];
//    [_allStackView setUserInteractionEnabled:YES];

//    [_allStackView addSubview:_scrollView];
//    [_allStackView addsubview:_APRslider];
    
    //------------------auto size a UIScrollView to fit its content--------------------------
    self.jumpToWebButton.hidden = true;
    [self.scrollView addSubview:self.imageView];
    CGRect contentRect = CGRectZero;
    for (UIView *view in self.scrollView.subviews) {
        contentRect = CGRectUnion(contentRect, view.frame);
    }
    self.scrollView.contentSize = contentRect.size;
    //------------------auto size a UIScrollView to fit its content--------------------------
    
    //------------set scrollView's parameter----------------
    self.scrollView.minimumZoomScale = 0.1;
    self.scrollView.maximumZoomScale = 4;
    self.scrollView.delegate = self;
    //------------set scrollView's parameter----------------
    

    
    //------------set labels----------------
    NSString *modelName = @"Model:  ";
    modelName = [modelName stringByAppendingString:[Cars sharedInstance].CarNames[[_imageIndex intValue]]];
    NSString *MakeName = @"Make:  ";
    MakeName = [MakeName stringByAppendingString:[Cars sharedInstance].CarBrands[[_imageIndex intValue]]];
    NSString *Price = @"Price:  $ ";
    Price = [Price stringByAppendingString:[Cars sharedInstance].CarPrices[[_imageIndex intValue]]];
    
    self.modelLabel.text = modelName;
    self.MakeLabel.text = MakeName;
    self.PriceLabel.text = Price;
    [self setEMPlabelValue];
    self.monthSteper.transform = CGAffineTransformMakeScale(0.7, 0.7);
    //------------set labels----------------
    
    //------------set label border----------------
    self.ARPLabel.layer.borderColor = [[UIColor grayColor]CGColor];
    self.ARPLabel.layer.borderWidth = 1;
    self.LoanTermLabel.layer.borderColor = [[UIColor grayColor]CGColor];
    self.LoanTermLabel.layer.borderWidth = 1;
    //------------set label border----------------
    
   

    //set timer
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(changeLabelColor) userInfo:nil repeats:(YES)];
    
    [timer fire];
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}


- (IBAction)stepperValueChanged:(UIStepper *)sender {
    NSString *stepperValue = [NSString stringWithFormat:@"%.0f", sender.value];
    self.LoanTermLabel.text = stepperValue;
//    double ARP = sender.value /12/100;
//    double months =self.monthSteper.value;
//    double carPrice = [[Cars sharedInstance].CarPrices[[_imageIndex intValue]] intValue] ;
//    int EMP = (carPrice* ARP)/ (1-pow(1+ARP, -months));
//
//    NSString *EMPValue = [NSString stringWithFormat:@"%d", EMP];
//    self.EMPLabel.text = EMPValue;
    [self setEMPlabelValue];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
//    NSLog(@"in outer part of segue");
    BOOL isVC = [[segue destinationViewController] isKindOfClass:[moreDetailsControllerViewController class]];
    if(isVC){
        moreDetailsControllerViewController *vc = [segue destinationViewController];
//        NSLog(@"in segue");
        vc.picIndex = self.imageIndex;
//        UIImageView* temp = [[UIImageView alloc] init];
//        temp = self.imageView;
//        vc.imageView = temp;
        vc.image =[[ImageModel sharedInstance] getImageWithName:self.imageName];
    }
}

@end
