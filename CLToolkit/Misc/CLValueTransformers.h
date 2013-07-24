//
//  CLValueTransformers.h
//  Collections
//
//  Created by Tony Xiao on 7/4/12.
//  Copyright (c) 2012 Collections Labs, Inc. All rights reserved.
//

#import "Misc.h"

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

