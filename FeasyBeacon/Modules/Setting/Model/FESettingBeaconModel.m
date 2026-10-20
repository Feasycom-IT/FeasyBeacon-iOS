//
//  FESettingBeaconModel.m
//  FeasyBeacon
//
//  Created by feasycom on 2025/12/4.
//  Copyright © 2025 Feasycom. All rights reserved.
//

#import "FESettingBeaconModel.h"
#import "NSString+FscKit.h"

@implementation FESettingBeaconModel

+ (BOOL)isValidEddystoneURL:(NSString *)urlString {
    
    if (urlString.length == 0) {
        return NO;
    }

    NSData *ascii = [urlString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:NO];
    if (!ascii) {
        return NO;
    }

    NSArray *prefixes = @[
        @"http://www.",
        @"https://www.",
        @"http://",
        @"https://"
    ];
    
    NSString *prefix = nil;
    
    for (NSString *p in prefixes) {
        if ([urlString hasPrefix:p]) {
            prefix = p;
            break;
        }
    }
    
    if (!prefix) {
        return NO;
    }

    NSString *urlBody = [urlString substringFromIndex:prefix.length];

    NSDictionary *expansion = @{
        @".com/": @(0x00),
        @".org/": @(0x01),
        @".edu/": @(0x02),
        @".net/": @(0x03),
        @".info/": @(0x04),
        @".biz/": @(0x05),
        @".gov/": @(0x06),
        @".com": @(0x07),
        @".org": @(0x08),
        @".edu": @(0x09),
        @".net": @(0x0A),
        @".info": @(0x0B),
        @".biz": @(0x0C),
        @".gov": @(0x0D)
    };
    
    NSInteger encodedLength = 0;
    NSInteger i = 0;
    
    while (i < urlBody.length) {
        
        BOOL matched = NO;
        
        for (NSString *key in expansion) {
            
            if (i + key.length <= urlBody.length) {
                
                NSString *sub = [urlBody substringWithRange:NSMakeRange(i, key.length)];
                
                if ([sub isEqualToString:key]) {
                    
                    encodedLength += 1;
                    i += key.length;
                    matched = YES;
                    break;
                }
            }
        }
        
        if (!matched) {
            encodedLength += 1;
            i += 1;
        }
        
        if (encodedLength > 17) {
            return NO;
        }
    }
    
    return encodedLength >= 1 && encodedLength <= 17;
}

+ (NSString *)validCustomData:(NSString *)str{
    // 前面4个必须是0201
    if (str.length < 4){
        if (![@"0201" hasPrefix:str]) {
            return @"The first four must be 0201";
        }
    } else {
        if (![str hasPrefix:@"0201"]) {
            return @"The first four must be 0201";
        }
    }
    return [FESettingBeaconModel validSplitString:str];
}

// 拆分检查内容
+ (NSString *)validSplitString:(NSString *)str{
    // 16进制长度是双数
    if (str.length%2 != 0) {
        return LS(@"Not HEX");
    }
    NSInteger index = 0;
    for (int i = 0; i < str.length; i+=2) {
        NSString *itemStr = [str substringWithRange:NSMakeRange(index + i, 2)];
        NSScanner *scanner = [NSScanner scannerWithString:itemStr];
        // 长度
        unsigned int length = 0;
        [scanner scanHexInt:&length];
        // 长度最少是2
        if (length < 2) {
            return LS(@"Length_MIN");
        }
        if (str.length < i + length * 2 + 2){
            return [NSString stringWithFormat:@"%@%ld",LS(@"Insufficient content length"), i + length * 2 + 2 - str.length];
        }
        i+=length*2; // *2是因为16进制是2位
    }
    return nil;
}

#pragma mark - 每种类型组
+ (NSArray<FEBeaconTitleInfoDetail *> *)iBeaconListWithTxPower:(BOOL)isWithTxPower {
    NSMutableArray *arr = [NSMutableArray arrayWithObjects:
                           [FEBeaconTitleInfoDetail title:@"UUID:" placeholder:[FESettingBeaconModel placeholder_UUID]],
                           [FEBeaconTitleInfoDetail title:@"Major:" placeholder:[FESettingBeaconModel placeholder_Major] keyboardType:UIKeyboardTypeNumberPad],
                           [FEBeaconTitleInfoDetail title:@"Minor:" placeholder:[FESettingBeaconModel placeholder_Minor] keyboardType:UIKeyboardTypeNumberPad],
                           [FEBeaconTitleInfoDetail title:@"RSSI at 1m:" placeholder:[FESettingBeaconModel placeholder_RSSI] keyboardType:UIKeyboardTypeNumbersAndPunctuation], nil];
    return isWithTxPower ? [arr arrayByAddingObjectsFromArray:[FESettingBeaconModel txpowerList]] : arr;
}

