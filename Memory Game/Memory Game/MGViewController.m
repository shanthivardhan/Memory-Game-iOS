//
//  MGViewController.m
//  Memory Game
//
//  Created by shanthivardhan on 24/08/14.
//  Copyright (c) 2014 Shanthi Vardhan. All rights reserved.
//

#import "MGViewController.h"
#import "MGImageCollectionCell.h"
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"
#import "MGGridImageView.h"

#define FLICKR_API @"http://api.flickr.com/services/feeds/photos_public.gne?format=json&nojsoncallback=1"

static NSOperationQueue * _imgDownloadQueue = nil;

NSOperationQueue * ImageDownloadQueue(){
    
    if (_imgDownloadQueue == nil) {
        
        _imgDownloadQueue = [[NSOperationQueue alloc] init];
        [_imgDownloadQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
    }
    return _imgDownloadQueue;
}


@interface MGViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate, MGGridImageViewDelegate>
{
    BOOL isPlayStarted;
    NSUInteger randomNumber;
    NSTimer * gameTimer;
    NSUInteger counter;
}

@property (strong, nonatomic) IBOutlet UILabel *countdownLabel;
@property (strong, nonatomic) IBOutlet AsyncImageView *imageToGuess;
@property (strong, nonatomic) IBOutlet UICollectionView *imageGrid;
@property (strong, nonatomic) IBOutlet UIView *guessImageView;
@property (nonatomic, strong) NSArray * images;
@property (strong, nonatomic) IBOutlet UIButton *retryButton;
@property (strong, nonatomic) IBOutlet UITableView *imageGridTable;
- (IBAction)didSelectRetryButton:(id)sender;

@end

@implementation MGViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.imageGrid.dataSource = self;
    self.imageGrid.delegate = self;
    
    self.imageGridTable.delegate = self;
    self.imageGridTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.imageGridTable.dataSource = self;
    
    MBProgressHUD * loadingView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    loadingView.labelText = @"Loading Game!";
    randomNumber = GetRandomNumberBelow(9);
    [self getFlickrImages];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - TableView Delegate & Data Source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return [self.images count]/3.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return ceilf(320/3);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString * cellIdentifier = @"Cell";
    
    UITableViewCell * cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell==nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight ;
    }
    for (UIView * vw in [cell.contentView subviews]) {
        
        [vw removeFromSuperview];
    }
    
    int i = 0, defaultX = 0;
    UIView * contentView = [[UIView alloc] initWithFrame:cell.contentView.frame];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight ;
    CGFloat gridCellWidth = CGRectGetWidth(contentView.frame);
    gridCellWidth = ceilf(((gridCellWidth)/3.0)) ;
    
    while (i < 3) {
        
        if ((indexPath.row * 3+ i >= self.images.count)) {
            
            break;
        }
        CGRect frameToSet = CGRectMake(defaultX, CGRectGetMinY(cell.contentView.frame), gridCellWidth-1, CGRectGetHeight(cell.contentView.frame)-1);
        
        MGGridImageView * gridImageView = [[MGGridImageView alloc] initWithFrame:frameToSet];
        gridImageView.delegate = self;
        gridImageView.isGameInPlay = isPlayStarted;
        if (i == 0) {
            
            gridImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight |  UIViewAutoresizingFlexibleRightMargin;
            
        }else if(i == 2){
            
            gridImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight |UIViewAutoresizingFlexibleLeftMargin;
        }
        else {
            
            gridImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin| UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight ;
            
        }
        NSString * imageURLStr = [self.images objectAtIndex:indexPath.row * 3+ i];
        gridImageView.imageView.imageURL = [NSURL URLWithString:imageURLStr];
        [contentView addSubview:gridImageView];
        
        if (i < 2) {
            
            UIView * separator  = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(gridImageView.frame), 0, 1, CGRectGetHeight(cell.frame))];
            separator.autoresizingMask =  UIViewAutoresizingFlexibleHeight |UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin  ;
            separator.backgroundColor= [UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0];
            separator.layer.shadowOffset = CGSizeMake(0, 1);
            separator.layer.shadowColor = [UIColor whiteColor].CGColor;
            [contentView addSubview:separator];
        }
        
        defaultX += gridCellWidth;
        
        i++;
    }
    [cell.contentView addSubview:contentView];

    
    return cell;
}

