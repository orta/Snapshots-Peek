//
//  IDEEditorContext_NavigationInsertion.m
//  SnapshotsPeek
//
//  Created by Orta Therox on 08/04/2016.
//  Copyright © 2016 Orta. All rights reserved.
//

#import "XcodeRuntime.h"
#import "SnapshotsPeek.h"
#import "NSObject+ORSPSwizzleMethods.h"

@implementation IDEEditorContext (NavigationInsertion)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [IDEEditorContext orsp_swizzleMethodWithOriginalSelector:@selector(_openNavigableItem:documentExtension:document:shouldInstallEditorBlock:)];
    });
}

- (int)orsp__openNavigableItem:(id)item documentExtension:(id)documentExtension document:(id)document shouldInstallEditorBlock:(id)block
{
    [[SnapshotsPeek sharedPlugin] editorContext:self didOpenItem:item];
    
    return [self orsp__openNavigableItem:item documentExtension:documentExtension document:document shouldInstallEditorBlock:block];
}

@end
