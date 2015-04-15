//
//  AXCCollectionViewCell.h
//  TypeGIF
//
//  Created by Andrew Rauh on 3/26/15.
//  Copyright (c) 2015 EECS493. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FLAnimatedImage/FLAnimatedImage.h>

@interface AXCCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet FLAnimatedImageView * imageView;
@property (strong, nonatomic) UIView *editingView;
@property (strong, nonatomic) NSString* imageURL;

- (void) shake:(BOOL) editing;

@end
