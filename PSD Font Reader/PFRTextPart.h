//
//  PFRTextPart.h
//  PhotoshopHelper
//
//  Created by Nicholas Schlueter on 10/5/13.
//  Copyright (c) 2013 2 Limes. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PFRPSDLayer;

@interface PFRTextPart : NSObject

@property (nonatomic, strong) NSString *fontName;
@property (nonatomic, assign) float fontSize;
@property (nonatomic, strong) NSString *textRepresented;
@property (nonatomic, weak) PFRPSDLayer *layer;
@property (nonatomic, strong) NSDictionary *styleSheet;
@property (nonatomic, strong) NSColor *color;

- (NSString *)displayFontScaledBy:(float)scale;

- (BOOL)sameFontAsTextPart:(PFRTextPart *)textPart;

@end
