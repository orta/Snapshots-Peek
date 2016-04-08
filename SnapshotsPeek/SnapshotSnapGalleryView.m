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
@end

@implementation SnapshotSnapGalleryView

- (instancetype)init
{
    self = [super init];
    if (!self) { return nil; }

    self.queue = dispatch_queue_create("io.orta.snapshots_peek_image_queue", DISPATCH_QUEUE_SERIAL);
    self.wantsLayer = YES;

    return self;
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

// NSImage -> NSImageView

- (void)updateWithImages:(NSArray <NSImage *>*)images
{
    [self.subviews.copy makeObjectsPerformSelector:@selector(removeFromSuperview)];

    CGFloat margin = 20;
    CGFloat offset = 0;

    for (NSImage *image in images) {
        CGFloat aspectRatio = image.size.width / image.size.height;
        CGFloat width = MIN(aspectRatio * 80, 120);
        CGFloat x = offset + margin;

        NSImageView *imageView = [[NSImageView alloc] initWithFrame:CGRectMake(x, 0, width, 80)];
        imageView.image = image;
        [self addSubview:imageView];

        offset += width + margin;
    }

    NSView *lastSubview = self.subviews.lastObject;
    self.frame = CGRectMake(0, 0, CGRectGetMaxX(lastSubview.frame), 80);
}

- (void)fadeAndRemove
{
    [self.animator setAlphaValue:0];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        [self.subviews.copy makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self removeFromSuperview];
    });
}

@end
