//
//  FirstViewController.m
//  TypeGIF
//
//  Created by Natasja Nielsen on 3/26/15.
//  Copyright (c) 2015 EECS493. All rights reserved.
//

#import "FirstViewController.h"
#import "AXCGiphy.h"
//#import "AXCCollectionViewCell.h"
@import QuartzCore;



@interface FirstViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate>

@property BOOL imageSelected;
@property (nonatomic, strong) NSMutableArray *resultsArray;
@property (nonatomic, strong) IBOutlet UICollectionView* resultsCollectionView;
@property (nonatomic, strong) UIPanGestureRecognizer* dragG;
@property (nonatomic, strong) UIImageView* movingCell;
@property (nonatomic, strong) IBOutlet UIVisualEffectView* blurView;


-(IBAction)didHoldImage:(id)sender;
-(void)handlePan:(UIPanGestureRecognizer *)panRecognizer;


@end

@implementation FirstViewController
@synthesize resultsCollectionView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.resultsArray = [[NSMutableArray alloc]init];
    self.searchTextField.delegate = self;
    
    self.resultsCollectionView.delegate = self;
    self.resultsCollectionView.dataSource = self;
    
    [self.resultsCollectionView registerClass:[AXCCollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    [AXCGiphy setGiphyAPIKey:kGiphyPublicAPIKey];
    
    [self.searchTextField setPlaceholder:@"search here"];
    [self.resultsCollectionView setBackgroundColor:[UIColor clearColor]];
    
    self.dragG = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
    [self.resultsCollectionView addGestureRecognizer:self.dragG];
    
    self.dragG.delegate = self;
    self.imageSelected = NO;
    UIPasteboard *pasteBoard=[UIPasteboard generalPasteboard];
    
    
    [self.blurView setHidden:YES];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextField Delegate Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    
    [AXCGiphy searchGiphyWithTerm:textField.text limit:30 offset:0 completion:^(NSArray *results, NSError *error) {
        self.resultsArray = [NSMutableArray arrayWithArray:results];
        NSLog(@"results : %@", results);
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.resultsCollectionView reloadData];
        }];
    }];

}

#pragma mark - UICollectionView delegate Methods

- (AXCCollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AXCCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    AXCGiphy * gif = self.resultsArray[indexPath.item];
    NSURLRequest * request = [NSURLRequest requestWithURL:gif.originalImage.url];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:data];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            cell.imageView.animatedImage = image;
            cell.imageView.frame = CGRectMake(0.0, 0.0, 100.0, 100.0);
        }];
    }] resume];
    return cell;
}

// 1
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [self.resultsArray count];
}
// 2
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Select Item
    AXCCollectionViewCell* curCell = (AXCCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
//    curCell.imageView.dealloc
//    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://fc05.deviantart.net/fs37/f/2008/283/a/b/KaleidoCoils_animated__gif_by_1389AD.gif"]];
    
    UIPasteboard *pasteBoard=[UIPasteboard generalPasteboard];
    
    [pasteBoard setData:curCell.imageView.animatedImage.data
      forPasteboardType:@"com.compuserve.gif"];
    NSLog(@"copied %@", [pasteBoard dataForPasteboardType:@"com.compuserve.gif"]);
    
    
    
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //You may want to create a divider to scale the size by the way..
    return CGSizeMake(100,100);
}


-(void)handlePan:(UIPanGestureRecognizer *)panRecognizer {
    
    CGPoint locationPoint = [panRecognizer locationInView:self.resultsCollectionView];
    self.imageSelected = YES;
    
    if (panRecognizer.state == UIGestureRecognizerStateBegan) {
        [self.blurView setHidden:NO];
        
        NSIndexPath *indexPathOfMovingCell = [self.resultsCollectionView indexPathForItemAtPoint:locationPoint];
        UICollectionViewCell *cell = [self.resultsCollectionView cellForItemAtIndexPath:indexPathOfMovingCell];
        
        UIGraphicsBeginImageContext(cell.bounds.size);
        [cell.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *cellImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        self.movingCell = [[UIImageView alloc] initWithImage:cellImage];
        [self.movingCell setCenter:locationPoint];
        [self.movingCell setAlpha:0.9f];
        [self.view addSubview:self.movingCell];
        [self.view bringSubviewToFront:self.movingCell];
        
        [UIView animateWithDuration:0.1 animations:^{
            self.movingCell.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
        }];
        
        
    }
    
    if (panRecognizer.state == UIGestureRecognizerStateChanged) {
        [self.movingCell setCenter:locationPoint];
        [self.view bringSubviewToFront:self.movingCell];
        BOOL methodB = CGRectIntersectsRect(self.movingCell.frame, self.blurView.frame);
        NSLog(@"here1");
        
        if (methodB) {
            [self.movingCell setCenter:self.blurView.center];
            [self.view addSubview:self.movingCell];
            [self.view bringSubviewToFront:self.movingCell];
            NSLog(@"here");
            [self.blurView setHidden:YES];
            
        }

    }
    if (panRecognizer.state == UIGestureRecognizerStateEnded) {
//        [self.movingCell removeFromSuperview];
        self.imageSelected = NO;
        
    }
}


-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    NSLog(@"got here");
    
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    if (self.imageSelected) {
        return NO;
    }
    return YES;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}
@end
