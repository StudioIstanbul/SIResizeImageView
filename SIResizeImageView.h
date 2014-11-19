//
//  SIResizeImageView.h
//  Photoroute
//
//  Created by Andreas Zöllner on 19.11.14.
//  Copyright (c) 2014 Studio Istanbul Medya Hiz. Tic. Ltd. Sti. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SIResizeImageView : NSView {
    NSPoint lastDragPoint;
    NSTrackingArea* leftTop, *rightTop, *bottomLeft, *bottomRight, *currentArea;
    BOOL resizeOperation;
}
@property (nonatomic, strong) NSImage* image;

@end
