//
//  Web.m
//  Collections
//
//  Created by Tony Xiao on 7/19/13.
//  Copyright (c) 2013 Collections Labs, Inc. All rights reserved.
//

#import "Web.h"

#if TARGET_OSX

WebScriptObject *ToWebScript(WebScriptObject *windowScriptObject, id json) {
    WebScriptObject *parser = [windowScriptObject valueForKey:@"JSON"];
    return [parser callWebScriptMethod:@"parse" withArguments:@[$jsonDumps(json)]];
}

id FromWebScript(WebScriptObject *windowScriptObject, WebScriptObject *webScriptObject) {
    WebScriptObject *parser = [windowScriptObject valueForKey:@"JSON"];
    return $jsonLoads([parser callWebScriptMethod:@"stringify" withArguments:@[webScriptObject]]);
}
#endif