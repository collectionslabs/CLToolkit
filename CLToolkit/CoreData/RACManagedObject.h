//
//  RACManagedObject.h
//  Collections
//
//  Created by Tony Xiao on 4/15/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

@interface RACManagedObject : NSManagedObject

- (RACSignal *)onWillAccessValue;
- (RACSignal *)onDidAccessValue;
- (RACSignal *)onWillSave;
- (RACSignal *)onDidSave;
- (RACSignal *)onPrepareDelete;
- (RACSignal *)onFaultWillFire;
- (RACSignal *)onFaultDidFire;
- (RACSignal *)onWillTurnIntoFault;
- (RACSignal *)onDidTurnIntoFault;

- (void)commonInit;

@end
