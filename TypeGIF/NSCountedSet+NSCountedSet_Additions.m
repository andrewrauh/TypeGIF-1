//
//  NSCountedSet+NSCountedSet_Additions.m
//  TypeGIF
//
//  Created by Andrew Rauh on 4/14/15.
//  Copyright (c) 2015 EECS493. All rights reserved.
//

#import "NSCountedSet+NSCountedSet_Additions.h"

@implementation NSCountedSet (NSCountedSet_Additions)

- (NSArray *) objectsWithCount:(NSUInteger) count {
    NSMutableArray *array = [NSMutableArray array];
    for(id obj in self) {
        if([self countForObject:obj] == count) {
            [array addObject:obj];
        }
    }
    return [array copy];
}

@end
