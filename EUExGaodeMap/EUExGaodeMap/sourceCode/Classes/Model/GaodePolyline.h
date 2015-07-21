//
//  GaodePolyline.h
//  AppCanPlugin
//
//  Created by lkl on 15/5/7.
//  Copyright (c) 2015年 zywx. All rights reserved.
//



@interface GaodePolyline : MAPolyline
@property (nonatomic,copy) NSString *identifier;
@property (nonatomic,assign) CGFloat lineWidth;
@property (nonatomic,assign) MALineJoinType lineJoinType;
@property (nonatomic,assign) MALineCapType lineCapType;
@property (nonatomic,strong) UIColor *color;


-(void)setFillC:(NSString*)colorString;
-(void)dataInit;
@end
