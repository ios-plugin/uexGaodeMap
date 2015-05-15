//
//  ColorConvert.m
//  AppCanPlugin
//
//  Created by AppCan on 15/5/7.
//  Copyright (c) 2015年 zywx. All rights reserved.
//

#import "ColorConvert.h"

@implementation ColorConvert
+(UIColor *)returnUIColorFromHex:(NSString *)colorString{
    if ([colorString length]<7) return [UIColor clearColor];
    if ([colorString hasPrefix:@"#"]){
        unsigned int r,g,b,a;
        NSString *str;
        NSRange range;
        if([colorString length]<9){
            a=255;
            range.location = 1;
            range.length = 6;
            str=[colorString  substringWithRange:range];
        }else{
            range.location = 1;
            range.length = 2;
            NSString *alpha =[colorString  substringWithRange:range];
            [[NSScanner scannerWithString:alpha] scanHexInt:&a];
            range.location = 3;
            range.length = 6;
            str=[colorString  substringWithRange:range];

        }
        range.location =0;
        range.length = 2;
        //r
        NSString *red = [str substringWithRange:range];
        //g
        range.location = 2;
        NSString *green = [str substringWithRange:range];
        //b
        range.location = 4;
        NSString *blue = [str substringWithRange:range];
        
        // Scan values

        [[NSScanner scannerWithString:red] scanHexInt:&r];
        [[NSScanner scannerWithString:green] scanHexInt:&g];
        [[NSScanner scannerWithString:blue] scanHexInt:&b];
        return [UIColor colorWithRed:(float)r/255.0 green:(float)g/255.0 blue:(float)b/255.0 alpha:(float)a/255.0];
        
    }
    
    
    
    return [UIColor clearColor];
    
}



@end