#pragma mark - CollectionView Delegate & Data Source

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
	return [self.images count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    MGImageCollectionCell * imageCell = [collectionView
                                         dequeueReusableCellWithReuseIdentifier:@"ImageCell"
                                         forIndexPath:indexPath];
    imageCell.layer.borderColor = [UIColor lightGrayColor].CGColor;
    imageCell.layer.borderWidth=0.5;
    if (isPlayStarted) {
        
        imageCell.backgroundView.hidden = NO;
        imageCell.imageView.hidden = YES;
    }else{
        
        imageCell.backgroundView.hidden = YES;
        imageCell.imageView.hidden = NO;
        NSString * imageURLStr = [self.images objectAtIndex:indexPath.row];
        imageCell.imageView.imageURL = [NSURL URLWithString:imageURLStr];
    }
	
    return imageCell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    MGImageCollectionCell * imageCell = (MGImageCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (isPlayStarted) {
        
        imageCell.imageView.hidden = NO;
        
        [UIView transitionFromView:imageCell.backgroundView
                            toView:imageCell.imageView
                          duration:1
                           options:UIViewAnimationOptionTransitionFlipFromRight
                        completion:nil];
    }
    if ([imageCell.imageView.image isEqual:self.imageToGuess.image]) {
        
        [[[UIAlertView alloc] initWithTitle:@"Success" message:@"You guess is successful!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
        isPlayStarted = NO;
    }
	
}

- (void) getFlickrImages{
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:FLICKR_API]];
    [request setHTTPMethod:@"GET"];
    [NSURLConnection sendAsynchronousRequest:request queue:ImageDownloadQueue() completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if ([data length] > 0 && connectionError == nil) {
            @try {
                
                NSError *parserError;
                NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parserError];
                if (parserError != nil) {
                    
                    [self reloadFlickrRequest];
                    
                    return;
                }
                if (responseDict != nil && ![responseDict isEqual:[NSNull null]]) {
                    
                    NSArray * photoDataArray = [responseDict valueForKey:@"items"];
                    if (photoDataArray != nil && ![photoDataArray isEqual:[NSNull null]]) {
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [self updateImageGridWithArray:photoDataArray];
                            
                        });
                    }
                }
            }
            @catch (NSException *exception) {
                
            }
            @finally {
                
            }
        }else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
                
            });
        }
    }];
}

- (void) reloadImageGrid{

    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(reloadImageGrid) withObject:nil
                            waitUntilDone:NO];
        return;
    }
    [self.imageGrid reloadData];
    [self.imageGrid layoutIfNeeded];

}

- (void) reloadFlickrRequest{

    [self getFlickrImages];
}

- (void) updateImageGridWithArray:(NSArray *) serverArray{

    self.images = [[serverArray valueForKeyPath:@"media.m"] subarrayWithRange:NSMakeRange(0, 9)];
    
   // [self performSelector:@selector(reloadImageGrid) withObject:nil afterDelay:0.5];
    
    [self.imageGridTable reloadData];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    counter = 0;
    gameTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateCountDown) userInfo:nil repeats:YES];
    
    
}

- (void) updateCountDown{

    counter++;
    [self.countdownLabel setHidden:NO];
    self.countdownLabel.text = [NSString stringWithFormat:@"%i", counter];
    if (counter == 15) {
        isPlayStarted = YES;

//        [self performSelector:@selector(reloadImageGrid) withObject:nil afterDelay:0.5];;
        [self.imageGridTable reloadData];
        self.imageToGuess.hidden = NO;
        self.guessImageView.hidden = NO;
        self.imageToGuess.imageURL = [NSURL URLWithString:[self.images objectAtIndex:randomNumber-1]];
        self.countdownLabel.hidden = YES;
        
        [gameTimer invalidate];
        gameTimer = nil;
        counter = 0;
    }
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{

    [self.imageGridTable reloadData];
    self.retryButton.hidden = NO;
}

NSUInteger GetRandomNumberBelow(NSUInteger n) {
    
    NSUInteger m = 1;
    do {
        m <<= 1;
    } while(m < n && m > 0);
    
    NSUInteger ret;
    
    do {
        ret = random() % m;
    } while(ret >= n);
    
    return ret;
}

- (IBAction)didSelectRetryButton:(id)sender {
    
    self.images = nil;
    [self.imageGridTable reloadData];
    //[self performSelector:@selector(reloadImageGrid) withObject:nil afterDelay:0.5];;
    self.guessImageView.hidden = YES;
    [self getFlickrImages];
    
    self.retryButton.hidden = YES;
    MBProgressHUD * loadingView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    loadingView.labelText = @"Loading Game!";
    randomNumber = GetRandomNumberBelow(9);
    
}

- (void) didSelectGridCell:(MGGridImageView *)imageCell{

    if (isPlayStarted) {
        
        
    }
    [UIView transitionFromView:imageCell.backgroundView
                        toView:imageCell.imageView
                      duration:1
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    completion:nil];
    
    if ([imageCell.imageView.image isEqual:self.imageToGuess.image]) {
        
        [[[UIAlertView alloc] initWithTitle:@"Success" message:@"You have guessed correctly!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
        isPlayStarted = NO;
    }
	
}

@end
