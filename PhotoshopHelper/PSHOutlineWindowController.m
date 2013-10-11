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
#import "PSHTextPart.h"

@interface PSHOutlineWindowController () <NSOutlineViewDataSource, NSOutlineViewDelegate, NSTextFieldDelegate>
@property (weak) IBOutlet NSTextField *documentSizeLabel;
@property (weak) IBOutlet NSTextField *colorLabel;
@property (weak) IBOutlet NSTextField *fontLabel;
@property (weak) IBOutlet NSTextField *scaleField;
@property (weak) IBOutlet NSOutlineView *outlineView;
@property (weak) IBOutlet NSTextField *frameLabel;
@property (weak) IBOutlet NSImageView *imageView;

@end

@implementation PSHOutlineWindowController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

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
    for (NSTextField *selectableField in @[self.documentSizeLabel, self.colorLabel, self.fontLabel, self.frameLabel]) {
        [selectableField setSelectable:YES];
        selectableField.stringValue = @"";
    }
    
    self.documentSizeLabel.stringValue = [NSString stringWithFormat:@"%dx%d", self.psd.fmPSD.width, self.psd.fmPSD.height];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectionChanged:) name:NSOutlineViewSelectionDidChangeNotification object:self.outlineView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scaleChanged) name:NSControlTextDidChangeNotification object:self.scaleField];
}

- (void)selectionChanged:(NSNotification *)notification {
    id item = [self.outlineView itemAtRow:[self.outlineView selectedRow]];
    PSHTextPart *textPart = nil;
    PSHPSDLayer *layer = nil;
    if ([item isKindOfClass:[PSHTextPart class]]) {
        textPart = item;
        layer = textPart.layer;
    } else {
        layer = item;
        if ([layer.textParts count] == 1) {
            textPart = layer.textParts[0];
        }
    }
    if (textPart) {
        self.colorLabel.stringValue = @"";
        self.fontLabel.stringValue = [textPart displayFontScaledBy:[self calculatedScale]];;
        NSLog(@"style sheet %@", textPart.styleSheet);
    } else {
        for (NSTextField *layerField in @[self.colorLabel, self.fontLabel]) {
            layerField.stringValue = @"";
        }
        
    }
    if (layer) {
        CGRect frame = layer.fmPSDLayer.frame;
        self.frameLabel.stringValue = [NSString stringWithFormat:@"x: %f y:%f width:%f height: %f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height];
        self.imageView.image = [[NSImage alloc] initWithCGImage:[layer.fmPSDLayer image] size:NSZeroSize];
    }
}

- (void)scaleChanged {
    [self selectionChanged:nil];
    [self.outlineView reloadData];
    [self  calculatedScale];
}

- (float)calculatedScale {
    NSNumber *value = @1;
    @try {
        NSExpression *expression = [NSExpression expressionWithFormat:[NSString stringWithFormat:@"1.0 * %@", self.scaleField.stringValue]];
        value = [expression expressionValueWithObject:nil context:nil];
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
    
    return [value floatValue];
}

#pragma mark - NSOutlineViewDataSource

/*******************************************************
 *
 * OUTLINE-VIEW DATASOURCE
 *
 *******************************************************/

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    if ([item isKindOfClass:[PSHTextPart class]]) {
        return NO;
    } else {
        PSHPSDLayer *layer = item;
        return [layer isExpandable];
    }
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    if ([item isKindOfClass:[PSHTextPart class]]) {
        return 0;
    } else {
        PSHPSDLayer *layer = item;
        if (layer==nil)
        {
            return [self.psd.rootLayer numberOfChildren];
        }
        else
        {
            return [layer numberOfChildren];
        }
    }
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    if (![item isKindOfClass:[PSHTextPart class]]) {
        PSHPSDLayer *layer = item;
        if (item == nil)
        {
            // Root
            return [self.psd.rootLayer childAtIndex:index];
        }
        
        if ([layer isExpandable])
        {
            return [layer childAtIndex:index];
        }
    }

    // File
    return nil;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)theColumn byItem:(id)item
{   
    if ([item isKindOfClass:[PSHTextPart class]]) {
        PSHTextPart *textPart = item;
        if ([[theColumn identifier] isEqualToString:@"LayerName"])
        {
            return textPart.textRepresented;
        }
        else if ([[theColumn identifier] isEqualToString:@"Font"])
        {
            return [textPart displayFontScaledBy:[self calculatedScale]];
        }
        else if ([[theColumn identifier] isEqualToString:@"Color"])
        {
            
        }
    } else {
        PSHPSDLayer *layer = item;
        PSHTextPart *textPart = nil;
        if ([layer.textParts count] == 1) {
            textPart = layer.textParts[0];
        }
        if ([[theColumn identifier] isEqualToString:@"LayerName"])
        {
            return layer.fmPSDLayer.layerName;
        }
        else if ([[theColumn identifier] isEqualToString:@"Font"] && textPart)
        {
            return [textPart displayFontScaledBy:[self calculatedScale]];
        }
        else if ([[theColumn identifier] isEqualToString:@"Color"] && textPart)
        {
            
            
        }
    }
    
    // Never reaches here
    return nil;
}

/*******************************************************
 *
 * OUTLINE-VIEW DELEGATE
 *
 *******************************************************/

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    return NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
    return YES;
}


@end
