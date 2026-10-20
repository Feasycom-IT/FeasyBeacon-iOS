//
//  FBGlobalObjects.h
//  FeasyBeacon
//
//  Created by chenchanghua on 2024/9/11.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@interface FBGlobalObjects : NSObject

+ (FBGlobalObjects*)instance;

@property CBCentralManager *centralManager;

@end

NS_ASSUME_NONNULL_END
