//
//  MagicalRecord+Reactive.m
//  Collections
//
//  Created by Tony Xiao on 7/11/13.
//  Copyright (c) 2013 Tony Xiao. All rights reserved.
//

#import "Operation.h"
#import "MagicalRecord+Reactive.h"

typedef void (^MRCompletionHandler)(BOOL success, NSError *error);

@implementation RACSubject (Completion)

- (MRCompletionHandler)mr_completionBlock {
    return ^(BOOL success, NSError *error) {
        // Subject must be retained by the block here otherwise there will be hard to debug issues
        // introduced by neither completion or error block being called
        (success || !error) ? [self sendCompleted] : [self sendError:error];
    };
}


+ (RACSubject *)mr_subject:(void (^)(MRCompletionHandler completionBlock))block; {
    RACSubject *subject = [RACReplaySubject subjectWithSelector:_cmd];
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
    @weakify(self);
    RACSubject *subject = [RACSubject subject];
    [queue addOperation:[NSBlockOperation blockOperationWithBlock:^{
        @strongify(self);
        [self saveWithBlock:block completion:^(BOOL success, NSError *error) {
            if (success)
                [subject sendCompleted];
            else
                [subject sendError:error];
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

- (RACSignal *)performBlockWithCompletion:(void (^)())block {
    RACSubject *subject = [RACSubject subjectWithSelector:_cmd];
    [self performBlock:^{
        block();
        [subject sendCompleted];
    }];
    return subject;
}

- (RACSignal *)performBlockAndSave:(void (^)())block {
    RACSubject *subject = [RACSubject subjectWithSelector:_cmd];
    [self performBlock:^{
        block();
        [[self saveToPersistentStore] subscribe:subject];
    }];
    return subject;
}

- (RACSignal *)saveToPersistentStore {
    return [RACSubject mr_subject:^(MRCompletionHandler completionBlock) {
        [self MR_saveToPersistentStoreWithCompletion:completionBlock];
    }];
}

- (RACSignal *)saveOnlySelf {
    return [RACSubject mr_subject:^(MRCompletionHandler completionBlock) {
        [self MR_saveOnlySelfWithCompletion:completionBlock];
    }];
}

- (RACSignal *)saveWithOptions:(MRSaveOptions)mask {
    return [RACSubject mr_subject:^(MRCompletionHandler completionBlock) {
        return [self MR_saveWithOptions:mask completion:completionBlock];
    }];
}


+ (void)MR_setContextForCurrentThread:(NSManagedObjectContext *)context {
    static NSString const * kMagicalRecordManagedObjectContextKey = @"MagicalRecord_NSManagedObjectContextForThreadKey";
	if ([NSThread isMainThread]) {
        [(id)self performSelector:@selector(MR_setDefaultContext:) withObject:context];
	} else {
		NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
        threadDict[kMagicalRecordManagedObjectContextKey] = context;
	}
}

@end
