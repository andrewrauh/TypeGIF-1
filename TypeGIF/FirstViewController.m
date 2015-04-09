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
#import "DatabaseManager.h"


//https://gist.github.com/codeswimmer/4437535

@interface FirstViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate>

@property BOOL imageSelected;
@property (nonatomic, strong) NSMutableArray *resultsArray;
@property (nonatomic, strong) IBOutlet UICollectionView* resultsCollectionView;
@property (nonatomic, strong) UIPanGestureRecognizer* dragG;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer* doubleTapRecognizer;
@property (nonatomic, strong) UIImageView* movingCell;
@property (nonatomic, strong) IBOutlet UIVisualEffectView* blurView;
@property (nonatomic, strong) DatabaseManager *db;


-(IBAction)didHoldImage:(id)sender;
-(void)handlePan:(UIPanGestureRecognizer *)panRecognizer;
-(void) handleLongPress:(UILongPressGestureRecognizer *)longPressRecog;
-(void) handleDoubleTap:(UITapGestureRecognizer*) tapRecognizer;
-(void) writeGifToDisk:(NSData * )gif withName:(NSString* ) name;


@end

@implementation FirstViewController
@synthesize resultsCollectionView;

- (void)setupGestureRecognizers {
    self.longPressRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
    
    self.doubleTapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleDoubleTap:)];
    
    [self.doubleTapRecognizer setNumberOfTapsRequired:2];
    [self.resultsCollectionView addGestureRecognizer:self.longPressRecognizer];
    [self.resultsCollectionView  addGestureRecognizer:self.doubleTapRecognizer];
    
    self.dragG.delegate = self;
    self.imageSelected = NO;
}

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
    
    [self setupGestureRecognizers];
    
    [self.blurView setHidden:YES];
    
    self.movingCell = [[UIImageView alloc]init];
    [self.movingCell setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.movingCell];
    
    UIAlertView *intro = [[UIAlertView alloc]initWithTitle:@"Hello!" message:@"To save a gif to a collection, double tap. To save to clipboard, hold down for a second" delegate:self cancelButtonTitle:@"Go away" otherButtonTitles:@"Okay", nil];
    [intro show];
    self.db = [DatabaseManager createDatabaseInstance];
    
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
    [cell setBackgroundColor:[UIColor grayColor]];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        
        NSData *myGif;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSCharacterSet *charactersToRemove = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
        NSString *str = [NSString stringWithFormat:@"%@", gif.originalImage.url];
        NSString *trimmedReplacement = [[str componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@""];
        NSString* fileName = [NSString stringWithFormat:@"%@.gif", trimmedReplacement];
        NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:fileName];
        
        myGif = [NSData dataWithContentsOfFile:dataPath];
        
        if (myGif.length == 0) {
            NSLog(@"nothing found in cache for %@", fileName);
            NSURLRequest * request = [NSURLRequest requestWithURL:gif.originalImage.url];
            NSURLResponse *response;
            NSError *Jerror = nil;
            myGif = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&Jerror];
            
            NSString *str = [NSString stringWithFormat:@"%@", gif.originalImage.url];
            [self writeGifToDisk:myGif withName:str];
        }
        else {
            NSLog(@"read from file! for %@", fileName);
        }
        
        FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:myGif];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            cell.imageView.animatedImage = image;
            cell.imageView.frame = CGRectMake(0.0, 0.0, 100.0, 100.0);
        });
    });
    return cell;
}



-(void) writeGifToDisk:(NSData * )gif withName:(NSString* ) name {
    // Use GCD's background queue
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSCharacterSet *charactersToRemove = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
        NSString *trimmedReplacement = [[name componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@""];
        NSString* fileName = [NSString stringWithFormat:@"%@.gif", trimmedReplacement];
        NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:fileName];
        [gif writeToFile:dataPath atomically:YES];
        NSLog(@"wrote to %@", dataPath);
        
    });
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
    
    CGPoint locationPoint = [longPressRecog locationInView:self.view];
    NSIndexPath *indexOfClickedCell = [self.resultsCollectionView indexPathForItemAtPoint:locationPoint];
    UICollectionViewCell *cell = [self.resultsCollectionView cellForItemAtIndexPath:indexOfClickedCell];
    AXCCollectionViewCell *curCell = (AXCCollectionViewCell*)cell;

    UIPasteboard *pasteBoard=[UIPasteboard generalPasteboard];
    [pasteBoard setData:curCell.imageView.animatedImage.data
      forPasteboardType:@"com.compuserve.gif"];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeCustomView;
    hud.labelText = @"Copied to Clipboard!";
    [hud hide:YES afterDelay:1.0f];
}

