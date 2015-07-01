//
//  EUExGaodeMapInstance.m
//  AppCanPlugin
//
//  Created by AppCan on 15/5/12.
//  Copyright (c) 2015年 zywx. All rights reserved.
//

#import "EUExGaodeMapInstance.h"


@implementation EUExGaodeMapInstance
+ (instancetype)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static EUExGaodeMapInstance *sharedObj = nil;
    dispatch_once(&pred, ^{
        sharedObj = [[self alloc] init];
        
        
    });
    return sharedObj;
}





-(void)clearAll{
    [self clearMapView];
    [self clearSearch];
    [self.annotations removeAllObjects];
    [self.overlays removeAllObjects];
    [self.gaodeView setMapStatus: _status animated:NO duration:0];
    
}

- (id)init
{
    self = [super init];
    if (self){
        self.annotations =[NSMutableArray array];
        self.overlays = [NSMutableArray array];
        self.isGaodeMaploaded=NO;
        self.locationStyleOptions=[[GaodeLocationStyle alloc] init];

            
            
    }
        
    return self;

}
-(BOOL)loadGaodeMapWithDataLeft:(CGFloat)left
                            top:(CGFloat)top
                          width:(CGFloat)width
                         height:(CGFloat)height{
    //if(!sharedObj) return NO;
    
    
    if(!self.isGaodeMaploaded){
        NSString *GaodeMapKey=[[[NSBundle mainBundle] infoDictionary] objectForKey:@"uexGaodeMapKey"];
        
#warning 输入GaodeMapKey
        //源码调试时，可以在此输入或更改GaodeMapKey
        //GaodeMapKey=@"d9b8208b019919dedda01cba2e0a2e21"
        [MAMapServices sharedServices].apiKey =GaodeMapKey;
        self.searchAPI = [[AMapSearchAPI alloc] initWithSearchKey:GaodeMapKey Delegate:self];
        self.isGaodeMaploaded =YES;
    }
    
    [self setFrameLeft:left top:top width:width height:height];
    
    

    
    
    
    return YES;
}



-(void)setFrameLeft:(CGFloat)left
                top:(CGFloat)top
              width:(CGFloat)width
             height:(CGFloat)height{
    if(!self.gaodeView){
        self.gaodeView = [[MAMapView alloc] initWithFrame:CGRectMake(left,top,width,height)];
        self.status =[self.gaodeView getMapStatus];
    }else{
        self.gaodeView.frame=CGRectMake(left,top,width,height);
    }
    self.gaodeView.scaleOrigin=CGPointMake(self.gaodeView.scaleOrigin.x, height-40);
    self.gaodeView.compassOrigin=CGPointMake(5, 5);
}


- (void)clearMapView{
    self.gaodeView.showsUserLocation = NO;
    
    [self.gaodeView removeAnnotations:self.gaodeView.annotations];
    
    [self.gaodeView removeOverlays:self.gaodeView.overlays];

    
    self.gaodeView.delegate = nil;
    
    [self.gaodeView setCompassImage:nil];

}


- (void)clearSearch
{
    self.searchAPI.delegate = nil;
}


@end


