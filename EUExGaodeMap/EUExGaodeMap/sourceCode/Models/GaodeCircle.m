//
//  GaodeCircle.m
//  AppCanPlugin
//
//  Created by AppCan on 15/5/11.
//  Copyright (c) 2015年 zywx. All rights reserved.
//

#import "GaodeCircle.h"

@implementation GaodeCircle

-(id)init{
    id tmp = self;
    self = [[self class] alloc];
    [tmp release];
    
    [self dataInit];
    
    return self;
}


-(void)setFillC:(NSString*)colorString{
    UIColor *fillColor=[ColorConvert returnUIColorFromHex:colorString];
    if(![fillColor isEqual:[UIColor clearColor]]){
        self.fillColor =fillColor;
    }
}
-(void)setStrokeC:(NSString*)colorString{
    UIColor *strokeColor=[ColorConvert returnUIColorFromHex:colorString];
    if(![strokeColor isEqual:[UIColor clearColor]]){
        self.strokeColor =strokeColor;
    }
}

-(void)dataInit{
    self.lineWidth =5.f;
    self.fillColor = [UIColor colorWithRed:1 green:0.8 blue:0.0 alpha:0.8];
    self.strokeColor =[UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:0.8];
    self.lineDash = YES;

    
}
@end
