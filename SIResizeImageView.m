//
//  SIResizeImageView.m
//  Photoroute
//
//  Created by Andreas Zöllner on 19.11.14.
//  Copyright (c) 2014 Studio Istanbul Medya Hiz. Tic. Ltd. Sti. All rights reserved.
//

#import "SIResizeImageView.h"

@implementation SIResizeImageView
@synthesize image;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        resizeOperation = NO;
    }
    
    return self;
}

/*-(void)setFrame:(NSRect)frame
{
    [super setFrame:frame];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self adjustTrackingAreas];
    });
}

-(void)setBounds:(NSRect)frame
{
    [super setBounds:frame];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self adjustTrackingAreas];
    });
}

-(void)adjustTrackingAreas {
    NSRect leftTopRect = NSMakeRect(0, self.frame.size.height - 20, 20, 20);
    //NSRect leftTopRect = NSMakeRect(0, 0, 20, 20);
    leftTop = [[NSTrackingArea alloc] initWithRect:leftTopRect options:NSTrackingMouseMoved | NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways owner:self userInfo:nil];
    [self up]
}*/

-(void)updateTrackingAreas {
    if (!resizeOperation) {
        NSLog(@"update tracking areas");
        [super updateTrackingAreas];
        NSRect leftTopRect = NSMakeRect(0, self.frame.size.height - 20, 20, 20);
        NSRect rightTopRect = NSMakeRect(self.frame.size.width-20, self.frame.size.height - 20, 20, 20);
        NSRect bottomLeftRect = NSMakeRect(0, 0, 20, 20);
        NSRect bottomRightRect = NSMakeRect(self.frame.size.width - 20, 0, 20, 20);
        [self removeTrackingArea:leftTop];
        [self removeTrackingArea:rightTop];
        [self removeTrackingArea:bottomLeft];
        [self removeTrackingArea:bottomRight];
        NSString *cursorName = @"resizenorthwestsoutheast";
        NSString *cursorName2 = @"resizenortheastsouthwest";
        NSString *cursorPath = [@"/System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/HIServices.framework/Versions/A/Resources/cursors" stringByAppendingPathComponent:cursorName];
        NSString *cursorPath2 = [@"/System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/HIServices.framework/Versions/A/Resources/cursors" stringByAppendingPathComponent:cursorName2];
        NSImage *cimage = [[NSImage alloc] initByReferencingFile:[cursorPath stringByAppendingPathComponent:@"cursor.pdf"]];
         NSImage *cimage2 = [[NSImage alloc] initByReferencingFile:[cursorPath2 stringByAppendingPathComponent:@"cursor.pdf"]];
        NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:[cursorPath stringByAppendingPathComponent:@"info.plist"]];
        NSDictionary *info2 = [NSDictionary dictionaryWithContentsOfFile:[cursorPath2 stringByAppendingPathComponent:@"info.plist"]];
        NSCursor *cursor = [[NSCursor alloc] initWithImage:cimage hotSpot:NSMakePoint([[info valueForKey:@"hotx"] doubleValue], [[info valueForKey:@"hoty"] doubleValue])];
        NSCursor *rightCursor = [[NSCursor alloc] initWithImage:cimage2 hotSpot:NSMakePoint([[info2 valueForKey:@"hotx"] doubleValue], [[info2 valueForKey:@"hoty"] doubleValue])];
        leftTop = [[NSTrackingArea alloc] initWithRect:leftTopRect options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways | NSTrackingAssumeInside | NSTrackingCursorUpdate owner:self userInfo:[NSDictionary dictionaryWithObject:cursor forKey:@"cursor"]];
        rightTop = [[NSTrackingArea alloc] initWithRect:rightTopRect options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways | NSTrackingAssumeInside | NSTrackingCursorUpdate owner:self userInfo:[NSDictionary dictionaryWithObject:rightCursor forKey:@"cursor"]];
        bottomLeft = [[NSTrackingArea alloc] initWithRect:bottomLeftRect options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways | NSTrackingAssumeInside | NSTrackingCursorUpdate owner:self userInfo:[NSDictionary dictionaryWithObject:rightCursor forKey:@"cursor"]];
        bottomRight = [[NSTrackingArea alloc] initWithRect:bottomRightRect options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways | NSTrackingAssumeInside | NSTrackingCursorUpdate owner:self userInfo:[NSDictionary dictionaryWithObject:cursor forKey:@"cursor"]];
        [self addTrackingArea:leftTop];
        [self addTrackingArea:rightTop];
        [self addTrackingArea:bottomLeft];
        [self addTrackingArea:bottomRight];
    }
    
}

