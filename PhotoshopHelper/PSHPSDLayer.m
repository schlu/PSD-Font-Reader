//
//  PSHPSDLayer.m
//  PhotoshopHelper
//
//  Created by Nicholas Schlueter on 10/5/13.
//  Copyright (c) 2013 2 Limes. All rights reserved.
//

#import "PSHPSDLayer.h"
#import "FMPSD.h"

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

@end
