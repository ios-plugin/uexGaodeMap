//
//  CustomImageView.m
//  EUExGaodeMap
//
//  Created by wang on 16/8/8.
//  Copyright © 2016年 AppCan. All rights reserved.
//

#import "CustomImageView.h"
#import "EUExGaodeMap.h"
@implementation CustomImageView
-(id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [self addGestureRecognizer:tapGR];
    }
    return self;
}
-(void)tap:(UITapGestureRecognizer*)gr{
    NSDictionary *dic = @{@"id":self.identifier};
    [self.uexObj callbackJsonWithName:@"onMarkerClickListener" Object:dic];
}

@end
