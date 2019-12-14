//
//  Cars.h
//  SMUExampleOne
//
//  Created by Xingming on 9/7/19.
//  Copyright © 2019 Eric Larson. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Cars : NSObject

@property (strong,nonatomic) NSDictionary* ImageNameToIndex;
@property (strong,nonatomic) NSArray* CarNames;
@property (strong,nonatomic) NSArray* CarBrands;
@property (strong,nonatomic) NSArray* CarPrices;


+(Cars*) sharedInstance;
@end

NS_ASSUME_NONNULL_END
