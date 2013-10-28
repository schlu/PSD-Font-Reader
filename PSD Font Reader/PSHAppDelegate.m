//
//  PSHAppDelegate.m
//  PhotoshopHelper
//
//  Created by Nicholas Schlueter on 10/3/13.
//  Copyright (c) 2013 2 Limes. All rights reserved.
//

#import "PSHAppDelegate.h"
#import "FMPSD.h"
#import "PSHDropView.h"

@interface PSHAppDelegate () <PSHDropViewDelegate>

@property (weak) IBOutlet PSHDropView *dropView;
@property (weak) IBOutlet NSProgressIndicator *activityIndicator;
@property (weak) IBOutlet NSButton *choosePSDButton;

@end

@implementation PSHAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.dropView.delegate = self;
}

- (IBAction)pickFolderAction:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO];
    panel.allowedFileTypes = @[@"psd"];
    [panel beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            for (NSURL *fileURL in [panel URLs]) {
                [self.dropView processPsd:fileURL];
            }
        }
    }];
}

#pragma mark - PSHDropViewDelegate

- (void)dropViewStartedProcessing:(PSHDropView *)dropView {
    [self.activityIndicator startAnimation:nil];
    [self.choosePSDButton setHidden:YES];
}

- (void)dropViewFinishedProcessing:(PSHDropView *)dropView {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.activityIndicator stopAnimation:nil];
        [self.choosePSDButton setHidden:NO];
    });
}

@end
