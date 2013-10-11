//
//  PSHTextPart.h
//  PhotoshopHelper
//
//  Created by Nicholas Schlueter on 10/5/13.
//  Copyright (c) 2013 2 Limes. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PSHPSDLayer;

@interface PSHTextPart : NSObject

@property (nonatomic, strong) NSString *fontName;
@property (nonatomic, assign) float fontSize;
@property (nonatomic, strong) NSString *textRepresented;
@property (nonatomic, weak) PSHPSDLayer *layer;
@property (nonatomic, strong) NSDictionary *styleSheet;

- (NSString *)displayFontScaledBy:(float)scale;

- (BOOL)sameFontAsTextPart:(PSHTextPart *)textPart;

@end
