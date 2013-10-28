//
//  PSHDropView.m
//  PhotoshopHelper
//
//  Created by Nicholas Schlueter on 10/4/13.
//  Copyright (c) 2013 2 Limes. All rights reserved.
//

#import "PSHDropView.h"
#import "FMPSD.h"
#import "PSHOutlineWindowController.h"
#import "PSHPSD.h"

@interface PSHDropView () <NSDraggingDestination>

@property (nonatomic, strong) NSMutableArray *windowControllers;

@end

@implementation PSHDropView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        [self registerForDraggedTypes:@[NSFilenamesPboardType]];
        self.windowControllers = [NSMutableArray array];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:nil];
    
    return self;
}

- (void)processPsd:(NSURL *)fileUrl {
    [self.delegate dropViewStartedProcessing:self];
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * .1);
    dispatch_after(delay, dispatch_get_main_queue(), ^(void){
        NSError *err;
        FMPSD *psd = [FMPSD imageWithContetsOfURL:fileUrl error:&err];
        if (!psd) {
            NSLog(@"Error loading PSD: %@", err);
        }
        
        PSHOutlineWindowController *windowController = [[PSHOutlineWindowController alloc] initWithWindowNibName:@"PSHOutlineWindowController"];
        [self.windowControllers addObject:windowController];
        windowController.psd = [PSHPSD psdWithFMPSD:psd];
        [windowController showWindow:self];
        [self.delegate dropViewFinishedProcessing:self];
    });
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    NSPasteboard *pboard = [((id<NSDraggingInfo>)sender) draggingPasteboard];
    NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
    if ([files count] != 1) {
        return NSDragOperationNone;
    }
    
    NSString *fileName = files[0];
    NSURL *fileUrl = [NSURL fileURLWithPath:fileName];
    BOOL isDir;
    [[NSFileManager defaultManager] fileExistsAtPath:fileName isDirectory:&isDir];
    if (![fileUrl.pathExtension isEqualToString:@"psd"] || isDir) {
        return NSDragOperationNone;
    }
    
    return NSDragOperationCopy;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    return YES;
}

- (void)concludeDragOperation:(id < NSDraggingInfo >)sender {
    NSPasteboard *pboard = [((id<NSDraggingInfo>)sender) draggingPasteboard];
    NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
    
    NSString *fileName = files[0];
    NSURL *fileUrl = [NSURL fileURLWithPath:fileName];
    [self processPsd:fileUrl];
}

- (void)windowWillClose:(NSNotification *)notification {
    NSWindow *window = notification.object;
    if (window.windowController && [self.windowControllers containsObject:window.windowController]) {
        [self.windowControllers removeObject:window.windowController];
    }
}

@end
