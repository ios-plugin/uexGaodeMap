//
//  GaodePolygon.m
//  AppCanPlugin
//
//  Created by AppCan on 15/5/11.
//  Copyright (c) 2015年 zywx. All rights reserved.
//

#import "GaodePolygon.h"
#import "GaodeModelUtils.h"
@implementation GaodePolygon
-(id)init{
    self=[super init];
    if(self){
        [self dataInit];
    }
    
    
    return self;
}
-(void)setFillC:(NSString*)colorString{
    UIColor *fillColor=[GaodeModelUtils returnUIColorFromHTMLStr:colorString];
    if(![fillColor isEqual:[UIColor clearColor]]){
        self.fillColor =fillColor;
    }
}
-(void)setStrokeC:(NSString*)colorString{
    UIColor *strokeColor=[GaodeModelUtils returnUIColorFromHTMLStr:colorString];
    if(![strokeColor isEqual:[UIColor clearColor]]){
        self.strokeColor =strokeColor;
    }
}

-(void)dataInit{
    self.lineWidth =5.f;
    self.fillColor = [UIColor colorWithRed:0.77 green:0.88 blue:0.94 alpha:0.8];
    self.strokeColor =[UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:0.8];
    self.lineJoinType = kMALineJoinMiter;
}
@end
