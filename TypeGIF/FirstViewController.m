//
//  FirstViewController.m
//  TypeGIF
//
//  Created by Natasja Nielsen on 3/26/15.
//  Copyright (c) 2015 EECS493. All rights reserved.
//

#import "FirstViewController.h"
#import "AXCGiphy.h"
@import QuartzCore;
#import "DatabaseManager.h"
#import "ChangeCollectionViewController.h"

@interface FirstViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate, ChangeDelegate>

@property BOOL imageSelected;
@property (nonatomic, strong) NSMutableArray *resultsArray;
@property (nonatomic, strong) IBOutlet UICollectionView* resultsCollectionView;
@property (nonatomic, strong) UIPanGestureRecognizer* dragG;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer* doubleTapRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer* singleTap;
@property (nonatomic, strong) UIImageView* movingCell;
@property (nonatomic, strong) IBOutlet UIVisualEffectView* blurView;
@property (nonatomic, strong) DatabaseManager *db;

-(IBAction)didHoldImage:(id)sender;
-(void) handleLongPress:(UILongPressGestureRecognizer *)longPressRecog;
-(void) handleDoubleTap:(UITapGestureRecognizer*) tapRecognizer;
-(void) handleSingleTap:(UITapGestureRecognizer*) tapRecognizer;
-(void) writeGifToDisk:(NSData * )gif withName:(NSString* ) name;

@end


@implementation FirstViewController
@synthesize resultsCollectionView;

- (void)setupGestureRecognizers {
    self.longPressRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
    
    self.doubleTapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleDoubleTap:)];
    self.singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSingleTap:)];
    [self.singleTap setNumberOfTapsRequired:1];
    
    
    [self.doubleTapRecognizer setNumberOfTapsRequired:2];
    [self.resultsCollectionView addGestureRecognizer:self.longPressRecognizer];
    [self.resultsCollectionView  addGestureRecognizer:self.doubleTapRecognizer];
//    [self.resultsCollectionView  addGestureRecognizer:self.singleTap];
    
    self.dragG.delegate = self;
    self.imageSelected = NO;
}

- (void)showAlertView {
    UIAlertView *intro = [[UIAlertView alloc]initWithTitle:@"Hello!" message:@"To save a gif to a collection, double tap. To save to clipboard, hold down for a second" delegate:self cancelButtonTitle:@"Go away" otherButtonTitles:@"Okay", nil];
    [intro show];
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
    
    [self.searchTextField setPlaceholder:@"Search here or look below for trending gifs!"];
    [self.searchTextField setTextAlignment:NSTextAlignmentCenter];
    
    [self.resultsCollectionView setBackgroundColor:[UIColor clearColor]];
    
    [self setupGestureRecognizers];
    
    [self.blurView setHidden:YES];
    
    self.movingCell = [[UIImageView alloc]init];
    [self.movingCell setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.movingCell];
    
    [self showAlertView];
    self.db = [DatabaseManager createDatabaseInstance];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.labelText = @"Loading";
    
    [AXCGiphy trendingGIFsWithlimit:30 offset:0 completion:^(NSArray *results, NSError *error) {
        self.resultsArray = [NSMutableArray arrayWithArray:results];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [hud hide:YES];
            [self.resultsCollectionView reloadData];
        }];
    }];
    
    
    [self.collectionButton setPossibleTitles:[NSSet setWithArray:[self.db getAllCollections]]];
    [self.resultsCollectionView setBackgroundColor:[UIColor whiteColor]];
    self.selectedCollectionName = [NSString stringWithFormat:@"favorites"]; //default value
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
    
    [self.resultsArray removeAllObjects];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.labelText = @"Loading";
    
    [AXCGiphy searchGiphyWithTerm:textField.text limit:30 offset:0 completion:^(NSArray *results, NSError *error) {
        self.resultsArray = [NSMutableArray arrayWithArray:results];
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
    
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:0.2];

    [cell setBackgroundColor:color];
    [cell.imageView setAnimatedImage:nil];
    
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
            NSURLRequest * request = [NSURLRequest requestWithURL:gif.originalImage.url];
            NSURLResponse *response;
            NSError *Jerror = nil;
            myGif = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&Jerror];
            NSString *str = [NSString stringWithFormat:@"%@", gif.originalImage.url];
            [self writeGifToDisk:myGif withName:str];
        }
        else {
            //NSLog(@"cache hit");
        }

        FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:myGif];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            cell.imageView.animatedImage = image;
            [cell setImageURL:str];
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
//        NSLog(@"wrote to %@", dataPath);
        
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

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    //You may want to create a divider to scale the size by the way..
//    return CGSizeMake(100,100);
//}
//
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
//{
//    return 0;
//}
//
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
//{
//    return 5;
//}
//
//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
//{
//    return UIEdgeInsetsMake(0, 0, 0, 0);
//}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize mElementSize = CGSizeMake(123, 100);
    return mElementSize;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 2.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 2.0;
}

