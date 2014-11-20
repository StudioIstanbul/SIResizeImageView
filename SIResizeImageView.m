//
//  SIResizeImageView.m
//  Photoroute
//
//  Created by Andreas Zöllner on 19.11.14.
//  Copyright (c) 2014 Studio Istanbul Medya Hiz. Tic. Ltd. Sti. All rights reserved.
//

#import "SIResizeImageView.h"

@implementation SIResizeImageView
@synthesize image, minSize, preserveAspect;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        resizeOperation = NO;
        inTrackingArea = NO;
        minSize = NSMakeSize(70, 70);
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
    [rectanglePath setLineWidth: 5];
    [rectanglePath stroke];
    [self.image drawInRect:NSInsetRect(frame, 2, 2) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    
    if (inTrackingArea || resizeOperation) {
        NSBezierPath* edges = [NSBezierPath bezierPath];
        [edges moveToPoint:NSMakePoint(frame.origin.x, frame.origin.y + (frame.size.height*0.2))];
        [edges lineToPoint:frame.origin];
        [edges lineToPoint:NSMakePoint(frame.origin.x + (frame.size.height*0.2), frame.origin.y)];
        
        [edges moveToPoint:NSMakePoint(frame.origin.x + frame.size.width - (frame.size.height*0.2), frame.origin.y)];
         [edges lineToPoint:NSMakePoint(frame.origin.x + frame.size.width, frame.origin.y)];
         [edges lineToPoint:NSMakePoint(frame.origin.x + frame.size.width, frame.origin.y + (frame.size.height*0.2))];
        [edges moveToPoint:NSMakePoint(frame.origin.x + frame.size.width, frame.origin.y + frame.size.height - (frame.size.height*0.2))];
        [edges lineToPoint:NSMakePoint(frame.origin.x + frame.size.width, frame.origin.y + frame.size.height)];
        [edges lineToPoint:NSMakePoint(frame.origin.x + frame.size.width  - (frame.size.height*0.2), frame.origin.y + frame.size.height)];
        [edges moveToPoint:NSMakePoint(frame.origin.x + (frame.size.height*0.2), frame.origin.y + frame.size.height)];
        [edges lineToPoint:NSMakePoint(frame.origin.x, frame.size.height + frame.origin.y)];
        [edges lineToPoint:NSMakePoint(frame.origin.x, frame.origin.y + frame.size.height  - (frame.size.height*0.2))];
        [edges setLineWidth:8];
        [[NSColor redColor] setStroke];
        [edges stroke];
        
        //// Color Declarations
        NSColor* shadowColor2 = [NSColor colorWithCalibratedRed: 1 green: 1 blue: 1 alpha: 1];
        NSColor* color2 = [NSColor colorWithCalibratedRed: 0.199 green: 0.199 blue: 0.199 alpha: 1];
        
        //// Shadow Declarations
        NSShadow* shadow = [[NSShadow alloc] init];
        [shadow setShadowColor: [shadowColor2 colorWithAlphaComponent: 0.33]];
        [shadow setShadowOffset: NSMakeSize(0.1, 1.1)];
        [shadow setShadowBlurRadius: 2];
        NSShadow* shadow2 = [[NSShadow alloc] init];
        [shadow2 setShadowColor: [[NSColor blackColor] colorWithAlphaComponent: 0.59]];
        [shadow2 setShadowOffset: NSMakeSize(0.1, -2.1)];
        [shadow2 setShadowBlurRadius: 3];
        
        //// Frames        
        //// Subframes
        NSRect resize = NSMakeRect(NSMinX(frame) + floor((NSWidth(frame) - 45) * 0.50000 + 0.5), NSMinY(frame) + floor((NSHeight(frame) - 45) * 0.50000 + 0.5), 45, 45);
        
        
        //// resize
        {
            //// Group 2
            {
                //// Group 3
                {
                    //// Bezier 5 Drawing
                    NSBezierPath* bezier5Path = [NSBezierPath bezierPath];
                    [bezier5Path moveToPoint: NSMakePoint(NSMinX(resize) + 0.92898 * NSWidth(resize), NSMinY(resize) + 1.00000 * NSHeight(resize))];
                    [bezier5Path lineToPoint: NSMakePoint(NSMinX(resize) + 0.95464 * NSWidth(resize), NSMinY(resize) + 0.99482 * NSHeight(resize))];
                    [bezier5Path lineToPoint: NSMakePoint(NSMinX(resize) + 0.95571 * NSWidth(resize), NSMinY(resize) + 0.99480 * NSHeight(resize))];
                    [bezier5Path lineToPoint: NSMakePoint(NSMinX(resize) + 0.95613 * NSWidth(resize), NSMinY(resize) + 0.99451 * NSHeight(resize))];
                    [bezier5Path curveToPoint: NSMakePoint(NSMinX(resize) + 0.95729 * NSWidth(resize), NSMinY(resize) + 0.99376 * NSHeight(resize)) controlPoint1: NSMakePoint(NSMinX(resize) + 0.95693 * NSWidth(resize), NSMinY(resize) + 0.99436 * NSHeight(resize)) controlPoint2: NSMakePoint(NSMinX(resize) + 0.95651 * NSWidth(resize), NSMinY(resize) + 0.99453 * NSHeight(resize))];
                    [bezier5Path lineToPoint: NSMakePoint(NSMinX(resize) + 0.97920 * NSWidth(resize), NSMinY(resize) + 0.97920 * NSHeight(resize))];
                    [bezier5Path lineToPoint: NSMakePoint(NSMinX(resize) + 0.99371 * NSWidth(resize), NSMinY(resize) + 0.95733 * NSHeight(resize))];
                    [bezier5Path curveToPoint: NSMakePoint(NSMinX(resize) + 0.99451 * NSWidth(resize), NSMinY(resize) + 0.95613 * NSHeight(resize)) controlPoint1: NSMakePoint(NSMinX(resize) + 0.99453 * NSWidth(resize), NSMinY(resize) + 0.95651 * NSHeight(resize)) controlPoint2: NSMakePoint(NSMinX(resize) + 0.99436 * NSWidth(resize), NSMinY(resize) + 0.95696 * NSHeight(resize))];
                    [bezier5Path curveToPoint: NSMakePoint(NSMinX(resize) + 0.99480 * NSWidth(resize), NSMinY(resize) + 0.95476 * NSHeight(resize)) controlPoint1: NSMakePoint(NSMinX(resize) + 0.99498 * NSWidth(resize), NSMinY(resize) + 0.95544 * NSHeight(resize)) controlPoint2: NSMakePoint(NSMinX(resize) + 0.99480 * NSWidth(resize), NSMinY(resize) + 0.95587 * NSHeight(resize))];
                    [bezier5Path lineToPoint: NSMakePoint(NSMinX(resize) + 1.00000 * NSWidth(resize), NSMinY(resize) + 0.92898 * NSHeight(resize))];
                    [bezier5Path lineToPoint: NSMakePoint(NSMinX(resize) + 1.00000 * NSWidth(resize), NSMinY(resize) + 0.64493 * NSHeight(resize))];
                    [bezier5Path curveToPoint: NSMakePoint(NSMinX(resize) + 0.92898 * NSWidth(resize), NSMinY(resize) + 0.57391 * NSHeight(resize)) controlPoint1: NSMakePoint(NSMinX(resize) + 1.00000 * NSWidth(resize), NSMinY(resize) + 0.60571 * NSHeight(resize)) controlPoint2: NSMakePoint(NSMinX(resize) + 0.96820 * NSWidth(resize), NSMinY(resize) + 0.57391 * NSHeight(resize))];
                    [bezier5Path curveToPoint: NSMakePoint(NSMinX(resize) + 0.85798 * NSWidth(resize), NSMinY(resize) + 0.64493 * NSHeight(resize)) controlPoint1: NSMakePoint(NSMinX(resize) + 0.88976 * NSWidth(resize), NSMinY(resize) + 0.57391 * NSHeight(resize)) controlPoint2: NSMakePoint(NSMinX(resize) + 0.85798 * NSWidth(resize), NSMinY(resize) + 0.60571 * NSHeight(resize))];
                    [bezier5Path lineToPoint: NSMakePoint(NSMinX(resize) + 0.85798 * NSWidth(resize), NSMinY(resize) + 0.75756 * NSHeight(resize))];
                    [bezier5Path lineToPoint: NSMakePoint(NSMinX(resize) + 0.64780 * NSWidth(resize), NSMinY(resize) + 0.54738 * NSHeight(resize))];
                    [bezier5Path curveToPoint: NSMakePoint(NSMinX(resize) + 0.54736 * NSWidth(resize), NSMinY(resize) + 0.54738 * NSHeight(resize)) controlPoint1: NSMakePoint(NSMinX(resize) + 0.62007 * NSWidth(resize), NSMinY(resize) + 0.51964 * NSHeight(resize)) controlPoint2: NSMakePoint(NSMinX(resize) + 0.57511 * NSWidth(resize), NSMinY(resize) + 0.51964 * NSHeight(resize))];
                    [bezier5Path curveToPoint: NSMakePoint(NSMinX(resize) + 0.54736 * NSWidth(resize), NSMinY(resize) + 0.64780 * NSHeight(resize)) controlPoint1: NSMakePoint(NSMinX(resize) + 0.51964 * NSWidth(resize), NSMinY(resize) + 0.57511 * NSHeight(resize)) controlPoint2: NSMakePoint(NSMinX(resize) + 0.51964 * NSWidth(resize), NSMinY(resize) + 0.62007 * NSHeight(resize))];
                    [bezier5Path lineToPoint: NSMakePoint(NSMinX(resize) + 0.75753 * NSWidth(resize), NSMinY(resize) + 0.85798 * NSHeight(resize))];
                    [bezier5Path lineToPoint: NSMakePoint(NSMinX(resize) + 0.64493 * NSWidth(resize), NSMinY(resize) + 0.85798 * NSHeight(resize))];
                    [bezier5Path curveToPoint: NSMakePoint(NSMinX(resize) + 0.57391 * NSWidth(resize), NSMinY(resize) + 0.92898 * NSHeight(resize)) controlPoint1: NSMakePoint(NSMinX(resize) + 0.60571 * NSWidth(resize), NSMinY(resize) + 0.85798 * NSHeight(resize)) controlPoint2: NSMakePoint(NSMinX(resize) + 0.57391 * NSWidth(resize), NSMinY(resize) + 0.88976 * NSHeight(resize))];
                    [bezier5Path curveToPoint: NSMakePoint(NSMinX(resize) + 0.64493 * NSWidth(resize), NSMinY(resize) + 1.00000 * NSHeight(resize)) controlPoint1: NSMakePoint(NSMinX(resize) + 0.57391 * NSWidth(resize), NSMinY(resize) + 0.96820 * NSHeight(resize)) controlPoint2: NSMakePoint(NSMinX(resize) + 0.60571 * NSWidth(resize), NSMinY(resize) + 1.00000 * NSHeight(resize))];
                    [bezier5Path lineToPoint: NSMakePoint(NSMinX(resize) + 0.92898 * NSWidth(resize), NSMinY(resize) + 1.00000 * NSHeight(resize))];
                    [bezier5Path closePath];
                    [bezier5Path setMiterLimit: 4];
                    [NSGraphicsContext saveGraphicsState];
                    [shadow set];
                    [color2 setFill];
                    [bezier5Path fill];
                    
                    ////// Bezier 5 Inner Shadow
                    NSRect bezier5BorderRect = NSInsetRect([bezier5Path bounds], -shadow2.shadowBlurRadius, -shadow2.shadowBlurRadius);
                    bezier5BorderRect = NSOffsetRect(bezier5BorderRect, -shadow2.shadowOffset.width, -shadow2.shadowOffset.height);
                    bezier5BorderRect = NSInsetRect(NSUnionRect(bezier5BorderRect, [bezier5Path bounds]), -1, -1);
                    
                    NSBezierPath* bezier5NegativePath = [NSBezierPath bezierPathWithRect: bezier5BorderRect];
                    [bezier5NegativePath appendBezierPath: bezier5Path];
                    [bezier5NegativePath setWindingRule: NSEvenOddWindingRule];
                    
                    [NSGraphicsContext saveGraphicsState];
                    {
                        NSShadow* shadow2WithOffset = [shadow2 copy];
                        CGFloat xOffset = shadow2WithOffset.shadowOffset.width + round(bezier5BorderRect.size.width);
                        CGFloat yOffset = shadow2WithOffset.shadowOffset.height;
                        shadow2WithOffset.shadowOffset = NSMakeSize(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset));
                        [shadow2WithOffset set];
                        [[NSColor grayColor] setFill];
                        [bezier5Path addClip];
                        NSAffineTransform* transform = [NSAffineTransform transform];
                        [transform translateXBy: -round(bezier5BorderRect.size.width) yBy: 0];
                        [[transform transformBezierPath: bezier5NegativePath] fill];
                    }
                    [NSGraphicsContext restoreGraphicsState];
                    
                    [NSGraphicsContext restoreGraphicsState];
                    
                }
                
                
                //// Group 4
                {
                    //// Bezier 6 Drawing
                    NSBezierPath* bezier6Path = [NSBezierPath bezierPath];
                    [bezier6Path moveToPoint: NSMakePoint(NSMinX(resize) + 0.58244 * NSWidth(resize), NSMinY(resize) + 0.47002 * NSHeight(resize))];
                    [bezier6Path curveToPoint: NSMakePoint(NSMinX(resize) + 0.62431 * NSWidth(resize), NSMinY(resize) + 0.46822 * NSHeight(resize)) controlPoint1: NSMakePoint(NSMinX(resize) + 0.61111 * NSWidth(resize), NSMinY(resize) + 0.46818 * NSHeight(resize)) controlPoint2: NSMakePoint(NSMinX(resize) + 0.59716 * NSWidth(resize), NSMinY(resize) + 0.46873 * NSHeight(resize))];
                    [bezier6Path lineToPoint: NSMakePoint(NSMinX(resize) + 0.64780 * NSWidth(resize), NSMinY(resize) + 0.45264 * NSHeight(resize))];
                    [bezier6Path lineToPoint: NSMakePoint(NSMinX(resize) + 0.85798 * NSWidth(resize), NSMinY(resize) + 0.24247 * NSHeight(resize))];
                    [bezier6Path lineToPoint: NSMakePoint(NSMinX(resize) + 0.85798 * NSWidth(resize), NSMinY(resize) + 0.35509 * NSHeight(resize))];
                    [bezier6Path curveToPoint: NSMakePoint(NSMinX(resize) + 0.92898 * NSWidth(resize), NSMinY(resize) + 0.42609 * NSHeight(resize)) controlPoint1: NSMakePoint(NSMinX(resize) + 0.85798 * NSWidth(resize), NSMinY(resize) + 0.39429 * NSHeight(resize)) controlPoint2: NSMakePoint(NSMinX(resize) + 0.88976 * NSWidth(resize), NSMinY(resize) + 0.42609 * NSHeight(resize))];
                    [bezier6Path curveToPoint: NSMakePoint(NSMinX(resize) + 1.00000 * NSWidth(resize), NSMinY(resize) + 0.35507 * NSHeight(resize)) controlPoint1: NSMakePoint(NSMinX(resize) + 0.96820 * NSWidth(resize), NSMinY(resize) + 0.42609 * NSHeight(resize)) controlPoint2: NSMakePoint(NSMinX(resize) + 1.00000 * NSWidth(resize), NSMinY(resize) + 0.39429 * NSHeight(resize))];
                    [bezier6Path lineToPoint: NSMakePoint(NSMinX(resize) + 1.00000 * NSWidth(resize), NSMinY(resize) + 0.07102 * NSHeight(resize))];
                    [bezier6Path lineToPoint: NSMakePoint(NSMinX(resize) + 0.99480 * NSWidth(resize), NSMinY(resize) + 0.04524 * NSHeight(resize))];
                    [bezier6Path curveToPoint: NSMakePoint(NSMinX(resize) + 0.99451 * NSWidth(resize), NSMinY(resize) + 0.04387 * NSHeight(resize)) controlPoint1: NSMakePoint(NSMinX(resize) + 0.99480 * NSWidth(resize), NSMinY(resize) + 0.04413 * NSHeight(resize)) controlPoint2: NSMakePoint(NSMinX(resize) + 0.99498 * NSWidth(resize), NSMinY(resize) + 0.04456 * NSHeight(resize))];
                    [bezier6Path curveToPoint: NSMakePoint(NSMinX(resize) + 0.99373 * NSWidth(resize), NSMinY(resize) + 0.04269 * NSHeight(resize)) controlPoint1: NSMakePoint(NSMinX(resize) + 0.99436 * NSWidth(resize), NSMinY(resize) + 0.04307 * NSHeight(resize)) controlPoint2: NSMakePoint(NSMinX(resize) + 0.99453 * NSWidth(resize), NSMinY(resize) + 0.04349 * NSHeight(resize))];
                    [bezier6Path lineToPoint: NSMakePoint(NSMinX(resize) + 0.97920 * NSWidth(resize), NSMinY(resize) + 0.02080 * NSHeight(resize))];
                    [bezier6Path lineToPoint: NSMakePoint(NSMinX(resize) + 0.95729 * NSWidth(resize), NSMinY(resize) + 0.00627 * NSHeight(resize))];
                    [bezier6Path curveToPoint: NSMakePoint(NSMinX(resize) + 0.95613 * NSWidth(resize), NSMinY(resize) + 0.00549 * NSHeight(resize)) controlPoint1: NSMakePoint(NSMinX(resize) + 0.95651 * NSWidth(resize), NSMinY(resize) + 0.00547 * NSHeight(resize)) controlPoint2: NSMakePoint(NSMinX(resize) + 0.95693 * NSWidth(resize), NSMinY(resize) + 0.00564 * NSHeight(resize))];
                    [bezier6Path curveToPoint: NSMakePoint(NSMinX(resize) + 0.95473 * NSWidth(resize), NSMinY(resize) + 0.00520 * NSHeight(resize)) controlPoint1: NSMakePoint(NSMinX(resize) + 0.95542 * NSWidth(resize), NSMinY(resize) + 0.00502 * NSHeight(resize)) controlPoint2: NSMakePoint(NSMinX(resize) + 0.95587 * NSWidth(resize), NSMinY(resize) + 0.00520 * NSHeight(resize))];
                    [bezier6Path lineToPoint: NSMakePoint(NSMinX(resize) + 0.92898 * NSWidth(resize), NSMinY(resize) + 0.00000 * NSHeight(resize))];
                    [bezier6Path lineToPoint: NSMakePoint(NSMinX(resize) + 0.64493 * NSWidth(resize), NSMinY(resize) + 0.00000 * NSHeight(resize))];
                    [bezier6Path curveToPoint: NSMakePoint(NSMinX(resize) + 0.57391 * NSWidth(resize), NSMinY(resize) + 0.07102 * NSHeight(resize)) controlPoint1: NSMakePoint(NSMinX(resize) + 0.60571 * NSWidth(resize), NSMinY(resize) + 0.00000 * NSHeight(resize)) controlPoint2: NSMakePoint(NSMinX(resize) + 0.57391 * NSWidth(resize), NSMinY(resize) + 0.03180 * NSHeight(resize))];
                    [bezier6Path curveToPoint: NSMakePoint(NSMinX(resize) + 0.64493 * NSWidth(resize), NSMinY(resize) + 0.14202 * NSHeight(resize)) controlPoint1: NSMakePoint(NSMinX(resize) + 0.57391 * NSWidth(resize), NSMinY(resize) + 0.11024 * NSHeight(resize)) controlPoint2: NSMakePoint(NSMinX(resize) + 0.60571 * NSWidth(resize), NSMinY(resize) + 0.14202 * NSHeight(resize))];
                    [bezier6Path lineToPoint: NSMakePoint(NSMinX(resize) + 0.75753 * NSWidth(resize), NSMinY(resize) + 0.14204 * NSHeight(resize))];
                    [bezier6Path lineToPoint: NSMakePoint(NSMinX(resize) + 0.54736 * NSWidth(resize), NSMinY(resize) + 0.35220 * NSHeight(resize))];
                    [bezier6Path curveToPoint: NSMakePoint(NSMinX(resize) + 0.54736 * NSWidth(resize), NSMinY(resize) + 0.45262 * NSHeight(resize)) controlPoint1: NSMakePoint(NSMinX(resize) + 0.51964 * NSWidth(resize), NSMinY(resize) + 0.37993 * NSHeight(resize)) controlPoint2: NSMakePoint(NSMinX(resize) + 0.51964 * NSWidth(resize), NSMinY(resize) + 0.42489 * NSHeight(resize))];
                    [bezier6Path curveToPoint: NSMakePoint(NSMinX(resize) + 0.58244 * NSWidth(resize), NSMinY(resize) + 0.47002 * NSHeight(resize)) controlPoint1: NSMakePoint(NSMinX(resize) + 0.55878 * NSWidth(resize), NSMinY(resize) + 0.46107 * NSHeight(resize)) controlPoint2: NSMakePoint(NSMinX(resize) + 0.56829 * NSWidth(resize), NSMinY(resize) + 0.46833 * NSHeight(resize))];
                    [bezier6Path closePath];
                    [bezier6Path setMiterLimit: 4];
                    [NSGraphicsContext saveGraphicsState];
                    [shadow set];
                    [color2 setFill];
                    [bezier6Path fill];
                    
                    ////// Bezier 6 Inner Shadow
                    NSRect bezier6BorderRect = NSInsetRect([bezier6Path bounds], -shadow2.shadowBlurRadius, -shadow2.shadowBlurRadius);
                    bezier6BorderRect = NSOffsetRect(bezier6BorderRect, -shadow2.shadowOffset.width, -shadow2.shadowOffset.height);
                    bezier6BorderRect = NSInsetRect(NSUnionRect(bezier6BorderRect, [bezier6Path bounds]), -1, -1);
                    
                    NSBezierPath* bezier6NegativePath = [NSBezierPath bezierPathWithRect: bezier6BorderRect];
                    [bezier6NegativePath appendBezierPath: bezier6Path];
                    [bezier6NegativePath setWindingRule: NSEvenOddWindingRule];
                    
                    [NSGraphicsContext saveGraphicsState];
                    {
                        NSShadow* shadow2WithOffset = [shadow2 copy];
                        CGFloat xOffset = shadow2WithOffset.shadowOffset.width + round(bezier6BorderRect.size.width);
                        CGFloat yOffset = shadow2WithOffset.shadowOffset.height;
                        shadow2WithOffset.shadowOffset = NSMakeSize(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset));
                        [shadow2WithOffset set];
                        [[NSColor grayColor] setFill];
                        [bezier6Path addClip];
                        NSAffineTransform* transform = [NSAffineTransform transform];
                        [transform translateXBy: -round(bezier6BorderRect.size.width) yBy: 0];
                        [[transform transformBezierPath: bezier6NegativePath] fill];
                    }
                    [NSGraphicsContext restoreGraphicsState];
                    
                    [NSGraphicsContext restoreGraphicsState];
                    
                }
                
                
                //// Group 5
                {
                    //// Bezier 7 Drawing
                    NSBezierPath* bezier7Path = [NSBezierPath bezierPath];
                    [bezier7Path moveToPoint: NSMakePoint(NSMinX(resize) + 0.38729 * NSWidth(resize), NSMinY(resize) + 0.47002 * NSHeight(resize))];
                    [bezier7Path curveToPoint: NSMakePoint(NSMinX(resize) + 0.42913 * NSWidth(resize), NSMinY(resize) + 0.46822 * NSHeight(resize)) controlPoint1: NSMakePoint(NSMinX(resize) + 0.41593 * NSWidth(resize), NSMinY(resize) + 0.46818 * NSHeight(resize)) controlPoint2: NSMakePoint(NSMinX(resize) + 0.40198 * NSWidth(resize), NSMinY(resize) + 0.46873 * NSHeight(resize))];
                    [bezier7Path lineToPoint: NSMakePoint(NSMinX(resize) + 0.45262 * NSWidth(resize), NSMinY(resize) + 0.45264 * NSHeight(resize))];
                    [bezier7Path curveToPoint: NSMakePoint(NSMinX(resize) + 0.45262 * NSWidth(resize), NSMinY(resize) + 0.35220 * NSHeight(resize)) controlPoint1: NSMakePoint(NSMinX(resize) + 0.48036 * NSWidth(resize), NSMinY(resize) + 0.42489 * NSHeight(resize)) controlPoint2: NSMakePoint(NSMinX(resize) + 0.48036 * NSWidth(resize), NSMinY(resize) + 0.37993 * NSHeight(resize))];
                    [bezier7Path lineToPoint: NSMakePoint(NSMinX(resize) + 0.24244 * NSWidth(resize), NSMinY(resize) + 0.14202 * NSHeight(resize))];
                    [bezier7Path lineToPoint: NSMakePoint(NSMinX(resize) + 0.35507 * NSWidth(resize), NSMinY(resize) + 0.14202 * NSHeight(resize))];
                    [bezier7Path curveToPoint: NSMakePoint(NSMinX(resize) + 0.42609 * NSWidth(resize), NSMinY(resize) + 0.07102 * NSHeight(resize)) controlPoint1: NSMakePoint(NSMinX(resize) + 0.39429 * NSWidth(resize), NSMinY(resize) + 0.14202 * NSHeight(resize)) controlPoint2: NSMakePoint(NSMinX(resize) + 0.42609 * NSWidth(resize), NSMinY(resize) + 0.11024 * NSHeight(resize))];
                    [bezier7Path curveToPoint: NSMakePoint(NSMinX(resize) + 0.35507 * NSWidth(resize), NSMinY(resize) + 0.00000 * NSHeight(resize)) controlPoint1: NSMakePoint(NSMinX(resize) + 0.42609 * NSWidth(resize), NSMinY(resize) + 0.03180 * NSHeight(resize)) controlPoint2: NSMakePoint(NSMinX(resize) + 0.39429 * NSWidth(resize), NSMinY(resize) + 0.00000 * NSHeight(resize))];
                    [bezier7Path lineToPoint: NSMakePoint(NSMinX(resize) + 0.07102 * NSWidth(resize), NSMinY(resize) + 0.00000 * NSHeight(resize))];
                    [bezier7Path lineToPoint: NSMakePoint(NSMinX(resize) + 0.04524 * NSWidth(resize), NSMinY(resize) + 0.00520 * NSHeight(resize))];
                    [bezier7Path curveToPoint: NSMakePoint(NSMinX(resize) + 0.04387 * NSWidth(resize), NSMinY(resize) + 0.00549 * NSHeight(resize)) controlPoint1: NSMakePoint(NSMinX(resize) + 0.04411 * NSWidth(resize), NSMinY(resize) + 0.00520 * NSHeight(resize)) controlPoint2: NSMakePoint(NSMinX(resize) + 0.04456 * NSWidth(resize), NSMinY(resize) + 0.00502 * NSHeight(resize))];
                    [bezier7Path curveToPoint: NSMakePoint(NSMinX(resize) + 0.04269 * NSWidth(resize), NSMinY(resize) + 0.00627 * NSHeight(resize)) controlPoint1: NSMakePoint(NSMinX(resize) + 0.04304 * NSWidth(resize), NSMinY(resize) + 0.00564 * NSHeight(resize)) controlPoint2: NSMakePoint(NSMinX(resize) + 0.04349 * NSWidth(resize), NSMinY(resize) + 0.00547 * NSHeight(resize))];
                    [bezier7Path lineToPoint: NSMakePoint(NSMinX(resize) + 0.02080 * NSWidth(resize), NSMinY(resize) + 0.02080 * NSHeight(resize))];
                    [bezier7Path lineToPoint: NSMakePoint(NSMinX(resize) + 0.00627 * NSWidth(resize), NSMinY(resize) + 0.04269 * NSHeight(resize))];
                    [bezier7Path curveToPoint: NSMakePoint(NSMinX(resize) + 0.00547 * NSWidth(resize), NSMinY(resize) + 0.04387 * NSHeight(resize)) controlPoint1: NSMakePoint(NSMinX(resize) + 0.00547 * NSWidth(resize), NSMinY(resize) + 0.04349 * NSHeight(resize)) controlPoint2: NSMakePoint(NSMinX(resize) + 0.00564 * NSWidth(resize), NSMinY(resize) + 0.04307 * NSHeight(resize))];
                    [bezier7Path curveToPoint: NSMakePoint(NSMinX(resize) + 0.00520 * NSWidth(resize), NSMinY(resize) + 0.04524 * NSHeight(resize)) controlPoint1: NSMakePoint(NSMinX(resize) + 0.00502 * NSWidth(resize), NSMinY(resize) + 0.04456 * NSHeight(resize)) controlPoint2: NSMakePoint(NSMinX(resize) + 0.00520 * NSWidth(resize), NSMinY(resize) + 0.04413 * NSHeight(resize))];
                    [bezier7Path lineToPoint: NSMakePoint(NSMinX(resize) + 0.00000 * NSWidth(resize), NSMinY(resize) + 0.07102 * NSHeight(resize))];
                    [bezier7Path lineToPoint: NSMakePoint(NSMinX(resize) + 0.00000 * NSWidth(resize), NSMinY(resize) + 0.35507 * NSHeight(resize))];
                    [bezier7Path curveToPoint: NSMakePoint(NSMinX(resize) + 0.07102 * NSWidth(resize), NSMinY(resize) + 0.42609 * NSHeight(resize)) controlPoint1: NSMakePoint(NSMinX(resize) + 0.00000 * NSWidth(resize), NSMinY(resize) + 0.39429 * NSHeight(resize)) controlPoint2: NSMakePoint(NSMinX(resize) + 0.03180 * NSWidth(resize), NSMinY(resize) + 0.42609 * NSHeight(resize))];
                    [bezier7Path curveToPoint: NSMakePoint(NSMinX(resize) + 0.14202 * NSWidth(resize), NSMinY(resize) + 0.35507 * NSHeight(resize)) controlPoint1: NSMakePoint(NSMinX(resize) + 0.11024 * NSWidth(resize), NSMinY(resize) + 0.42609 * NSHeight(resize)) controlPoint2: NSMakePoint(NSMinX(resize) + 0.14202 * NSWidth(resize), NSMinY(resize) + 0.39429 * NSHeight(resize))];
                    [bezier7Path lineToPoint: NSMakePoint(NSMinX(resize) + 0.14202 * NSWidth(resize), NSMinY(resize) + 0.24247 * NSHeight(resize))];
                    [bezier7Path lineToPoint: NSMakePoint(NSMinX(resize) + 0.35220 * NSWidth(resize), NSMinY(resize) + 0.45264 * NSHeight(resize))];
                    [bezier7Path curveToPoint: NSMakePoint(NSMinX(resize) + 0.38729 * NSWidth(resize), NSMinY(resize) + 0.47002 * NSHeight(resize)) controlPoint1: NSMakePoint(NSMinX(resize) + 0.36360 * NSWidth(resize), NSMinY(resize) + 0.46107 * NSHeight(resize)) controlPoint2: NSMakePoint(NSMinX(resize) + 0.37313 * NSWidth(resize), NSMinY(resize) + 0.46833 * NSHeight(resize))];
                    [bezier7Path closePath];
                    [bezier7Path setMiterLimit: 4];
                    [NSGraphicsContext saveGraphicsState];
                    [shadow set];
                    [color2 setFill];
                    [bezier7Path fill];
                    
                    ////// Bezier 7 Inner Shadow
                    NSRect bezier7BorderRect = NSInsetRect([bezier7Path bounds], -shadow2.shadowBlurRadius, -shadow2.shadowBlurRadius);
                    bezier7BorderRect = NSOffsetRect(bezier7BorderRect, -shadow2.shadowOffset.width, -shadow2.shadowOffset.height);
                    bezier7BorderRect = NSInsetRect(NSUnionRect(bezier7BorderRect, [bezier7Path bounds]), -1, -1);
                    
                    NSBezierPath* bezier7NegativePath = [NSBezierPath bezierPathWithRect: bezier7BorderRect];
                    [bezier7NegativePath appendBezierPath: bezier7Path];
                    [bezier7NegativePath setWindingRule: NSEvenOddWindingRule];
                    
                    [NSGraphicsContext saveGraphicsState];
                    {
                        NSShadow* shadow2WithOffset = [shadow2 copy];
                        CGFloat xOffset = shadow2WithOffset.shadowOffset.width + round(bezier7BorderRect.size.width);
                        CGFloat yOffset = shadow2WithOffset.shadowOffset.height;
                        shadow2WithOffset.shadowOffset = NSMakeSize(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset));
                        [shadow2WithOffset set];
                        [[NSColor grayColor] setFill];
                        [bezier7Path addClip];
                        NSAffineTransform* transform = [NSAffineTransform transform];
                        [transform translateXBy: -round(bezier7BorderRect.size.width) yBy: 0];
                        [[transform transformBezierPath: bezier7NegativePath] fill];
                    }
                    [NSGraphicsContext restoreGraphicsState];
                    
                    [NSGraphicsContext restoreGraphicsState];
                    
                }
                
                
                //// Group 6
                {
                    //// Bezier 8 Drawing
                    NSBezierPath* bezier8Path = [NSBezierPath bezierPath];
                    [bezier8Path moveToPoint: NSMakePoint(NSMinX(resize) + 0.35507 * NSWidth(resize), NSMinY(resize) + 1.00000 * NSHeight(resize))];
                    [bezier8Path curveToPoint: NSMakePoint(NSMinX(resize) + 0.42609 * NSWidth(resize), NSMinY(resize) + 0.92898 * NSHeight(resize)) controlPoint1: NSMakePoint(NSMinX(resize) + 0.39429 * NSWidth(resize), NSMinY(resize) + 1.00000 * NSHeight(resize)) controlPoint2: NSMakePoint(NSMinX(resize) + 0.42609 * NSWidth(resize), NSMinY(resize) + 0.96820 * NSHeight(resize))];
                    [bezier8Path curveToPoint: NSMakePoint(NSMinX(resize) + 0.35507 * NSWidth(resize), NSMinY(resize) + 0.85798 * NSHeight(resize)) controlPoint1: NSMakePoint(NSMinX(resize) + 0.42609 * NSWidth(resize), NSMinY(resize) + 0.88976 * NSHeight(resize)) controlPoint2: NSMakePoint(NSMinX(resize) + 0.39429 * NSWidth(resize), NSMinY(resize) + 0.85798 * NSHeight(resize))];
                    [bezier8Path lineToPoint: NSMakePoint(NSMinX(resize) + 0.24247 * NSWidth(resize), NSMinY(resize) + 0.85798 * NSHeight(resize))];
                    [bezier8Path lineToPoint: NSMakePoint(NSMinX(resize) + 0.45262 * NSWidth(resize), NSMinY(resize) + 0.64780 * NSHeight(resize))];
                    [bezier8Path curveToPoint: NSMakePoint(NSMinX(resize) + 0.45262 * NSWidth(resize), NSMinY(resize) + 0.54738 * NSHeight(resize)) controlPoint1: NSMakePoint(NSMinX(resize) + 0.48036 * NSWidth(resize), NSMinY(resize) + 0.62007 * NSHeight(resize)) controlPoint2: NSMakePoint(NSMinX(resize) + 0.48036 * NSWidth(resize), NSMinY(resize) + 0.57511 * NSHeight(resize))];
                    [bezier8Path curveToPoint: NSMakePoint(NSMinX(resize) + 0.35220 * NSWidth(resize), NSMinY(resize) + 0.54738 * NSHeight(resize)) controlPoint1: NSMakePoint(NSMinX(resize) + 0.42489 * NSWidth(resize), NSMinY(resize) + 0.51964 * NSHeight(resize)) controlPoint2: NSMakePoint(NSMinX(resize) + 0.37993 * NSWidth(resize), NSMinY(resize) + 0.51964 * NSHeight(resize))];
                    [bezier8Path lineToPoint: NSMakePoint(NSMinX(resize) + 0.14202 * NSWidth(resize), NSMinY(resize) + 0.75756 * NSHeight(resize))];
                    [bezier8Path lineToPoint: NSMakePoint(NSMinX(resize) + 0.14202 * NSWidth(resize), NSMinY(resize) + 0.64493 * NSHeight(resize))];
                    [bezier8Path curveToPoint: NSMakePoint(NSMinX(resize) + 0.07102 * NSWidth(resize), NSMinY(resize) + 0.57391 * NSHeight(resize)) controlPoint1: NSMakePoint(NSMinX(resize) + 0.14202 * NSWidth(resize), NSMinY(resize) + 0.60571 * NSHeight(resize)) controlPoint2: NSMakePoint(NSMinX(resize) + 0.11024 * NSWidth(resize), NSMinY(resize) + 0.57391 * NSHeight(resize))];
                    [bezier8Path curveToPoint: NSMakePoint(NSMinX(resize) + 0.00000 * NSWidth(resize), NSMinY(resize) + 0.64493 * NSHeight(resize)) controlPoint1: NSMakePoint(NSMinX(resize) + 0.03180 * NSWidth(resize), NSMinY(resize) + 0.57391 * NSHeight(resize)) controlPoint2: NSMakePoint(NSMinX(resize) + 0.00000 * NSWidth(resize), NSMinY(resize) + 0.60571 * NSHeight(resize))];
                    [bezier8Path lineToPoint: NSMakePoint(NSMinX(resize) + 0.00000 * NSWidth(resize), NSMinY(resize) + 0.92898 * NSHeight(resize))];
                    [bezier8Path lineToPoint: NSMakePoint(NSMinX(resize) + 0.00520 * NSWidth(resize), NSMinY(resize) + 0.95476 * NSHeight(resize))];
                    [bezier8Path curveToPoint: NSMakePoint(NSMinX(resize) + 0.00547 * NSWidth(resize), NSMinY(resize) + 0.95613 * NSHeight(resize)) controlPoint1: NSMakePoint(NSMinX(resize) + 0.00520 * NSWidth(resize), NSMinY(resize) + 0.95587 * NSHeight(resize)) controlPoint2: NSMakePoint(NSMinX(resize) + 0.00502 * NSWidth(resize), NSMinY(resize) + 0.95544 * NSHeight(resize))];
                    [bezier8Path curveToPoint: NSMakePoint(NSMinX(resize) + 0.00627 * NSWidth(resize), NSMinY(resize) + 0.95733 * NSHeight(resize)) controlPoint1: NSMakePoint(NSMinX(resize) + 0.00564 * NSWidth(resize), NSMinY(resize) + 0.95696 * NSHeight(resize)) controlPoint2: NSMakePoint(NSMinX(resize) + 0.00544 * NSWidth(resize), NSMinY(resize) + 0.95651 * NSHeight(resize))];
                    [bezier8Path lineToPoint: NSMakePoint(NSMinX(resize) + 0.02080 * NSWidth(resize), NSMinY(resize) + 0.97920 * NSHeight(resize))];
                    [bezier8Path curveToPoint: NSMakePoint(NSMinX(resize) + 0.04038 * NSWidth(resize), NSMinY(resize) + 0.99144 * NSHeight(resize)) controlPoint1: NSMakePoint(NSMinX(resize) + 0.03820 * NSWidth(resize), NSMinY(resize) + 0.99102 * NSHeight(resize)) controlPoint2: NSMakePoint(NSMinX(resize) + 0.03100 * NSWidth(resize), NSMinY(resize) + 0.98831 * NSHeight(resize))];
                    [bezier8Path curveToPoint: NSMakePoint(NSMinX(resize) + 0.07102 * NSWidth(resize), NSMinY(resize) + 1.00000 * NSHeight(resize)) controlPoint1: NSMakePoint(NSMinX(resize) + 0.05002 * NSWidth(resize), NSMinY(resize) + 1.00107 * NSHeight(resize)) controlPoint2: NSMakePoint(NSMinX(resize) + 0.04200 * NSWidth(resize), NSMinY(resize) + 0.99413 * NSHeight(resize))];
                    [bezier8Path lineToPoint: NSMakePoint(NSMinX(resize) + 0.35507 * NSWidth(resize), NSMinY(resize) + 1.00000 * NSHeight(resize))];
                    [bezier8Path closePath];
                    [bezier8Path setMiterLimit: 4];
                    [NSGraphicsContext saveGraphicsState];
                    [shadow set];
                    [color2 setFill];
                    [bezier8Path fill];
                    
                    ////// Bezier 8 Inner Shadow
                    NSRect bezier8BorderRect = NSInsetRect([bezier8Path bounds], -shadow2.shadowBlurRadius, -shadow2.shadowBlurRadius);
                    bezier8BorderRect = NSOffsetRect(bezier8BorderRect, -shadow2.shadowOffset.width, -shadow2.shadowOffset.height);
                    bezier8BorderRect = NSInsetRect(NSUnionRect(bezier8BorderRect, [bezier8Path bounds]), -1, -1);
                    
                    NSBezierPath* bezier8NegativePath = [NSBezierPath bezierPathWithRect: bezier8BorderRect];
                    [bezier8NegativePath appendBezierPath: bezier8Path];
                    [bezier8NegativePath setWindingRule: NSEvenOddWindingRule];
                    
                    [NSGraphicsContext saveGraphicsState];
                    {
                        NSShadow* shadow2WithOffset = [shadow2 copy];
                        CGFloat xOffset = shadow2WithOffset.shadowOffset.width + round(bezier8BorderRect.size.width);
                        CGFloat yOffset = shadow2WithOffset.shadowOffset.height;
                        shadow2WithOffset.shadowOffset = NSMakeSize(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset));
                        [shadow2WithOffset set];
                        [[NSColor grayColor] setFill];
                        [bezier8Path addClip];
                        NSAffineTransform* transform = [NSAffineTransform transform];
                        [transform translateXBy: -round(bezier8BorderRect.size.width) yBy: 0];
                        [[transform transformBezierPath: bezier8NegativePath] fill];
                    }
                    [NSGraphicsContext restoreGraphicsState];
                    
                    [NSGraphicsContext restoreGraphicsState];
                    
                }
            }
        }
    }
    
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
    [super mouseDown:e];
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
    [super mouseDragged:theEvent];
    NSPoint newDragLocation = [[self superview] convertPoint:[theEvent locationInWindow] fromView:nil];
    NSPoint thisOrigin = [self frame].origin;
    thisOrigin.x += (-lastDragPoint.x + newDragLocation.x);
    thisOrigin.y += (-lastDragPoint.y + newDragLocation.y);
    double adjustX = (lastDragPoint.x - newDragLocation.x);
    double adjustY = (lastDragPoint.y - newDragLocation.y);
    if (!resizeOperation) {
        [self setFrameOrigin:thisOrigin];
    } else {
        double x = self.frame.origin.x, y = self.frame.origin.y, width = self.frame.size.width, height = self.frame.size.height;
        if (currentArea == leftTop) {
            x = self.frame.origin.x - adjustX;
            width = self.frame.size.width + adjustX;
            height = self.frame.size.height - adjustY;
        } else if (currentArea == rightTop) {
            width = self.frame.size.width - adjustX;
            height = self.frame.size.height - adjustY;
        } else if (currentArea == bottomLeft) {
            x = self.frame.origin.x - adjustX;
            y = self.frame.origin.y - adjustY;
            width = self.frame.size.width + adjustX;
            height = self.frame.size.height + adjustY;
        } else if (currentArea == bottomRight) {
            y = self.frame.origin.y - adjustY;
            width = self.frame.size.width - adjustX;
            height = self.frame.size.height + adjustY;
        }
        if (width < self.minSize.width) width = self.minSize.width;
        if (height < self.minSize.height) height = self.minSize.height;
        NSRect newRect = NSMakeRect(x, y, width, height);
        [self setFrame:newRect];
        resizeOperation = YES;

    }
    lastDragPoint = newDragLocation;
}

-(void)mouseUp:(NSEvent *)theEvent {
    [super mouseUp:theEvent];
    resizeOperation = NO;
    currentArea = nil;
    [self updateTrackingAreas];
}

-(void)mouseEntered:(NSEvent *)theEvent {
    [super mouseEntered:theEvent];
    inTrackingArea = YES;
    [self setNeedsDisplay:YES];
}

-(void)mouseExited:(NSEvent *)theEvent {
    [super mouseExited:theEvent];
    inTrackingArea = NO;
    [self setNeedsDisplay:YES];
}

@end
