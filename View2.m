//
//  View2.m
//  First-try
//
//  Created by E-Twenty Janahan on 1/6/14.
//  Copyright (c) 2014 E-Twenty Dev. All rights reserved.
//

#import "View2.h"
#import <CoreMotion/CoreMotion.h>

@interface View2 ()

@end

@implementation View2

# define filterLength 51
# define samplingFreq 51
# define secondIntegralInterval 70
# define upperBoundOfRaw_RunningMean 0.045
# define lowerBoundOfRaw_RunningMean -0.045

@synthesize motionManager,text;
@synthesize gravHistory;
@synthesize accelHistory;
@synthesize gyroHistory;
@synthesize sensorInfoData;
@synthesize keySensorInfo;
@synthesize secondIntegral;
@synthesize horizontalAccel;
@synthesize gyroPlanarizedHistory;
@synthesize table;

@synthesize numberOfSecondIntegral;
@synthesize avgThres;
@synthesize avgThresPrep;
@synthesize avgWeight;

@synthesize pastMean;
@synthesize currMean;
@synthesize raw_RunningMeanPrep;
@synthesize Raw_RunningMean;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)startMyMotionDetect
{
    self.motionManager.deviceMotionUpdateInterval = 1/((double)(100))/((double)(1));
    [self.motionManager
     startDeviceMotionUpdatesToQueue:[[NSOperationQueue alloc] init]
     withHandler:^(CMDeviceMotion *data, NSError *error)
     {
         
         dispatch_async(dispatch_get_main_queue(),
                        ^{
                            X_Gravity.text = [NSString stringWithFormat:@"%.2f", data.gravity.x];
                            Y_Gravity.text = [NSString stringWithFormat:@"%.2f", data.gravity.y];
                            Z_Gravity.text = [NSString stringWithFormat:@"%.2f", data.gravity.z];
                            
                            NSArray *filterParam = [NSArray arrayWithObjects:
                                                    [NSNumber numberWithInteger:filterLength],
                                                    [NSNumber numberWithDouble:0.05],
                                                    [NSNumber numberWithDouble:0.06],
                                                    [NSNumber numberWithDouble:samplingFreq],nil];
                            
                            NSArray *filterParamGyro = [NSArray arrayWithObjects:
                                                        [NSNumber numberWithInteger:filterLength],
                                                        [NSNumber numberWithDouble:0.466222],
                                                        [NSNumber numberWithDouble:0.684419],
                                                        [NSNumber numberWithDouble:samplingFreq],nil];
                            
                            E203dDataPoint *dataPoint = [[E203dDataPoint alloc] init];
                            dataPoint.x = data.gravity.x;
                            dataPoint.y = data.gravity.y;
                            dataPoint.z = data.gravity.z;
                            [self.gravHistory addObject:dataPoint];
                            if([accelHistory count]>1){
                                //planarize the accel vector in the direction of grav
                                //using same function that planarizes gyro omega parallel to grav
                                E201dDataPoint* keySensorPoint = [E20SensorInfo getAccelPlanarizedForGrav:gravHistory ForAccel:accelHistory];
                                [keySensorInfo addObject:keySensorPoint];
                                if([keySensorInfo count]>filterLength){
                                    [keySensorInfo removeObjectAtIndex:0];
                                }
                                E201dDataPoint *z_data = [E201dDataPoint dataPointFromDouble:keySensorPoint.value];
                                [self.raw_RunningMeanPrep addObject:z_data];
                                
                                E201dDataPoint* accelForHorizon = [E20SensorInfo getAccelPlanarizedForHorizontal:gravHistory ForAccel:accelHistory];
                                [horizontalAccel addObject:accelForHorizon];
                                if ([horizontalAccel count] > filterLength) {
                                    [horizontalAccel removeObjectAtIndex:0];
                                }
                            }
                            if ([self.raw_RunningMeanPrep count] >= 130) {    //for walking and standing
                                double sumForMean = 0;
                                for (int j =0; j < [self.raw_RunningMeanPrep count]; j++) {
                                    E201dDataPoint *oneRawData = [self.raw_RunningMeanPrep objectAtIndex:j];
                                    sumForMean += oneRawData.value;
                                }
                                double temp_mean = sumForMean/[self.raw_RunningMeanPrep count];
                                double weight = [self.Raw_RunningMean count];
                                currMean = (pastMean*weight + temp_mean)/(weight + 1);
                                pastMean = currMean;
                                E201dDataPoint* raw = [self.raw_RunningMeanPrep objectAtIndex:0];
                                double raw_mean = raw.value - currMean;
                                E201dDataPoint* datapoint = [E201dDataPoint dataPointFromDouble:raw_mean];
                                [Raw_RunningMean addObject:datapoint];
                                [raw_RunningMeanPrep removeObjectAtIndex:0];
                            }
                            if([gravHistory count] > filterLength){
                                [gravHistory removeObjectAtIndex:0];
                                if([gyroHistory count] >= filterLength && [accelHistory count] >= filterLength && [keySensorInfo count]>=filterLength){
                                    //check if it's ok to start filtering signals, as I'd like all of them to be synchronized with enough
                                    //data points
                                    [E20SensorInfo set3dRawAndFilteredValueWithInput:gravHistory withFilterParam:filterParam forRawData:sensorInfoData.gravRaw forFilteredData:sensorInfoData.gravFiltered];
                                    
                                    [E20SensorInfo set3dRawAndFilteredValueWithInput:gyroHistory withFilterParam:filterParam forRawData:sensorInfoData.gyroRaw forFilteredData:sensorInfoData.gyroFiltered];
                                    
                                    [E20SensorInfo set3dRawAndFilteredValueWithInput:accelHistory withFilterParam:filterParam forRawData:sensorInfoData.accelRaw forFilteredData:sensorInfoData.accelFiltered];
                                    
                                    [E20SensorInfo set1dRawAndFilteredValueWithInput:self.gyroPlanarizedHistory withFilterParam:filterParamGyro forRawData:sensorInfoData.gyroPlanarizedRaw forFilteredData:sensorInfoData.gyroPlanarizedFiltered];
                                    
                                    [E20SensorInfo set1dRawAndFilteredValueWithInput:keySensorInfo withFilterParam:filterParam forRawData:sensorInfoData.accelKeySensorRaw forFilteredData:sensorInfoData.accelKeySensorFiltered];
                                    
                                    [E20SensorInfo set1dRawAndFilteredValueWithInput:horizontalAccel withFilterParam:filterParam forRawData:sensorInfoData.accelForHorizontalRaw forFilteredData:sensorInfoData.accelForHoriontalFiltered];
                                    if ([[sensorInfoData accelKeySensorFiltered] count] >= maxSensorHistoryStored) {
                                        double sum = 0;
                                        for (int i = 0; i<[[sensorInfoData accelKeySensorFiltered] count]; i++) {
                                            E201dDataPoint *filteredpoint =[[sensorInfoData accelKeySensorFiltered] objectAtIndex:i];
                                            sum += filteredpoint.value;
                                        }
                                        //NSLog(@"first sum:%f",sum);
                                        E201dDataPoint *integral = [E201dDataPoint dataPointFromDouble:sum];
                                        [secondIntegral addObject:integral];
                                        if ([secondIntegral count] >= secondIntegralInterval) {
                                            double secondSum = 0;
                                            for (int i = 0; i<[secondIntegral count]; i++) {
                                                E201dDataPoint *firstIntegral = [secondIntegral objectAtIndex:i];
                                                secondSum += firstIntegral.value;
                                            }
//                                            self.numberOfSecondIntegral++;
//                                            if (self.numberOfSecondIntegral > 49 && self.numberOfSecondIntegral <= 249) {
//                                                E201dDataPoint* avg = [E201dDataPoint dataPointFromDouble:secondSum];
//                                                [avgThresPrep addObject:avg];
//                                                if ([avgThresPrep count] == 200) {
//                                                    double total = 0;
//                                                    for (int i = 0; i < [avgThresPrep count]; i++) {
//                                                        E201dDataPoint *one = [avgThresPrep objectAtIndex:i];
//                                                        total += one.value;
//                                                        avgWeight = 200;
//                                                    }
//                                                    self.avgThres = total/200;
//                                                }
//                                            }
                                            if (self.avgThres != 0) {        //when the avg is ready
                                                double centralizedData = secondSum - self.avgThres;
                                                if (centralizedData < -0.8) {
                                                    state.text = @"Accelerating";
                                                }
                                                else if (centralizedData > 0.9){
                                                    state.text = @"Decelerating";
                                                }
                                                else{
                                                    avgThres = avgThres*(avgWeight/(avgWeight + 1)) + secondSum/(avgWeight + 1);
                                                    avgWeight++;
                                                    double check_counter = 0;
                                                    if ([Raw_RunningMean count] >= 70) {
                                                        for (int i = 0; i < 70; i++) {
                                                            E201dDataPoint* one = [Raw_RunningMean objectAtIndex:[Raw_RunningMean count] - i - 1];
                                                            if (one.value < 0.04 && one.value > -0.05) {
                                                                check_counter++;
                                                            }
                                                        }
                                                        if (check_counter > 63) {
                                                            state.text = @"Standing";
                                                        }
                                                        else{
                                                            state.text = @"Walking";
                                                        }
                                                    }
                                                    else{
                                                        for (int i = 0; i < [Raw_RunningMean count]; i++) {
                                                            E201dDataPoint* one = [Raw_RunningMean objectAtIndex:i];
                                                            if (one.value < 0.04 && one.value > -0.05) {
                                                                check_counter++;
                                                            }
                                                        }
                                                        if (check_counter/[Raw_RunningMean count] > 0.9) {
                                                            state.text = @"Standing";
                                                        }
                                                        else{
                                                            state.text = @"Walking";
                                                        }
                                                    }
                                                }
                                            }
                                            else{                          //when the avg is not ready
                                                //NSLog(@"second sum:%f",secondSum);
                                                //E201dDataPoint* gyroPlanarizedRawPoint = [sensorInfoData.gyroPlanarizedRaw objectAtIndex:0];
                                                //NSLog(@"Second Sum: %f",secondSum);
                                                double max = 0;
                                                double min = 0;
                                                for (int i = 0; i < 50; i++) {
                                                    E201dDataPoint* oneData = [Raw_RunningMean objectAtIndex:[Raw_RunningMean count] - i - 1];
                                                    double dataValue = oneData.value;
                                                    if (dataValue > max) {
                                                        max = dataValue;
                                                    }
                                                    if (dataValue < min) {
                                                        min = dataValue;
                                                    }
                                                }
                                                if ((max > upperBoundOfRaw_RunningMean) && (min < lowerBoundOfRaw_RunningMean)) {
                                                    //avgThres value update
                                                    avgThres = avgThres*(avgWeight/(avgWeight + 1)) + secondSum/(avgWeight + 1);
                                                    avgWeight++;
                                                    avgWeight++;
                                                    state.text = @"Standing";
                                                }
                                                else if ((min < lowerBoundOfRaw_RunningMean) && (max < upperBoundOfRaw_RunningMean)){
                                                    state.text = @"Accelerating";
                                                }
                                                else if ((max > upperBoundOfRaw_RunningMean) && (min > lowerBoundOfRaw_RunningMean)){
                                                    state.text = @"Decelerating";
                                                }
                                                else{
                                                    avgThres = avgThres*(avgWeight/(avgWeight + 1)) + secondSum/(avgWeight + 1);
                                                    avgWeight++;
                                                    state.text = @"Walking";
                                                }
                                                
//                                                E201dDataPoint* gyroPlanarizedRawPoint = [sensorInfoData.gyroPlanarizedRaw objectAtIndex:0];
//                                                int phoneOrientation = gyroPlanarizedRawPoint.phoneOrientation;
//                                                if (phoneOrientation == 0) {
//                                                    if (secondSum > -97.00) {
//                                                        state.text = @"Decelerating";
//                                                    }
//                                                    else if (secondSum < -99.50){
//                                                        state.text = @"Accelerating";
//                                                    }
//                                                    else{
//                                                        state.text = @"Walking";
//                                                    }
//                                                    NSLog(@"sided");
//                                                }   //sided phone
//                                                else{
//                                                    //NSLog(@"%d",phoneOrientation);
//                                                    if (secondSum > -95.70) {
//                                                        state.text = @"Decelerating";
//                                                    }
//                                                    else if (secondSum < -97.90){
//                                                        state.text = @"Accelerating";
//                                                    }
//                                                    else{
//                                                        int check_counter = 0;
//                                                        for (int i = 0; i < [Raw_RunningMean count]; i++) {
//                                                            E201dDataPoint* one = [Raw_RunningMean objectAtIndex:i];
//                                                            if (one.value < 0.04 && one.value > -0.05) {
//                                                                check_counter++;
//                                                            }
//                                                        }
//                                                        if (check_counter > 63) {
//                                                            state.text = @"Standing";
//                                                        }
//                                                        else{
//                                                            state.text = @"Walking";
//                                                        }
//                                                        if ([Raw_RunningMean count] >= 70) {
//                                                            [Raw_RunningMean removeObjectAtIndex:0];
//                                                        }
//                                                    }
//                                                }

                                            }
                                            [secondIntegral removeObjectAtIndex:0];
                                            //NSLog(@"Number of data: %lu",(unsigned long)[[sensorInfoData accelKeySensorFiltered] count]);
                                        }
                                        else{
                                            double max = 0;
                                            double min = 0;
                                            for (int i = 0; i < 50; i++) {
                                                E201dDataPoint* oneData = [Raw_RunningMean objectAtIndex:[Raw_RunningMean count] - i - 1];
                                                double dataValue = oneData.value;
                                                if (dataValue > max) {
                                                    max = dataValue;
                                                }
                                                if (dataValue < min) {
                                                    min = dataValue;
                                                }
                                            }
                                            if ((max > upperBoundOfRaw_RunningMean) && (min < lowerBoundOfRaw_RunningMean)) {
                                                state.text = @"Walking";
                                            }
                                            else if ((min < lowerBoundOfRaw_RunningMean) && (max < upperBoundOfRaw_RunningMean)){
                                                state.text = @"Accelerating";
                                            }
                                            else if ((max > upperBoundOfRaw_RunningMean) && (min > lowerBoundOfRaw_RunningMean)){
                                                state.text = @"Decelerating";
                                            }
                                        }
                                    }
                                }
                                
                                
                            }
                            
                            static NSTimeInterval prevTime; //holds the timestamp of the last sensor interrupt
                            static dispatch_once_t once;
                            
                            dispatch_once(&once, ^{
                                prevTime = data.timestamp;
                                
                            });
                            NSTimeInterval currTime = data.timestamp;
                            NSTimeInterval deltaT = currTime-prevTime; //time elapsed since last sensor interrupt
                            //NSLog(@"Time: %f", deltaT);
                            if([self.gravHistory count] > 0 && [self.accelHistory count] > 0 && [self.gyroHistory count] > 0)
                            {
                                E203dDataPoint *lastGrav = [self.gravHistory objectAtIndex:[self.gravHistory count]-1];
                                E203dDataPoint *lastAccel = [self.accelHistory objectAtIndex:[self.accelHistory count]-1];
                                E203dDataPoint *lastGyro = [self.gyroHistory objectAtIndex:[self.gyroHistory count]-1];
                                
                                [self.text appendFormat:@"\n%f,%1.2f,%1.2f,%1.2f,%1.2f,%1.2f,%1.2f,%1.2f,%1.2f,%1.2f",deltaT,lastGyro.x,lastGyro.y,lastGyro.z,lastGrav.x,lastGrav.y,lastGrav.z,lastAccel.x,lastAccel.y,lastAccel.z];
                            
                            }
                            
                            //NSLog(@"Time: %f", deltaT);
                            prevTime = currTime;
                            
                        }
                        );
     }
     ];
    
    self.motionManager.gyroUpdateInterval = 1/150.0f;
    [self.motionManager
     startGyroUpdatesToQueue:[[NSOperationQueue alloc] init]
     withHandler:^(CMGyroData *data, NSError *error)
     {
         
         dispatch_async(dispatch_get_main_queue(),
                        ^{
                            X_Gyro.text = [NSString stringWithFormat:@"%.2f", data.rotationRate.x];
                            Y_Gyro.text = [NSString stringWithFormat:@"%.2f", data.rotationRate.y];
                            Z_Gyro.text = [NSString stringWithFormat:@"%.2f", data.rotationRate.z];
                            E203dDataPoint *dataPoint = [[E203dDataPoint alloc] init];
                            dataPoint.x = data.rotationRate.x;
                            dataPoint.y = data.rotationRate.y;
                            dataPoint.z = data.rotationRate.z;
                            [self.gyroHistory addObject:dataPoint];
                            if([self.gravHistory count] >0){
                                E201dDataPoint *gyroPlanarizedPoint = [E20SensorInfo getGyroPlanarizedForGrav:self.gravHistory ForGyro:self.gyroHistory];
                                [self.gyroPlanarizedHistory addObject:gyroPlanarizedPoint];
                                if([self.gyroPlanarizedHistory count]>filterLength){
                                    [self.gyroPlanarizedHistory removeObjectAtIndex:0];
                                }
                            }
                            if ([self.gyroHistory count]>filterLength)
                            {
                                [self.gyroHistory removeObjectAtIndex:0];
                            }
                        }
                        );
     }
     ];
    
    self.motionManager.accelerometerUpdateInterval = 1/150.0f;
    [self.motionManager
     startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init]
     withHandler:^(CMAccelerometerData *data, NSError *error)
     {
         
         dispatch_async(dispatch_get_main_queue(),
                        ^{
                            X_Acceleration.text = [NSString stringWithFormat:@"%.2f", data.acceleration.x];
                            Y_Acceleration.text = [NSString stringWithFormat:@"%.2f", data.acceleration.y];
                            Z_Acceleration.text = [NSString stringWithFormat:@"%.2f", data.acceleration.z];
                            E203dDataPoint *dataPoint = [[E203dDataPoint alloc] init];
                            dataPoint.x = data.acceleration.x;
                            dataPoint.y = data.acceleration.y;
                            dataPoint.z = data.acceleration.z;
                            [self.accelHistory addObject:dataPoint];
                            if ([self.accelHistory count]>filterLength)
                            {
                                [self.accelHistory removeObjectAtIndex:0];
                            }
                        }
                        );
     }
     ];
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self setGravHistory:[[NSMutableArray alloc] init]];
    [self setGyroHistory:[[NSMutableArray alloc] init]];
    [self setAccelHistory:[[NSMutableArray alloc] init]];
    [self setKeySensorInfo:[[NSMutableArray alloc] init]];
    [self setSecondIntegral:[[NSMutableArray alloc] init]];
    [self setHorizontalAccel:[[NSMutableArray alloc] init]];
    [self setGyroPlanarizedHistory:[[NSMutableArray alloc] init]];
    [self setAvgThresPrep:[[NSMutableArray alloc] init]];
    [self setRaw_RunningMeanPrep:[[NSMutableArray alloc] init]];
    [self setRaw_RunningMean:[[NSMutableArray alloc] init]];
    self.avgThres = 0;
    self.numberOfSecondIntegral = 0;
    self.avgWeight = 0;
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    _counterScanning = 0;
    self.peripheralList = [[NSMutableArray alloc] init];
