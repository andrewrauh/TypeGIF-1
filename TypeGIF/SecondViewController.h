//
//  SecondViewController.h
//  TypeGIF
//
//  Created by Natasja Nielsen on 3/26/15.
//  Copyright (c) 2015 EECS493. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThirdViewController.h"
#import "GIFCollectionCell.h"
#import "DatabaseManager.h"

@interface SecondViewController : UIViewController

@property (nonatomic, strong) IBOutlet UITableView *collectionsTableView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addCollectionButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *editCollectionsButton;
@property (nonatomic, strong) NSMutableArray *tableData;

@end

