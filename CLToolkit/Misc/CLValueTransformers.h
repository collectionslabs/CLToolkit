//
//  CLValueTransformers.h
//  Collections
//
//  Created by Tony Xiao on 7/4/12.
//  Copyright (c) 2012 Collections Labs, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLWebViewProgressTransformer : NSValueTransformer
@end

@interface CLJSONValueTransformer : NSValueTransformer
@end

@interface CLURLValueTransformer : NSValueTransformer
@end

@interface CLOppositeBoolValueTransformer : NSValueTransformer
@end

@interface CLDateToRelativeStringValueTransformer : NSValueTransformer
@end

@interface CLArrayCountValueTransformer : NSValueTransformer
@end

@interface CLFileSizeValueTransformer : NSValueTransformer
@end

@interface CLDisplayAttrValueTransformer : NSValueTransformer
@end

@interface CLDisplayTextValueTransformer : NSValueTransformer
@end

@interface CLDisplayDateValueTransformer : NSValueTransformer
@end

@interface CLDisplayLocationValueTransformer : NSValueTransformer
@end

@interface CLDisplayImageValueTransformer : NSValueTransformer
@end

@interface CLDisplayNumberValueTransformer : NSValueTransformer
@end

// to_one / to_many