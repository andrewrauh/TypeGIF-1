//
//  Keyboard.h
//  TypeGIF
//
//  Created by Carl Lachner on 4/13/15.
//  Copyright (c) 2015 EECS493. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Keyboard : UIView
@property (weak, nonatomic) IBOutlet UIButton *nextKey;
@property (weak, nonatomic) IBOutlet UISegmentedControl *librarySelector;

@end