-(void) animateShowBlurView {
    CGRect oldFrame = self.blurView.frame;
    
    [self.blurView setFrame:CGRectMake(0, self.view.frame.size.height+self.blurView.frame.size.height, self.blurView.frame.size.width, self.blurView.frame.size.height)];
    [self.blurView setHidden:NO];
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.blurView setFrame:oldFrame];
    }
    completion:^(BOOL finished) {
        
    }];
}

- (void) animateHideBlurView {
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.blurView setFrame:CGRectMake(0, self.view.frame.size.height+self.blurView.frame.size.height, self.blurView.frame.size.width, self.blurView.frame.size.height)];

    } completion:^(BOOL finished) {
        
    } ];
}

-(void)handleDoubleTap:(UITapGestureRecognizer *)tapRecognizer {
    NSLog(@"got here");
    
    [self animateShowBlurView];
    
    CGPoint locationPoint = [tapRecognizer locationInView:self.view];
    
    NSIndexPath *indexOfClickedCell = [self.resultsCollectionView indexPathForItemAtPoint:locationPoint];
    
    UICollectionViewCell *cell = [self.resultsCollectionView cellForItemAtIndexPath:indexOfClickedCell];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        UIGraphicsBeginImageContext(cell.bounds.size);
        [cell.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *cellImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        dispatch_async(dispatch_get_main_queue(), ^(void){
            
            if (self.movingCell.image != nil) {
                self.movingCell = [[UIImageView alloc] initWithImage:cellImage];
            }
            else{
                [self.movingCell setImage:cellImage];
            }
            
            [self.movingCell setCenter:locationPoint];
            
            [self.movingCell setAlpha:0.9f];
            [self.view bringSubviewToFront:self.movingCell];
            [self.movingCell setFrame:cell.frame];
            
            [UIView animateWithDuration:0.1 animations:^{
                self.movingCell.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.6f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self.movingCell setCenter:self.blurView.center];

                } completion:^(BOOL finished) {
                    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    hud.mode = MBProgressHUDModeCustomView;
                    hud.labelText = @"Saved to Favorites!";
                    [hud hide:YES afterDelay:1.0f];
                    [self.blurView setHidden:YES];
                    [self.movingCell setImage:nil];
                }];
            }];
        });
    });
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    NSLog(@"got here");
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //TODO
//    locate the scrollview which is in the centre
//    CGPoint centerPoint = CGPointMake(self.collectionView.frame.size.width / 2 + scrollView.contentOffset.x, self.collectionView.frame.size.height /2 + scrollView.contentOffset.y);
//    NSIndexPath *indexPathOfCentralCell = [self.collectionView indexPathForItemAtPoint:centerPoint];

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

/* Experimental Drag + Drop Code */

//-(void)handlePan:(UIPanGestureRecognizer *)panRecognizer {
//
//    CGPoint locationPoint = [panRecognizer locationInView:self.view];
//    self.imageSelected = YES;
//
//    if (panRecognizer.state == UIGestureRecognizerStateBegan) {
////
////        [self.blurView setHidden:NO];
////
////        NSIndexPath *indexPathOfMovingCell = [self.resultsCollectionView indexPathForItemAtPoint:locationPoint];
////        UICollectionViewCell *cell = [self.resultsCollectionView cellForItemAtIndexPath:indexPathOfMovingCell];
////
////        UIGraphicsBeginImageContext(cell.bounds.size);
////        [cell.layer renderInContext:UIGraphicsGetCurrentContext()];
////        UIImage *cellImage = UIGraphicsGetImageFromCurrentImageContext();
////        UIGraphicsEndImageContext();
////        self.movingCell = [[UIImageView alloc] initWithImage:cellImage];
////
////
////
//    }
//
//    if (panRecognizer.state == UIGestureRecognizerStateChanged) {
////        [self.movingCell setCenter:locationPoint];
////        [self.view bringSubviewToFront:self.movingCell];
////
////        CGRect intersection = CGRectMake(self.blurView.frame.origin.x, self.blurView.frame.origin.y, self.blurView.frame.size.width, self.blurView.frame.size.height-100);
////
////        BOOL methodB = CGRectIntersectsRect(self.movingCell.frame, intersection);
////        NSLog(@"here1");
////
////        if (methodB) {
////            NSLog(@"%f, %f", self.movingCell.center.x, self.movingCell.center.y);
////            [self.movingCell setCenter:self.blurView.center];
////            [self.view bringSubviewToFront:self.movingCell];
////            [self.blurView.contentView addSubview:self.movingCell];
////            [self.blurView setHidden:YES];
////
////
////            NSLog(@"here");
////
////        }
//
//    }
//    if (panRecognizer.state == UIGestureRecognizerStateEnded) {
//        self.imageSelected = NO;
//
//    }
//}

@end
