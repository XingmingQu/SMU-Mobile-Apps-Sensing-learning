//
//  TableViewController.m
//  SMUExampleOne
//
//  Created by Eric Larson on 1/21/15.
//  Copyright (c) 2015 Eric Larson. All rights reserved.
//

#import "TableViewController.h"
#import "ImageModel.h"
#import "ViewController.h"
#import "Cars.h"

@interface TableViewController ()
@property (weak, nonatomic) IBOutlet UINavigationItem *titilelabel;

@property (strong,nonatomic) ImageModel* myImageModel;
@property (strong,nonatomic) Cars* myCarModel;
@property (strong,nonatomic) NSArray* TitleNames;
@end

@implementation TableViewController

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

-(void)changeTitle{
    
//    int randomIndex = UINT32_C(self.TitleNames.count);
  
//    int i = arc4random_uniform(self.TitleNames.count);
    if (self.TitleNames.count == 0){
        self.titilelabel.title = _TitleNames[0];
    }else{
        
    NSUInteger r = arc4random_uniform(4);
    self.titilelabel.title = _TitleNames[r];
//    NSLog(@"%d",self.TitleNames.count);

    }
}


-(NSArray*)TitleNames{
    
    if(!_TitleNames)
        _TitleNames = @[@"Car Gallery",@"Find Your Favourite Cars",@"See Your Estimated Monthly Payment", @"View Car Brands and History"];
    
    return _TitleNames;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.titilelabel.title =@"dasdasd";
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(changeTitle) userInfo:nil repeats:(YES)];
    
    [timer fire];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
    // Three prototype cells
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    // Only first type has more than one sections
    if(section==0)
        return self.myImageModel.imageNames.count;
    else
        return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    
    if(indexPath.section==0){
        cell = [tableView dequeueReusableCellWithIdentifier:@"ImageNameCell" forIndexPath:indexPath];
//        cell.textLabel.text = self.myImageModel.imageNames[indexPath.row];
        cell.textLabel.text = self.myCarModel.CarNames[indexPath.row];
        cell.detailTextLabel.text = @"More";
        
    }
    else if(indexPath.section==1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CollectionCell" forIndexPath:indexPath];
        
        // Configure the cell...
        cell.textLabel.text = @"Car Photos Collection";
        cell.detailTextLabel.text = @"Click images inside to view detail";
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"PickerCell" forIndexPath:indexPath];
        
        // Configure the cell...
        cell.textLabel.text = @"Brands and History";
        cell.detailTextLabel.text = @"See car Brand logos and their history";
    }
    
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    BOOL isVC = [[segue destinationViewController] isKindOfClass:[ViewController class]];
    
    if(isVC){
        UITableViewCell* cell = (UITableViewCell*)sender;
        ViewController *vc = [segue destinationViewController];
        NSString *index = self.myCarModel.ImageNameToIndex[cell.textLabel.text];
//        NSLog(@"%@",index);
        vc.imageName = self.myImageModel.imageNames[[index intValue]];
        vc.imageIndex = index;
//        NSLog(@"%@",vc.imageName);
//        cell.textLabel.text;
    }
    
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
