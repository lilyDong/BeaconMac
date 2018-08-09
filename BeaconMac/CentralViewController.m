//
//  CentralViewController.m
//  BeaconMac
//
//  Created by dongliyun on 2018/8/8.
//  Copyright © 2018年 LY. All rights reserved.
//

#import "CentralViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>


// 蓝牙4.0设备名
static NSString * const kBlePeripheralName = @"董小云的iPhone";
// 通知服务
static NSString * const kNotifyServerUUID = @"FFE0";
// 写服务
static NSString * const kWriteServerUUID = @"FFE1";
// 通知特征值
static NSString * const kNotifyCharacteristicUUID = @"FFE2";
// 写特征值
static NSString * const kWriteCharacteristicUUID = @"FFE3";

static NSString *const kBatteryUUID = @"180F";

@interface CentralViewController()<CBCentralManagerDelegate, CBPeripheralDelegate>
@property (unsafe_unretained) IBOutlet NSTextView *textView;
@property (weak) IBOutlet NSButton *startBtn;
@property (weak) IBOutlet NSButton *stopBtn;
@property (weak) IBOutlet NSButton *linkBtn;
@property (weak) IBOutlet NSButton *clearBtn;

/// 中央管理者 -->管理设备的扫描 --连接
@property (nonatomic, strong) CBCentralManager *centralManager;
// 存储的设备
@property (nonatomic, strong) NSMutableArray *peripherals;
// 扫描到的设备
@property (nonatomic, strong) CBPeripheral *cbPeripheral;
// 蓝牙状态
@property (nonatomic, assign) CBManagerState peripheralState;

@end

@implementation CentralViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

- (IBAction)clickStartBtn:(NSButton *)sender {
    NSLog(@"扫描设备");
    [self showMessage:@"扫描设备"];
    if (self.peripheralState ==  CBManagerStatePoweredOn)
    {
        [self.centralManager scanForPeripheralsWithServices:nil options:nil];
    }
}
- (IBAction)stopBtn:(NSButton *)sender {
    [self.centralManager stopScan];
}
- (IBAction)clickLinkBtn:(NSButton *)sender {
    if (self.cbPeripheral != nil)
    {
        NSLog(@"连接设备");
        [self showMessage:@"连接设备"];
        [self.centralManager connectPeripheral:self.cbPeripheral options:nil];
    }
    else
    {
        [self showMessage:@"无设备可连接"];
    }
}
- (IBAction)clickClearBtn:(NSButton *)sender {
    NSLog(@"清空设备");
    [self.peripherals removeAllObjects];

    [self showMessage:@"清空设备"];
    
    if (self.cbPeripheral != nil)
    {
        // 取消连接
        NSLog(@"取消连接");
        [self showMessage:@"取消连接"];
        [self.centralManager cancelPeripheralConnection:self.cbPeripheral];
    }
}

#pragma mark - CBPeripheralDelegate

/**
 扫描到设备
 
 @param central 中心管理者
 @param peripheral 扫描到的设备
 @param advertisementData 广告信息
 @param RSSI 信号强度
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    [self showMessage:[NSString stringWithFormat:@"发现设备,设备名:%@",peripheral.name]];
    
    if (![self.peripherals containsObject:peripheral])
    {
        [self.peripherals addObject:peripheral];
        NSLog(@"peripheral:%@",peripheral);
        
        if ([peripheral.name isEqualToString:kBlePeripheralName])
        {
            [self showMessage:[NSString stringWithFormat:@"设备名:%@",peripheral.name]];
            self.cbPeripheral = peripheral;
            
            [self showMessage:@"开始连接"];
            [self.centralManager connectPeripheral:peripheral options:nil];
            
            [self.centralManager stopScan];
        }
    }
}

/**
 连接失败
 
 @param central 中心管理者
 @param peripheral 连接失败的设备
 @param error 错误信息
 */

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self showMessage:@"连接失败"];
    if ([peripheral.name isEqualToString:kBlePeripheralName])
    {
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
}

/**
 连接断开
 
 @param central 中心管理者
 @param peripheral 连接断开的设备
 @param error 错误信息
 */

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self showMessage:@"断开连接"];
    if ([peripheral.name isEqualToString:kBlePeripheralName])
    {
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
}