+ (NSArray<FEBeaconTitleInfoDetail *> *)urlListWithTxPower:(BOOL)isWithTxPower {
    NSMutableArray *arr = [NSMutableArray arrayWithObjects:
                           [FEBeaconTitleInfoDetail title:@"URL:" placeholder:[FESettingBeaconModel placeholder_URL] keyboardType:UIKeyboardTypeURL],
                           [FEBeaconTitleInfoDetail title:@"RSSI at 0m:" placeholder:[FESettingBeaconModel placeholder_RSSI] keyboardType:UIKeyboardTypeNumbersAndPunctuation], nil];
    return isWithTxPower ? [arr arrayByAddingObjectsFromArray:[FESettingBeaconModel txpowerList]] : arr;
}

+ (NSArray<FEBeaconTitleInfoDetail *> *)uidListWithTxPower:(BOOL)isWithTxPower {
    NSMutableArray *arr = [NSMutableArray arrayWithObjects:
                           [FEBeaconTitleInfoDetail title:@"Namespace:" placeholder:[FESettingBeaconModel placeholder_Namespace]],
                           [FEBeaconTitleInfoDetail title:@"Instance:" placeholder:[FESettingBeaconModel placeholder_Instance]],
                           [FEBeaconTitleInfoDetail title:@"Reserved:" placeholder:[FESettingBeaconModel placeholder_Reserved]],
                           [FEBeaconTitleInfoDetail title:@"RSSI at 0m:" placeholder:[FESettingBeaconModel placeholder_RSSI] keyboardType:UIKeyboardTypeNumbersAndPunctuation], nil];
    return isWithTxPower ? [arr arrayByAddingObjectsFromArray:[FESettingBeaconModel txpowerList]] : arr;
}

+ (NSArray<FEBeaconTitleInfoDetail *> *)altBeaconListWithTxPower:(BOOL)isWithTxPower {
    NSMutableArray *arr = [NSMutableArray arrayWithObjects:
                           [FEBeaconTitleInfoDetail title:@"ID1:" placeholder:[FESettingBeaconModel placeholder_ID1]],
                           [FEBeaconTitleInfoDetail title:@"ID2:" placeholder:[FESettingBeaconModel placeholder_ID2]],
                           [FEBeaconTitleInfoDetail title:@"ID3:" placeholder:[FESettingBeaconModel placeholder_ID3]],
                           [FEBeaconTitleInfoDetail title:@"RSSI at 1m:" placeholder:[FESettingBeaconModel placeholder_RSSI] keyboardType:UIKeyboardTypeNumbersAndPunctuation],
                           [FEBeaconTitleInfoDetail title:@"Manufacturer ID:" placeholder:[FESettingBeaconModel placeholder_ManufacturerID] keyboardType:UIKeyboardTypeNumberPad],
                           [FEBeaconTitleInfoDetail title:@"Manufacturer Reserved:" placeholder:[FESettingBeaconModel placeholder_ManufacturerReserved]], nil];
    return isWithTxPower ? [arr arrayByAddingObjectsFromArray:[FESettingBeaconModel txpowerList]] : arr;
}

+ (NSArray<FEBeaconTitleInfoDetail *> *)customListWithTxPower:(BOOL)isWithTxPower {
    NSMutableArray *arr = [NSMutableArray arrayWithObjects:
                           [FEBeaconTitleInfoDetail title:@"Data:" placeholder:[FESettingBeaconModel placeholder_Data]], nil];
    return isWithTxPower ? [arr arrayByAddingObjectsFromArray:[FESettingBeaconModel txpowerList]] : arr;
}

#pragma mark - placeholder
+ (NSString *)placeholder_UUID {
    return LS(@"Placeholder UUID");
}
+ (NSString *)placeholder_RSSI {
    return @"-128~127";
}
+ (NSString *)placeholder_Major {
    return @"0~65535";
}
+ (NSString *)placeholder_Minor {
    return @"0~65535";
}
+ (NSString *)placeholder_URL {
    return @"http/https";
}
+ (NSString *)placeholder_Namespace {
    return LS(@"Placeholder Namespace");
}
+ (NSString *)placeholder_Instance {
    return LS(@"Placeholder Instance");
}
+ (NSString *)placeholder_Reserved {
    return LS(@"Placeholder Reserved");
}
+ (NSString *)placeholder_ID1 {
    return LS(@"Placeholder ID1");
}
+ (NSString *)placeholder_ID2 {
    return LS(@"Placeholder ID2");
}
+ (NSString *)placeholder_ID3 {
    return LS(@"Placeholder ID3");
}
+ (NSString *)placeholder_ManufacturerID {
    return @"0~65535";
}
+ (NSString *)placeholder_ManufacturerReserved {
    return LS(@"Placeholder Manufacturer Reserved");
}
+ (NSString *)placeholder_Data {
    return LS(@"Placeholder custom");
}
+ (NSString *)placeholder_Internal {
    return @"20~10000";
}
+ (NSString *)placeholder_Timeout {
    return @"100~65535";
}

