//
//  NSImage+QuickLook.h
//  QuickLookTest
//
//  Created by Matt Gemmell on 29/10/2007.
//
#if TARGETING_OSX
#import <Cocoa/Cocoa.h>

@interface NSImage (QuickLook)

+ (NSImage *)imageWithPreviewOfFileAtURL:(NSURL *)url ofSize:(NSSize)size asIcon:(BOOL)icon;


@end
#endif