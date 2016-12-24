//
//  EUExGaodeMapInstance.m
//  AppCanPlugin
//
//  Created by lkl on 15/5/12.
//  Copyright (c) 2015年 zywx. All rights reserved.
//

#import "EUExGaodeMapInstance.h"

@interface EUExGaodeMapInstance()<UIGestureRecognizerDelegate,MAMapViewDelegate, AMapSearchDelegate>
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;

@end




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
    [self clearDelegate];
    [self.annotations removeAllObjects];
    [self.overlays removeAllObjects];
    [self.gaodeView setMapStatus: _status animated:NO duration:0];
    [self.gaodeView removeFromSuperview];
    [self.buttonMgr hideAllButtons];
    
}

- (id)init
{
    self = [super init];
    if (self){
        _annotations = [NSMutableArray array];
        _overlays = [NSMutableArray array];
        _isGaodeMaploaded = NO;
        _locationStyleOptions = [[GaodeLocationStyle alloc] init];
        _offlineMgr = [[GaodeOfflineMapManager alloc]initWithMapView:self.gaodeView];

            
            
    }
        
    return self;

}
-(BOOL)loadGaodeMapWithDataLeft:(CGFloat)left
                            top:(CGFloat)top
                          width:(CGFloat)width
                         height:(CGFloat)height
                         APIKey:(NSString *)key{
    if(!self.isGaodeMaploaded){
        NSString *GaodeMapKey=[[[NSBundle mainBundle] infoDictionary] objectForKey:@"uexGaodeMapKey"];
        if(key && key.length>0){
            [AMapServices sharedServices].apiKey = key;
        }else{
           [AMapServices sharedServices].apiKey = GaodeMapKey;
        }
        
        self.searchAPI = [[AMapSearchAPI alloc] init];
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
        [self setupGestures];
        self.status =[self.gaodeView getMapStatus];
        self.buttonMgr=[[GaodeCustomButtonManager alloc]initWithMapView:self.gaodeView];
    }else{
        self.gaodeView.frame = CGRectMake(left,top,width,height);
    }
    self.gaodeView.scaleOrigin = CGPointMake(self.gaodeView.scaleOrigin.x, height-40);
    self.gaodeView.compassOrigin = CGPointMake(5, 5);
     
}



- (void)clearMapView{
    self.gaodeView.showsUserLocation = NO;
    
    [self.gaodeView removeAnnotations:self.gaodeView.annotations];
    
    [self.gaodeView removeOverlays:self.gaodeView.overlays];

    
    
    
    [self.gaodeView setCompassImage:nil];

}


- (void)clearDelegate
{
    self.searchAPI.delegate = nil;
    self.gaodeView.delegate = nil;
    self.delegate = nil;
}


#pragma mark - 手势

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ((gestureRecognizer == self.singleTap||gestureRecognizer==self.longPress) && ([touch.view isKindOfClass:[UIControl class]] || [touch.view isKindOfClass:[MAAnnotationView class]]))
    {
        return NO;
    }
    

    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)setupGestures
{
    self.longPress=[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
    self.longPress.minimumPressDuration=1.0;
    self.longPress.delegate=self;
    [self.gaodeView addGestureRecognizer:self.longPress];
    
    self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    self.singleTap.delegate = self;
    [self.singleTap requireGestureRecognizerToFail:self.longPress];
    [self.gaodeView addGestureRecognizer:self.singleTap];
    
    
   
    
    
    
}

-(void)handleSingleTap:(UITapGestureRecognizer *)theSingleTap{
    CLLocationCoordinate2D coordinate=[self parseGesture:theSingleTap];
    if([self.delegate respondsToSelector:@selector(handleGesture:withCoordinate:)]){
        [self.delegate handleGesture:GaodeGestureTypeClick withCoordinate:coordinate];
    }
    
    
    

}

-(void)handleLongPress:(UILongPressGestureRecognizer *)theLongPress{
    
    if(theLongPress.state==UIGestureRecognizerStateBegan){
        CLLocationCoordinate2D coordinate=[self parseGesture:theLongPress];
        if([self.delegate respondsToSelector:@selector(handleGesture:withCoordinate:)]){
            [self.delegate handleGesture:GaodeGestureTypeLongPress withCoordinate:coordinate];
        }
        

    }
   
}

-(CLLocationCoordinate2D)parseGesture:(UIGestureRecognizer *)gesture{
    CGPoint point=[gesture locationInView:self.gaodeView];
    return [self.gaodeView convertPoint:point toCoordinateFromView:self.gaodeView];
    
}

@end


