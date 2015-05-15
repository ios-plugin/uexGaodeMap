//
//  GaodePointAnnotation.h
//  AppCanPlugin
//
//  Created by AppCan on 15/5/7.
//  Copyright (c) 2015年 zywx. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>

@interface GaodePointAnnotation : MAPointAnnotation
@property (nonatomic,copy) NSString *identifier;
@property (nonatomic,strong) UIImage *iconImage;
@property (assign,nonatomic) BOOL canShowCallout;
@property (assign,nonatomic) BOOL animatesDrop;
@property (assign,nonatomic) BOOL draggable;

-(void)createIconImage:(NSString *)str;

@end
