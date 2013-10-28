//
//  PSHTextPart.m
//  PhotoshopHelper
//
//  Created by Nicholas Schlueter on 10/5/13.
//  Copyright (c) 2013 2 Limes. All rights reserved.
//

#import "PSHTextPart.h"

@implementation PSHTextPart
 
- (BOOL)sameFontAsTextPart:(PSHTextPart *)textPart {
    if ([self.fontName isEqualToString:textPart.fontName]) {
        if (self.fontSize - textPart.fontSize < 0.01f) {
            return YES;
        }
    }
    return NO;
}

- (NSString *)displayFontScaledBy:(float)scale {
    return [NSString stringWithFormat:@"%@ %dpt", self.fontName, (int)roundf(self.fontSize*scale)];
}

@end