//    NSString* first = @"first";
//    NSString* second = @"second";
//    [self.peripheralList addObject:first];
//    [self.peripheralList addObject:second];
    //table = [[UITableView alloc] init];
    self.table.delegate = self;
    self.table.dataSource = self;
    self.pastMean = 0;
    self.currMean = 0;
    
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.peripheralList count];
    //return 2;
}



-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == Nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.text = [self.peripheralList objectAtIndex:indexPath.row];
    //cell.textLabel.text = @"first";
    
    return cell;
}



- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_centralManager stopScan];
}

-(void)centralManagerDidUpdateState:(CBCentralManager *)central {
    // You should test all scenarios
    if (central.state != CBCentralManagerStatePoweredOn) {
        return;
    }
    
    if (central.state == CBCentralManagerStatePoweredOn) {
        // Scan for devices
        _counterScanning = 0;
        NSTimer* myTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(methodB:) userInfo:nil repeats:YES];
        
    }
}

- (void) methodB:(NSTimer*)timer
{
    if(_counterScanning%3==0 || _counterScanning%4==0){
        [_centralManager scanForPeripheralsWithServices:Nil options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
        NSLog(@"Scanning started");
    }
    else{
        [_centralManager stopScan];
        //[self.bleTagsInRange removeAllObjects];
        
    }
    _counterScanning++;
    
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    if (peripheral.name != Nil) {
        NSString *textString = [NSString stringWithFormat:@"Discovered %@ at strength: %f", peripheral.name, [RSSI doubleValue]];
        int index = -1;
        for (int i = 0 ; i < [self.peripheralList count];i++) {
            NSString* text = [self.peripheralList objectAtIndex:i];
            if ([text rangeOfString:peripheral.name].location != NSNotFound) {
                index = i;
            }
            
        }
        if (index != -1) {
            [self.peripheralList replaceObjectAtIndex:index withObject:textString];
        }
        else{
            [self.peripheralList addObject:textString];
        }
    }
    [self.table reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)CoordinatesGetter:(id)sender
{
    self.text = [NSMutableString stringWithFormat:@"Time,GyroX,GyroY,GyroZ,GravX,GravY,GravZ,AccelX,AccelY,AccelZ"];
    sensorInfoData = [[E20SensorInfo alloc] init];
    [self startMyMotionDetect];
    
}


-(IBAction)CoordinatesStopper:(id)sender;
{
    [self.raw_RunningMeanPrep removeAllObjects];
    [self.Raw_RunningMean removeAllObjects];
    self.pastMean = 0;
    self.currMean = 0;
    [self.motionManager stopDeviceMotionUpdates];
    [self.motionManager stopAccelerometerUpdates];
    [self.motionManager stopGyroUpdates];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    NSString *filePath= nil;
    NSDate *myDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    NSString *myDateString = [dateFormatter stringFromDate:myDate];
    filePath = [documentsDirectoryPath  stringByAppendingPathComponent:[myDateString stringByAppendingString:@".csv"]];
    
    NSData* settingsData;
    settingsData = [self.text dataUsingEncoding: NSASCIIStringEncoding];
    
    [settingsData writeToFile:filePath atomically:YES];

    
}

- (CMMotionManager *)motionManager
{
    CMMotionManager *motionManager = nil;
    
    id appDelegate = [UIApplication sharedApplication].delegate;
    
    if ([appDelegate respondsToSelector:@selector(motionManager)]) {
        motionManager = [appDelegate motionManager];
    }
    
    return motionManager;
}






@end
