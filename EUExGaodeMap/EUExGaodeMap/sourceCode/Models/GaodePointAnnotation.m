//
//  GaodePointAnnotation.m
//  AppCanPlugin
//
//  Created by AppCan on 15/5/7.
//  Copyright (c) 2015年 zywx. All rights reserved.
//

#import "GaodePointAnnotation.h"

@implementation GaodePointAnnotation

-(id)init{
    id tmp = self;
    self = [[self class] alloc];
    [tmp release];
    self.canShowCallout =NO;
    self.animatesDrop =YES;
    self.draggable = NO;
    
    return self;
}

-(void)createIconImage:(NSString *)str{
    NSData *imageData = [NSData dataWithContentsOfFile: str];
    UIImage *image = [UIImage imageWithData: imageData];
    if(image){
        self.iconImage = image;

    }

    
}
@end
