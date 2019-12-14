//
//  moreDetailsControllerViewController.h
//  SMUExampleOne
//
//  Created by Xingming on 9/11/19.
//  Copyright © 2019 Eric Larson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface moreDetailsControllerViewController : ViewController
@property (strong, nonatomic) UIImageView* imageView;
@property (strong, nonatomic) NSString* picIndex;
@property (strong, nonatomic) UIImage* image;
@end

NS_ASSUME_NONNULL_END
