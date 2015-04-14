//
//  GIFCollectionCell.m
//  TypeGIF
//
//  Created by Carl Lachner on 4/7/15.
//  Copyright (c) 2015 EECS493. All rights reserved.
//

#import "GIFCollectionCell.h"
@import QuartzCore;

@implementation GIFCollectionCell

- (void)awakeFromNib {
    // Initialization code
//    self.layer.cornerRadius = 10.0f;
    [self.nameLabel setTextColor:[UIColor whiteColor]];
    [self.nameLabel setFont:[UIFont fontWithName:@"Avenir Next" size:30.0f]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
