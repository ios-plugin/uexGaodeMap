//
//  GaodeLocationStyle.h
//  AppCanPlugin
//
//  Created by AppCan on 15/5/12.
//  Copyright (c) 2015年 zywx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GaodeLocationStyle : NSObject
@property (nonatomic,copy) NSString *identifier;
@property (nonatomic,assign) CGFloat lineWidth;
@property (nonatomic,assign) BOOL lineDash;
@property (nonatomic,strong) UIColor *strokeColor;
@property (nonatomic,strong) UIColor *fillColor;



typedef NS_ENUM(NSInteger,UserLocationStatus){
    ContinuousLocationDisabled      = 0,
    ContinuousLocationEnabled,
    ContinuousLocationEnabledWithMarker,
    GettingCurrentPosition,
    GettingCurrentPositionWhileLocating,
    GettingCurrentPositionWhileMarking

  };

@end
