//
//  GaodeCustomButtonManager.h
//  EUExGaodeMap
//
//  Created by Cerino on 15/8/18.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GaodeCustomButton.h"




@interface GaodeCustomButtonManager : NSObject
@property(nonatomic,weak)MAMapView *mapView;
@property(nonatomic,strong)NSMutableDictionary *buttonDict;

-(instancetype)initWithMapView:(MAMapView *)mapView;

-(void)addButtonWithId:(NSString*)identifier andX:(CGFloat)x andY:(CGFloat)y andWidth:(CGFloat)width andHeight:(CGFloat)height andTitle:(NSString *)title andTitleColor:(UIColor*)titleColor andBGImage:(UIImage*)bgImg completion:(void(^)(NSString * identifier,BOOL result))completion;

-(void)removeButtonWithId:(NSString*)identifier completion:(void(^)(NSString * identifier,BOOL result))completion;


-(void)showButtons:(NSArray*)ids completion:(void(^)(NSArray* succArr,NSArray* failArr))completion onClick:(eventBlock)clickBlock;
-(void)hideButtons:(NSArray*)ids completion:(void(^)(NSArray* succArr,NSArray* failArr))completion;
-(void)hideAllButtons;
@end
