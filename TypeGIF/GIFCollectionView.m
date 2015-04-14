//
//  GIFCollectionView.m
//  TypeGIF
//
//  Created by Natasja Nielsen on 4/14/15.
//  Copyright (c) 2015 EECS493. All rights reserved.
//

#import "GIFCollectionView.h"

@implementation GIFCollectionView

- (id)init {
    self = [super init];
    if (self) {
        self.editing = false;
    }
    return self;
}

@end
