//
//  E20SensorInfo.h
//  InertialInternal
//
//  Created by E-Twenty Janahan on 11/3/13.
//  Copyright (c) 2013 E-Twenty Dev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "E203dDataPoint.h"
#import "E201dDataPoint.h"



#define maxSensorHistoryStored 131
#define maxPastStepDataStored 110;

@interface E20SensorInfo : NSObject

@property (retain,nonatomic) NSMutableArray* gyroRaw;
@property (retain,nonatomic) NSMutableArray* gyroFiltered;
@property (retain,nonatomic) NSMutableArray* gyroPlanarizedRaw; //taking the gyro magnitude in the direction of gravity
@property (retain,nonatomic) NSMutableArray* gyroPlanarizedFiltered; 
@property (retain,nonatomic) NSMutableArray* gyroWhittaker;  //passing the gyroPlanarized through whittaker bias removal
@property (retain,nonatomic) NSMutableArray* gravRaw;
@property (retain,nonatomic) NSMutableArray* gravFiltered;

@property (retain,nonatomic) NSMutableArray* accelRaw;
@property (retain,nonatomic) NSMutableArray* accelFiltered;
@property (retain,nonatomic) NSMutableArray* accelKeySensorRaw;
@property (retain,nonatomic) NSMutableArray* accelKeySensorFiltered;

@property (retain, nonatomic) NSMutableArray* accelForHorizontalRaw;
@property (retain, nonatomic) NSMutableArray* accelForHoriontalFiltered;

+ (void)set3dRawAndFilteredValueWithInput:(NSMutableArray *) sensorHistory withFilterParam:(NSArray*) filterParam forRawData:(NSMutableArray *) rawData forFilteredData:(NSMutableArray *) filteredData; //sycnhronizing raw and filtered values for 3d datapoints

+ (void)set1dRawAndFilteredValueWithInput:(NSMutableArray *) sensorHistory withFilterParam:(NSArray*) filterParam forRawData:(NSMutableArray *) rawData forFilteredData:(NSMutableArray *) filteredData; //sycnhronizing raw and filtered values for 1d datapoints

+ (E201dDataPoint*)getGyroPlanarizedForGrav: (NSMutableArray *) gravHistory ForGyro: (NSMutableArray *) gyroHistory; //returns a 1dDataPoint
                //using the last gyro and gravity measurements

+ (E201dDataPoint*)getAccelPlanarizedForGrav: (NSMutableArray *) gravHistory ForAccel: (NSMutableArray *) accelHistory; //returns a 1dDataPoint
//using the last accel and gravity measurements representing the magnitude of accel in the plane

+ (E201dDataPoint*)getAccelPlanarizedForHorizontal: (NSMutableArray *) gravHistory ForAccel: (NSMutableArray *) accelHistory;


+(int) getPhoneOrientationWithRespectToGravity:(NSMutableArray*) gravHistory;




@end
