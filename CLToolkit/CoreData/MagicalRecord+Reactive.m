//
//  MagicalRecord+Reactive.m
//  Collections
//
//  Created by Tony Xiao on 7/11/13.
//  Copyright (c) 2013 Tony Xiao. All rights reserved.
//

#import "RACSignalOperation.h"
#import "MagicalRecord+Reactive.h"

typedef void (^MRCompletionHandler)(BOOL success, NSError *error);

@implementation RACSubject (Completion)

- (MRCompletionHandler)mr_completionBlock {
    @weakify(self);
    return ^(BOOL success, NSError *error) {
        @strongify(self);
        (success || !error) ? [self sendCompleted] : [self sendError:error];
    };
}

+ (RACSubject *)mr_subject:(void (^)(MRCompletionHandler completionBlock))block; {
    RACSubject *subject = [RACReplaySubject subject];
    block(subject.mr_completionBlock);
    return subject;
}

@end

@implementation MagicalRecord (Reactive)

+ (RACSignal *)rac_saveWithBlock:(void (^)(NSManagedObjectContext *))block {
    return [RACSubject mr_subject:^(MRCompletionHandler completionBlock) {
        [self saveWithBlock:block completion:completionBlock];
    }];
}

+ (RACSignal *)rac_saveWithBlock:(void (^)(NSManagedObjectContext *))block onQueue:(NSOperationQueue *)queue {
    RACSubject *subject = [RACReplaySubject subject];
    @weakify(self);
    
    [queue addOperation:[CLAsyncOperation operationWithBlock:^(CLAsyncOperation *operation) {
        @strongify(self);
        [self saveWithBlock:block completion:^(BOOL success, NSError *error) {
            [operation finish];
            success ? [subject sendCompleted] : [subject sendError:error];
        }];
    }]];
    return subject;
}

+ (RACSignal *)rac_saveUsingCurrentThreadContextWithBlock:(void (^)(NSManagedObjectContext *localContext))block {
    return [RACSubject mr_subject:^(MRCompletionHandler completionBlock) {
        [self saveUsingCurrentThreadContextWithBlock:block completion:completionBlock];
    }];
}

@end


@implementation NSManagedObjectContext (Reactive)

- (RACSignal *)saveToPersistentStore {
    return [RACSubject mr_subject:^(MRCompletionHandler completionBlock) {
        [self saveToPersistentStoreWithCompletion:completionBlock];
    }];
}

- (RACSignal *)saveOnlySelf {
    return [RACSubject mr_subject:^(MRCompletionHandler completionBlock) {
        [self saveOnlySelfWithCompletion:completionBlock];
    }];
}

- (RACSignal *)saveWithOptions:(MRSaveContextOptions)mask {
    return [RACSubject mr_subject:^(MRCompletionHandler completionBlock) {
        return [self saveWithOptions:mask completion:completionBlock];
    }];
}

@end