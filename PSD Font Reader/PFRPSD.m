//
//  PFRPSD.m
//  PhotoshopHelper
//
//  Created by Nicholas Schlueter on 10/5/13.
//  Copyright (c) 2013 2 Limes. All rights reserved.
//

#import "PFRPSD.h"
#import "FMPSD.h"
#import "PFRPSDLayer.h"
#import "PFRTextPart.h"

@implementation PFRPSD

+ (PFRPSD *)psdWithFMPSD:(FMPSD *)fmPSD {
    PFRPSD *psd = [[PFRPSD alloc] init];
    psd.fmPSD = fmPSD;
    psd.rootLayer = [PFRPSDLayer psdLayerWithFMPSDLayer:fmPSD.baseLayerGroup psd:psd parent:nil];
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
