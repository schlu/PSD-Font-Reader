//
//  PSHPSDLayer.m
//  PhotoshopHelper
//
//  Created by Nicholas Schlueter on 10/5/13.
//  Copyright (c) 2013 2 Limes. All rights reserved.
//

#import "PSHPSDLayer.h"
#import "FMPSD.h"
#import "FMPSDTextEngineParser.h"
#import "PSHTextPart.h"

@implementation PSHPSDLayer

+ (PSHPSDLayer *)psdLayerWithFMPSDLayer:(FMPSDLayer *)fmPSDLayer psd:(PSHPSD *)psd parent:(PSHPSDLayer *)parent {
    PSHPSDLayer *psdLayer = [[PSHPSDLayer alloc] init];
    psdLayer.psd = psd;
    psdLayer.parent = parent;
    psdLayer.fmPSDLayer = fmPSDLayer;
    psdLayer.children = [NSMutableArray array];
    for (FMPSDLayer *layer in fmPSDLayer.layers) {
        PSHPSDLayer *child = [PSHPSDLayer psdLayerWithFMPSDLayer:layer psd:psd parent:psdLayer];
        if (layer.isText) {
            child.hasTextDecendant = NO;
            [child markParentsForText];
        }
        [psdLayer.children addObject:child];
    }
    return psdLayer;
}

- (void)markParentsForText {
    for (PSHPSDLayer *ancestor in [self ancestors]) {
        ancestor.hasTextDecendant = YES;
    }
}

- (NSMutableArray *)childrenToDisplay {
    if (!_childrenToDisplay) {
        _childrenToDisplay = [NSMutableArray array];
        for (PSHPSDLayer *child in self.children) {
            if (child.hasTextDecendant || child.fmPSDLayer.isText) {
                [self.childrenToDisplay addObject:child];
            }
        }
    }
    
    return _childrenToDisplay;
}

- (NSMutableArray *)ancestors {
    NSMutableArray *ancestors = [NSMutableArray array];
    PSHPSDLayer *up = self.parent;
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
                        PSHTextPart *textPart = [[PSHTextPart alloc] init];
                        textPart.layer = self;
                        textPart.textRepresented = partString;
                        
                        NSDictionary *styleSheet = parsedTextProperties[@"EngineDict"][@"StyleRun"][@"RunArray"][currentStyle][@"StyleSheet"][@"StyleSheetData"];
                        textPart.fontName = [self fontNames][[styleSheet[@"Font"] intValue]];
                        textPart.fontSize = [styleSheet[@"FontSize"] floatValue];
                        textPart.styleSheet = styleSheet;
                        
                        if (currentStyle > 0 && [textPart sameFontAsTextPart:[_textParts lastObject]]) {
                            PSHTextPart *lastTextPart = [_textParts lastObject];
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

@end
