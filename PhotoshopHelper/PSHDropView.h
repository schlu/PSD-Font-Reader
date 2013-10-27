//
//  PSHDropView.h
//  PhotoshopHelper
//
//  Created by Nicholas Schlueter on 10/4/13.
//  Copyright (c) 2013 2 Limes. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol PSHDropViewDelegate;

@interface PSHDropView : NSView

@property (nonatomic, weak) id<PSHDropViewDelegate> delegate;

- (void)processPsd:(NSURL *)fileUrl;

@end

@protocol PSHDropViewDelegate <NSObject>

- (void)dropViewStartedProcessing:(PSHDropView *)dropView;
- (void)dropViewFinishedProcessing:(PSHDropView *)dropView;

@end
