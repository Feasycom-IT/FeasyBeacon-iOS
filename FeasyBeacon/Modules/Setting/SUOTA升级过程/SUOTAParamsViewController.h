/*
 *******************************************************************************
 *
 * Copyright (C) 2019-2020 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "SuotaLib.h"

@interface SUOTAParamsViewController : UIViewController <UITextFieldDelegate>

@end

/**
 `SUOTAParamsViewController` 类是用于管理和设置 SUOTA（Software Update Over The Air）过程中的参数的视图控制器。这个类的主要功能和用途如下：
 
 1. **设备信息显示**：
 - `deviceNameLabel` 用于显示连接设备的名称。
 - `fileTextField` 显示当前选择的固件文件名。
 
 2. **选择内存类型**：
 - 用户可以通过 `UISegmentedControl` 控件（`memoryTypeControl`）选择内存类型（如 SPI 或 I2C），不同的内存类型将显示不同的配置选项。
 - 当内存类型变化时，会触发 `onMemoryTypeChange:` 方法，来显示或隐藏与该类型相关的设置视图。
 
 3. **配置 SPI 和 I2C 参数**：
 - 根据选择的内存类型，用户可以输入相应的 GPIO（通用输入输出）引脚配置。
 - 对于 SPI 类型，用户需要配置 MISO、MOSI、CS、SCK 等引脚。
 - 对于 I2C 类型，用户需要配置 SDA 和 SCL 引脚，以及设备地址。
 
 4. **保存和加载用户设置**：
 - 该类支持将用户的配置保存到 `NSUserDefaults`，以便下次打开时可以恢复之前的设置。这包括内存类型、块大小、GPIO 引脚配置等。
 
 5. **初始化 SUOTA 管理器**：
 - 在执行固件更新之前，该类会将用户输入的参数传递给 `SuotaManager`，以便它能够正确地初始化并开始固件更新过程。
 
 6. **GPIO 引脚选择器**：
 - 该类实现了一个简单的 GPIO 引脚选择器。当用户点击相关的 `UITextField` 时，会弹出一个选择器（通过 `ActionSheetStringPicker` 实现），用户可以从预定义的 GPIO 列表中选择引脚。
 
 7. **验证和准备固件更新**：
 - 在准备进行固件更新（通过 Segue 跳转到下一个视图控制器之前），该类会验证用户的输入数据，并根据所选的内存类型初始化 SUOTA 管理器。
 
 总结来说，`SUOTAParamsViewController` 是一个用于让用户配置固件更新参数的界面控制器。它处理各种输入、配置保存和验证，并在用户配置完成后初始化 SUOTA 管理器，为固件更新过程做好准备。
 */
