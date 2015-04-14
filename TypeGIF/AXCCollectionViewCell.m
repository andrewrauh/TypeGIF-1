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

-(void)layoutSubviews {
    self.imageURL  = [NSString new];
    self.imageView = [[FLAnimatedImageView alloc]initWithFrame:self.contentView.frame];
    [self.contentView addSubview:self.imageView];
    
}
- (void) prepareForReuse
{
    [super prepareForReuse];
    self.imageView.image = nil;
}

@end
