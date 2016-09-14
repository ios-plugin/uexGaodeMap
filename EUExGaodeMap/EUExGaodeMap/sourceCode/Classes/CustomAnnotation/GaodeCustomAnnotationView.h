//
//  GaodeCustomAnnotationView.h
//  EUExGaodeMap
//
//  Created by lkl on 15/7/9.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//


#import "GaodeCACallouts.h"

@interface GaodeCustomAnnotationView : MAPinAnnotationView


@property(nonatomic,strong)GaodeCACalloutBase *callout;
@property(nonatomic,strong)NSDictionary *calloutData;
@property(nonatomic,assign)GaodeCACalloutType calloutType;
@property(nonatomic,assign)UIImageView *yellowView;

-(void)setupWithCalloutDict:(NSDictionary*)dataDict;

-(void)createCalloutWithError:(NSError **)Error;



@end