- (void)drawRect:(NSRect)dirtyRect
{
    //// Color Declarations
    NSColor* color = [NSColor colorWithCalibratedRed: 0.5 green: 0.5 blue: 0.5 alpha: 1];
    NSColor* color2 = [NSColor colorWithCalibratedRed: 1 green: 1 blue: 1 alpha: 1];
    
    //// Shadow Declarations
    NSShadow* shadow = [[NSShadow alloc] init];
    [shadow setShadowColor: [[NSColor blackColor] colorWithAlphaComponent: 0.27]];
    [shadow setShadowOffset: NSMakeSize(3.1, -3.1)];
    [shadow setShadowBlurRadius: 5];
    
    //// Frames
    NSRect frame = NSMakeRect(self.bounds.origin.x + 5, self.bounds.origin.y + 15, self.bounds.size.width-20, self.bounds.size.height-20);
    
    //// Rectangle Drawing
    NSBezierPath* rectanglePath = [NSBezierPath bezierPathWithRect: NSMakeRect(NSMinX(frame), NSMinY(frame), NSWidth(frame), NSHeight(frame))];
    [NSGraphicsContext saveGraphicsState];
    [shadow set];
    [color setFill];
    [rectanglePath fill];

    [NSGraphicsContext restoreGraphicsState];
    
    [color2 setStroke];
    [rectanglePath setLineWidth: 2.5];
    [rectanglePath stroke];
    [self.image drawInRect:NSInsetRect(frame, 2, 2) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
}

#pragma mark mouse events

- (void)cursorUpdate:(NSEvent *)event;
{
    if (resizeOperation && currentArea) {
        [((NSCursor*)[currentArea.userInfo objectForKey:@"cursor"]) set];
    } else {
        NSPoint hitPoint;
        NSTrackingArea *trackingArea;
        
        trackingArea = [event trackingArea];
        if (!trackingArea) NSLog(@"event without tracking area");
        hitPoint = [self convertPoint:[event locationInWindow]
                             fromView:nil];
        if (NSPointInRect(hitPoint, trackingArea.rect)) {
            [((NSCursor*)[[trackingArea userInfo] objectForKey:@"cursor"]) set];
        } else {
            [[NSCursor arrowCursor] set];
        }
    }
}

-(BOOL)acceptsFirstMouse:(NSEvent *)theEvent {
    return YES;
}

- (void)mouseDown:(NSEvent *) e {
    
    // Convert to superview's coordinate space
    lastDragPoint = [[self superview] convertPoint:[e locationInWindow] fromView:nil];
    for (NSTrackingArea* area in [self trackingAreas]) {
        if (NSPointInRect([self convertPoint:[e locationInWindow] fromView:nil], area.rect)) {
            currentArea = area;
            resizeOperation = YES;
        }
    }
}

- (void)mouseDragged:(NSEvent *)theEvent {
    NSPoint newDragLocation = [[self superview] convertPoint:[theEvent locationInWindow] fromView:nil];
    NSPoint thisOrigin = [self frame].origin;
    thisOrigin.x += (-lastDragPoint.x + newDragLocation.x);
    thisOrigin.y += (-lastDragPoint.y + newDragLocation.y);
    double adjustX = (lastDragPoint.x - newDragLocation.x);
    double adjustY = (lastDragPoint.y - newDragLocation.y);
    if (!resizeOperation) {
        [self setFrameOrigin:thisOrigin];
    } else {
        if (currentArea == leftTop) {
            NSRect newRect = NSMakeRect(self.frame.origin.x - adjustX, self.frame.origin.y, self.frame.size.width + adjustX, self.frame.size.height - adjustY);
            [self setFrame:newRect];
            resizeOperation = YES;
        } else if (currentArea == rightTop) {
            NSRect newRect = NSMakeRect(self.frame.origin.x, self.frame.origin.y, self.frame.size.width - adjustX, self.frame.size.height - adjustY);
            [self setFrame:newRect];
            resizeOperation = YES;
        } else if (currentArea == bottomLeft) {
            NSRect newRect = NSMakeRect(self.frame.origin.x - adjustX, self.frame.origin.y - adjustY, self.frame.size.width + adjustX, self.frame.size.height + adjustY);
            [self setFrame:newRect];
            resizeOperation = YES;
        } else if (currentArea == bottomRight) {
            NSRect newRect = NSMakeRect(self.frame.origin.x, self.frame.origin.y - adjustY, self.frame.size.width - adjustX, self.frame.size.height + adjustY);
            [self setFrame:newRect];
            resizeOperation = YES;
        }
    }
    lastDragPoint = newDragLocation;
}

-(void)mouseUp:(NSEvent *)theEvent {
    resizeOperation = NO;
    currentArea = nil;
    [self updateTrackingAreas];
}

-(void)mouseEntered:(NSEvent *)theEvent {
    [super mouseEntered:theEvent];
    if (theEvent.trackingArea == leftTop) {
    }
}

-(void)mouseExited:(NSEvent *)theEvent {
    [super mouseExited:theEvent];
    if (!resizeOperation && [NSEvent pressedMouseButtons] != 1 << 0) {
    }
}

@end
