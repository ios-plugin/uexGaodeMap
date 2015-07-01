//
//  EUExGaodeMapInstance.h
//  AppCanPlugin
//
//  Created by AppCan on 15/5/12.
//  Copyright (c) 2015年 zywx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>
#import "EBrowserView.h"
#import "EUtility.h"
#import "model.h"

@interface EUExGaodeMapInstance : NSObject<MAMapViewDelegate, AMapSearchDelegate>
@property (nonatomic,strong)MAMapView *gaodeView;
@property (nonatomic,strong)AMapSearchAPI *searchAPI;
@property (nonatomic,strong) NSMutableArray *annotations;
@property (nonatomic,strong) NSMutableArray *overlays;
@property(nonatomic,strong) GaodeLocationStyle *locationStyleOptions;
@property (nonatomic,assign) BOOL isGaodeMaploaded;
@property (nonatomic,strong) MAMapStatus *status;



+ (instancetype) sharedInstance;
-(BOOL)loadGaodeMapWithDataLeft:(CGFloat)left
                            top:(CGFloat)top
                          width:(CGFloat)width
                         height:(CGFloat)height;

-(void)clearAll;
@end
