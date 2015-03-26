//
//  AXCCollectionViewCell.m
//  TypeGIF
//
//  Created by Andrew Rauh on 3/26/15.
//  Copyright (c) 2015 EECS493. All rights reserved.
//

#import "AXCCollectionViewCell.h"

@implementation AXCCollectionViewCell

//
//- (FLAnimatedImageView *) imageView
//{
//    if (!_imageView) {
//        _imageView = [[FLAnimatedImageView alloc] initWithFrame:self.contentView.bounds];
//        [self.contentView addSubview:_imageView];
//    }
//    return _imageView;
//}

-(void)layoutSubviews {
    self.imageView = [[FLAnimatedImageView alloc]initWithFrame:self.contentView.frame];
    [self.contentView addSubview:self.imageView];
    
}

- (void) prepareForReuse
{
    [super prepareForReuse];
//    [self.imageView removeFromSuperview];
    self.imageView.image = nil;
}

@end
