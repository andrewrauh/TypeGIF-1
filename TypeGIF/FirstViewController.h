//
//  FirstViewController.h
//  TypeGIF
//
//  Created by Natasja Nielsen on 3/26/15.
//  Copyright (c) 2015 EECS493. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AXCGiphy.h>
#import <FLAnimatedImage/FLAnimatedImage.h>
#import "AXCCollectionViewCell.h"
#import <MBProgressHUD.h>

@interface FirstViewController : UIViewController  <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextField* searchTextField;
@property (nonatomic, strong) UIBarButtonItem *collectionButton;

@end

