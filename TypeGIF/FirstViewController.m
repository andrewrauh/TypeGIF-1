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


//https://gist.github.com/codeswimmer/4437535

@interface FirstViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate>

@property BOOL imageSelected;
@property (nonatomic, strong) NSMutableArray *resultsArray;
@property (nonatomic, strong) IBOutlet UICollectionView* resultsCollectionView;
@property (nonatomic, strong) UIPanGestureRecognizer* dragG;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressRecognizer;
@property (nonatomic, strong) UIImageView* movingCell;
@property (nonatomic, strong) IBOutlet UIVisualEffectView* blurView;


-(IBAction)didHoldImage:(id)sender;
-(void)handlePan:(UIPanGestureRecognizer *)panRecognizer;
-(void) handleLongPress:(UILongPressGestureRecognizer *)longPressRecog;



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
    self.longPressRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
    
    
    [self.resultsCollectionView addGestureRecognizer:self.dragG];
    [self.resultsCollectionView addGestureRecognizer:self.longPressRecognizer];

    self.dragG.delegate = self;
    self.imageSelected = NO;
    UIPasteboard *pasteBoard=[UIPasteboard generalPasteboard];
    NSLog(@"%@", [pasteBoard pasteboardTypes] );
    
    [self.blurView setHidden:YES];
    self.movingCell = [[UIImageView alloc]init];
    [self.movingCell setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:self.movingCell];


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
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.labelText = @"Loading";
    
    [AXCGiphy searchGiphyWithTerm:textField.text limit:30 offset:0 completion:^(NSArray *results, NSError *error) {
        self.resultsArray = [NSMutableArray arrayWithArray:results];
        NSLog(@"results : %@", results);
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [hud hide:YES];
            [self.resultsCollectionView reloadData];
        }];
    }];

}

#pragma mark - UICollectionView delegate Methods

- (AXCCollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AXCCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    AXCGiphy * gif = self.resultsArray[indexPath.item];

    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        NSURLRequest * request = [NSURLRequest requestWithURL:gif.originalImage.url];
        NSURLResponse *response;
        NSError *Jerror = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&Jerror];
        FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:data];
        //Background Thread
        dispatch_async(dispatch_get_main_queue(), ^(void){
            cell.imageView.animatedImage = image;
            cell.imageView.frame = CGRectMake(0.0, 0.0, 100.0, 100.0);
        });
    });
    

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
    
    UIPasteboard *pasteBoard=[UIPasteboard generalPasteboard];
    
    [pasteBoard setData:curCell.imageView.animatedImage.data
      forPasteboardType:@"com.compuserve.gif"];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeCustomView;
    hud.labelText = @"Copied to Clipboard!";
    [hud hide:YES afterDelay:1.0f];
    
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

#pragma mark - Gesture Recognizer Delegate Methods


-(void)handleLongPress:(UILongPressGestureRecognizer *)longPressRecog {
    //make copy of image
    //scale copy of image

    [self.blurView setHidden:NO];
    CGPoint locationPoint = [longPressRecog locationInView:self.view];

    NSIndexPath *indexPathOfMovingCell = [self.resultsCollectionView indexPathForItemAtPoint:locationPoint];
    
    UICollectionViewCell *cell = [self.resultsCollectionView cellForItemAtIndexPath:indexPathOfMovingCell];

    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        
        UIGraphicsBeginImageContext(cell.bounds.size);
        [cell.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *cellImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self.view addSubview:self.movingCell];

            if (self.movingCell.image != nil) {
                self.movingCell = [[UIImageView alloc] initWithImage:cellImage];
            }
            else{
                [self.movingCell setImage:cellImage];
            }
            
            [self.movingCell setCenter:locationPoint];
            [self.movingCell setAlpha:0.9f];
            [self.view bringSubviewToFront:self.movingCell];
            
            [UIView animateWithDuration:0.1 animations:^{
                self.movingCell.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
            }];

        });
    });


}

-(void)handlePan:(UIPanGestureRecognizer *)panRecognizer {
    
    CGPoint locationPoint = [panRecognizer locationInView:self.view];
    self.imageSelected = YES;
    
    if (panRecognizer.state == UIGestureRecognizerStateBegan) {
//        
//        [self.blurView setHidden:NO];
//        
//        NSIndexPath *indexPathOfMovingCell = [self.resultsCollectionView indexPathForItemAtPoint:locationPoint];
//        UICollectionViewCell *cell = [self.resultsCollectionView cellForItemAtIndexPath:indexPathOfMovingCell];
//        
//        UIGraphicsBeginImageContext(cell.bounds.size);
//        [cell.layer renderInContext:UIGraphicsGetCurrentContext()];
//        UIImage *cellImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        self.movingCell = [[UIImageView alloc] initWithImage:cellImage];
//        
//        
//        
    }
    
    if (panRecognizer.state == UIGestureRecognizerStateChanged) {
//        [self.movingCell setCenter:locationPoint];
//        [self.view bringSubviewToFront:self.movingCell];
//        
//        CGRect intersection = CGRectMake(self.blurView.frame.origin.x, self.blurView.frame.origin.y, self.blurView.frame.size.width, self.blurView.frame.size.height-100);
//        
//        BOOL methodB = CGRectIntersectsRect(self.movingCell.frame, intersection);
//        NSLog(@"here1");
//        
//        if (methodB) {
//            NSLog(@"%f, %f", self.movingCell.center.x, self.movingCell.center.y);
//            [self.movingCell setCenter:self.blurView.center];
//            [self.view bringSubviewToFront:self.movingCell];
//            [self.blurView.contentView addSubview:self.movingCell];
//            [self.blurView setHidden:YES];
//
//
//            NSLog(@"here");
//            
//        }

    }
    if (panRecognizer.state == UIGestureRecognizerStateEnded) {
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
