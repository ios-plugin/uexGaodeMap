//
//  GaodeCustomButton.h
//  EUExGaodeMap
//
//  Created by Cerino on 15/8/18.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GaodeCustomButtonManager;


typedef void (^eventBlock)(NSString *identifier);

@interface GaodeCustomButton : UIButton
@property(nonatomic,copy)NSString* identifier;
@property(nonatomic,assign)BOOL isShown;
@property(nonatomic,weak)GaodeCustomButtonManager *GaodeCBMgr;
@property(nonatomic,strong) eventBlock clickBlock;

+(instancetype)buttonWithType:(UIButtonType)buttonType identifier:(NSString*)identifier manager:(GaodeCustomButtonManager*)mgr;

@end
