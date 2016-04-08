//
//  SnapshotSnapGalleryView.h
//  SnapshotsPeek
//
//  Created by Orta Therox on 08/04/2016.
//  Copyright © 2016 Orta. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SnapshotSnapGalleryView : NSView

- (void)updateWithURLs:(NSArray <NSURL *>*)URLs;

- (void)fadeAndRemove;

@end
