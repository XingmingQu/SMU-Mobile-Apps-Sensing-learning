//
//  BrandsAndHistory.m
//  SMUExampleOne
//
//  Created by Xingming on 9/9/19.
//  Copyright © 2019 Eric Larson. All rights reserved.
//

#import "BrandsAndHistory.h"

@implementation BrandsAndHistory

-(NSString*)getTxtContent:(NSString *)fileName{
    NSString* path = [[NSBundle mainBundle] pathForResource:fileName ofType:(@"txt")];
    NSString* content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    return content;
}



//-(NSDictionary*)BrandNameToIndex{
//    // initialization
//    if (!_BrandNameToIndex)
//    {
//        _BrandNameToIndex =  @{@"Honda": @"0",
//                               @"BMW": @"1",
//                               @"Ford": @"2",
//                               @"Ferrari": @"3",
//                               @"Audi": @"4",
//                               @"Lamborghini": @"5"};
//    }
//    return _BrandNameToIndex;
//}


-(NSArray*)BrandNames{
    

    
    if(!_BrandNames)
    {
        _BrandNames = @[@"Honda",
                        @"BMW",
                        @"Ford",
                        @"Ferrari",
                        @"Audi",
                        @"Lamborghini"];
        
    }
//    [self getTxtContent:@"hondaHistory"],
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"hondaHistory" ofType:@"txt"];
//        NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
//        
//    NSLog(@"%lu",(unsigned long)_BrandNames.count);

    return _BrandNames;
}


-(NSArray*)BrandHistory{
    
    if(!_BrandHistory)
        _BrandHistory= @[[self getTxtContent:@"hondaHistory"],
                        [self getTxtContent:@"BMWHistory"],
                        [self getTxtContent:@"FordHistory"],
                        [self getTxtContent:@"FerrariHistory"],
                        [self getTxtContent:@"AudiHistory"],
                        [self getTxtContent:@"LamborghiniHistory"]];
    
    return _BrandHistory;
}

-(NSArray*)Specs{
    
    if(!_Specs)
        _Specs= @[[self getTxtContent:@"civicS"],
                         [self getTxtContent:@"M4S"],
                         [self getTxtContent:@"mustang"],
                         [self getTxtContent:@"ferrari"],
                         [self getTxtContent:@"audi"],
                         [self getTxtContent:@"lambo"]];
    
    return _Specs;
}

+(BrandsAndHistory*)sharedInstance{
    static BrandsAndHistory * _sharedInstance = nil;
    
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate,^{
        _sharedInstance = [[BrandsAndHistory alloc] init];
    });
    
    return _sharedInstance;
}


@end
