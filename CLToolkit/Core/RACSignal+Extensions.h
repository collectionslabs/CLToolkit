//
//  RACSignal+Extensions.h
//  medigram
//
//  Created by Tony Xiao on 7/9/13.
//  Copyright (c) 2013 Bradford Toney. All rights reserved.
//

#import "RACSignal.h"

@interface RACSignal (Extensions)

+ (RACSignal *)delay:(NSTimeInterval)seconds;
- (RACDisposable *)subscribeCompleted:(void (^)(void))completedBlock error:(void (^)(NSError *error))errorBlock;

@end
