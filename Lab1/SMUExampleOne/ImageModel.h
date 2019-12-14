//
//  ImageModel.h
//  SMUExampleOne
//
//  Created by Eric Larson on 1/21/15.
//  Copyright (c) 2015 Eric Larson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageModel : NSObject

@property (strong,nonatomic) NSArray* imageNames;
@property (strong,nonatomic) NSArray* CollectionimageNames;


+(ImageModel*) sharedInstance;

-(UIImage*)getImageWithName:(NSString*)name;

@end
