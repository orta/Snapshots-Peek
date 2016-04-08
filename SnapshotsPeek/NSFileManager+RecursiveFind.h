//
//  NSFileManager+RecursiveFind.h
//  SnapshotDiffs
//
//  Created by Orta on 6/16/14.
//  Copyright (c) 2014 Orta. All rights reserved.
//

@interface NSFileManager (ORRecursiveFind)

- (NSURL *)or_findFileInFolder:(NSURL *)folder withNamePrefix:(NSString *)name;

@end