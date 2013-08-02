//
//  Web.h
//  Collections
//
//  Created by Tony Xiao on 7/19/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import "Core.h"

#if TARGETING_OSX
#import <WebKit/WebKit.h>

WebScriptObject *ToWebScript(WebScriptObject *windowScriptObject, id json);
id FromWebScript(WebScriptObject *windowScriptObject, WebScriptObject *webScriptObject);
#endif