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

- (void)layoutSubviews {
    self.imageURL  = [NSString new];
    self.imageView = [[FLAnimatedImageView alloc]initWithFrame:self.contentView.frame];
    [self.contentView addSubview:self.imageView];
    
}
- (void)prepareForReuse
{
    [super prepareForReuse];
    self.imageView.image = nil;
}

- (void)shake:(BOOL)editing {
    CABasicAnimation *quiverAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    if (editing) {
        float startAngle = (-2) * M_PI/180.0;
        float stopAngle = -startAngle;
        quiverAnim.fromValue = [NSNumber numberWithFloat:startAngle];
        quiverAnim.toValue = [NSNumber numberWithFloat:3 * stopAngle];
        quiverAnim.autoreverses = YES;
        quiverAnim.duration = 0.2;
        quiverAnim.repeatCount = HUGE_VALF;
        float timeOffset = (float)(arc4random() % 100)/100 - 0.50;
        quiverAnim.timeOffset = timeOffset;
        CALayer *layer = self.layer;
        [layer addAnimation:quiverAnim forKey:@"shake"];
    } else {
        CALayer *layer = self.layer;
        [layer removeAnimationForKey:@"shake"];
    }
}

@end