/**
 连接成功
 
 @param central 中心管理者
 @param peripheral 连接成功的设备
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"连接设备:%@成功",peripheral.name);
    
    //    self.peripheralText.text = [NSString stringWithFormat:@"连接设备:%@成功",peripheral.name];
    [self showMessage:[NSString stringWithFormat:@"连接设备:%@成功",peripheral.name]];
    // 设置设备的代理
    peripheral.delegate = self;
    // services:传入nil  代表扫描所有服务
    [peripheral discoverServices:nil];
}

/**
 扫描到服务
 
 @param peripheral 服务对应的设备
 @param error 扫描错误信息
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    // 遍历所有的服务
    for (CBService *service in peripheral.services)
    {
        NSLog(@"服务:%@",service.UUID.UUIDString);
        // 获取对应的服务
//        if ([service.UUID.UUIDString isEqualToString:kWriteServerUUID] || [service.UUID.UUIDString isEqualToString:kNotifyServerUUID])
//        {
//            // 根据服务去扫描特征
//            [peripheral discoverCharacteristics:nil forService:service];
//        }
//        if ([service.UUID.UUIDString isEqualToString:@"1805"]) {
//        if ([service.UUID.UUIDString isEqualToString:@"180A"]) {

        if ([service.UUID.UUIDString isEqualToString:kBatteryUUID]) {
//        if ([service.UUID.UUIDString isEqualToString:@"9FA480E0-4967-4542-9390-D343DC5D04AE"]) {
//        if ([service.UUID.UUIDString isEqualToString:@"D0611E78-BBB4-4591-A5F8-487910AE4366"]) {
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }
}

/**
 扫描到对应的特征
 
 @param peripheral 设备
 @param service 特征对应的服务
 @param error 错误信息
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSLog(@"特征值们:%@",service.characteristics);
    // 遍历所有的特征
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        NSLog(@"特征值:%@",characteristic);
        [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        
        if ([characteristic.UUID.UUIDString isEqualToString:kWriteCharacteristicUUID])
        {
            // 写入数据
            [self showMessage:@"写入特征值"];
            for (Byte i = 0x0; i < 0x73; i++)
            {
                Byte byte[] = {0xf0, 0x3d, 0x3d, i,
                    0x02,0xf7};
                NSData *data = [NSData dataWithBytes:byte length:6];
                [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
            }
        }
        if ([characteristic.UUID.UUIDString isEqualToString:kNotifyCharacteristicUUID])
        {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
}

/**
 根据特征读到数据
 
 @param peripheral 读取到数据对应的设备
 @param characteristic 特征
 @param error 错误信息
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    if ([characteristic.UUID.UUIDString isEqualToString:kNotifyCharacteristicUUID])
    {
        NSData *data = characteristic.value;
        NSLog(@"%@",data);
    }
}
#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    switch (central.state) {
        case CBManagerStateUnknown:{
            NSLog(@"为知状态");
            self.peripheralState = central.state;
        }
            break;
        case CBManagerStateResetting:
        {
            NSLog(@"重置状态");
            self.peripheralState = central.state;
        }
            break;
        case CBManagerStateUnsupported:
        {
            NSLog(@"不支持的状态");
            self.peripheralState = central.state;
        }
            break;
        case CBManagerStateUnauthorized:
        {
            NSLog(@"未授权的状态");
            self.peripheralState = central.state;
        }
            break;
        case CBManagerStatePoweredOff:
        {
            NSLog(@"关闭状态");
            self.peripheralState = central.state;
        }
            break;
        case CBManagerStatePoweredOn:
        {
            NSLog(@"开启状态－可用状态");
            self.peripheralState = central.state;
            NSLog(@"%ld",(long)self.peripheralState);
            [self.centralManager scanForPeripheralsWithServices:nil options:nil];

        }
            break;
        default:
            break;
    }
}

#pragma mark - private method
- (void)showMessage:(NSString *)message
{
    self.textView.string = [self.textView.string stringByAppendingFormat:@"%@\n",message];
    [self.textView scrollRectToVisible:NSMakeRect(0, self.textView.textContainer.size.height -15, self.textView.textContainer.size.width, 10)];
}
#pragma mark - custom accessor
- (NSMutableArray *)peripherals{
    if (!_peripherals) {
        _peripherals = [NSMutableArray array];
    }
    return _peripherals;
}

@end
//
//@interface CentralViewController()<CBCentralManagerDelegate, CBPeripheralDelegate,CBPeripheralManagerDelegate> {
//    NSMutableArray *_peripheralsList;
//}
//@property (unsafe_unretained) IBOutlet NSTextView *textView;
//
//@property (nonatomic, strong) CBCentralManager *centralManager;
//@property (nonatomic, strong) CBPeripheral *currentPeripheral;
//@property (nonatomic, strong) NSArray<CBPeripheral *> *peripherals;
//
//@end
//
//@implementation CentralViewController
//
//- (void)viewDidLoad{
//    [super viewDidLoad];
//    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
//}
//
//#pragma mark - CBCentralManagerDelegate
//
//// 在 cetral 的状态变为 CBManagerStatePoweredOn 的时候开始扫描
//- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
//    if (central.state == CBCentralManagerStatePoweredOn) {
//        [_centralManager scanForPeripheralsWithServices:nil options:nil];
//    }
//    NSLog(@"state:%ld",central.state);
//}
//
//- (void)centralManager:(CBCentralManager *)central
// didDiscoverPeripheral:(CBPeripheral *)peripheral
//     advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
//
//    if (!peripheral.name) return; // Ingore name is nil peripheral.
//    if (![_peripheralsList containsObject:peripheral]) {
//        [_peripheralsList addObject:peripheral];
//        _peripherals = _peripheralsList.copy;
//    }
//
//    // 在某个地方停止扫描并连接至周边设备
//    [_centralManager stopScan];
//    [_centralManager connectPeripheral:peripheral options:nil];
//}
//
//- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
//
//    peripheral.delegate = self;
//
//    //     Client to do discover services method...
//    CBUUID *seriveUUID = [CBUUID UUIDWithString:@"d2009d00-6000-1000-8000-000000000000"];
//    [peripheral discoverServices:@[seriveUUID]];
//}
//
//- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
//
//}
//
//- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
//
//}
//
//#pragma mark - CBPeripheralManagerDelegate
//
//- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
//
//}
//
//
//#pragma mark - CBPeripheralDelegate
//
//// 发现服务
//- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error {
//    NSArray *services = peripheral.services;
//    if (services) {
//        CBService *service = services[0];
//        CBUUID *writeUUID = [CBUUID UUIDWithString:@"D2009D01-6000-1000-8000-000000000000"];
//        CBUUID *notifyUUID = [CBUUID UUIDWithString:@"D2009D02-6000-1000-8000-000000000000"];
//        __unused CBUUID *unusedUUID = [CBUUID UUIDWithString:@"D2009D02-6000-1000-8000-000000000001"];
//
//        [peripheral discoverCharacteristics:@[writeUUID, notifyUUID] forService:service]; // 发现服务
//    }
//}
//
//// 发现特性值
//- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error {
//    if (!error) {
//        NSArray *characteristicArray = service.characteristics;
//        CBCharacteristic *writeCharacteristic = characteristicArray[0];
//        CBCharacteristic *notifyCharacteristic = characteristicArray[1];
//
//        // 通知使能， `YES` enable notification only, `NO` disabel notifications and indications
//        [peripheral setNotifyValue:YES forCharacteristic:notifyCharacteristic];
//        [peripheral writeValue:[NSData data] forCharacteristic:writeCharacteristic type:CBCharacteristicWriteWithResponse];
//    } else {
//        NSLog(@"Discover charactertics Error : %@", error);
//    }
//}
//
//// 写入成功
//- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
//    if (!error) {
//        NSLog(@"Write Success");
//    } else {
//        NSLog(@"WriteVale Error = %@", error);
//    }
//}
//
//// 回复
//- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
//    if (error) {
//        NSLog(@"update value error: %@", error);
//    } else {
//        __unused NSData *responseData = characteristic.value;
//    }
//}
//
//- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
//
//}
//
//- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral {
//
//}
//
//- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
//
//}
//
//- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
//
//}
//@end
