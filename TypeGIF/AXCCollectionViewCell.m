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
        self.imageView = [[FLAnimatedImageView alloc]initWithFrame:self.contentView.frame];

        self.imageView.frame = CGRectMake(0.0, 0.0, 123.0, 100.0);
        self.editingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 123.0, 100.0)];
        self.editingView.backgroundColor = [UIColor blackColor];
        self.editingView.tag = 1234;
        self.editingView.alpha = 0.3;
        self.editingView.opaque = YES;
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
    self.imageView.animatedImage = nil;
}

- (void)shake:(BOOL)editing {
    CABasicAnimation *quiverAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    if (editing) {
        float startAngle = (-1) * M_PI/270.0;
        float stopAngle = -startAngle;
        quiverAnim.fromValue = [NSNumber numberWithFloat:startAngle];
        quiverAnim.toValue = [NSNumber numberWithFloat:3 * stopAngle];
        quiverAnim.autoreverses = YES;
        quiverAnim.duration = 0.1;
        quiverAnim.repeatCount = HUGE_VALF;
        float timeOffset = (float)(arc4random() % 100)/100 - 0.50;
        quiverAnim.timeOffset = timeOffset;
        CALayer *layer = self.layer;
        [layer addAnimation:quiverAnim forKey:@"shake"];
        [layer setAllowsEdgeAntialiasing:YES];
        [self addSubview:self.editingView];
    } else {
        CALayer *layer = self.layer;
        [layer removeAnimationForKey:@"shake"];
        [[self viewWithTag:1234]removeFromSuperview];
    }
}

@end
