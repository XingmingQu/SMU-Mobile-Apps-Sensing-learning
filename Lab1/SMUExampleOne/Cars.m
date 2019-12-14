//
//  Cars.m
//  SMUExampleOne
//
//  Created by Xingming on 9/7/19.
//  Copyright © 2019 Eric Larson. All rights reserved.
//

#import "Cars.h"

@implementation Cars



-(NSDictionary*)ImageNameToIndex{
    // initialization
    if (!_ImageNameToIndex)
    {
        _ImageNameToIndex =  @{@"Civic Type R": @"0",
                               @"M4": @"1",
                               @"Mustang Bullitt": @"2",
                               @"Ferrari 458 Italia": @"3",
                               @"Audi RS 5": @"4",
                               @"Lamboghini Aventador LP750": @"5"};
    }
    return _ImageNameToIndex;
}

-(NSArray*)CarNames{
    if(!_CarNames)
        _CarNames = @[@"Civic Type R",
                      @"M4",
                      @"Mustang Bullitt",
                      @"Ferrari 458 Italia",
                      @"Audi RS 5",
                      @"Lamboghini Aventador LP750"];
    return _CarNames;
}

-(NSArray*)CarBrands{
    if(!_CarBrands)
        _CarBrands = @[@"Honda",
                       @"BMW",
                       @"Ford",
                       @"Ferrari",
                       @"Audi",
                       @"Lamboghini"];
    return _CarBrands;
}

-(NSArray*)CarPrices{
    if(!_CarPrices)
        _CarPrices = @[@"37230",
                       @"105745",
                       @"53475",
                       @"219990",
                       @"100240",
                       @"569995"];
    return _CarPrices;
}


+(Cars*)sharedInstance{
    static Cars * _sharedInstance = nil;
    
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate,^{
        _sharedInstance = [[Cars alloc] init];
    });
    
    return _sharedInstance;
}


@end
