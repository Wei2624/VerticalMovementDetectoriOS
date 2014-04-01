//
//  E20SensorInfo.m
//  InertialInternal
//
//  Created by E-Twenty Janahan on 11/3/13.
//  Copyright (c) 2013 E-Twenty Dev. All rights reserved.
//


#import "E20SensorInfo.h"
#include <math.h>
#include <vector>


#define _USE_MATH_DEFINES


@implementation E20SensorInfo
@synthesize  gyroRaw;
@synthesize  gyroFiltered;
@synthesize  gravRaw;
@synthesize  gravFiltered;
@synthesize  accelRaw;
@synthesize  accelFiltered;
@synthesize gyroPlanarizedRaw;
@synthesize gyroPlanarizedFiltered;
@synthesize gyroWhittaker;
@synthesize accelKeySensorRaw;
@synthesize accelKeySensorFiltered;
@synthesize accelForHorizontalRaw;
@synthesize accelForHoriontalFiltered;

-(id) init
{
    self = [super init];
    if(self){
        gyroRaw = [[NSMutableArray alloc] init];
        gyroFiltered = [[NSMutableArray alloc] init];
        gravRaw = [[NSMutableArray alloc] init];
        gravFiltered = [[NSMutableArray alloc] init];
        accelRaw = [[NSMutableArray alloc] init];
        accelFiltered = [[NSMutableArray alloc] init];
        gyroPlanarizedRaw = [[NSMutableArray alloc] init];
        gyroPlanarizedFiltered = [[NSMutableArray alloc] init];
        gyroWhittaker = [[NSMutableArray alloc] init];
        accelKeySensorRaw = [[NSMutableArray alloc] init];
        accelKeySensorFiltered = [[NSMutableArray alloc] init];
        accelForHorizontalRaw = [[NSMutableArray alloc] init];
        accelForHoriontalFiltered = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (void)set3dRawAndFilteredValueWithInput:(NSMutableArray *) sensorHistory withFilterParam:(NSArray*) filterParam forRawData:(NSMutableArray *) rawData forFilteredData:(NSMutableArray *) filteredData
{
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
    
    double outputSignal[3] = {0};
    for (int i=0; i<[sensorHistory count]; i++) {
        E203dDataPoint* dataPoint = [sensorHistory objectAtIndex:i];
        outputSignal[0] += dataPoint.x*weights[i];
        outputSignal[1] += dataPoint.y*weights[i];
        outputSignal[2] += dataPoint.z*weights[i];
        
    }
    E203dDataPoint* sourcePoint = [sensorHistory objectAtIndex:M/2];
    E203dDataPoint* rawPoint = [E203dDataPoint copyDataPoint:sourcePoint];
    [rawData addObject:rawPoint];
    if([rawData count]>maxSensorHistoryStored){
        [rawData removeObjectAtIndex:0];
    }
    E203dDataPoint* filteredPoint = [E203dDataPoint dataPointFromDouble:outputSignal];
    [filteredData addObject:filteredPoint];
    if([filteredData count]>maxSensorHistoryStored){
        [filteredData removeObjectAtIndex:0];
    }
    
}

+ (void)set1dRawAndFilteredValueWithInput:(NSMutableArray *) sensorHistory withFilterParam:(NSArray*) filterParam forRawData:(NSMutableArray *) rawData forFilteredData:(NSMutableArray *) filteredData
{

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
    [rawData addObject:rawPoint];
    if([rawData count]>maxSensorHistoryStored){
        [rawData removeObjectAtIndex:0];
    }
    E201dDataPoint* filteredPoint = [E201dDataPoint dataPointFromDouble:outputSignal];
    //careful not setting timeStamp for filteredData...could be useful later on
    [filteredData addObject:filteredPoint];
    if([filteredData count]>maxSensorHistoryStored){
        [filteredData removeObjectAtIndex:0];
    }
    
}

+ (E201dDataPoint*)getGyroPlanarizedForGrav: (NSMutableArray *) gravHistory ForGyro: (NSMutableArray *) gyroHistory{
    /*explained in header file*/
    E203dDataPoint* axis = [gravHistory objectAtIndex:[gravHistory count]-1];
    [axis normalizeDataPoint];
    E203dDataPoint* gyroPoint = [gyroHistory objectAtIndex:[gyroHistory count]-1];
    double gyroPlanarized = [gyroPoint dotProductWith:axis]*gyroPoint.timeStamp;
    E201dDataPoint* gyroPlanarizedPoint = [E201dDataPoint dataPointFromDouble:gyroPlanarized];
    gyroPlanarizedPoint.timeStamp = gyroPoint.timeStamp;
    gyroPlanarizedPoint.phoneOrientation = [E20SensorInfo getPhoneOrientationWithRespectToGravity:gravHistory];
    return gyroPlanarizedPoint;

}

+ (E201dDataPoint*)getAccelPlanarizedForGrav: (NSMutableArray *) gravHistory ForAccel: (NSMutableArray *) accelHistory{
    E203dDataPoint* axis = [gravHistory objectAtIndex:[gravHistory count]-1];
    [axis normalizeDataPoint];
    [axis normalizeDataPoint];
    E203dDataPoint* accelPoint = [accelHistory objectAtIndex:[accelHistory count]-1];
    double projection = [accelPoint dotProductWith:axis];
    E201dDataPoint *dataPoint = [[E201dDataPoint alloc] init];
    dataPoint.value = -projection;
    //E203dDataPoint* accelPlanarized = [accelPoint addByDataPoint:[axis multiplyByScalar:-projection]];
    
    //return [accelPlanarized convert3Dto1DByTakingMagnitude];
    return dataPoint;

}

+ (E201dDataPoint*) getAccelPlanarizedForHorizontal:(NSMutableArray *)gravHistory ForAccel:(NSMutableArray *)accelHistory{
    E203dDataPoint* grav = [gravHistory objectAtIndex:[gravHistory count]-1];
    E203dDataPoint* axis = [[E203dDataPoint alloc] init];
    axis.x = -grav.z;
    axis.y = grav.y;
    axis.z = grav.x;
    [axis normalizeDataPoint];
    [axis normalizeDataPoint];
    E203dDataPoint* accelPoint = [accelHistory objectAtIndex:[accelHistory count]-1];
    double projection = [accelPoint dotProductWith:axis];
    E201dDataPoint *dataPoint = [[E201dDataPoint alloc] init];
    dataPoint.value = projection;
    //E203dDataPoint* accelPlanarized = [accelPoint addByDataPoint:[axis multiplyByScalar:-projection]];
    
    //return [accelPlanarized convert3Dto1DByTakingMagnitude];
    return dataPoint;
}

+(int) getPhoneOrientationWithRespectToGravity:(NSMutableArray*) gravHistory{
    /*explained in header file*/
    E203dDataPoint* dataPoint = [gravHistory objectAtIndex:[gravHistory count]-1];
    int orientation = [E203dDataPoint indexOfMaxAbsValueOfDataPoint:dataPoint];
    return orientation;
}


@end
