//
//  E20BLESensorData.m
//  First-try
//
//  Created by E-Twenty Janahan on 4/22/14.
//  Copyright (c) 2014 E-Twenty Dev. All rights reserved.
//

#import "E20BLESensorData.h"
#include <math.h>
#include <vector>

@implementation E20BLESensorData

@synthesize BLESignalRaw_dict;
@synthesize BLESignalFilter_dict;
@synthesize BLESecondIntegralPrep;

-(id) init
{
    self = [super init];
    if(self){
        BLESignalRaw_dict = [[NSMutableDictionary alloc] init];
        BLESignalFilter_dict = [[NSMutableDictionary alloc] init];
        BLESecondIntegralPrep = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

+ (void)set1dRawAndFilteredValueWithInput:(NSMutableArray *) sensorHistory withFilterParam:(NSArray*) filterParam forRawDictionary:(NSMutableDictionary *) Raw_dict filterDictionary:(NSMutableDictionary *) Filter_dict keyName: (NSString *) key{
    int filterLength=[[filterParam objectAtIndex:0] intValue];
    double samplingFreq = [[filterParam objectAtIndex:3] doubleValue];
    double firstFreqCutoff = [[filterParam objectAtIndex:1] doubleValue];
    double secondFreqCutoff = [[filterParam objectAtIndex:2] doubleValue];
    double* weights=new double[filterLength];
    int M = filterLength-1;
    double ft1 = firstFreqCutoff/samplingFreq;
    double ft2 = secondFreqCutoff/samplingFreq;
    for (int i=0; i<filterLength; i++) {
        if(i!=M/2){
            weights[i]= sin(2*M_PI*ft2*(i-M/2))/(M_PI*(i-M/2))-sin(2*M_PI*ft1*(i-M/2))/(M_PI*(i-M/2));
        }
        else{
            weights[i] =  2*(ft2-ft1);
        }
        weights[i] = weights[i]*(0.54 - 0.46*cos(2*M_PI*i/M));
    }
    
    double outputSignal = 0;
    for (int i=0; i<[sensorHistory count]; i++) {
        E201dDataPoint* dataPoint = [sensorHistory objectAtIndex:i];
        outputSignal += dataPoint.value*weights[i];
    }
    E201dDataPoint* sourcePoint = [sensorHistory objectAtIndex:M/2];
    E201dDataPoint* rawPoint = [E201dDataPoint copyDataPoint:sourcePoint];
    NSMutableArray* rawData = [[NSMutableArray alloc] init];
    NSMutableArray* filteredData = [[NSMutableArray alloc] init];
    if ([Raw_dict objectForKey:key] != Nil && [Filter_dict objectForKey:key] != Nil) {
        rawData = [Raw_dict objectForKey:key];
        filteredData = [Filter_dict objectForKey:key];
        [rawData addObject:rawPoint];
        if([rawData count] > maxBLESensorDataStored){
            [rawData removeObjectAtIndex:0];
        }
        E201dDataPoint* filteredPoint = [E201dDataPoint dataPointFromDouble:outputSignal];
        //careful not setting timeStamp for filteredData...could be useful later on
        [filteredData addObject:filteredPoint];
        if([filteredData count] > maxBLESensorDataStored){
            [filteredData removeObjectAtIndex:0];
        }
        [Raw_dict setObject:rawData forKey:key];
        [Filter_dict setObject:filteredData forKey:key];
    }
    else{
        [rawData addObject:rawPoint];
        E201dDataPoint* filteredPoint = [E201dDataPoint dataPointFromDouble:outputSignal];
        //careful not setting timeStamp for filteredData...could be useful later on
        [filteredData addObject:filteredPoint];
        [Raw_dict setObject:rawData forKey:key];
        [Filter_dict setObject:filteredData forKey:key];
    }
}


+ (NSString *)bleDistanceDetectionWithFilteredDictionary:(NSMutableDictionary *) filterDict forKey: (NSString *) key{
    NSMutableArray* oneDevice = [filterDict objectForKey:key];
    E201dDataPoint* oneData = [oneDevice lastObject];
    NSLog(@"%f",oneData.value);
    if (oneData.value > -2.3) {
        return key;
    }
    else{
        return Nil;
    }
}

@end
