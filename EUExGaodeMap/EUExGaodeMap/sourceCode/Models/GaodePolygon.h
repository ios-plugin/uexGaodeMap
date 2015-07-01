//
//  GaodePolygon.h
//  AppCanPlugin
//
//  Created by AppCan on 15/5/11.
//  Copyright (c) 2015年 zywx. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>
#import "GaodeModelUtils.h"
@interface GaodePolygon : MAPolygon
@property (nonatomic,copy) NSString *identifier;
@property (nonatomic,assign) CGFloat lineWidth;
@property (nonatomic,assign) MALineJoinType lineJoinType;
@property (nonatomic,strong) UIColor *strokeColor;
@property (nonatomic,strong) UIColor *fillColor;

-(void)setFillC:(NSString*)colorString;
-(void)setStrokeC:(NSString*)colorString;
-(void)dataInit;
@end
