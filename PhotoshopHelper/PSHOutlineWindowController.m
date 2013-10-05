//
//  PSHOulineWindowController.m
//  PhotoshopHelper
//
//  Created by Nicholas Schlueter on 10/4/13.
//  Copyright (c) 2013 2 Limes. All rights reserved.
//

#import "PSHOutlineWindowController.h"
#import "PSHPSD.h"
#import "PSHPSDLayer.h"
#import "FMPSD.h"

@interface PSHOutlineWindowController () <NSOutlineViewDataSource>

@end

@implementation PSHOutlineWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

#pragma mark - NSOutlineViewDataSource

/*******************************************************
 *
 * OUTLINE-VIEW DATASOURCE
 *
 *******************************************************/

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    PSHPSDLayer *layer = item;
    if (layer.fmPSDLayer.isGroup)
        return YES;
    else
        return NO;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    PSHPSDLayer *layer = item;
    if (layer==nil)
    {
        return [self.psd.rootLayer.childrenToDisplay count];
    }
    else
    {
        if (layer.hasTextDecendant)
        {
            return [layer.childrenToDisplay count];
        }
        else
        {
            return 0;
        }
    }
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    PSHPSDLayer *layer = item;
    if (item == nil)
    {
        // Root
        return self.psd.rootLayer.childrenToDisplay[index];
    }
    
    if (layer.fmPSDLayer.isGroup)
    {
        return layer.childrenToDisplay[index];
    }
    
    // File
    return nil;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)theColumn byItem:(id)item
{
    PSHPSDLayer *layer = item;
    if ([[theColumn identifier] isEqualToString:@"LayerName"])
    {
        return layer.fmPSDLayer.layerName;
    }
    else if ([[theColumn identifier] isEqualToString:@"FontName"])
    {
        
    }
    else if ([[theColumn identifier] isEqualToString:@"FontSize"])
    {
        
    }
    
    // Never reaches here
    return nil;
}

/*******************************************************
 *
 * OUTLINE-VIEW DELEGATE
 *
 *******************************************************/

//- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
//{
//    return YES;
//}
//
//- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
//{
//    return NO;
//}
//
//- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
//    [cell setDrawsBackground:NO];
//    
//    if ([item isFileHidden]) [cell setTextColor:[NSColor grayColor]];
//    else [cell setTextColor:[NSColor whiteColor]];
//    
//    if ([[tableColumn identifier] isEqualToString:@"NameColumn"])
//    {
//        if ([item isFolder])
//            [cell setImage:[[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kGenericFolderIcon)] size:15.0];
//        else
//            [cell setImage:[[NSWorkspace sharedWorkspace] iconForFile:item] size:15.0];
//        
//        if ([item isFileHidden])
//        {
//            [cell setFileHidden:YES];
//        }
//        else
//        {
//            [cell setFileHidden:NO];
//        }
//        
//    }


@end
