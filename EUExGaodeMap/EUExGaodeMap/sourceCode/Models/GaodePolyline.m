//
//  GaodePolyline.m
//  AppCanPlugin
//
//  Created by AppCan on 15/5/7.
//  Copyright (c) 2015年 zywx. All rights reserved.
//

#import "GaodePolyline.h"
#import "GaodeModelUtils.h"

@implementation GaodePolyline
-(id)init{
    self=[super init];
    if(self){
        [self dataInit];
    }
    
    
    return self;
}


-(void)setFillC:(NSString*)colorString{
    UIColor *color=[GaodeModelUtils returnUIColorFromHTMLStr:colorString];
    if(![color isEqual:[UIColor clearColor]]){
        self.color =color;
    }
}

-(void)dataInit{
    self.lineWidth =10.f;
    self.color = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.6];
    self.lineJoinType = kMALineJoinRound;
    self.lineCapType = kMALineCapRound;
}
@end
