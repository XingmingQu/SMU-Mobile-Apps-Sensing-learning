//
//  CollectionViewController.m
//  SMUExampleOne
//
//  Created by Eric Larson on 1/21/15.
//  Copyright (c) 2015 Eric Larson. All rights reserved.
//

#import "CollectionViewController.h"
#import "ImageModel.h"
#import "CollectionViewCell.h"
#import "collectionViewPopUpModelViewController.h"
@interface CollectionViewController ()




@property (strong,nonatomic) ImageModel* myImageModel;

@end

@implementation CollectionViewController
- (IBAction)goToPopUp:(UIButton*)sender {
//    collectionPopUp
    collectionViewPopUpModelViewController *popUpVC = [self.storyboard instantiateViewControllerWithIdentifier:@"collectionPopUp"];
//    NSLog(@"%@",sender.titleLabel.text);

    popUpVC.imageIndex = sender.titleLabel.text;
    [self presentViewController:popUpVC animated:YES completion:nil];
    
}

-(ImageModel*)myImageModel{
    
    if(!_myImageModel)
        _myImageModel =[ImageModel sharedInstance];
    
    return _myImageModel;
}

static NSString * const reuseIdentifier = @"ImageCollectCell";

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    // UPDATE: this is only required when the cell is configured programatically
    // Since we use the storyboard, we should NOT register the class. Per the instructions here:
    // https://developer.apple.com/library/ios/documentation/WindowsViews/Conceptual/CollectionViewPGforIOS/CreatingCellsandViews/CreatingCellsandViews.html#//apple_ref/doc/uid/TP40012334-CH7-SW10
    //[self.collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.myImageModel.CollectionimageNames.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    cell.backgroundColor = [UIColor blueColor];
    cell.imageView.image = [self.myImageModel getImageWithName:self.myImageModel.CollectionimageNames[indexPath.row]];
    
    [cell.passButton setTitle:[NSString stringWithFormat:@"%ld", (long)indexPath.row] forState:(UIControlStateNormal)];
    cell.userInteractionEnabled = true;
//    _labelForPassingIndex.text = [NSString stringWithFormat:@"%d", indexPath.row];
//    collectionViewPopUpModelViewController *popUpVC;
//    popUpVC identi
//    popUpVC.imageIndex = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    CGFloat red = (CGFloat)random()/(CGFloat)RAND_MAX;
    CGFloat green = (CGFloat)random()/(CGFloat)RAND_MAX;
    CGFloat blue = (CGFloat)random()/(CGFloat)RAND_MAX;
    [cell.colorCell setTextColor:[UIColor colorWithRed:red green:green blue:blue alpha:1]];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
