//
//  E201dDataPoint.h
//  InertialInternal
//
//  Created by E-Twenty Janahan on 11/4/13.
//  Copyright (c) 2013 E-Twenty Dev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface E201dDataPoint : NSObject
@property    double value;
@property    NSTimeInterval timeStamp;
@property    int phoneOrientation; //how is the phone oriented wrt gravity eg. z-up or y-up or...
                                    //0 +/-x up, 1 +/-y up, 2 +/-z up


+(E201dDataPoint*) dataPointFromDouble:(double) value;
+(E201dDataPoint*) copyDataPoint:(E201dDataPoint *) sourcePoint;
-(double) getValue;


@end
