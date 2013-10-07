//
//  PSHTextPart.h
//  PhotoshopHelper
//
//  Created by Nicholas Schlueter on 10/5/13.
//  Copyright (c) 2013 2 Limes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSHTextPart : NSObject

@property (nonatomic, strong) NSString *fontName;
@property (nonatomic, assign) float fontSize;
@property (nonatomic, strong) NSString *textRepresented;

@end
