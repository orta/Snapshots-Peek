//
//  SnapshotSnapGalleryView.m
//  SnapshotsPeek
//
//  Created by Orta Therox on 08/04/2016.
//  Copyright © 2016 Orta. All rights reserved.
//

#import "SnapshotSnapGalleryView.h"

@interface SnapshotSnapGalleryView()
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) NSTrackingArea *trackingArea;
@end

@implementation SnapshotSnapGalleryView

- (instancetype)init
{
    self = [super init];
    if (!self) { return nil; }

    self.queue = dispatch_queue_create("io.orta.snapshots_peek_image_queue", DISPATCH_QUEUE_SERIAL);
    self.trackingArea = [[NSTrackingArea alloc] initWithRect:NSZeroRect options:NSTrackingInVisibleRect | NSTrackingActiveAlways | NSTrackingMouseMoved | NSTrackingMouseEnteredAndExited owner:self userInfo:nil];
    self.wantsLayer = YES;

    return self;
}

// Ensure that we get frame changes

- (void)viewDidMoveToWindow
{
    [super viewDidMoveToWindow];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowResized) name:
     NSWindowWillStartLiveResizeNotification object:self.window];
}

- (void)windowResized
{
    self.frame = CGRectMake(0, 0, CGRectGetWidth(self.superview.bounds), [self maxDimension]);
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/// NSURL -> NSImage

- (void)updateWithURLs:(NSArray <NSURL *>*)URLs
{
    dispatch_async(self.queue, ^{
        NSMutableArray <NSImage *> *images = [NSMutableArray array];
        for (NSURL *url in URLs) {
            NSImage *image = [[NSImage alloc] initByReferencingURL:url];
            if (image) { [images addObject:image]; }
        }

        dispatch_sync(dispatch_get_main_queue(), ^{
            [self updateWithImages:images];
        });
    });
}

// NSImage -> CALayer

- (void)updateWithImages:(NSArray <NSImage *>*)images
{
    [self setAlphaValue:0];
    [self.animator setAlphaValue:1];

    [self.subviews.copy makeObjectsPerformSelector:@selector(removeFromSuperview)];

    for (NSImage *image in images) {
        CALayer *layer = [CALayer layer];
        layer.contents = image;
        [self.layer addSublayer:layer];
    }

    [self updateLayersWithMouseXLocation:100000];
    self.frame = CGRectMake(0, 0, CGRectGetWidth(self.superview.bounds), [self maxDimension]);
}

- (CGFloat)maxDimension
{
    return CGRectGetHeight(self.superview.bounds) / 2;
}

// Taken from my ActionScript 3 Dock implementation:
// https://github.com/orta/virtualapps/blob/master/src/dock/Dock.as#L139

// Lays out the screenshots with a dock-like animation

- (void)updateLayersWithMouseXLocation:(CGFloat)mouseX
{
    CGFloat maxDimension = [self maxDimension];
    CGFloat totalPixelsOfCurve = maxDimension * 1.2;
    CGFloat bottomScale = 0.3;

    CGFloat halfPixelsOfCurve = totalPixelsOfCurve / 2;
    CGFloat itemMargin = 20;
    CGFloat offset = 0;

    for (CALayer *layer in self.layer.sublayers) {
        NSImage *image = layer.contents;
        CGFloat aspectRatio = image.size.width / image.size.height;

        CGFloat distanceFromMouseX = CGRectGetMidX(layer.frame) - mouseX;
        CGFloat scale = bottomScale;

        /// Support fancy dock-like animation
        if ((distanceFromMouseX < halfPixelsOfCurve) && (distanceFromMouseX > (halfPixelsOfCurve * -1))) {

            CGFloat curvedDistanceFromMouseX = ((distanceFromMouseX / halfPixelsOfCurve) * 90) + 90;
            CGFloat radians = curvedDistanceFromMouseX * (M_PI / 180.0);
            CGFloat newScale = sin(radians);

            if(newScale > 1) newScale = 1;
            if(newScale < bottomScale) newScale = bottomScale;
            scale = newScale;
        }

        CGFloat coreWidth = scale * maxDimension;

        CGFloat width = MIN(aspectRatio * coreWidth, maxDimension);
        CGFloat height = MIN(maxDimension * scale,  maxDimension / aspectRatio );

        CGFloat x = offset + itemMargin;

        layer.frame = CGRectMake(x, 0, width, height);
        offset += width + itemMargin;
    }
}

- (NSView *)hitTest:(NSPoint)aPoint
{
    return nil;
}

/// Fades out, then removes the view

- (void)fadeAndRemove
{
    [self.animator setAlphaValue:0];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        [self.subviews.copy makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self removeFromSuperview];
    });
}

/// Lets the view do mouse tracking

- (void)updateTrackingAreas
{
    [super updateTrackingAreas];
    if (![[self trackingAreas] containsObject:self.trackingArea]) {
        [self addTrackingArea:self.trackingArea];
    }
}

/// Converts the window location into one
/// relative to the view

- (void)mouseMoved:(NSEvent *)event
{
    NSPoint location = [self convertPoint:event.locationInWindow toView:self.superview];
    CGFloat xOffset = [self convertRect:self.bounds fromView:nil].origin.x;
    [self updateLayersWithMouseXLocation:location.x + xOffset];
}

/// Resets the dock-like animation

- (void)mouseExited:(NSEvent *)theEvent
{
    [self updateLayersWithMouseXLocation:100000];
}

@end
