//
//  GaodePointAnnotation.h
//  AppCanPlugin
//
//  Created by lkl on 15/5/7.
//  Copyright (c) 2015年 zywx. All rights reserved.
//



@interface GaodePointAnnotation : MAPointAnnotation
@property (nonatomic,copy) NSString *identifier;
@property (nonatomic,strong) UIImage *iconImage;
@property (nonatomic,strong) UIImage *flashImage;
@property (nonatomic,strong) UIImage *bgImage;
@property (nonatomic,assign) BOOL canShowCallout;
@property (nonatomic,assign) BOOL animatesDrop;
@property (nonatomic,assign) BOOL draggable;
@property (nonatomic,assign) BOOL isCustomCallout;
@property (nonatomic,strong) NSDictionary *customCalloutData;
-(void)createIconImage:(NSString *)str topIconStr:(NSString *)topIconStr radius:(CGFloat)radius borderColor:(UIColor*)borderColor borderWidth:(CGFloat)borderWidth;

@end
