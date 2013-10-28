//
//  PFRDropView.h
//  PhotoshopHelper
//
//  Created by Nicholas Schlueter on 10/4/13.
//  Copyright (c) 2013 2 Limes. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol PFRDropViewDelegate;

@interface PFRDropView : NSView

@property (nonatomic, weak) id<PFRDropViewDelegate> delegate;

- (void)processPsd:(NSURL *)fileUrl;

@end

@protocol PFRDropViewDelegate <NSObject>

- (void)dropViewStartedProcessing:(PFRDropView *)dropView;
- (void)dropViewFinishedProcessing:(PFRDropView *)dropView;

@end
