//
//  popUpViewController.h
//  SMUExampleOne
//
//  Created by Xingming on 9/11/19.
//  Copyright © 2019 Eric Larson. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol popUpViewControllerDelegate <NSObject>

-(void) sendZipBack:(NSString *)message;

@end

@interface popUpViewController : UIViewController
@property (nonatomic,weak) id <popUpViewControllerDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
