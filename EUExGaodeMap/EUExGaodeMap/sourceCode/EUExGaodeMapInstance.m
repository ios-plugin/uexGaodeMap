//
//  EUExGaodeMapInstance.m
//  AppCanPlugin
//
//  Created by AppCan on 15/5/12.
//  Copyright (c) 2015年 zywx. All rights reserved.
//

#import "EUExGaodeMapInstance.h"

static EUExGaodeMapInstance *sharedObj = nil;
@implementation EUExGaodeMapInstance



+ (instancetype) sharedInstance
{
    @synchronized (self)
    {
        if (sharedObj == nil)
        {
            [[self alloc] init];
        }
    }
    return sharedObj;
}

+ (id) allocWithZone:(NSZone *)zone
{
    @synchronized (self) {
        if (sharedObj == nil) {
            sharedObj = [super allocWithZone:zone];
            return sharedObj;
        }
    }
    return nil;
}
-(void)clearAll{
    [self clearMapView];
    [self clearSearch];
    [self.annotations removeAllObjects];
    [self.overlays removeAllObjects];
    [self.gaodeView setMapStatus: _status animated:NO duration:0];
    
}
- (id) copyWithZone:(NSZone *)zone 
{
    return self;
}

- (id) retain
{
    return self;
}

- (NSUInteger) retainCount
{
    return UINT_MAX;
}

- (oneway void) release
{
    
}

- (id) autorelease
{
    return self;
}

- (id)init
{
    @synchronized(self) {
        if (self = [super init]){
            self.annotations =[NSMutableArray array];
            self.overlays = [NSMutableArray array];
            self.isGaodeMaploaded=NO;
            self.locationStyleOptions=[[GaodeLocationStyle alloc] init];

            
            
        }
        
        return nil;
    }
}
-(BOOL)loadGaodeMap{
    if(!sharedObj) return NO;

    NSString *GaodeMapKey=[[[NSBundle mainBundle] infoDictionary] objectForKey:@"uexGaodeMapKey"];
    
#warning 输入GaodeMapKey 
    //源码调试时，可以在此输入或更改GaodeMapKey
    //GaodeMapKey=@"d9b8208b019919dedda01cba2e0a2e21"
    
    
    
    [MAMapServices sharedServices].apiKey =GaodeMapKey;
    self.searchAPI = [[AMapSearchAPI alloc] initWithSearchKey:GaodeMapKey Delegate:self];

    self.gaodeView = [[MAMapView alloc] initWithFrame:CGRectMake(0.0,0.0,100.0,100.0)];
    self.status =[self.gaodeView getMapStatus];
    self.isGaodeMaploaded =YES;
    return YES;
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


