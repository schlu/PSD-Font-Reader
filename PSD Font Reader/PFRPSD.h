//
//  PFRPSD.h
//  PhotoshopHelper
//
//  Created by Nicholas Schlueter on 10/5/13.
//  Copyright (c) 2013 2 Limes. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMPSD;
@class PFRPSDLayer;

@interface PFRPSD : NSObject

@property (nonatomic, strong) FMPSD *fmPSD;
@property (nonatomic, strong) PFRPSDLayer *rootLayer;
@property (nonatomic, strong) NSArray *textParts;

+ (PFRPSD *)psdWithFMPSD:(FMPSD *)fmPSD;

@end
