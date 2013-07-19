//
//  NSAttributeDescription+CLExtensions.h
//  Collections
//
//  Created by Tony Xiao on 4/10/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSAttributeDescription (CLExtensions)

- (NSValueTransformer *)valueTransformer;

// From CoreData -> JSON
- (id)transformedValue:(id)value;

// From JSON -> CoreData
- (id)reverseTransformedValue:(id)value;

@end

@interface NSRelationshipDescription (CLExtensions)

@property (nonatomic, assign) BOOL isInverse;

@end