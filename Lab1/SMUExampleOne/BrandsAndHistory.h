//
//  BrandsAndHistory.h
//  SMUExampleOne
//
//  Created by Xingming on 9/9/19.
//  Copyright © 2019 Eric Larson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@interface BrandsAndHistory : NSObject

@property (strong,nonatomic) NSArray* Specs;
@property (strong,nonatomic) NSArray* BrandNames;
@property (strong,nonatomic) NSArray* BrandHistory;
@property (strong,nonatomic) NSDictionary* BrandNameToIndex;
-(NSString*)getTxtContent:(NSString*)fileName;
+(BrandsAndHistory*) sharedInstance;

//-(UIImage*)getImageWithName:(NSString*)name;


@end

NS_ASSUME_NONNULL_END
