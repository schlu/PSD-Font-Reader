//
//  PFRPSDLayer.h
//  PhotoshopHelper
//
//  Created by Nicholas Schlueter on 10/5/13.
//  Copyright (c) 2013 2 Limes. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMPSDLayer;
@class PFRPSD;

@interface PFRPSDLayer : NSObject

@property (nonatomic, weak) PFRPSD *psd;
@property (nonatomic, weak) PFRPSDLayer *parent;
@property (nonatomic, strong) FMPSDLayer *fmPSDLayer;
@property (nonatomic, strong) NSMutableArray *children;
@property (nonatomic, strong) NSMutableArray *childrenToDisplay;
@property (nonatomic, assign) BOOL hasTextDecendant;
@property (nonatomic, strong) NSMutableArray *textParts;

+ (PFRPSDLayer *)psdLayerWithFMPSDLayer:(FMPSDLayer *)fmPSDLayer psd:(PFRPSD *)psd parent:(PFRPSDLayer *)parent;

- (BOOL)isText;
- (NSArray *)fontNames;
- (BOOL)isExpandable;
- (NSInteger)numberOfChildren;
- (id)childAtIndex:(NSInteger)index;
- (NSMutableArray *)recursiveTextParts;

@end