#pragma mark - 输入限制
+ (BOOL)dealwith_UUID_TextField:(UITextField *)textField newText:(NSString *)newText{
    if (![newText isHexDigits]) {
        return NO;
    }
    const NSInteger newLength = newText.length;
    if (newLength < 32) {
        textField.textColor = [UIColor redColor];
    } else {
        textField.textColor = [UIColor darkGrayColor];
    }
    return newLength <= 32;
}

// 处理信号范围
+ (BOOL)dealwith_RSSI_TextField:(UITextField *)textField newText:(NSString *)newText inputString:(NSString *)string{
    if (![newText isDigits] && ![string isEqualToString:@"-"]) {
        return NO;
    }
    // 支持只是负号
    if ([newText isEqualToString:@"-"]){
        return YES;
    }
    int beforeValue = [textField.text intValue];
    int newValue = [newText intValue];
    // 输入负号进行正负切换
    if ([string isEqualToString:@"-"]) {
        if ([textField.text isEqualToString:@"-"]){
            // 如果之前是负号，抵消负号
            textField.text = @"";
            return NO;
        }
        if (newText.length == 1) {
            return YES;
        }
        newValue = -beforeValue;
    }
    
    textField.text = [NSString stringWithFormat:@"%d", newValue];
    if (-128 <= newValue && newValue <= 127) {
        textField.textColor = [UIColor darkGrayColor];
    } else if (newValue < -128) {
        textField.textColor = [UIColor darkGrayColor];
        textField.text = @"-128";
    } else if (newValue > 127) {
        textField.textColor = [UIColor darkGrayColor];
        textField.text = @"127";
    } else {
        textField.textColor = [UIColor redColor];
    }
    return NO;
}

