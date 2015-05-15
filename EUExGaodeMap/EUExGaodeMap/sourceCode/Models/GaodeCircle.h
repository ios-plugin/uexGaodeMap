//
//  GaodeCircle.h
//  AppCanPlugin
//
//  Created by AppCan on 15/5/11.
//  Copyright (c) 2015年 zywx. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>
#import "ColorConvert.h"
@interface GaodeCircle : MACircle
@property (nonatomic,assign) CGFloat lineWidth;
@property (nonatomic,assign) BOOL lineDash;
@property (nonatomic,strong) UIColor *strokeColor;
@property (nonatomic,strong) UIColor *fillColor;
@property (nonatomic,copy)NSString *identifier;



-(void)setStrokeC:(NSString *)colorString;
-(void)setFillC:(NSString *)colorString;
-(void)dataInit;

@end