// Layout: Set Edges
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    // return UIEdgeInsetsMake(0,8,0,8);  // top, left, bottom, right
    return UIEdgeInsetsMake(0,0,0,0);  // top, left, bottom, right
}


#pragma mark - Gesture Recognizer Delegate Methods

-(void)handleLongPress:(UILongPressGestureRecognizer *)longPressRecog {
    
    CGPoint locationPoint = [longPressRecog locationInView:self.resultsCollectionView];
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

- (NSString*) buildFilePathFromURL:(NSString*) url {
    NSCharacterSet *charactersToRemove = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    NSString *str = [NSString stringWithFormat:@"%@", url];
    NSString *trimmedReplacement = [[str componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@""];
    NSString* fileName = [NSString stringWithFormat:@"%@.gif", trimmedReplacement];
    return fileName;
}

-(void)handleDoubleTap:(UITapGestureRecognizer *)tapRecognizer {
    [self animateShowBlurView];
    
    CGPoint locationPoint = [tapRecognizer locationInView:self.resultsCollectionView];
    CGPoint animationPoint = [tapRecognizer locationInView:self.view];
    animationPoint = CGPointMake(animationPoint.x, animationPoint.y-100);
    NSIndexPath *indexOfClickedCell = [self.resultsCollectionView indexPathForItemAtPoint:locationPoint];
    
    AXCCollectionViewCell *cell = (AXCCollectionViewCell*)[self.resultsCollectionView cellForItemAtIndexPath:indexOfClickedCell];

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
            
            [self.movingCell setAlpha:0.9f];
            [self.view bringSubviewToFront:self.movingCell];
            [self.movingCell setFrame:cell.frame];
            [self.movingCell setFrame:CGRectMake(cell.frame.origin.x, cell.frame.origin.y+100, cell.frame.size.width, cell.frame.size.height)];

            [UIView animateWithDuration:0.1 animations:^{
                self.movingCell.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.6f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self.movingCell setCenter:self.blurView.center];

                } completion:^(BOOL finished) {
                    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    hud.mode = MBProgressHUDModeCustomView;
                    NSString *hudStr = [NSString stringWithFormat:@"Saved to %@", self.selectedCollectionName];
                    hud.labelText = hudStr;
                    [hud hide:YES afterDelay:1.0f];
                    [self.blurView setHidden:YES];
                    [self.movingCell setImage:nil];
                    NSLog(@"collection name is!!!!!! %@", self.selectedCollectionName);
                    [self.db addGifToCollection:self.selectedCollectionName and:[self buildFilePathFromURL:cell.imageURL]];
                }];
            }];
        });
    });
}

-(void) handleSingleTap:(UITapGestureRecognizer*) tapRecognizer {
    
    CGPoint locationPoint = [tapRecognizer locationInView:self.resultsCollectionView];
    CGPoint animationPoint = [tapRecognizer locationInView:self.view];
    animationPoint = CGPointMake(animationPoint.x, animationPoint.y-100);
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
            
            [self.view bringSubviewToFront:self.movingCell];
            [self.movingCell setFrame:cell.frame];
            [self.movingCell setFrame:CGRectMake(cell.frame.origin.x, cell.frame.origin.y+100, cell.frame.size.width, cell.frame.size.height)];
            
            [UIView animateWithDuration:1.1 animations:^{
                self.movingCell.transform = CGAffineTransformScale(CGAffineTransformIdentity, 2.0, 2.0);
                [self.movingCell setCenter:self.view.center];
            } completion:^(BOOL finished) {

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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"collections_segue"])
    {
        // Get reference to the destination view controller
        ChangeCollectionViewController *vc = [segue destinationViewController];
        vc.delegate = self;
        // Pass any objects to the view controller here, like...
    }
}

#pragma mark - Change Collection Delegate Method
// Implement the delegate methods for ChildViewControllerDelegate
- (void)childViewController:(ChangeCollectionViewController *)viewController didChooseCollection:(NSString *)collection {

    self.selectedCollectionName = collection;
    [self.collectionButton setTitle:collection];
    self.collectionButton.title = collection;
    
    self.selectedCollectionName = collection;
    NSLog(@"%@",self.selectedCollectionName);
    
}

/* Experimental Drag + Drop Code */



@end
