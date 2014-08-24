//
//  MGImageCollectionCell.m
//  Memory Game
//
//  Created by shanthivardhan on 24/08/14.
//  Copyright (c) 2014 Shanthi Vardhan. All rights reserved.
//


#import "MGImageCollectionCell.h"

@implementation MGImageCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)prepareForReuse{

    [super prepareForReuse];
}

@end
