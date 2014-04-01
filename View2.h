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


@property double pastMean;
@property double currMean;
@property (nonatomic, strong) NSMutableArray* raw_RunningMeanPrep; //this is to hold 130 results for raw data - running mean
@property (nonatomic,strong) NSMutableArray* Raw_RunningMean; //data of raw - running mean


@property NSMutableArray* peripheralList;

@property (retain, nonatomic) E20SensorInfo* sensorInfoData;  //stores all the filtered and manipulated data

@property int counterScanning;

-(IBAction)CoordinatesGetter:(id)sender;
-(IBAction)CoordinatesStopper:(id)sender;

@end
