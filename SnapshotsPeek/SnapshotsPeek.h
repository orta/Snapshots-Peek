//
//  SnapshotsPeek.h
//  SnapshotsPeek
//
//  Created by Orta Therox on 08/04/2016.
//  Copyright © 2016 Orta. All rights reserved.
//

#import <AppKit/AppKit.h>
@class IDEEditorContext;
@interface SnapshotsPeek : NSObject

+ (instancetype)sharedPlugin;
- (void)editorContext:(IDEEditorContext *)editorContext didOpenItem:(id)item;

@property (nonatomic, strong, readonly) NSBundle *bundle;
@end