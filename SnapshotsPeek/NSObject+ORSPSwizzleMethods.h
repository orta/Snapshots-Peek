//
//  NSObject+ORSPSwizzleMethods.h
//  SnapshotsPeek
//
//  Created by Orta Therox on 08/04/2016.
//  Copyright © 2016 Orta. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject(ORSPSwizzleMethods)

+ (void)orsp_swizzleMethodWithOriginalSelector:(SEL)originalSelector;

@end
