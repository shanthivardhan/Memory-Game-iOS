//
//  MGGridImageView.m
//  Memory Game
//
//  Created by shanthivardhan on 24/08/14.
//  Copyright (c) 2014 Shanthi Vardhan. All rights reserved.
//

#import "MGGridImageView.h"

@interface MGGridImageView ()
{

    BOOL isClicked;
}

@end

@implementation MGGridImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        

        _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        _backgroundView.backgroundColor = [UIColor grayColor];
        [self addSubview:_backgroundView];
        _imageView = [[AsyncImageView alloc] initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeScaleToFill;
		_imageView.clipsToBounds = YES;
        [self addSubview:_imageView];


    }
    return self;
}

-(void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.imageView.frame = self.bounds;
    self.backgroundView.frame = self.bounds;
    if (self.isGameInPlay) {
        
        [self bringSubviewToFront:self.backgroundView];
        
    }else {
    
        [self bringSubviewToFront:self.imageView];
    }
    
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    isClicked = YES;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (isClicked) {
        
        [self selectRedeemCell:nil];
        
    }
}

- (void) selectRedeemCell:(id)sender {
    
    [self.delegate didSelectGridCell:self];
}


@end
