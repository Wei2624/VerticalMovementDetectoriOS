//
//  E201dDataPoint.m
//  InertialInternal
//
//  Created by E-Twenty Janahan on 11/4/13.
//  Copyright (c) 2013 E-Twenty Dev. All rights reserved.
//

#import "E201dDataPoint.h"

@implementation E201dDataPoint


-(id) init
{
    self = [super init];
    if(self){
        self.timeStamp = -1; //default value if not set
        self.phoneOrientation = -1; //default value if not set
    }
    
    return self;
}

+(E201dDataPoint*) dataPointFromDouble:(double) value{
    E201dDataPoint* dataPoint = [[E201dDataPoint alloc] init];
    dataPoint.value = value;

    
    return dataPoint;
    
}

+(E201dDataPoint*) copyDataPoint:(E201dDataPoint *) sourcePoint{
    E201dDataPoint* dataPoint = [[E201dDataPoint alloc] init];
    dataPoint.value = sourcePoint.value;
    if (sourcePoint.timeStamp != -1){
        dataPoint.timeStamp=sourcePoint.timeStamp;
    }
    dataPoint.phoneOrientation = sourcePoint.phoneOrientation;
    return dataPoint;
}

-(double) getValue{
    return [self value];
}



@end
