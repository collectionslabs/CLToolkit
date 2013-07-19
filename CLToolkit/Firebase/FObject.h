//
//  FObject.h
//  Collections
//
//  Created by Tony Xiao on 4/15/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import "Firebase.h"

@class FNode;
@interface FObject : RACManagedObject

@property (nonatomic, strong) FNode *ref;
@property (nonatomic, strong) NSString *fPath;

- (void)generateFPathIfMissing;

+ (instancetype)findByFPath:(NSString *)fPath;
+ (instancetype)findByFPath:(NSString *)fPath inContext:(NSManagedObjectContext *)context;
+ (instancetype)findByFPath:(NSString *)fPath inContext:(NSManagedObjectContext *)context createIfMissing:(BOOL)create;

+ (NSEntityDescription *)entityForFPath:(NSString *)fPath;

@end
