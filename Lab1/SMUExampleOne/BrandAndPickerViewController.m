//
//  BrandAndPickerViewController.m
//  SMUExampleOne
//
//  Created by Xingming on 9/9/19.
//  Copyright © 2019 Eric Larson. All rights reserved.
//

#import "BrandAndPickerViewController.h"
#import "BrandsAndHistory.h"
@interface BrandAndPickerViewController () <UIPickerViewDelegate,UIPickerViewDataSource>
//@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControlButton;

{
NSArray *pickerData;
}

@property (weak, nonatomic) IBOutlet UITextView *historyText;
@property (weak, nonatomic) IBOutlet UIImageView *brandView;
@property (weak, nonatomic) IBOutlet UISwitch *SwitchButton;
@property (weak, nonatomic) IBOutlet UILabel *DarkModelLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *brandPicker;



@property (strong,nonatomic) BrandsAndHistory* myBrandHistory;
@property (weak, nonatomic) IBOutlet UITextView *testTextVIew;

@property (weak, nonatomic) IBOutlet UILabel *text_history_label;

@end

@implementation BrandAndPickerViewController
@synthesize historyText;
@synthesize brandView;
@synthesize SwitchButton;
@synthesize DarkModelLabel;
@synthesize titleLabel;
@synthesize brandPicker;

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    [self.view setNeedsDisplay];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [brandScrollView addSubview:stackView];
//    [stackView addSubview:historyText];
    [stackView addSubview:titleLabel];
    [stackView addSubview:brandPicker];
    [stackView addSubview:darkModelStackView];
    [darkModelStackView addSubview:DarkModelLabel];
    [darkModelStackView addSubview:SwitchButton];

    _text_history_label.text =  [BrandsAndHistory sharedInstance].BrandHistory[0];

    brandScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height*2)];
//    [brandScrollView setContentOffset:CGPointMake(0, -200) animated:YES];
//    brandScrollView.scrollsToTop = true;
//    stackView=[[UIStackView alloc] initWithFrame:CGRectMake(0, 0,self.view.frame.size.width,self.view.frame.size.height)];
//
//    [brandScrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height*2)];
// subview that can be scroll at different direction


    
    // Do any additional setup after loading the view.
    //    _historyText.text = @"HisroryHisroryHisroryHisroryHisrory";
    
//    NSString *ss = [BrandsAndHistory sharedInstance].BrandHistory[1];
//    NSLog(@"%@",ss);
    
    pickerData = [BrandsAndHistory sharedInstance].BrandNames;
    self.brandPicker.dataSource = self;
    self.brandPicker.delegate = self;
}

- (IBAction)SwitchChanged:(UISwitch *)sender {
    if (sender.on) {
        self.view.backgroundColor = [UIColor lightGrayColor];
        historyText.backgroundColor = [UIColor lightGrayColor];
        brandView.backgroundColor =[UIColor lightGrayColor];
        brandPicker.backgroundColor = [UIColor lightGrayColor];
        
        DarkModelLabel.textColor = [UIColor whiteColor];
        historyText.textColor = [UIColor whiteColor];
        titleLabel.textColor = [UIColor whiteColor];
    }else{
        self.view.backgroundColor = [UIColor whiteColor];
        historyText.backgroundColor =[UIColor whiteColor];
        brandView.backgroundColor =[UIColor whiteColor];
        brandPicker.backgroundColor = [UIColor colorWithRed:235.0f/255 green:252.0f/255 blue:255.0f/255 alpha:1];
        
        DarkModelLabel.textColor = [UIColor blackColor];
        historyText.textColor = [UIColor blackColor];
        titleLabel.textColor = [UIColor blackColor];
    }
}




-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return pickerData.count;
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [pickerData objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
//    [self.historyText setContentOffset:CGPointMake(0, 0) animated:YES];
//    self.historyText.text = [BrandsAndHistory sharedInstance].BrandHistory[row];
//    [self.historyText setContentOffset:CGPointMake(0, 0) animated:YES];
    _text_history_label.text =  [BrandsAndHistory sharedInstance].BrandHistory[row];

    NSString *logoImageName = [BrandsAndHistory sharedInstance].BrandNames[row];
    logoImageName = [logoImageName stringByAppendingString:@"_ic"];
//    NSLog(@"%@",logoImageName);
//    UIImage* image = [UIImage imageNamed:logoImageName];
    UIImage* image = nil;
    image = [UIImage imageNamed:logoImageName];
    self.brandView.image = image;
//    [brandScrollView setContentOffset:CGPointMake(0, 0) animated:YES];

//    self.historyText.scrollsToTop = true;
//    [[UIImageView alloc] initWithImage:image];
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
