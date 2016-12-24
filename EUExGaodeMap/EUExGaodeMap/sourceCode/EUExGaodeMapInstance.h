//
//  EUExGaodeMapInstance.h
//  AppCanPlugin
//
//  Created by lkl on 15/5/12.
//  Copyright (c) 2015年 zywx. All rights reserved.
//


#import "EBrowserView.h"
#import "EUtility.h"
#import "GaodeModels.h"
#import "GaodeCustomAnnotationView.h"
#import "GaodeOfflineMapManager.h"
#import "GaodeCustomButtonManager.h"

typedef NS_ENUM(NSInteger, GaodeGestureType){
    GaodeGestureTypeClick=0,
    GaodeGestureTypeLongPress
};

@protocol GaodeGestureDelegate<NSObject>

-(void)handleGesture:(GaodeGestureType)type withCoordinate:(CLLocationCoordinate2D)coordinate;


@end

@interface EUExGaodeMapInstance : NSObject
@property (nonatomic,strong)MAMapView *gaodeView;
@property (nonatomic,strong)AMapSearchAPI *searchAPI;
@property (nonatomic,strong) NSMutableArray *annotations;
@property (nonatomic,strong) NSMutableArray *overlays;
@property(nonatomic,strong) GaodeLocationStyle *locationStyleOptions;
@property (nonatomic,assign) BOOL isGaodeMaploaded;
@property (nonatomic,strong) MAMapStatus *status;
@property(nonatomic,strong)GaodeOfflineMapManager *offlineMgr;
@property(nonatomic,strong)GaodeCustomButtonManager *buttonMgr;
@property(nonatomic,weak)id<GaodeGestureDelegate> delegate;



+ (instancetype) sharedInstance;
-(BOOL)loadGaodeMapWithDataLeft:(CGFloat)left
                            top:(CGFloat)top
                          width:(CGFloat)width
                         height:(CGFloat)height
                         APIKey:(NSString *)key;

-(void)clearAll;
@end
