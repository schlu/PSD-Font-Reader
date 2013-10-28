//
//  PFRPSDLayer.m
//  PhotoshopHelper
//
//  Created by Nicholas Schlueter on 10/5/13.
//  Copyright (c) 2013 2 Limes. All rights reserved.
//

#import "PFRPSDLayer.h"
#import "FMPSD.h"
#import "FMPSDTextEngineParser.h"
#import "PFRTextPart.h"

@implementation PFRPSDLayer

+ (PFRPSDLayer *)psdLayerWithFMPSDLayer:(FMPSDLayer *)fmPSDLayer psd:(PFRPSD *)psd parent:(PFRPSDLayer *)parent {
    PFRPSDLayer *psdLayer = [[PFRPSDLayer alloc] init];
    psdLayer.psd = psd;
    psdLayer.parent = parent;
    psdLayer.fmPSDLayer = fmPSDLayer;
    psdLayer.children = [NSMutableArray array];
    for (FMPSDLayer *layer in fmPSDLayer.layers) {
        PFRPSDLayer *child = [PFRPSDLayer psdLayerWithFMPSDLayer:layer psd:psd parent:psdLayer];
        if (layer.isText) {
            child.hasTextDecendant = NO;
            [child markParentsForText];
        }
        [psdLayer.children addObject:child];
    }
    return psdLayer;
}

- (void)markParentsForText {
    for (PFRPSDLayer *ancestor in [self ancestors]) {
        ancestor.hasTextDecendant = YES;
    }
}

- (NSMutableArray *)childrenToDisplay {
    if (!_childrenToDisplay) {
        _childrenToDisplay = [NSMutableArray array];
        for (PFRPSDLayer *child in self.children) {
            if (child.hasTextDecendant || child.fmPSDLayer.isText) {
                [self.childrenToDisplay addObject:child];
            }
        }
    }
    
    return _childrenToDisplay;
}

- (NSMutableArray *)ancestors {
    NSMutableArray *ancestors = [NSMutableArray array];
    PFRPSDLayer *up = self.parent;
    while (up) {
        [ancestors addObject:up];
        up = up.parent;
    }
    return ancestors;
}

- (BOOL)isText {
    return self.fmPSDLayer.isText;
}

- (BOOL)isExpandable {
    return [self numberOfChildren] > 0;
}

- (NSInteger)numberOfChildren {
    if (self.hasTextDecendant) {
        return [self.childrenToDisplay count];
    } else if ([self.textParts count] > 1) {
        return [self.textParts count];
    }
    return 0;
}

- (id)childAtIndex:(NSInteger)index {
    if (self.hasTextDecendant) {
        return self.childrenToDisplay[index];
    } else if ([self.textParts count] > 0) {
        return self.textParts[index];
    }
    return nil;
}

- (NSArray *)fontNames {
    if ([self isText]) {
        NSMutableArray *fontNames = [NSMutableArray array];
        NSDictionary *parsedTextProperties = [self parsedTextProperties];
        if (parsedTextProperties) {
            if (parsedTextProperties[@"ResourceDict"] && parsedTextProperties[@"ResourceDict"][@"FontSet"]) {
                for (NSDictionary *fontDict in parsedTextProperties[@"ResourceDict"][@"FontSet"]) {
                    if ([fontDict isKindOfClass:[NSDictionary class]] && fontDict[@"Name"]) {
                        [fontNames addObject:fontDict[@"Name"]];
                    }
                }
            }
        }
        
        return fontNames;
    } else {
        return @[];
    }
}

- (NSDictionary *)parsedTextProperties {
    FMPSDTextEngineParser *parser = self.fmPSDLayer.textDescriptor.attributes[@"EngineData"];
    if (parser && parser.parsedProperties) {
        return parser.parsedProperties;
    } else {
        return nil;
    }
}

- (NSMutableArray *)textParts {
    if (!_textParts) {
        _textParts = [NSMutableArray array];
        if ([self isText]) {
            NSDictionary *parsedTextProperties = [self parsedTextProperties];
            if (parsedTextProperties && parsedTextProperties[@"EngineDict"][@"StyleRun"] && parsedTextProperties[@"EngineDict"][@"Editor"]) {
                NSString *text = parsedTextProperties[@"EngineDict"][@"Editor"][@"Text"];
                NSInteger currentChar = 0;
                NSArray *runLengths = [parsedTextProperties[@"EngineDict"][@"StyleRun"][@"RunLengthArray"] componentsSeparatedByString:@" "];
                NSInteger currentStyle = 0;
                for (NSString *runLength in runLengths) {
                    if (![runLength isEqualToString:@"["] && ![runLength isEqualToString:@"]"]) {
                        NSInteger charCount = [runLength integerValue];
                        if (currentChar + charCount > [text length]) {
                            charCount = charCount - 1;
                        }
                        NSString *partString = [text substringWithRange:NSMakeRange(currentChar, charCount)];
                        currentChar += charCount;
                        PFRTextPart *textPart = [[PFRTextPart alloc] init];
                        textPart.layer = self;
                        textPart.textRepresented = partString;
                        
                        NSDictionary *styleSheet = parsedTextProperties[@"EngineDict"][@"StyleRun"][@"RunArray"][currentStyle][@"StyleSheet"][@"StyleSheetData"];
                        textPart.fontName = [self fontNames][[styleSheet[@"Font"] intValue]];
                        textPart.fontSize = [styleSheet[@"FontSize"] floatValue];
                        
                        NSArray *colorParts = [styleSheet[@"FillColor"][@"Values"] componentsSeparatedByString:@" "];
                        if ([colorParts count] == 6) {
                            textPart.color = [NSColor colorWithCalibratedRed:[colorParts[2] floatValue] green:[colorParts[3] floatValue] blue:[colorParts[4] floatValue] alpha:[colorParts[1] floatValue]];
                        }
                        
                        textPart.styleSheet = styleSheet;
                        
                        if (currentStyle > 0 && [textPart sameFontAsTextPart:[_textParts lastObject]]) {
                            PFRTextPart *lastTextPart = [_textParts lastObject];
                            lastTextPart.textRepresented = [lastTextPart.textRepresented stringByAppendingString:textPart.textRepresented];
                        } else {
                            [_textParts addObject:textPart];
                        }
                        
                        currentStyle++;
                    }
                }
            }
        }
    }
    
    return _textParts;
}

- (NSMutableArray *)recursiveTextParts {
    NSMutableArray * recursiveTextParts = [NSMutableArray array];
    if ([self isText]) {
        return self.textParts;
    } else {
        for (PFRPSDLayer *layer in self.children) {
            [recursiveTextParts addObjectsFromArray:[layer recursiveTextParts]];
        }
    }
    return recursiveTextParts;
}

@end
