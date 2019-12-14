//
//  OpenCVBridge.h
//  LookinLive
//
//  Created by Eric Larson on 8/27/15.
//  Copyright (c) 2015 Eric Larson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>
#import "AVFoundation/AVFoundation.h"
#import <Accelerate/Accelerate.h>
#import <AudioToolbox/AudioToolbox.h>
#import "PrefixHeader.pch"

@interface OpenCVBridge : NSObject

@property (nonatomic) NSInteger processType;
@property (nonatomic) bool isFull; //check if array is true
@property (nonatomic) int bufferSizeVar;  // need to var to be used in modual B view
@property (nonatomic) bool needReset;   // check if we need to reset the plot
// set the image for processing later
-(void) setImage:(CIImage*)ciFrameImage
      withBounds:(CGRect)rect
      andContext:(CIContext*)context;

//get the image raw opencv
-(CIImage*)getImage;

//get the image inside the original bounds
-(CIImage*)getImageComposite;

// call this to perfrom processing (user controlled for better transparency)
-(void)processImage;
// call this to processing heart rate
-(void)processHeartRate;


// for the video manager transformations
-(void)setTransforms:(CGAffineTransform)trans;

-(void)loadHaarCascadeWithFilename:(NSString*)filename;

-(void)addText:(NSString *)infoText atY:(int)y;

-(float*)returnHeartData;

-(int)calculatedHeartRateFrom:(float *)REDArray Withlenth:(int)arrLength withWindowSize:(int)windowSize;

@end
