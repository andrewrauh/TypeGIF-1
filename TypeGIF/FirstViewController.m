//
//  FirstViewController.m
//  TypeGIF
//
//  Created by Natasja Nielsen on 3/26/15.
//  Copyright (c) 2015 EECS493. All rights reserved.
//

#import "FirstViewController.h"
#import "AXCGiphy.h"


@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
   __block NSArray *giphyResults = [[NSMutableArray alloc]init];
    
    [AXCGiphy setGiphyAPIKey:kGiphyPublicAPIKey];
    
    [AXCGiphy searchGiphyWithTerm:@"frogs" limit:10 offset:0 completion:^(NSArray *results, NSError *error) {
        giphyResults = results;
        
        NSLog(@"results : %@", giphyResults);
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//            [self.collectionView reloadData];
        }];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
