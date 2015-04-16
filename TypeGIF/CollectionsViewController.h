//
//  CollectionsViewController.h
//  TypeGIF
//
//  Created by Andrew Rauh on 4/15/15.
//  Copyright (c) 2015 EECS493. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) IBOutlet UITableView *collectionsTableView;
@property (nonatomic,strong)  NSArray *tableData;
@property (nonatomic, strong) NSString *selectedTerm;

@end
