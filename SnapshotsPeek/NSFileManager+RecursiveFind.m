//
//  NSFileManager+RecursiveFind.m
//  SnapshotDiffs
//
//  Created by Orta on 6/16/14.
//  Copyright (c) 2014 Orta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@implementation NSFileManager (ORRecursiveFind)

- (NSURL *)or_findFileInFolder:(NSURL *)folder withNamePrefix:(NSString *)name
{
    @try {
        // Sure glad I built OROpenInAppCode, then SnapshotDiffs already :)
        NSFileManager *fileManager = self;
        NSDirectoryEnumerator *enumerator = nil;
        enumerator = [fileManager enumeratorAtURL:folder
                       includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey]
                                          options:NSDirectoryEnumerationSkipsHiddenFiles
                                     errorHandler:^BOOL(NSURL *url, NSError *error) {
            NSLog(@"[Error] %@ (%@)", error, url);
            return YES;
        }];
        
        NSMutableArray *mutableFileURLs = [NSMutableArray array];
        for (NSURL *fileURL in enumerator) {

            NSString *filename;
            [fileURL getResourceValue:&filename forKey:NSURLNameKey error:nil];
            
            NSNumber *isDirectory;
            [fileURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
            
            // Skip directories with '_' prefix
            if ([filename hasPrefix:@"_"] && [isDirectory boolValue]) {
                [enumerator skipDescendants];
                continue;
            }
            
            if (![isDirectory boolValue]) {
                [mutableFileURLs addObject:fileURL];
            }
            
            if ([filename hasPrefix:name]) {
                return fileURL;
            }
        }
    }
    @catch (NSException *exception) {
        return nil;
    }

    return nil;
}

@end