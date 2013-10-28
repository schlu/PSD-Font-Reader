//
//  PFROulineWindowController.m
//  PhotoshopHelper
//
//  Created by Nicholas Schlueter on 10/4/13.
//  Copyright (c) 2013 2 Limes. All rights reserved.
//

#import "PFRPSDOutputController.h"
#import "PFRPSD.h"
#import "PFRPSDLayer.h"
#import "FMPSD.h"
#import "PFRTextPart.h"

@interface PFRPSDOutputController () <NSOutlineViewDataSource, NSOutlineViewDelegate, NSTextFieldDelegate, NSTableViewDataSource, NSTableViewDelegate>
@property (weak) IBOutlet NSTextField *documentSizeLabel;
@property (weak) IBOutlet NSTextField *colorLabel;
@property (weak) IBOutlet NSTextField *fontLabel;
@property (weak) IBOutlet NSTextField *scaleField;
@property (weak) IBOutlet NSOutlineView *outlineView;
@property (weak) IBOutlet NSTextField *frameLabel;
@property (weak) IBOutlet NSImageView *imageView;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSScrollView *tableContainer;
@property (weak) IBOutlet NSScrollView *outlineContainer;
@property (weak) IBOutlet NSTextField *layerNameLabel;

@end

@implementation PFRPSDOutputController

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
    [self.layerNameLabel.cell setLineBreakMode:NSLineBreakByTruncatingHead];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(outlineSelectionChanged:) name:NSOutlineViewSelectionDidChangeNotification object:self.outlineView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableSelectionChanged:) name:NSTableViewSelectionDidChangeNotification object:self.tableView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scaleChanged) name:NSControlTextDidChangeNotification object:self.scaleField];
}

- (void)tableSelectionChanged:(NSNotification *)notification {
    [self displayTextPart:[self.psd textParts][[self.tableView selectedRow]]];
}

- (void)outlineSelectionChanged:(NSNotification *)notification {
    id item = [self.outlineView itemAtRow:[self.outlineView selectedRow]];
    PFRTextPart *textPart = nil;
    PFRPSDLayer *layer = nil;
    if ([item isKindOfClass:[PFRTextPart class]]) {
        textPart = item;
        layer = textPart.layer;
    } else {
        layer = item;
        if ([layer.textParts count] == 1) {
            textPart = layer.textParts[0];
        }
    }
    if (textPart) {
        [self displayTextPart:textPart];
    } else {
        for (NSTextField *layerField in @[self.colorLabel, self.fontLabel]) {
            layerField.stringValue = @"";
        }
        [self displayPSDLayer:layer];
    }
}

- (void)displayTextPart:(PFRTextPart *)textPart {
    if (textPart) {
        NSString* hexString = [NSString stringWithFormat:@"#%02X%02X%02X",
                               (int) (textPart.color.redComponent * 0xFF), (int) (textPart.color.greenComponent * 0xFF),
                               (int) (textPart.color.blueComponent * 0xFF)];
        self.colorLabel.stringValue = hexString;
        self.fontLabel.stringValue = [textPart displayFontScaledBy:[self calculatedScale]];
        NSMutableArray *layerParts = [NSMutableArray array];
        PFRPSDLayer *currentLayer = textPart.layer;
        [layerParts addObject:currentLayer.fmPSDLayer.layerName];
        while ((currentLayer = currentLayer.parent)) {
            [layerParts insertObject:currentLayer.fmPSDLayer.layerName atIndex:0];
        }
        [layerParts removeObjectAtIndex:0];
        self.layerNameLabel.stringValue = [layerParts componentsJoinedByString:@" > "];
        [self displayPSDLayer:textPart.layer];
    }
}

- (void)displayPSDLayer:(PFRPSDLayer *)layer {
    CGRect frame = layer.fmPSDLayer.frame;
    self.frameLabel.stringValue = [NSString stringWithFormat:@"x: %d y: %d width: %d height: %d", (int)frame.origin.x, (int)layer.fmPSDLayer.top, (int)frame.size.width, (int)frame.size.height];
    
    self.imageView.image = [[NSImage alloc] initWithCGImage:[layer.fmPSDLayer image] size:NSZeroSize];
}

- (void)scaleChanged {
    [self outlineSelectionChanged:nil];
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
- (IBAction)segmentChanged:(id)sender {
    NSSegmentedControl *segmentedControl = sender;
    if (segmentedControl.selectedSegment == 0) {
        [self.tableContainer setHidden:NO];
        [self.outlineContainer setHidden:YES];
    } else {
        [self.tableContainer setHidden:YES];
        [self.outlineContainer setHidden:NO];
    }
}

#pragma mark - NSTableViewDelegate AND NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [[self.psd textParts] count];
}


- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    PFRTextPart *textPart = [self.psd textParts][row];
    
    if ([[tableColumn identifier] isEqualToString:@"Text"]) {
        return textPart.textRepresented;
    } else if ([[tableColumn identifier] isEqualToString:@"Font"]) {
        return [textPart displayFontScaledBy:[self calculatedScale]];
    } else if ([[tableColumn identifier] isEqualToString:@"Color"]) {
        NSString* hexString = [NSString stringWithFormat:@"#%02X%02X%02X",
                               (int) (textPart.color.redComponent * 0xFF), (int) (textPart.color.greenComponent * 0xFF),
                               (int) (textPart.color.blueComponent * 0xFF)];
        return hexString;
    }
    
    return nil;
}

#pragma mark - NSOutlineViewDataSource AND NSOutlineViewDelegate

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    if ([item isKindOfClass:[PFRTextPart class]]) {
        return NO;
    } else {
        PFRPSDLayer *layer = item;
        return [layer isExpandable];
    }
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    if ([item isKindOfClass:[PFRTextPart class]]) {
        return 0;
    } else {
        PFRPSDLayer *layer = item;
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
    if (![item isKindOfClass:[PFRTextPart class]]) {
        PFRPSDLayer *layer = item;
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
    NSLog(@"[theColumn identifier] %@", [theColumn identifier]);
    PFRTextPart *textPart = nil;
    if ([item isKindOfClass:[PFRTextPart class]]) {
        textPart = item;
        if ([[theColumn identifier] isEqualToString:@"LayerName"])
        {
            return textPart.textRepresented;
        }
    } else {
        PFRPSDLayer *layer = item;
        if ([layer.textParts count] == 1) {
            textPart = layer.textParts[0];
        }
        if ([[theColumn identifier] isEqualToString:@"LayerName"])
        {
            return layer.fmPSDLayer.layerName;
        }
    }
    
    if ([[theColumn identifier] isEqualToString:@"Font"] && textPart)
    {
        return [textPart displayFontScaledBy:[self calculatedScale]];
    }
    else if ([[theColumn identifier] isEqualToString:@"Color"] && textPart)
    {
        NSString* hexString = [NSString stringWithFormat:@"#%02X%02X%02X",
                               (int) (textPart.color.redComponent * 0xFF), (int) (textPart.color.greenComponent * 0xFF),
                               (int) (textPart.color.blueComponent * 0xFF)];
        return hexString;
    }
    
    // Never reaches here
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    return NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
    return YES;
}


@end
