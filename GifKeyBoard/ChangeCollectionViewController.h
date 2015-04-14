//
//  ChangeCollectionViewController.h
//  TypeGIF
//
//  Created by Andrew Rauh on 4/13/15.
//  Copyright (c) 2015 EECS493. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ChangeDelegate;

@interface ChangeCollectionViewController : UIViewController

@property (nonatomic, strong) IBOutlet UITableView* collectionsTableView;
@property (nonatomic, strong) NSMutableArray *collections;
@property (nonatomic, weak) id<ChangeDelegate> delegate;

- (IBAction)didPressClose:(id)sender;
@end
// 3. Definition of the delegate's interface
@protocol ChangeDelegate <NSObject>

- (void)childViewController:(ChangeCollectionViewController*)viewController
             didChooseCollection:(NSString*)collection;

@end