+ (BOOL)dealwith_Major_TextField:(UITextField *)textField newText:(NSString *)newText {
    if (![newText isUnsignedDigits]) {
        return NO;
    }
    const int newValue = [newText intValue];
    textField.text = [NSString stringWithFormat:@"%d", newValue];
    if (0 <= newValue && newValue <= 65535) {
        textField.textColor = [UIColor darkGrayColor];
    } else if (newValue > 65535) {
        textField.textColor = [UIColor darkGrayColor];
        textField.text = @"65535";
    } else {
        textField.textColor = [UIColor redColor];
    }
    return NO;
}
+ (BOOL)dealwith_Minor_TextField:(UITextField *)textField newText:(NSString *)newText {
    if (![newText isUnsignedDigits]) {
        return NO;
    }
    const int newValue = [newText intValue];
    textField.text = [NSString stringWithFormat:@"%d", newValue];
    if (0 <= newValue && newValue <= 65535) {
        textField.textColor = [UIColor darkGrayColor];
    } else if (newValue > 65535) {
        textField.textColor = [UIColor darkGrayColor];
        textField.text = @"65535";
    } else {
        textField.textColor = [UIColor redColor];
    }
    return NO;
}
+ (BOOL)dealwith_URL_TextField:(UITextField *)textField newText:(NSString *)newText inputString:(NSString *)string {
    if([FESettingBeaconModel isValidEddystoneURL:newText]){
        textField.textColor = [UIColor darkGrayColor];
    }else{
        textField.textColor = [UIColor redColor];
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^[\\u4e00-\\u9fa5]+$"];
    
    if ([predicate evaluateWithObject:string]) {
        return NO;
    }
    return YES;
}
+ (BOOL)dealwith_Namespace_TextField:(UITextField *)textField newText:(NSString *)newText {
    if (![newText isHexDigits]) {
        return NO;
    }
    const NSInteger newLength = newText.length;
    if (newLength < 20) {
        textField.textColor = [UIColor redColor];
    } else {
        textField.textColor = [UIColor darkGrayColor];
    }
    return newLength <= 20;
}
+ (BOOL)dealwith_Instance_TextField:(UITextField *)textField newText:(NSString *)newText {
    if (![newText isHexDigits]) {
        return NO;
    }
    const NSInteger newLength = newText.length;
    if (newLength < 12) {
        textField.textColor = [UIColor redColor];
    } else {
        textField.textColor = [UIColor darkGrayColor];
    }
    return newLength <= 12;
}
+ (BOOL)dealwith_Reserved_TextField:(UITextField *)textField newText:(NSString *)newText {
    if (![newText isHexDigits]) {
        return NO;
    }
    const NSInteger newLength = newText.length;
    if (newLength < 4) {
        textField.textColor = [UIColor redColor];
    } else {
        textField.textColor = [UIColor darkGrayColor];
    }
    return newLength <= 4;
}
+ (BOOL)dealwith_ID1_TextField:(UITextField *)textField newText:(NSString *)newText {
    if (![newText isHexDigits]) {
        return NO;
    }
    const NSInteger newLength = newText.length;
    if (newLength < 32) {
        textField.textColor = [UIColor redColor];
    } else {
        textField.textColor = [UIColor darkGrayColor];
    }
    return newLength <= 32;
}
+ (BOOL)dealwith_ID2_TextField:(UITextField *)textField newText:(NSString *)newText {
    if (![newText isHexDigits]) {
        return NO;
    }
    const NSInteger newLength = newText.length;
    if (newLength >= 4) {
        textField.textColor = [UIColor blackColor];
    } else {
        textField.textColor = [UIColor redColor];
    }
    return newLength <= 4;
}
+ (BOOL)dealwith_ID3_TextField:(UITextField *)textField newText:(NSString *)newText {
    if (![newText isHexDigits]) {
        return NO;
    }
    const NSInteger newLength = newText.length;
    if (newLength >= 4) {
        textField.textColor = [UIColor blackColor];
    } else {
        textField.textColor = [UIColor redColor];
    }
    return newLength <= 4;
}
+ (BOOL)dealwith_ManufacturerID_TextField:(UITextField *)textField newText:(NSString *)newText {
    if (![newText isDigits]) {
        return NO;
    }
    const int newValue = [newText intValue];
    if (0 <= newValue && newValue <= 65535) {
        textField.textColor = [UIColor blackColor];
        return YES;
    } else {
        textField.textColor = [UIColor redColor];
    }
    if (newText.length > 6) {
        return NO;
    }
    return YES;
}
+ (BOOL)dealwith_ManufacturerReserved_TextField:(UITextField *)textField newText:(NSString *)newText range:(NSRange)range {
    if (![newText isHexDigits]) {
        return NO;
    }
    if (range.length + range.location > textField.text.length) {
        return NO;
    }
    const NSInteger newLength = newText.length;
    if (newLength < 2) {
        textField.textColor = [UIColor redColor];
    } else {
        textField.textColor = [UIColor darkGrayColor];
    }
    return newLength <= 2;
}
+ (BOOL)dealwith_Data_TextField:(UITextField *)textField newText:(NSString *)newText {
    if (![newText isHexDigits]) {
        return NO;
    }
    if (newText.length > 62){
        return NO;
    }
    if ([FESettingBeaconModel validCustomData:newText]) {
        textField.textColor = [UIColor redColor];
    }else {
        textField.textColor = [UIColor darkGrayColor];
    }
    return YES;
}
+ (BOOL)dealwith_Internal_TextField:(UITextField *)textField newText:(NSString *)newText {
    if (![newText isDigits]) {
        return NO;
    }
    const int newValue = [newText intValue];
    // 防止前面都是0
    textField.text = [NSString stringWithFormat:@"%d", newValue];
    if (20 <= newValue && newValue <= 10000) {
        textField.textColor = [UIColor blackColor];
    } else if (newValue > 10000) {
        textField.textColor = [UIColor blackColor];
        textField.text = @"10000";
    } else {
        textField.textColor = [UIColor redColor];
    }
    return NO;
}
+ (BOOL)dealwith_Timeout_TextField:(UITextField *)textField newText:(NSString *)newText {
    if (![newText isDigits]) {
        return NO;
    }
    const int newValue = [newText intValue];
    // 防止前面都是0
    textField.text = [NSString stringWithFormat:@"%d", newValue];
    if (100 <= newValue && newValue <= 65535) {
        textField.textColor = [UIColor blackColor];
    } else if (newValue > 65535) {
        textField.textColor = [UIColor blackColor];
        textField.text = @"65535";
    } else {
        textField.textColor = [UIColor redColor];
    }
    return NO;
}


+ (NSArray<FEBeaconTitleInfoDetail *> *)txpowerList{
    return @[[FEBeaconTitleInfoDetail title:LS(@"Interval(ms):") placeholder:@""],
             [FEBeaconTitleInfoDetail title:@"TxPower(db):" placeholder:@""],
             [FEBeaconTitleInfoDetail title:LS(@"Phy:") placeholder:@""]];
}

@end
