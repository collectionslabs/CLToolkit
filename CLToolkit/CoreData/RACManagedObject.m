//
//  RACManagedObject.m
//  Collections
//
//  Created by Tony Xiao on 4/15/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import "RACManagedObject.h"

@implementation RACManagedObject {
    RACSubject *_onWillAccessValue;
    RACSubject *_onDidAccessValue;
    RACSubject *_onWillSave;
    RACSubject *_onDidSave;
    RACSubject *_onPrepareDelete;
    RACSubject *_onFaultWillFire;
    RACSubject *_onFaultDidFire;
    RACSubject *_onWillTurnIntoFault;
    RACSubject *_onDidTurnIntoFault;
}

- (RACSignal *)onWillSave { return _onWillSave ?: (_onWillSave = [RACSubject subject]); }
- (RACSignal *)onDidSave { return _onDidSave ?: (_onDidSave = [RACSubject subject]); }
- (RACSignal *)onPrepareDelete { return _onPrepareDelete ?: (_onPrepareDelete = [RACSubject subject]); }
- (RACSignal *)onFaultWillFire { return _onFaultWillFire ?: (_onFaultWillFire = [RACSubject subject]); }
- (RACSignal *)onFaultDidFire { return _onFaultDidFire ?: (_onFaultDidFire = [RACSubject subject]); }
- (RACSignal *)onWillTurnIntoFault { return _onWillTurnIntoFault ?: (_onWillTurnIntoFault = [RACSubject subject]); }
- (RACSignal *)onDidTurnIntoFault { return _onDidTurnIntoFault ?: (_onDidTurnIntoFault = [RACSubject subject]); }

- (RACSignal *)onWillAccessValue { return _onWillAccessValue ?: (_onWillAccessValue = [RACSubject subject]); }
- (RACSignal *)onDidAccessValue { return _onDidAccessValue ?: (_onDidAccessValue = [RACSubject subject]); }

- (void)willSave {
    [super willSave];
    [_onWillSave sendNext:self];
}

- (void)didSave {
    [super didSave];
    [_onDidSave sendNext:self];
}

- (void)prepareForDeletion {
    [super prepareForDeletion];
    [_onPrepareDelete sendNext:self];
}

- (void)willAccessValueForKey:(NSString *)key {
//    TODO: This logic doesn't work if key isn't a CoreData attribute / relationship. Need to check for key match model attrs. 
//    if (self.isFault && self.managedObjectContext) {
//        [_onFaultWillFire sendNext:self];
//        [super willAccessValueForKey:key];
//        NSAssert(!self.isFault, @"Should not be fault at this point");
//        [_onFaultDidFire sendNext:self];
//    } else {
        [super willAccessValueForKey:key];
//    }
    [_onWillAccessValue sendNext:key];
}

- (void)didAccessValueForKey:(NSString *)key {
    [super didAccessValueForKey:key];
    [_onDidAccessValue sendNext:key];
}

- (void)willTurnIntoFault {
    [super willTurnIntoFault];
    [_onWillTurnIntoFault sendNext:self];
}

- (void)didTurnIntoFault {
    [super didTurnIntoFault];
    [_onDidTurnIntoFault sendNext:self];
}

- (void)awakeFromFetch {
    [super awakeFromFetch];
    [self commonInit];
}

- (void)awakeFromInsert {
    [super awakeFromInsert];
    [self commonInit];
}

- (void)commonInit {
    // Hook for subclass
}

@end
