//
//  MGImageCollectionCell.h
//  Memory Game
//
//  Created by shanthivardhan on 24/08/14.
//  Copyright (c) 2014 Shanthi Vardhan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface MGImageCollectionCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIView *backgroundView;
@property (strong, nonatomic) IBOutlet AsyncImageView *imageView;

@end
