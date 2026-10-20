---

---

V2.1.5  
1、完善AoA Beacon广播解析，增加Company ID、Sub Type、CTE Info、Beacon ID、Beacon Type、电量及原始Manufacturer Data字段  
2、型号131增加AoA开关配置，AoA广播支持37、38、39频道配置  
3、相同AoA Beacon再次收到广播时，更新CTE Info、电量和原始数据

---

V2.1.4  
allDevice API 增加鉴权

---

V2.1.3  
GBeacon产品广播的解析适配

---

V2.1.2.5  
SUOTA协议连接未完成时，出现闪退问题的修复

---

V2.1.2.4  
适配BP110可编程按键协议:  
对于AT指令中，删除SADV广播，修改指令为：AT+SADV=%d,00,0,0,0,0,0\r\n

---

V2.1.2.3  
适配BP110可编程按键协议:  
对于AT指令中，SADVBeacon广播内容为空时，不转为FBMutableBeacon对象

---

V2.1.2.2  
1、去除SDK启动APi接口的调用  
2、去除反馈APi接口的调用  
3、适配BP110可编程按键协议

---

V2.1.2  
FBBluetoothBrowser新增初始化init接口：  
/// 初始化  
/// - Parameters:  
///   - type: 设备数组'peripheralItems'中只放置一种类型的设备  
///   - shouldRequestAlways: 是否扫描iBeacon广播

- (instancetype)initWithType:(const FBBluetoothBrowserType)type  
  requestLocationAlways:(BOOL)shouldRequestAlways

增加AoA广播帧、FBMutableBeacon对象增加index属性，应用层可指定广播位

---

V2.1.1  
新增iBeacon UUIDs配置接口：  
支持通过 [FBBluetoothBrowser iBeaconUUIDs] 获取当前SDK用于iBeacon扫描的UUID列表  
支持通过 [FBBluetoothBrowser setIBeaconUUIDs:uuids] 设置自定义iBeacon UUIDs，供App灵活管理

---

V2.1.0  
1、更新了SDK集成文档（主要是SUOTA OTA升级部分的增加）

---

V2.0.5  
1、SDK中做本地化字符串（中、EN）

---

V2.0.4  
1、增加日志开关  
2、集成SUOTA空中升级协议（AUTH）  
3、Fix RSSI过滤无效问题

---

V2.0.3  
1、兼容BP104E 2nd

---

V2.0.2  
支持解密温湿度、gSensor传感器数据

---

V2.0.1  
只适用于真机

---

V2.0.0  
兼容BP106Q
