//
//  AXCCollectionViewCell.m
//  TypeGIF
//
//  Created by Andrew Rauh on 3/26/15.
//  Copyright (c) 2015 EECS493. All rights reserved.
//

#import "AXCCollectionViewCell.h"

@implementation AXCCollectionViewCell


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) prepareForReuse
{
    [super prepareForReuse];
    self.imageView.image = nil;
}

@end
