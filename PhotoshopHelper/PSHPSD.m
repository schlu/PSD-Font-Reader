//
//  PSHPSD.m
//  PhotoshopHelper
//
//  Created by Nicholas Schlueter on 10/5/13.
//  Copyright (c) 2013 2 Limes. All rights reserved.
//

#import "PSHPSD.h"
#import "FMPSD.h"
#import "PSHPSDLayer.h"
#import "PSHTextPart.h"

@implementation PSHPSD

+ (PSHPSD *)psdWithFMPSD:(FMPSD *)fmPSD {
    PSHPSD *psd = [[PSHPSD alloc] init];
    psd.fmPSD = fmPSD;
    psd.rootLayer = [PSHPSDLayer psdLayerWithFMPSDLayer:fmPSD.baseLayerGroup psd:psd parent:nil];
    return psd;
}

- (NSArray *)textParts {
    if (!_textParts) {
        NSMutableArray *recursiveParts = [self.rootLayer recursiveTextParts];
        [recursiveParts sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"textRepresented" ascending:YES]]];
        _textParts = recursiveParts;
        
    }
    
    return _textParts;
}

@end
