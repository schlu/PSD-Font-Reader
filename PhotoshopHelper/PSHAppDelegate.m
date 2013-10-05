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

@interface PSHAppDelegate ()
@property (weak) IBOutlet PSHDropView *dropView;

@end

@implementation PSHAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
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
                dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * .1);
                dispatch_after(delay, dispatch_get_main_queue(), ^(void){
                    [self.dropView processPsd:fileURL];
                });
                
            }
        }
    }];
}

@end
