//
//  MGGridImageView.h
//  Memory Game
//
//  Created by shanthivardhan on 24/08/14.
//  Copyright (c) 2014 Shanthi Vardhan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@class MGGridImageView;

@protocol MGGridImageViewDelegate <NSObject>

- (void) didSelectGridCell:(MGGridImageView *) imageCell;

@end

@interface MGGridImageView : UIView

@property (strong, nonatomic)  UIView *backgroundView;
@property (strong, nonatomic)  AsyncImageView *imageView;
@property (nonatomic) NSUInteger index;
@property (nonatomic) BOOL isGameInPlay;

@property(nonatomic,assign) id<MGGridImageViewDelegate> delegate;

@end
