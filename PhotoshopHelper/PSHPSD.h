//
//  PSHPSD.h
//  PhotoshopHelper
//
//  Created by Nicholas Schlueter on 10/5/13.
//  Copyright (c) 2013 2 Limes. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMPSD;
@class PSHPSDLayer;

@interface PSHPSD : NSObject

@property (nonatomic, strong) FMPSD *fmPSD;
@property (nonatomic, strong) PSHPSDLayer *rootLayer;
@property (nonatomic, strong) NSArray *textParts;

+ (PSHPSD *)psdWithFMPSD:(FMPSD *)fmPSD;

@end
