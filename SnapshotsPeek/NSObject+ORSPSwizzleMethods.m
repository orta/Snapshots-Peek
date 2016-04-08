//
//  NSObject+ORSPSwizzleMethods.m
//  SnapshotsPeek
//
//  Created by Orta Therox on 08/04/2016.
//  Copyright © 2016 Orta. All rights reserved.
//

// Based on NSObject+KKSwizzleMethods.m
// from the proejct KKHighlightRecentPlugin
// https://github.com/karolkozub/KKHighlightRecentPlugin/blob/master/LICENSE

#import "NSObject+ORSPSwizzleMethods.h"
#import <objc/runtime.h>

@implementation NSObject(ORSPSwizzleMethods)

+ (void)orsp_swizzleMethodWithOriginalSelector:(SEL)originalSelector
{
    SEL swizzledSelector = NSSelectorFromString([@"orsp_" stringByAppendingString:NSStringFromSelector(originalSelector)]);

    Method originalMethod = class_getInstanceMethod([self class], originalSelector);
    Method swizzledMethod = class_getInstanceMethod([self class], swizzledSelector);

    NSAssert(originalMethod, nil);
    NSAssert(swizzledMethod, nil);

    method_exchangeImplementations(originalMethod, swizzledMethod);
}

@end
