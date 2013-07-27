//
//  Misc.m
//  Collections
//
//  Created by Tony Xiao on 7/19/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import "Misc.h"

#if !TARGET_OS_IPHONE
void TransformToForegroundApplication() {
    ProcessSerialNumber psn = { 0, kCurrentProcess };
    TransformProcessType(&psn, kProcessTransformToForegroundApplication);
    SetFrontProcess(&psn);
}

void TransformToAccessoryApplication() {
    ProcessSerialNumber psn = { 0, kCurrentProcess };
    TransformProcessType(&psn, kProcessTransformToUIElementApplication);
}
#endif