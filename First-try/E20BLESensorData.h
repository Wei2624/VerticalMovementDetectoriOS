//
//  E20BLESensorData.h
//  First-try
//
//  Created by E-Twenty Janahan on 4/22/14.
//  Copyright (c) 2014 E-Twenty Dev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "E203dDataPoint.h"
#import "E201dDataPoint.h"


# define maxBLESensorDataStored 6
# define filterLengthOfBLE 10

@interface E20BLESensorData : NSObject

@property (retain, nonatomic) NSMutableDictionary* BLESignalRaw_dict;
@property (retain, nonatomic) NSMutableDictionary* BLESignalFilter_dict;
@property (retain, nonatomic) NSMutableDictionary* BLESecondIntegralPrep;


+ (void)set1dRawAndFilteredValueWithInput:(NSMutableArray *) sensorHistory withFilterParam:(NSArray*) filterParam forRawDictionary:(NSMutableDictionary *) Raw_dict filterDictionary:(NSMutableDictionary *) Filter_dict keyName: (NSString *) key;
+ (NSString *)bleDistanceDetectionWithFilteredDictionary:(NSMutableDictionary *) filterDict forKey: (NSString *) key;

@end
