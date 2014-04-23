//
//  View2.h
//  First-try
//
//  Created by E-Twenty Janahan on 1/6/14.
//  Copyright (c) 2014 E-Twenty Dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "E20SensorInfo.h"
#import "E203dDataPoint.h"
#import "E201dDataPoint.h"
#import "E20BLESensorData.h"

@interface View2 : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    IBOutlet UITextField *X_Acceleration;
    IBOutlet UITextField *Y_Acceleration;
    IBOutlet UITextField *Z_Acceleration;
    IBOutlet UITextField *X_Gravity;
    IBOutlet UITextField *Y_Gravity;
    IBOutlet UITextField *Z_Gravity;
    IBOutlet UITextField *X_Gyro;
    IBOutlet UITextField *Y_Gyro;
    IBOutlet UITextField *Z_Gyro;
    IBOutlet UITextField *state;
    //IBOutlet UITableView *table;
}
@property IBOutlet UITableView* table;

@property (nonatomic, strong) CMMotionManager *motionManager;
@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) CBPeripheral *discoveredPeripheral;
@property (nonatomic,strong) NSMutableString *text;
@property (nonatomic,strong) NSMutableArray* gravHistory;
@property (nonatomic,strong) NSMutableArray* accelHistory;
@property (nonatomic,strong) NSMutableArray* gyroHistory;
@property (nonatomic, strong) NSMutableArray* gyroPlanarizedHistory;
@property (nonatomic,strong) NSMutableArray* keySensorInfo;  //stores the accel info dot producted with gravity
@property (nonatomic, strong) NSMutableArray* secondIntegral;
@property (nonatomic,strong) NSMutableArray* horizontalAccel;

@property (nonatomic,strong) NSMutableArray* avgThresPrep; //to get the average value of 50-250 after second integral
@property int numberOfSecondIntegral;         //count of integral. data will be selected between 50 and 250
@property double avgThres;
@property double avgWeight;

@property double avgThres_flat;
@property double avgThres_tilt;
@property double avgThres_sided;
@property double avgWeight_flat;
@property double avgWeight_tilt;
@property double avgWeight_sided;


@property double pastMean;
@property double currMean;
@property (nonatomic, strong) NSMutableArray* raw_RunningMeanPrep; //this is to hold 130 results for raw data - running mean
@property (nonatomic,strong) NSMutableArray* Raw_RunningMean; //data of raw - running mean


@property int meter_counter;
@property NSMutableString* BLEsig;
@property NSMutableDictionary* BLE_List;//this will store the string including name and signal strength
@property NSDate* BLE_prevTime;
@property NSDate* BLE_currTime;
@property NSMutableDictionary* BLESig_List; //This stores signal strenght. Each object is an array containing E201d data point.
@property NSMutableDictionary* BLEinRangeDeviceList;


@property NSMutableArray* peripheralList;

@property (retain, nonatomic) E20SensorInfo* sensorInfoData;  //stores all the filtered and manipulated data
@property (retain, nonatomic) E20BLESensorData* BLEsensorData;

@property int counterScanning;

-(IBAction)CoordinatesGetter:(id)sender;
-(IBAction)CoordinatesStopper:(id)sender;

-(IBAction)MeterResponder_0M:(id)sender;
-(IBAction)MeterResponder_1M:(id)sender;
-(IBAction)MeterResponder_2M:(id)sender;
-(IBAction)MeterResponder_3M:(id)sender;
-(IBAction)MeterResponder_4M:(id)sender;
-(IBAction)MeterResponder_5M:(id)sender;
-(IBAction)MeterResponder_6M:(id)sender;
-(IBAction)MeterResponder_7M:(id)sender;
-(IBAction)MeterResponder_8M:(id)sender;
-(IBAction)MeterResponder_9M:(id)sender;
-(IBAction)MeterResponder_10M:(id)sender;
@end
