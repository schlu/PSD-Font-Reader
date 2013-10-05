//
//  PSHPSDLayer.h
//  PhotoshopHelper
//
//  Created by Nicholas Schlueter on 10/5/13.
//  Copyright (c) 2013 2 Limes. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMPSDLayer;
@class PSHPSD;

@interface PSHPSDLayer : NSObject

+ (PSHPSDLayer *)psdLayerWithFMPSDLayer:(FMPSDLayer *)fmPSDLayer psd:(PSHPSD *)psd parent:(PSHPSDLayer *)parent;

@property (nonatomic, weak) PSHPSD *psd;
@property (nonatomic, weak) PSHPSDLayer *parent;
@property (nonatomic, strong) FMPSDLayer *fmPSDLayer;
@property (nonatomic, strong) NSMutableArray *children;
@property (nonatomic, strong) NSMutableArray *childrenToDisplay;
@property (nonatomic, assign) BOOL hasTextDecendant;

@end
