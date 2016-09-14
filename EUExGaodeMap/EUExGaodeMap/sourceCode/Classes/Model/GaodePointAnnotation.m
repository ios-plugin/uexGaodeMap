//
//  GaodePointAnnotation.m
//  AppCanPlugin
//
//  Created by lkl on 15/5/7.
//  Copyright (c) 2015年 zywx. All rights reserved.
//

#import "GaodePointAnnotation.h"

@implementation GaodePointAnnotation

-(id)init{

    self = [super init];
    if(self){
        self.canShowCallout =NO;
        self.animatesDrop =YES;
        self.draggable = NO;
        self.isCustomCallout=NO;
    }
    
    
    return self;
}

-(void)createIconImage:(NSString *)str topIconStr:(NSString *)topIconStr radius:(CGFloat)radius borderColor:(UIColor*)borderColor borderWidth:(CGFloat)borderWidth{
    NSLog(@"topIconStr:%@",topIconStr);
     str=[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
     topIconStr=[topIconStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSData *imageData=nil;
    NSData *topImageData=nil;
    if([str hasPrefix:@"http"] || [str hasPrefix:@"https"]){
        imageData=[NSData dataWithContentsOfURL:[NSURL URLWithString:str]];
    }else{
        imageData = [NSData dataWithContentsOfFile:str];
    }
    if([topIconStr hasPrefix:@"http"] || [topIconStr hasPrefix:@"https"]){
        topImageData =[NSData dataWithContentsOfURL:[NSURL URLWithString:topIconStr]];
    }else{
        topImageData = [NSData dataWithContentsOfFile:topIconStr];
    }

    UIImage *image = [UIImage imageWithData: imageData];
    UIImage *topImage = [UIImage imageWithData: topImageData];
    //CGFloat radius = 100;
    if(image && topImage){
        //UIImage *scaleImage = [self OriginImage:topImage scaleToSize:[self OriginImage:topImage Width:2*radius Height:2*radius]];
        //self.iconImage = [self overlay:[self imageWithImage:scaleImage border:5 borderColor:borderColor] andImage:image];
         self.iconImage = image;
        UIImage *tempImage = [self OriginImage:topImage scaleToSize:[self OriginImage:topImage Width:2*radius Height:2*radius]];
        self.flashImage = [self imageWithImage:tempImage border:borderWidth borderColor:borderColor];
         self.bgImage = [self imageWithImage:tempImage border:borderWidth borderColor:[UIColor clearColor]];
    }else{
        self.iconImage = image;
    }
    
    
}
//-(UIImage*)overlay:(UIImage *)bottomImage andImage:(UIImage*)frontImage{
//    CGSize finalSize = [bottomImage size];
//    CGSize hatSize = [frontImage size];
//    CGFloat lwidth;
//    CGFloat swidth;
//    CGFloat margin = 1;
//    if (finalSize.width >= hatSize.width) {
//        lwidth = finalSize.width;
//        swidth = hatSize.width;
//    }else{
//        lwidth = hatSize.width;
//        swidth = finalSize.width;
//    }
//    UIGraphicsBeginImageContext(CGSizeMake(lwidth, finalSize.height+hatSize.height+margin));
//    [bottomImage drawInRect:CGRectMake(0,0,finalSize.width,finalSize.height)];
//    [frontImage drawInRect:CGRectMake(lwidth/2-swidth/2,finalSize.height+margin,hatSize.width,hatSize.height)];
//    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return newImage;
//    
//}
- (UIImage *)imageWithImage:(UIImage *)image border:(CGFloat)border borderColor:(UIColor *)color
{
    // 加载旧的图片
    UIImage *oldImage = image;
    
    //  新的画布的尺寸
    CGFloat imageWidth = oldImage.size.width + 2*border;
    CGFloat imageHeight = oldImage.size.height + 2*border;
    
    // 设置与大圆相切的正方形的宽
    CGFloat circleW = MIN(imageWidth, imageHeight);
    
    // 开启图片上下文
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(circleW, circleW), NO, 0.0);
    
    // 画大的实心圆
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, circleW, circleW)];
    
    // 设置颜色
    [color setFill];
    
    // 绘制
    [path fill];
    
    CGRect smallCircle = CGRectMake(border, border,circleW-2*border, circleW-2*border);
    // 绘制小圆的路径
    UIBezierPath *smallPath = [UIBezierPath bezierPathWithOvalInRect:smallCircle];
    [smallPath addClip];
    // 画原有的旧图
    [oldImage drawInRect:smallCircle];
    //获取新的图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    // 关闭上下文
    UIGraphicsEndImageContext();
    
    return newImage;
    
}
-(CGSize)OriginImage:(UIImage *)image Width:(CGFloat)drawWidth Height:(CGFloat)drawHeight {
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    NSDecimalNumber *drawWidthNumber = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f",drawWidth]];
    NSDecimalNumber *drawHeightNumber = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f",drawHeight]];
    NSDecimalNumber *widthNumber = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f",width]];
    NSDecimalNumber *heightNumber = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f",height]];
    
    if (width > height) {
        
        NSDecimalNumber *ratioNumber = [drawWidthNumber decimalNumberByDividingBy:widthNumber];
        NSDecimalNumber *height1Number = [ratioNumber decimalNumberByMultiplyingBy:heightNumber];
        //CGFloat ratio1 = drawWidth/width;
        //CGFloat height1 = height*ratio1;
        return CGSizeMake(drawWidth, [height1Number floatValue]);
    }else{
        NSDecimalNumber *ratioNumber = [drawHeightNumber decimalNumberByDividingBy:heightNumber];
        NSDecimalNumber *width1Number = [ratioNumber decimalNumberByMultiplyingBy:widthNumber];
        //CGFloat ratio1 = drawHeight/height;
        //CGFloat width1 = width*ratio1;
        return CGSizeMake([width1Number floatValue], drawHeight);
    }
    
    return CGSizeZero;
}
-(UIImage*) OriginImage:(UIImage *)image scaleToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size); //size 为CGSize类型，即你所需要的图片尺寸
    
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage; //返回的就是已经改变的图片
}

@end
