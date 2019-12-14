//
//  ImageModel.m
//  SMUExampleOne
//
//  Created by Eric Larson on 1/21/15.
//  Copyright (c) 2015 Eric Larson. All rights reserved.
//

#import "ImageModel.h"

@implementation ImageModel
@synthesize imageNames = _imageNames;

-(NSArray*)imageNames{
    
    if(!_imageNames)
        _imageNames = @[@"civic",
                        @"bmw",
                        @"mustang",
                        @"ferr",
                        @"RS5",
                        @"lambo"];
    
    return _imageNames;
}

-(NSArray*)CollectionimageNames{
    
    if(!_CollectionimageNames)
        _CollectionimageNames = @[@"civicC",
                                  @"bmwC",
                                  @"mustangC",
                                  @"ferrC",
                                  @"RS5C",
                                  @"lamboC"];
    
    return _CollectionimageNames;
}


+(ImageModel*)sharedInstance{
    static ImageModel * _sharedInstance = nil;
    
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate,^{
        _sharedInstance = [[ImageModel alloc] init];
    });
    
    return _sharedInstance;
}

-(UIImage*)getImageWithName:(NSString *)name{
    UIImage* image = nil;
    image = [UIImage imageNamed:name];
    return image;
}

@end
