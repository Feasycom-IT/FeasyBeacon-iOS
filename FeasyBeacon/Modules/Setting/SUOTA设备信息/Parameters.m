/*
 *******************************************************************************
 *
 * Copyright (C) 2019 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "Parameters.h"

@implementation Parameters

static Parameters* instance;

+ (Parameters*) instance {
    @synchronized (self) {
        if (!instance)
            instance = [Parameters new];
    }
    return instance;
}

@end
