//
//  GaodeLocationStyle.m
//  AppCanPlugin
//
//  Created by AppCan on 15/5/12.
//  Copyright (c) 2015年 zywx. All rights reserved.
//

#import "GaodeLocationStyle.h"

@implementation GaodeLocationStyle
-(id)init{

    self=[super init];
    if(self){
        [self dataInit];
    }
    
    
    return self;
}


-(void)dataInit{
    self.lineWidth = 2.f;
    self.fillColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:.3];
    self.strokeColor =[UIColor lightGrayColor];
    self.identifier =@"userLocationStyleReuseIndetifier";


}
@end

