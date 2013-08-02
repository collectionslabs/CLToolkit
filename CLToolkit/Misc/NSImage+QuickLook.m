//
//  NSImage+QuickLook.m
//  QuickLookTest
//
//  Created by Matt Gemmell on 29/10/2007.
//
#if TARGETING_OSX
#import "NSImage+QuickLook.h"
#import <QuickLook/QuickLook.h> // Remember to import the QuickLook framework into your project!

@implementation NSImage (QuickLook)

+ (NSImage *)imageWithPreviewOfFileAtURL:(NSURL *)url ofSize:(NSSize)size asIcon:(BOOL)icon {
    if (!url.isFileURL)
        return nil;
    
    NSDictionary *dict = @{(NSString *)kQLThumbnailOptionIconModeKey: @(icon)};
    CGImageRef ref = QLThumbnailImageCreate(kCFAllocatorDefault,
                                            (__bridge CFURLRef)url,
                                            CGSizeMake(size.width, size.height),
                                            (__bridge CFDictionaryRef)dict);
    if (ref != NULL) {
        // Take advantage of NSBitmapImageRep's -initWithCGImage: initializer, new in Leopard,
        // which is a lot more efficient than copying pixel data into a brand new NSImage.
        // Thanks to Troy Stephens @ Apple for pointing this new method out to me.
        NSBitmapImageRep *bitmapImageRep = [[NSBitmapImageRep alloc] initWithCGImage:ref];
        NSImage *newImage = nil;
        if (bitmapImageRep) {
            newImage = [[NSImage alloc] initWithSize:[bitmapImageRep size]];
            [newImage addRepresentation:bitmapImageRep];
        }
        CFRelease(ref);
        if (newImage)
            return newImage;
    } else {
        // If we couldn't get a Quick Look preview, fall back on the file's Finder icon.
        NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:url.path];
        if (icon) {
            [icon setSize:size];
        }
        return icon;
    }
    
    return nil;
}


@end
#endif
