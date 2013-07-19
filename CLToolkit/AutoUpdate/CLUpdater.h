//
//  CLUpdater.h
//  Collections
//
//  Created by Tony Xiao on 11/21/12.
//  Copyright (c) 2012 Collections Labs, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLUpdater : NSObject
@property (nonatomic, strong) NSPanel *releaseNotesPanel;
@property (nonatomic, assign) BOOL updateReady;

- (IBAction)installUpdateIfReady:(id)sender;
- (IBAction)checkForUpdatesWithUI:(id)sender;
- (IBAction)showReleaseNotes:(id)sender;

- (void)checkForUpdatesInBackground;
- (void)startAutoUpdater;

+ (id)sharedUpdater;

@end
