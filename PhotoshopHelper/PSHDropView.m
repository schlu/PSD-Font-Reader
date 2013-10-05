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

- (id)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        [self registerForDraggedTypes:@[NSFilenamesPboardType]];
        self.windowControllers = [NSMutableArray array];
    }
    
    return self;
}

- (void)processPsd:(NSURL *)fileUrl {
    NSError *err;
    FMPSD *psd = [FMPSD imageWithContetsOfURL:fileUrl error:&err];
    if (!psd) {
        NSLog(@"Error loading PSD: %@", err);
    }
    
    PSHOutlineWindowController *windowController = [[PSHOutlineWindowController alloc] initWithWindowNibName:@"PSHOutlineWindowController"];
    [self.windowControllers addObject:windowController];
    windowController.psd = [PSHPSD psdWithFMPSD:psd];
    [windowController showWindow:self];
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

@end
