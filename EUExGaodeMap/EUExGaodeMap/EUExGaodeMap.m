//
//  EUExGaodeMap.m
//  AppCanPlugin
//
//  Created by AppCan on 15/5/5.
//  Copyright (c) 2015年 zywx. All rights reserved.
//

#import "EUExGaodeMap.h"
#import "EUExGaodeMapInstance.h"
#import "CustomView.h"
#import "uexGaodeRouteSearch.h"

#define PathImageString @"lineImagePath"
#define IsShowLineImage @"isShowLineImage"

static inline NSString * newUUID(){
    return [NSUUID UUID].UUIDString;
}

@interface EUExGaodeMap ()<MAMapViewDelegate, AMapSearchDelegate,GaodeGestureDelegate,GaodeOfflineDelegate> {
}
@property(nonatomic,readonly)MAMapView *mapView;
@property(nonatomic,readonly)AMapSearchAPI *search;
@property(nonatomic,readonly)EUExGaodeMapInstance *sharedInstance;
@property(nonatomic,assign) BOOL isInitialized;
@property(nonatomic,assign) float zoom;

@property(nonatomic,assign) UserLocationStatus locationStatus;

@property(nonatomic,readonly) NSMutableArray *annotations;
@property(nonatomic,readonly) NSMutableArray *overlays;
@property(nonatomic,strong) GaodeLocationStyle *locationStyleOptions;
@property(nonatomic,strong) ACJSFunctionRef *func;

@property (nonatomic, strong) MAAnnotationView *userLocationAnnotationView;
//记录地图最后一次的缩放级别数值
@property(nonatomic,assign) float lastZoomLevel;
//是否停止旋转箭头
@property(nonatomic,assign) BOOL isStopRotateHeader;
//折线的纹理图片
@property (nonatomic, strong) UIImage *lineImage;
//折线是否使用纹理图片
@property(nonatomic,assign) BOOL isShowLineImage;

@end

@implementation EUExGaodeMap

- (instancetype)initWithWebViewEngine:(id<AppCanWebViewEngineObject>)engine{
    if (self = [super initWithWebViewEngine:engine]) {


      
    }
    return self;
}

- (void)dealloc{
    [self clean];

}



- (void)clean{
    
    [self.sharedInstance clearAll];

}


- (NSMutableArray *)annotations{
    return self.sharedInstance.annotations;
}

- (NSMutableArray *)overlays{
    return self.sharedInstance.overlays;
}

- (EUExGaodeMapInstance *)sharedInstance{
    return [EUExGaodeMapInstance sharedInstance];
}

- (MAMapView *)mapView{
    return self.sharedInstance.gaodeView;
}
- (AMapSearchAPI *)search{
    return self.sharedInstance.searchAPI;
}

/*
 ### open
 打开地图

 ### 参数：
 var json = {
 left:,//(可选) 左间距，默认0
 top:,//(可选) 上间距，默认0
 width:,//(可选) 地图宽度
 height:,//(可选) 地图高度
 longitude:,//(可选) 中心点经度
 latitude://(可选) 中心点纬度
 isScrollWithWeb:,//(可选) 地图是否跟随网页滚动，默认为false
 }
 
 */




- (void)open:(NSMutableArray *)inArguments{
    if([inArguments count]<1) return;
    ACArgsUnpack(NSDictionary *initInfo) = inArguments;
    
    self.lastZoomLevel = 0;
    self.isStopRotateHeader = NO;
    
    CGFloat left=0;
    CGFloat top=0;
    CGFloat width=CGRectGetWidth([self.webViewEngine webView].bounds);
    CGFloat height=CGRectGetHeight([self.webViewEngine webView].bounds);
    BOOL isScrollWithWeb=false;
    if(initInfo[@"left"]){
        left=[[initInfo getStringForKey:@"left"] floatValue];
    }
    if([initInfo getStringForKey:@"top"]){
        top=[[initInfo getStringForKey:@"top"] floatValue];
    }
    if([initInfo getStringForKey:@"width"]){
        width=[[initInfo getStringForKey:@"width"] floatValue];
    }
    if([initInfo getStringForKey:@"height"]){
        height=[[initInfo getStringForKey:@"height"] floatValue];
    }
    if([initInfo objectForKey:@"isScrollWithWeb"] &&[[initInfo objectForKey:@"isScrollWithWeb"] boolValue]){
        isScrollWithWeb=YES;
    }
    NSString *APIKey=nil;
    if([initInfo objectForKey:@"APIKey"] && [initInfo[@"APIKey"] isKindOfClass:[NSString class]]){
        APIKey=initInfo[@"APIKey"];
    }
    
    [self.sharedInstance clearAll];
    [self.sharedInstance loadGaodeMapWithDataLeft:left top:top width:width height:height APIKey:APIKey];


  


    self.search.delegate = self;
    self.mapView.delegate = self;
    self.sharedInstance.offlineMgr.delegate=self;
     self.sharedInstance.delegate=self;
    self.mapView.customizeUserLocationAccuracyCircleRepresentation = YES;

    self.locationStyleOptions=self.sharedInstance.locationStyleOptions;
    self.mapView.showTraffic= NO;
    self.mapView.mapType=MAMapTypeStandard;
    //self.mapView.showsScale= NO;
   
    
    if(isScrollWithWeb){
        
         [[self.webViewEngine webScrollView] addSubview:self.mapView];
    }else{
       
         [[self.webViewEngine webView] addSubview:self.mapView];
    }
    


    
    
    if([initInfo getStringForKey:@"latitude"]){
        if([initInfo getStringForKey:@"longitude"]){
            NSString *latitude=[initInfo getStringForKey:@"latitude"];
            NSString *longitude=[initInfo getStringForKey:@"longitude"];
            double lat=[latitude doubleValue];

           

            double lon=[longitude doubleValue];
           CLLocationCoordinate2D center=CLLocationCoordinate2DMake(lat,lon);
           [self.mapView setCenterCoordinate:center animated:NO];
            

        }
        
    }
    
    //[self callbackJsonWithName:@"cbOpen" Object:@"Initialize GaodeMap successfully!" Function:func];
      
    
}





- (void)resize:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSDictionary *info) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(info);
    
    CGRect frame = self.mapView.frame;
    NSNumber *x = numberArg(info[@"left"]);
    NSNumber *y = numberArg(info[@"top"]);
    NSNumber *width = numberArg(info[@"width"]);
    NSNumber *height = numberArg(info[@"height"]);
    if (x) {
        frame.origin.x = x.floatValue;
    }
    if (y) {
        frame.origin.y = y.floatValue;
    }
    if (width) {
        frame.size.width = width.floatValue;
    }
    if (height) {
        frame.size.height = height.floatValue;
    }
    self.mapView.frame = frame;
}



/*
 ### close
 关闭地图
 ```
 uexGaodeMap.close()
 ```
 ### 参数：
 ```
 无
 ```
 */
- (void)close:(NSMutableArray *)inArguments{
    [self clean];
}

/*
 ### setMapType
 设置地图类型
 ```
 uexGaodeMap.setMapType(json)
 ```
 ### 参数：
 ```
 var json = {
 type://（必选）地图类型，1-标准地图，2-卫星地图，3-夜景地图
 }
 ```
 */
- (void)setMapType:(NSMutableArray *)inArguments{
    if([inArguments count]<1) return;
    ACArgsUnpack(NSDictionary *mapType) = inArguments;
    //id mapType = [self getDataFromJson:inArguments[0]];
    NSInteger MAMapType;
    NSString *type = [mapType getStringForKey:@"type"];
    if([type isEqual:@"2"]){
        MAMapType=MAMapTypeSatellite;
    }else if ([type isEqual:@"3"]){
        MAMapType=MAMapTypeStandardNight;
        
    }else if([type isEqual:@"1"]){
        MAMapType =MAMapTypeStandard;
    }
    self.mapView.mapType = MAMapType;
    
}
/*
### setTrafficEnabled
开启或关闭实时路况
```
uexGaodeMap.setTrafficEnabled(json)
```
### 参数：
```
var json = {
type://（必选） 0-关闭，1-开启
}
*/
- (void)setTrafficEnabled:(NSMutableArray *)inArguments{
    if([inArguments count]<1) return;
    ACArgsUnpack(NSDictionary *info) = inArguments;
    
    NSString *traffic=[info getStringForKey:@"type"];
    if([traffic isEqual:@"1"]){
        self.mapView.showTraffic= YES;
    }else if([traffic isEqual:@"0"]){
        self.mapView.showTraffic= NO;
    }
    
}
/*
 ### setCenter
 设置地图中心点
 ```
 uexGaodeMap.setCenter(json)
 ```
 ### 参数：
 ```
 var json = {
 longitude:,//（必选）中心点经度
 latitude://（必选）中心点纬度
 }
 */
- (void)setCenter:(NSMutableArray *)inArguments{
    if([inArguments count]<1) return;
    
    ACArgsUnpack(NSDictionary *info) = inArguments;
    NSString *longitude,*latitude;
    if(![info getStringForKey:@"longitude"]){
        return;
    }else{
        longitude =[info getStringForKey:@"longitude"];
    }
    if(![info getStringForKey:@"latitude"]){
        return;
    }else{
        latitude =[info getStringForKey:@"latitude"];
    }
      [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake([latitude floatValue], [longitude floatValue]) animated:YES];
}
/*
 ### setZoomLevel
 设置地图缩放级别
 ```
 uexGaodeMap.setZoomLevel(json)
 ```
 ### 参数：
 ```
 var json = {
 level://(必选)级别，范围(3,20)
 }
 ```
 */
- (void)mapZoom:(float)zoom{
    zoom=(zoom>19)?19.0:zoom;
    zoom=(zoom<3)?3.0:zoom;
    self.zoom=zoom;
    [self.mapView setZoomLevel:zoom];
    
}
- (void)setZoomLevel:(NSMutableArray *)inArguments{
    if([inArguments count]<1) return;
    
    ACArgsUnpack(NSDictionary *info) = inArguments;
    float zoom =[[info getStringForKey:@"level"] floatValue];
    [self mapZoom:zoom];

    
}



/*
 ###zoomIn
  放大一个地图级别
 */



- (void)zoomIn:(NSMutableArray *)inArguments{
    
    [self mapZoom:(self.zoom+1)];
    
    
}



/*
 ###zoomOut
  缩小一个地图级别
 */



- (void)zoomOut:(NSMutableArray *)inArguments{
    
    
    [self mapZoom:(self.zoom-1)];
    
}



/*
 ###rotate
  旋转地图
 params:
 angle://（必选）旋转角度，正北方向到地图方向逆时针旋转的角度，范围(0,360)。
 
 */



- (void)rotate:(NSMutableArray *)inArguments{
    
    if([inArguments count]<1) return;
    
    ACArgsUnpack(NSDictionary *info) = inArguments;
    NSString *angle=nil;
    if([info getStringForKey:@"angle"]){
        angle=[info getStringForKey:@"angle"];
    }else return;
     [self.mapView setRotationDegree:[angle floatValue] animated:YES duration:0.5];
    
    
}



/*
 ###overlook
 倾斜地图
 params:
 angle://(必选)地图倾斜度，范围(0,45)。
 
 */



- (void)overlook:(NSMutableArray *)inArguments{
    
    if([inArguments count]<1) return;
    
    ACArgsUnpack(NSDictionary *info) = inArguments;
    NSString *angle=nil;
    if([info getStringForKey:@"angle"]){
        angle=[info getStringForKey:@"angle"];
    }else return;
    
    [self.mapView setCameraDegree:[angle floatValue] animated:YES duration:0.5];
    
}



/*
 ###setZoomEnable
 开启或关闭手势缩放
 params:
 type://（必选） 0-关闭，1-开启
 
 */



- (void)setZoomEnable:(NSMutableArray *)inArguments{
    
    if([inArguments count]<1) return;
    ACArgsUnpack(NSDictionary *info) = inArguments;
    
    NSString *type=nil;
    if([info getStringForKey:@"type"]){
        type=[info getStringForKey:@"type"];
    }else return;
    
    if([type isEqual:@"1"]) self.mapView.zoomEnabled = YES;
    if([type isEqual:@"0"]) self.mapView.zoomEnabled = NO;
    
}



/*
 ###setRotateEnable
 params:
 type
 
 */



- (void)setRotateEnable:(NSMutableArray *)inArguments{
    
    if([inArguments count]<1) return;
    
    ACArgsUnpack(NSDictionary *info) = inArguments;
    NSString *type=nil;
    if([info getStringForKey:@"type"]){
        type=[info getStringForKey:@"type"];
    }else return;
    if([type isEqual:@"1"]) self.mapView.rotateEnabled = YES;
    if([type isEqual:@"0"]) self.mapView.rotateEnabled = NO;
    
    
    
}



/*
 ###setCompassEnable
 params:
 type
 
 */



- (void)setCompassEnable:(NSMutableArray *)inArguments{
    
    if([inArguments count]<1) return;
    
    ACArgsUnpack(NSDictionary *info) = inArguments;
    NSString *type=nil;
    if([info getStringForKey:@"type"]){
        type=[info getStringForKey:@"type"];
    }else return;
    if([type isEqual:@"1"]) self.mapView.showsCompass= YES;
    if([type isEqual:@"0"]) self.mapView.showsCompass= NO;
    
    
}



/*
 ###setScrollEnable
 params:
 type
 
 */



- (void)setScrollEnable:(NSMutableArray *)inArguments{
    
    if([inArguments count]<1) return;
    
    ACArgsUnpack(NSDictionary *info) = inArguments;
    NSString *type=nil;
    if([info getStringForKey:@"type"]){
        type=[info getStringForKey:@"type"];
    }else return;
    
    if([type isEqual:@"1"])self.mapView.scrollEnabled = YES;
    if([type isEqual:@"0"])self.mapView.scrollEnabled = NO;
    
}


#pragma mark AnnotationDelegate

/*!
 @brief 地图区域即将改变时会调用此接口
 @param mapview 地图View
 @param animated 是否动画
 */
//- (void)mapView:(MAMapView *)mapView regionWillChangeAnimated:(BOOL)animated
//{
//
//}

/*!
 @brief 地图区域改变完成后会调用此接口
 @param mapview 地图View
 @param animated 是否动画
 */
- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    
    //NSLog(@"AppCan --> uexGaodeMap --> regionDidChangeAnimated --> mapView.zoomLevel = %f",mapView.zoomLevel);
    if (self.lastZoomLevel != mapView.zoomLevel) {
        
        NSDictionary *resultDic = [NSDictionary dictionaryWithObjectsAndKeys:@(mapView.zoomLevel),@"zoom",@(mapView.centerCoordinate.longitude),@"longitude",@(mapView.centerCoordinate.longitude),@"latitude", nil];
        
        NSString *dataStr = [resultDic ac_JSONFragment];
        
        [self callbackJsonWithName:@"onCameraChangeFinish" Object:dataStr];
        
        self.lastZoomLevel = mapView.zoomLevel;
    }
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation{
    
    //带箭头的原点图片
    NSBundle *pluginBundle = [EUtility bundleForPlugin:@"uexGaodeMap"];
    NSString *pathImage = [[pluginBundle resourcePath] stringByAppendingPathComponent:@"userPosition.png"];
    UIImage *imageHeader = [UIImage imageWithContentsOfFile:pathImage];
    
    //大头针标注
    if ([annotation isKindOfClass:[GaodePointAnnotation class]]) {
        GaodePointAnnotation *pointAnnotation=annotation;
        if(pointAnnotation.isCustomCallout){
            GaodeCustomAnnotationView *annotationView;
            if([self.mapView dequeueReusableAnnotationViewWithIdentifier:pointAnnotation.identifier]&&[[self.mapView dequeueReusableAnnotationViewWithIdentifier:pointAnnotation.identifier] isKindOfClass:[GaodeCustomAnnotationView class]]){
                annotationView=(GaodeCustomAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:pointAnnotation.identifier];
            }else{
                annotationView=[[GaodeCustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointAnnotation.identifier];
                [annotationView setupWithCalloutDict:pointAnnotation.customCalloutData];
            }
        
           
            annotationView.canShowCallout=NO;
            annotationView.animatesDrop = pointAnnotation.animatesDrop  ; //设置标注动画显示
            annotationView.draggable = pointAnnotation.draggable; //设置标注可以拖动
            annotationView.pinColor = MAPinAnnotationColorPurple;
            if(pointAnnotation.iconImage){
  
                annotationView.image = pointAnnotation.iconImage;
                //设置中心心点偏移,使得标注底部中间点成为经纬度对应点
                CGFloat offsetY=annotationView.image.size.height/-2;
                annotationView.centerOffset = CGPointMake(0, offsetY);
            }
            return annotationView;

            
            
            
            
        }else{
            MAPinAnnotationView *annotationView = (MAPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:pointAnnotation.identifier];
            

            if (annotationView == nil) {
                annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointAnnotation.identifier];
            }
            annotationView.canShowCallout= pointAnnotation.canShowCallout; //设置气泡可以弹出
            annotationView.animatesDrop = pointAnnotation.animatesDrop  ; //设置标注动画显示
            annotationView.draggable = pointAnnotation.draggable; //设置标注可以拖动
            annotationView.pinColor = MAPinAnnotationColorPurple;
            if(pointAnnotation.iconImage){
                annotationView.image = pointAnnotation.iconImage;
                //设置中心心点偏移,使得标注底部中间点成为经纬度对应点
                CGFloat offsetY=annotationView.image.size.height/-2;
                annotationView.centerOffset = CGPointMake(0, offsetY);
            }
            
            return annotationView;
        }
        
        
    }
    
    //自定义标注
    
        
        
    
    //自定义定位标注
    
    if ([annotation isKindOfClass:[MAUserLocation class]]) {
        //        if(self.locationStatus == ContinuousLocationEnabledWithMarker){
        //            return nil;
        //        }
        MAAnnotationView *annotationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:self.locationStyleOptions.identifier];
        if (annotationView == nil) {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation
                                                          reuseIdentifier:self.locationStyleOptions.identifier];
            
        }
        
        //使用箭头
        annotationView.image = imageHeader;
        
        self.userLocationAnnotationView = annotationView;
        return annotationView;
    }
    
    return nil;
}
#pragma mark OverlayDelegate
//- (MAOverlayView *)mapView:(MAMapView *)mapView viewForOverlay:(id<MAOverlay>)overlay{
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay{
    //tileOverlay
    if ([overlay isKindOfClass:[MATileOverlay class]]) {
             }
    
    //大地曲线
    if ([overlay isKindOfClass:[MAGeodesicPolyline class]])
    {
        
    }
    //折线
    if ([overlay isKindOfClass:[GaodePolyline class]]) {
        GaodePolyline *polyline=(GaodePolyline*)overlay;
        MAPolylineRenderer *polylineView = [[MAPolylineRenderer alloc] initWithPolyline:polyline];
        polylineView.lineWidth = polyline.lineWidth;
        polylineView.strokeColor = polyline.color;
        polylineView.lineJoinType = polyline.lineJoinType;//连接类型
        polylineView.lineCapType = polyline.lineCapType;//端点类型
        
        if (self.isShowLineImage == YES && self.lineImage) {
            [polylineView loadStrokeTextureImage:self.lineImage];
        }
        
        return polylineView;
    }
    
    //多边形
    if ([overlay isKindOfClass:[GaodePolygon class]]) {
        GaodePolygon *polygon =(GaodePolygon *)overlay;
        MAPolygonRenderer *polygonView = [[MAPolygonRenderer alloc] initWithPolygon:polygon];
        polygonView.lineWidth = polygon.lineWidth;
        polygonView.strokeColor = polygon.strokeColor;
        polygonView.fillColor = polygon.fillColor;
        polygonView.lineJoinType = polygon.lineJoinType;//连接类型
        return polygonView;
    }
    //圆
    if ([overlay isKindOfClass:[GaodeCircle class]]) {
        GaodeCircle *circle =(GaodeCircle *)overlay;
        MACircleRenderer *circleView = [[MACircleRenderer alloc] initWithCircle:overlay];
        circleView.lineWidth = circle.lineWidth;
        circleView.strokeColor = circle.strokeColor;
        circleView.fillColor = circle.fillColor;
        circleView.lineDash = circle.lineDash;
        return circleView;
    }
    
    //自定义图片
    if ([overlay isKindOfClass:[GaodeGroundOverlay class]])
    {
        MAGroundOverlayRenderer *groundOverlayView = [[MAGroundOverlayRenderer alloc]
                                                  initWithGroundOverlay:overlay];
        
        return groundOverlayView;
    }
    /* 自定义定位精度对应的 MACircleView. */
    
    if (overlay == mapView.userLocationAccuracyCircle) {
        if(self.locationStatus == ContinuousLocationEnabled){
            return nil;
        }

        MACircleRenderer  *accuracyCircleView = [[MACircleRenderer alloc] initWithCircle:overlay];
        accuracyCircleView.lineWidth=self.locationStyleOptions.lineWidth;
        accuracyCircleView.strokeColor=self.locationStyleOptions.strokeColor;
        accuracyCircleView.fillColor=self.locationStyleOptions.fillColor;
        
        return accuracyCircleView;

        
  
        
    }

    
    return nil;
}
/*
 ###addMarkersOverlay
 params:[ //标注数组
 {
 id:,//(必选) 唯一标识符
 longitude:,//(必选) 标注经度
 latitude:,//(必选) 标注纬度
 icon:,//(可选) 标注图标
 bubble:{//(可选) 标注气泡
    title:,//(必选) 气泡标题
    subTitle://(可选) 气泡子标题
 }
 】
 */



-(NSArray*)addMarkersOverlay:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSArray *markerArray) = inArguments;
    if (!markerArray) {
        return nil;
    }
    NSMutableArray *ids = [NSMutableArray arrayWithCapacity:markerArray.count];
    for(NSDictionary *info in markerArray)    {
        NSString *identifier = stringArg(info[@"id"]) ?: newUUID();
        NSNumber *longitude = numberArg(info[@"longitude"]);
        NSNumber *latitude = numberArg(info[@"latitude"]);
        if (!longitude || !latitude || [self searchAnnotationById:identifier]) {
            continue;
        }
        [ids addObject:identifier];

        NSString *icon = [self absPath:stringArg(info[@"icon"])];
        

        NSDictionary *bubble = dictionaryArg(info[@"bubble"]);
        NSDictionary *customBubble = dictionaryArg(info[@"customBubble"]);




        GaodePointAnnotation *pointAnnotation = [[GaodePointAnnotation alloc] init];
        pointAnnotation.identifier =identifier;
        pointAnnotation.coordinate = CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]);
        if(icon){
            [pointAnnotation createIconImage:icon];
        }
        if(customBubble){
            pointAnnotation.isCustomCallout = YES;
            pointAnnotation.customCalloutData = customBubble;
        }else{
            pointAnnotation.title = stringArg(bubble[@"title"]);
            pointAnnotation.subtitle = stringArg(bubble[@"subTitle"]);
            pointAnnotation.canShowCallout = pointAnnotation.title || pointAnnotation.subtitle;
        }

        [self.mapView addAnnotation:pointAnnotation];
        [self.annotations addObject:pointAnnotation];

    }
    return [ids copy];
}
- (UIImage*) convertViewToImage:(UIView*)v{
    CGSize s = v.bounds.size;
    UIGraphicsBeginImageContextWithOptions(s, NO, [UIScreen mainScreen].scale);
    [v.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
- (NSArray*) addMultiInfoWindow:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSArray *markerArray) = inArguments;
    NSMutableArray *returnArr = [NSMutableArray arrayWithCapacity:markerArray.count];
    if([inArguments count]<1) return nil;
    for(NSDictionary *info in markerArray){
        NSString *identifier=nil;
        if([info getStringForKey:@"id"]){
            identifier=[info getStringForKey:@"id"];
        }else{
            identifier = newUUID();
        };
        [returnArr addObject:identifier];
        NSString *longitude=nil;
        if([info getStringForKey:@"longitude"]){
            longitude=[info getStringForKey:@"longitude"];
        }else return nil;
        NSString *latitude=nil;
        if([info getStringForKey:@"latitude"]){
            latitude=[info getStringForKey:@"latitude"];
        }else return nil;
        
        NSString *title= info[@"title"]?:@"";
        NSNumber *titleSize = info[@"titleSize"]?:@18;
        NSString *titleColor = info[@"titleColor"]?:@"#000000";
        
        NSString *subTitle= info[@"subTitle"]?:@"";
        NSNumber *subTitleSize = info[@"subTitleSize"]?:@12;
        NSString *subTitleColor = info[@"subTitleColor"]?:@"#000000";
        NSDictionary *dic =@{@"titleContent":title,@"titleFontSize":titleSize,@"titleColor":titleColor,@"textContent":subTitle,@"textFontSize":subTitleSize, @"textColor":subTitleColor,@"bgColor":@"#FFFFFF"};
        CustomView *view = [[CustomView alloc]init];
        view.dataDict = dic;
        BOOL isLoad = [view loadData];
        UIImage *image = nil;
        
        if (isLoad) {
            image =  [self convertViewToImage:view];
        }
        
        if([self searchAnnotationById:identifier])return nil;
        GaodePointAnnotation *pointAnnotation =[[GaodePointAnnotation alloc] init];
        pointAnnotation.isCustomCallout=NO;
        pointAnnotation.identifier =identifier;
        pointAnnotation.coordinate=CLLocationCoordinate2DMake([latitude floatValue], [longitude floatValue]);
        pointAnnotation.iconImage = image;
        
        [self.mapView addAnnotation:pointAnnotation];
        [self.annotations addObject:pointAnnotation];
        
    }
    return [returnArr copy];
}


/*
 ###setMarkerOverlay
 params:
 id
 longitude
 latitude
 icon
 bubble
 
 */

-(GaodePointAnnotation*)searchAnnotationById:(NSString *)identifier{
    for(GaodePointAnnotation *annotation in self.annotations){
        if ([annotation.identifier isEqual:identifier]){
            return annotation;
        }
    }
    return  nil;
}


- (void)setMarkerOverlay:(NSMutableArray *)inArguments{
    
    if([inArguments count]<1) return;
    
    ACArgsUnpack(NSDictionary *info) = inArguments;
    NSString *identifier=nil;
    if([info getStringForKey:@"id"]){
        identifier=[info getStringForKey:@"id"];
    }else return;
    NSString *longitude=nil;
    if([info getStringForKey:@"longitude"]){
        longitude=[info getStringForKey:@"longitude"];
    }
    NSString *latitude=nil;
    if([info getStringForKey:@"latitude"]){
        latitude=[info getStringForKey:@"latitude"];
    }
    NSString *icon=nil;
    if([info getStringForKey:@"icon"]){
        icon=[info getStringForKey:@"icon"];
        icon=[self absPath:icon];
    }
    NSDictionary *bubble=nil;
    if([info objectForKey:@"bubble"]){
        bubble=[info objectForKey:@"bubble"];
    }
    
    GaodePointAnnotation *pointAnnotation =[self searchAnnotationById:identifier];
    if(!pointAnnotation) return;

    [self.mapView removeAnnotation:pointAnnotation];


    if(latitude && longitude){
        pointAnnotation.coordinate=CLLocationCoordinate2DMake([latitude floatValue], [longitude floatValue]);
    }
    
    if(icon){
        [pointAnnotation createIconImage:icon];
    }
    
    if(bubble){
        BOOL isEmpty=YES;
        if([bubble getStringForKey:@"title"]){
            pointAnnotation.title=[bubble getStringForKey:@"title"];
            isEmpty =NO;
        }
        
        if([bubble getStringForKey:@"subTitle"]){
            pointAnnotation.subtitle=[bubble getStringForKey:@"subTitle"];
            isEmpty =NO;
        }
        pointAnnotation.canShowCallout=!isEmpty;
    }
    NSDictionary *customBubble=nil;
    if([info objectForKey:@"customBubble"]&&[[info objectForKey:@"customBubble"] isKindOfClass:[NSDictionary class]]){
        customBubble=[info objectForKey:@"customBubble"];
        
    }
        
    
    if(customBubble){
        pointAnnotation.isCustomCallout=YES;
        pointAnnotation.customCalloutData=customBubble;
    }else{
        pointAnnotation.isCustomCallout=NO;
        pointAnnotation.customCalloutData=nil;
    }
    [self.mapView addAnnotation:pointAnnotation];

}


/*
 ###addPolylineOverlay
 params:
 id:,//(必选) 唯一标识符
 fillColor:,//(可选) 折线颜色
 lineWidth:,//(可选) 折线宽
 property:[//(必选) 数据
 {
 longitude:,//(必选) 连接点经度
 latitude://(必选) 连接点纬度
 }
 ]
 
 */



-(NSString*)addPolylineOverlay:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSDictionary *info) = inArguments;
    if([inArguments count]<1) return nil;
    
    NSString *identifier=nil;
    if([info getStringForKey:@"id"]){
        identifier=[info getStringForKey:@"id"];
    }else{
        identifier = newUUID();
    }
    NSString *fillColor=nil;
    if([info getStringForKey:@"fillColor"]){
        fillColor=[info getStringForKey:@"fillColor"];
    }
    NSString *lineWidth=nil;
    if([info getStringForKey:@"lineWidth"]){
        lineWidth=[info getStringForKey:@"lineWidth"];
    }
    NSArray *property=nil;
    if([info objectForKey:@"property"]){
        property=[info objectForKey:@"property"];
    }else return nil;

    self.isShowLineImage = NO;
    if ([info objectForKey:IsShowLineImage] && [[info objectForKey:IsShowLineImage] boolValue]) {
        
        self.isShowLineImage = YES;
        
        if ([info objectForKey:PathImageString]) {
            NSString *imagePath = [self absPath:[NSString stringWithFormat:@"%@",[info objectForKey:PathImageString]]];
            self.lineImage = [UIImage imageWithContentsOfFile:imagePath];
        } else {
            NSBundle *pluginBundle = [EUtility bundleForPlugin:@"uexGaodeMap"];
            NSString *imagePath = [[pluginBundle resourcePath] stringByAppendingPathComponent:@"arrowTexture.png"];
            self.lineImage = [UIImage imageWithContentsOfFile:imagePath];
        }
    }

    NSInteger count =[property count];
    CLLocationCoordinate2D commonPolylineCoords[count];
    
    for(int i = 0;i<count;i++){
        NSDictionary *location =property[i];
        
        commonPolylineCoords[i].latitude = [[location getStringForKey:@"latitude"] floatValue];
        commonPolylineCoords[i].longitude = [[location getStringForKey:@"longitude"] floatValue];
    }
    //[self clearOverlayById:identifier];
    for (GaodePolyline *polyline in self.overlays) {
        if ([polyline.identifier isEqualToString:identifier]) {
            return nil;
        }
    }
    GaodePolyline *polyline = [GaodePolyline polylineWithCoordinates:commonPolylineCoords count:count];
    polyline.identifier =identifier;
    [polyline dataInit];
    if(fillColor){
        [polyline setFillC:fillColor];
    }
    
    if(lineWidth){
        polyline.lineWidth=[lineWidth floatValue];
    }
    [self.mapView addOverlay: polyline];
    [self.overlays addObject:polyline];
    return identifier;
}



/*
 ###removeOverlay
 params:
 id
 
*/
-(id<MAOverlay>)searchOverlayById:(NSString *)identifier{
    if(!identifier) return nil;
    for(int i=0;i<[self.overlays count];i++){
        id overlay=self.overlays[i];
        
        //GaodePolyline
        if([overlay isKindOfClass:[GaodePolyline class]]){
            GaodePolyline *polyline =(GaodePolyline *)overlay;
            if([polyline.identifier isEqual:identifier]){
                return polyline;
            }
        }
        //GaodeCircle
        if([overlay isKindOfClass:[GaodeCircle class]]){
            GaodeCircle *circle =(GaodeCircle *)overlay;
            if([circle.identifier isEqual:identifier]){
                return circle;
                
            }
        }
        //GaodePolygon
        if([overlay isKindOfClass:[GaodePolygon class]]){
            GaodePolygon *polygon =(GaodePolygon *)overlay;
            if([polygon.identifier isEqual:identifier]){
                return polygon;
                
            }
        }
        
        //GaodeGroundOverlay
        if([overlay isKindOfClass:[GaodeGroundOverlay class]]){
            GaodeGroundOverlay *groundOverlay =(GaodeGroundOverlay *)overlay;
            if([groundOverlay.identifier isEqual:identifier]){
                return groundOverlay;
                
            }
        }
        
        
        
    }
    
    return nil;

}

- (void)clearOverlayById:(NSString *)identifier{
    id<MAOverlay> overlay=[self searchOverlayById:identifier];
    if(overlay){
        [self.mapView removeOverlay:overlay];
        [self.overlays removeObject:overlay];
    }

}
- (void)removeOverlay:(NSMutableArray *)inArguments{
    
    if([inArguments count]<1) return;
    ACArgsUnpack(NSDictionary *info) = inArguments;
    NSString *identifier=nil;
    if([info getStringForKey:@"id"]){
        identifier=[info getStringForKey:@"id"];
    }
    if(!identifier) return;
    [self clearOverlayById:identifier];
}






/*
 ###addCircleOverlay
 params:
 id:,//(必选) 唯一标识符
 longitude:,//(必选) 圆心经度
 latitude:,//(必选) 圆心纬度
 radius:,//(必选) 半径
 fillColor:,//(可选) 填充颜色
 strokeColor:,//(可选) 边框颜色
 lineWidth://(可选) 边框线宽
 
 */



-(NSString*)addCircleOverlay:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSDictionary *info) = inArguments;
    if([inArguments count]<1) return nil;
    
    NSString *identifier=nil;
    if([info getStringForKey:@"id"]){
        identifier=[info getStringForKey:@"id"];
    }else{
        identifier = newUUID();
    }
    NSString *longitude=nil;
    if([info getStringForKey:@"longitude"]){
        longitude=[info getStringForKey:@"longitude"];
    }else return nil;
    NSString *latitude=nil;
    if([info getStringForKey:@"latitude"]){
        latitude=[info getStringForKey:@"latitude"];
    }else return nil;
    NSString *radius=nil;
    if([info getStringForKey:@"radius"]){
        radius=[info getStringForKey:@"radius"];
    }else return nil;
    NSString *fillColor=nil;
    if([info getStringForKey:@"fillColor"]){
        fillColor=[info getStringForKey:@"fillColor"];
    }
    NSString *strokeColor=nil;
    if([info getStringForKey:@"strokeColor"]){
        strokeColor=[info getStringForKey:@"strokeColor"];
    }
    NSString *lineWidth=nil;
    if([info getStringForKey:@"lineWidth"]){
        lineWidth=[info getStringForKey:@"lineWidth"];
    }
    
    //[self clearOverlayById:identifier];
    for (GaodeCircle *circle in self.overlays) {
        if ([circle.identifier isEqualToString:identifier]) {
            return nil;
        }
    }
    GaodeCircle *circle = [GaodeCircle circleWithCenterCoordinate:CLLocationCoordinate2DMake([latitude floatValue], [longitude floatValue])
                                                           radius:[radius doubleValue]];
    circle.identifier =identifier;
    [circle dataInit];
    
    
    if(fillColor) {
       [circle setFillC:fillColor];
    }
    if(strokeColor){
        [circle setStrokeC:strokeColor];
    }
    if(lineWidth){
        circle.lineWidth=[lineWidth floatValue];
    }
    
    if([info objectForKey:@"lineDash"]&&[[info objectForKey:@"lineDash"] boolValue]==YES){
        circle.lineDash=YES;
    }
    //在地图上添加圆
    [self.mapView addOverlay: circle];

    [self.overlays addObject:circle];
    return identifier;
}



/*
 ###addPolygonOverlay
 params:
 id:,//(必选) 唯一标识符
 fillColor:,//(可选) 填充颜色
 strokeColor:,//(可选) 边框颜色
 lineWidth:,//(可选) 边框线宽
 property:[//(必选) 数据
    {
    longitude:,//(必选) 顶点经度
    latitude://(必选) 顶点纬度
    }
 ]
 
 */



-(NSString*)addPolygonOverlay:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSDictionary *info) = inArguments;
    if([inArguments count]<1) return nil;
    
    NSString *identifier=nil;
    if([info getStringForKey:@"id"]){
        identifier=[info getStringForKey:@"id"];
    }else{
        identifier = newUUID();
    }
    NSString *fillColor=nil;
    if([info getStringForKey:@"fillColor"]){
        fillColor=[info getStringForKey:@"fillColor"];
    }
    NSString *strokeColor=nil;
    if([info getStringForKey:@"strokeColor"]){
        strokeColor=[info getStringForKey:@"strokeColor"];
    }
    NSString *lineWidth=nil;
    if([info getStringForKey:@"lineWidth"]){
        lineWidth=[info getStringForKey:@"lineWidth"];
    }
    NSArray *property=nil;
    if([info objectForKey:@"property"]){
        property=[info objectForKey:@"property"];
    }else return nil;
    
    NSInteger count =[property count];
    CLLocationCoordinate2D coordinates[count];
    
    for(int i = 0;i<count;i++){
        NSDictionary *location =property[i];
        
        coordinates[i].latitude = [[location getStringForKey:@"latitude"] floatValue];
        coordinates[i].longitude = [[location getStringForKey:@"longitude"] floatValue];
    }
    //[self clearOverlayById:identifier];
    for (GaodePolygon *polygon in self.overlays) {
        if ([polygon.identifier isEqualToString:identifier]) {
            return nil;
        }
    }
    GaodePolygon *polygon = [GaodePolygon polygonWithCoordinates:coordinates count:count];
    polygon.identifier =identifier;
    [polygon dataInit];
    
    
    if(fillColor) {
        [polygon setFillC:fillColor];
    }
    if(strokeColor){
        [polygon setStrokeC:strokeColor];
    }
    if(lineWidth){
        polygon.lineWidth=[lineWidth floatValue];
    }

    [self.mapView addOverlay:polygon];
    [self.overlays addObject:polygon];
    return identifier;
}



/*
 ###addGroundOverlay
 params:
 id:,//(必选) 唯一标识符
 imageUrl:,//(必选) 图片地址
 transparency:,//(可选) 图片透明度（仅Android支持该参数）
 property:[//(必选) 数据，数组长度为2，第一个元素表示西南角的经纬度，第二个表示东北角的经纬度；
 {
 longitude:,//(必选) 顶点经度
 latitude://(必选) 顶点纬度
 }
 ]
 
 */


-(NSString*)addGroundOverlay:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSDictionary *info) = inArguments;
    if([inArguments count]<1) return nil;
    
    NSString *identifier=nil;
    if([info getStringForKey:@"id"]){
        identifier=[info getStringForKey:@"id"];
    }else{
        identifier = newUUID();
    }
    NSString *imageUrl=nil;
    if([info getStringForKey:@"imageUrl"]){
        imageUrl=[info objectForKey:@"imageUrl"];
    }else return nil;

    NSArray *property=nil;
    if([info objectForKey:@"property"]){
        property=[info objectForKey:@"property"];
    }else return nil;
    
    if([property count] < 2) return nil;
    NSDictionary *southWestDict =property[0];
    NSDictionary *northEastDict =property[1];
    
    
    CLLocationCoordinate2D northEastEPoint =CLLocationCoordinate2DMake([[northEastDict getStringForKey:@"latitude"] floatValue],[[northEastDict getStringForKey:@"longitude"] floatValue]);
    CLLocationCoordinate2D southWestPoint =CLLocationCoordinate2DMake([[southWestDict getStringForKey:@"latitude"] floatValue],[[southWestDict getStringForKey:@"longitude"] floatValue]);
    
    MACoordinateBounds coordinateBounds = MACoordinateBoundsMake(northEastEPoint,southWestPoint);
    
    NSData *overlayImageData = [NSData dataWithContentsOfFile:[self absPath:imageUrl]];
    if(!overlayImageData){
        overlayImageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[self absPath:imageUrl]]];
    }
    //[self clearOverlayById:identifier];
    for (GaodeGroundOverlay *groundOverlay in self.overlays) {
        if ([groundOverlay.identifier isEqualToString:identifier]) {
            return nil;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        GaodeGroundOverlay *groundOverlay = [GaodeGroundOverlay groundOverlayWithBounds:coordinateBounds icon:[UIImage imageWithData:overlayImageData]];
        groundOverlay.identifier =identifier;
        [self.mapView addOverlay:groundOverlay];
        self.mapView.visibleMapRect = groundOverlay.boundingMapRect;
         [self.overlays addObject:groundOverlay];
    });
     return identifier;
    
}



/*
 ###removeMarkersOverlay
 params:
id://(必选) 唯一标识符
 
 */

- (void)clearMarkersOverlay:(NSString *)identifier{
    if(!identifier) return;
    if([self searchAnnotationById:identifier]){
        GaodePointAnnotation *annotation=[self searchAnnotationById:identifier];
        [self.mapView removeAnnotation:annotation];
        [self.annotations removeObject:annotation];
    }
    
}

- (void)removeMarkersOverlay:(NSMutableArray *)inArguments{
    
    if([inArguments count]<1) return;
    ACArgsUnpack(NSDictionary *info) = inArguments;
    NSString *identifier=nil;
    if([info getStringForKey:@"id"]){
        identifier=[info getStringForKey:@"id"];
    }
    [self clearMarkersOverlay:identifier];
    
    
}



/*
 ###poiSearch
 params:
 searchKey:,//(可选) 搜索关键字
 poiTypeSet:,//(可选) Poi兴趣点，searchKey和poiTypeSet必须至少包含其中的一个
 city:,//(可选) 城市，不传时表示全国范围内（iOS无效，默认全国范围内搜索）
 pageNum:,//(可选) 搜索结果页索引，默认为0
 searchBound://(可选) 区域搜索，city和searchBound必须至少包含其中的一个。以下的三个类别有且只有一种。
 {
 type:"circle",//(必选) 圆形区域搜索
 dataInfo:{
 center:{//(必选) 圆心
 longitude:,//(必选) 经度
 latitude://(必选) 纬度
 },
 radius:,//(必选) 半径
 isDistanceSort://(可选) 是否按距离由小到大排序，默认true
 }
 }
 {
 type:"rectangle",//(必选) 矩形区域搜索
 dataInfo:{
 lowerLeft:{//(必选) 左下角
 longitude:,//(必选) 经度
 latitude://(必选) 纬度
 },
 upperRight:{//(必选) 右上角
 longitude:,//(必选) 经度
 latitude://(必选) 纬度
 }
 }
	}
 {
 type:"polygon",//(必选) 多边形区域搜索
 dataInfo:[//(必选) 顶点集合
 {
 longitude:,//(必选) 顶点经度
 latitude://(必选) 顶点纬度
 }
 ]
	}
 }
 
 */



- (void)poiErrorCallBack:(NSString*)errorString{
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    [dict setValue:@"1" forKey:@"errorCode"];
    [dict setValue:errorString forKey:@"errorInfo" ];
    [self callbackJsonWithName:@"cbPoiSearch" Object:dict];
    
}


- (void)poiSearch:(NSMutableArray *)inArguments{
    
    if([inArguments count]<1) return;
    ACJSFunctionRef *func = JSFunctionArg(inArguments.lastObject);
    self.func = func;
    
    ACArgsUnpack(NSDictionary *info) = inArguments;
    NSString *searchKey=nil;
    if([info getStringForKey:@"searchKey"]){
        searchKey=[info getStringForKey:@"searchKey"];
    }
    NSString *poiTypeSet=nil;
    if([info getStringForKey:@"poiTypeSet"]){
        poiTypeSet=[info getStringForKey:@"poiTypeSet"];
    }
    NSString *city=nil;
    if([info getStringForKey:@"city"]){
        city=[info getStringForKey:@"city"];
    }
    NSString *pageNum=nil;
    if([info getStringForKey:@"pageNum"]){
        pageNum=[info getStringForKey:@"pageNum"];
    }else{
        pageNum = @"0";
    }
    NSDictionary *searchBound=nil;
    if([info objectForKey:@"searchBound"]){
        searchBound=[info objectForKey:@"searchBound"];
    }
 
    BOOL isKeyEmpty=YES;
    if(searchKey){
        isKeyEmpty=NO;
    }
    if(poiTypeSet){
        isKeyEmpty =NO;
    }
    if(isKeyEmpty){
        [self poiErrorCallBack:@"Missing searchKey or poiTypeSet!"];
        [self.func executeWithArguments:ACArgsPack(@(1),@"Missing searchKey or poiTypeSet!")];
        return;
    }
    
    
    BOOL isPlaceEmpty=YES;
    if(city){
        isPlaceEmpty=NO;
    }
    BOOL searchBoundAvailable = NO;
    if(searchBound){
        NSString *type = nil;
        if([searchBound getStringForKey:@"type"]){
            type=[searchBound getStringForKey:@"type"];
            type=[type lowercaseString];
            if([type isEqual:@"circle"]){
               AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
                if([searchBound objectForKey:@"dataInfo"]){
                    NSDictionary *dataInfo=[searchBound objectForKey:@"dataInfo"];
                    NSDictionary *center=[dataInfo objectForKey:@"center"];
                    request.location = [AMapGeoPoint locationWithLatitude:[[center getStringForKey:@"latitude"] floatValue] longitude:[[center getStringForKey:@"longitude"] floatValue]];
                    request.radius =[[dataInfo getStringForKey:@"radius"] integerValue]?:1000;
                    request.sortrule =[[dataInfo objectForKey:@"isDistanceSort"] boolValue]?0:1;
                    request.requireExtension=YES;
                    request.offset=30;
                    request.page=([pageNum integerValue]+1);
                    if(searchKey){
                        request.keywords =searchKey;
                        poiTypeSet = nil;
                    }
                    if(poiTypeSet){
                        request.types = poiTypeSet;
                    }
                    searchBoundAvailable =YES;
                    isPlaceEmpty=NO;
                    [self.search AMapPOIAroundSearch:request];
                }else{
                    [self poiErrorCallBack:@"Missing dataInfo!"];
                    [self.func executeWithArguments:ACArgsPack(@(1),@"Missing dataInfo!")];
                   return;
                }
            }else if([type isEqual:@"rectangle"]){
                
                if([searchBound objectForKey:@"dataInfo"]){
                    NSDictionary *dataInfo=[searchBound objectForKey:@"dataInfo"];
                    NSDictionary *lowerLeft=[dataInfo objectForKey:@"lowerLeft"];
                    NSDictionary *upperRight=[dataInfo objectForKey:@"upperRigh"];
                    
                    AMapGeoPoint *leftTopPoint =[AMapGeoPoint locationWithLatitude:[[upperRight getStringForKey:@"latitude"] floatValue]
                                                                        longitude:[[lowerLeft getStringForKey:@"longitude"] floatValue]];
                    
                     AMapGeoPoint *rightButtomPoint =[AMapGeoPoint locationWithLatitude:[[lowerLeft getStringForKey:@"latitude"] floatValue]
                                                                             longitude:[[upperRight getStringForKey:@"longitude"] floatValue]
                                                      ];
                    
                    
                    AMapGeoPolygon *polygon = [AMapGeoPolygon polygonWithPoints:@[leftTopPoint,rightButtomPoint]];
                    AMapPOIPolygonSearchRequest *request = [[AMapPOIPolygonSearchRequest alloc] init];
                    request.polygon = polygon;
                    request.requireExtension=YES;
                    request.offset=30;
                    request.page=([pageNum integerValue]+1);
                    if(searchKey){
                        request.keywords =searchKey;
                        poiTypeSet = nil;
                    }
                    if(poiTypeSet){
                        request.types = poiTypeSet;
                    }
                    searchBoundAvailable =YES;
                    isPlaceEmpty=NO;
                     [self.search AMapPOIPolygonSearch:request];
                }else{
                    [self poiErrorCallBack:@"Missing dataInfo!"];
                    [self.func executeWithArguments:ACArgsPack(@(1),@"Missing dataInfo!")];
                    return;
                }
          
            }else if([type isEqual:@"polygon"]){
                if([searchBound objectForKey:@"dataInfo"]){
                    NSArray *dataInfo=[searchBound objectForKey:@"dataInfo"];
                    NSMutableArray *polygonPoints=[NSMutableArray array];
                    for(int i=0;i<[dataInfo count];i++){
                        NSDictionary *pointDict=dataInfo[i];
                        AMapGeoPoint *point =[AMapGeoPoint locationWithLatitude:[[pointDict getStringForKey:@"latitude"] floatValue]
                                                                             longitude:[[pointDict getStringForKey:@"longitude"] floatValue]];
                        
                        [polygonPoints addObject:point];
                    }
                    AMapPOIPolygonSearchRequest *request = [[AMapPOIPolygonSearchRequest alloc] init];
                    request.polygon = [AMapGeoPolygon polygonWithPoints:polygonPoints];
                    request.requireExtension=YES;
                    request.offset=30;
                    request.page=([pageNum integerValue]+1);
                    if(searchKey){
                        request.keywords =searchKey;
                        poiTypeSet = nil;
                    }
                    if(poiTypeSet){
                        request.types = poiTypeSet;
                    }
                    searchBoundAvailable =YES;
                    isPlaceEmpty=NO;
                    [self.search AMapPOIPolygonSearch:request];
                }else{
                    [self poiErrorCallBack:@"Missing dataInfo!"];
                    [self.func executeWithArguments:ACArgsPack(@(1),@"Missing dataInfo!")];
                    return;
                }
            }

        }
        
    }
    if(!searchBoundAvailable){
        AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
        if(searchKey){
            request.keywords =searchKey;
            poiTypeSet = nil;
        }
        if(poiTypeSet){
            request.types = poiTypeSet;
        }
        if(city){
            request.city = city;
            
        }
        request.requireExtension    = YES;
        
        /*  搜索SDK 3.2.0 中新增加的功能，只搜索本城市的POI。*/
        request.cityLimit           = YES;
        request.requireSubPOIs      = YES;
        isPlaceEmpty=NO;
        [self.search AMapPOIKeywordsSearch:request];
        
    }
    if(isPlaceEmpty){
        [self poiErrorCallBack:@"Missing city or searchBound!"];
        [self.func executeWithArguments:ACArgsPack(@(1),@"Missing city or searchBound!")];
        return;
    }
    
    
}



/*
 ###geocode
 params:
 city
 address
 
 */



- (void)geocode:(NSMutableArray *)inArguments{
    
    if([inArguments count]<1) return;
    
    ACArgsUnpack(NSDictionary *info) = inArguments;
    NSString *city=nil;
    ACJSFunctionRef *func = JSFunctionArg(inArguments.lastObject);
    self.func = func;
    if([info getStringForKey:@"city"]){
        city=[info getStringForKey:@"city"];
    }
    NSString *address=nil;
    if([info getStringForKey:@"address"]){
        address=[info getStringForKey:@"address"];
    }else return;
    
    AMapGeocodeSearchRequest *geoRequest = [[AMapGeocodeSearchRequest alloc] init];
    //geoRequest.searchType =AMapSearchType_Geocode;
    geoRequest.address = address;
    if(city){
        geoRequest.city = city;
    }
    
    [self.search AMapGeocodeSearch: geoRequest];
}



/*
 ###reverseGeocode
 params:
 longitude
 latitude
 
 */



- (void)reverseGeocode:(NSMutableArray *)inArguments{
    
    if([inArguments count]<1) return;
    
    ACArgsUnpack(NSDictionary *info) = inArguments;
    NSString *longitude=nil;
    ACJSFunctionRef *func = JSFunctionArg(inArguments.lastObject);
    self.func = func;
    if([info getStringForKey:@"longitude"]){
        longitude=[info getStringForKey:@"longitude"];
    }else return;
    NSString *latitude=nil;
    if([info getStringForKey:@"latitude"]){
        latitude=[info getStringForKey:@"latitude"];
    }else return;
    AMapReGeocodeSearchRequest *regeoRequest = [[AMapReGeocodeSearchRequest alloc] init];
    regeoRequest.location = [AMapGeoPoint locationWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
    regeoRequest.radius = 10000;
    regeoRequest.requireExtension = YES;
    
    [self.search AMapReGoecodeSearch: regeoRequest];

}


/*
 ###getCurrentLocation
 
 */



- (void)getCurrentLocation:(NSMutableArray *)inArguments{
    switch (self.locationStatus) {
        case ContinuousLocationDisabled:
            self.locationStatus=GettingCurrentPosition;
            break;
        case ContinuousLocationEnabled:
            self.locationStatus=GettingCurrentPositionWhileLocating;
            break;
        case ContinuousLocationEnabledWithMarker:
            self.locationStatus=GettingCurrentPositionWhileMarking;
            break;
            
        default:
            return;
            break;
    
    }
    if (inArguments.count > 0) {
        ACJSFunctionRef *func = JSFunctionArg(inArguments.lastObject);
        self.func = func;
    }

    self.mapView.showsUserLocation = YES;


    
    
    
    
}


/*
 ###startLocation
 
 */



- (void)startLocation:(NSMutableArray *)inArguments{
    self.locationStatus =ContinuousLocationEnabled;
    self.mapView.showsUserLocation = YES;

    
}



/*
 ###stopLocation
 
 */



- (void)stopLocation:(NSMutableArray *)inArguments{
    self.locationStatus=ContinuousLocationDisabled;
    self.mapView.showsUserLocation = NO;

}



/*
 ###setMyLocationEnable
   显示或隐藏我的位置
 params:
 type
 
 */



- (void)setMyLocationEnable:(NSMutableArray *)inArguments{
    
    if([inArguments count]<1) return;
    if(self.locationStatus == ContinuousLocationDisabled) return;
    
    ACArgsUnpack(NSDictionary *info) = inArguments;
    NSString *type=nil;
    if([info getStringForKey:@"type"]){
        type=[info getStringForKey:@"type"];
    }else return;
    
    if([type isEqual:@"0"]){
        self.locationStatus= ContinuousLocationEnabled;
        self.mapView.showsUserLocation = NO;
        //        _mapView.showsUserLocation = YES;
        
        
    }
    if([type isEqual:@"1"]){
        self.locationStatus=ContinuousLocationEnabledWithMarker;
        //        _mapView.showsUserLocation = NO;
        self.mapView.showsUserLocation = YES;
        
    }

    
    
    
}



/*
 ###setUserTrackingMode
 params:
 type://(必选) 模式，1-只在第一次定位移动到地图中心点；
 2-定位、移动到地图中心点并跟随；
 3-定位、移动到地图中心点，跟踪并根据方向
 
*/


- (void)setUserTrackingMode:(NSMutableArray *)inArguments{
    
    if([inArguments count]<1) return;
    
    ACArgsUnpack(NSDictionary *info) = inArguments;
    NSString *type=nil;
    if([info getStringForKey:@"type"]){
        type=[info getStringForKey:@"type"];
    }else return;
    if ([type  isEqual:@"1"]){
        [self.mapView setUserTrackingMode:MAUserTrackingModeNone  animated:YES];
        self.isStopRotateHeader = YES;
    }
    if ([type  isEqual:@"2"]){
        [self.mapView setUserTrackingMode:MAUserTrackingModeFollow  animated:YES];
        self.isStopRotateHeader = YES;
    }
    if ([type  isEqual:@"3"]){
        [self.mapView setUserTrackingMode:MAUserTrackingModeFollowWithHeading  animated:YES];
        self.isStopRotateHeader = NO;
    }
    if ([type  isEqual:@"4"]){
        [self.mapView setUserTrackingMode:MAUserTrackingModeFollow  animated:YES];
        self.isStopRotateHeader = NO;
    }
}




/*
 ###cbGetCurrentLocation
 
 uexGaodeMap.cbGetCurrentLocation(json);
 var json = {
 longitude:,//当前位置经度
 latitude:,//当前位置纬度
 timestamp://时间戳
 }
 */

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation
updatingLocation:(BOOL)updatingLocation
{
    //让定位箭头随着方向旋转
    if (!updatingLocation && self.userLocationAnnotationView != nil && self.isStopRotateHeader==NO)
    {
        [UIView animateWithDuration:0.1 animations:^{
            
            double degree = userLocation.heading.trueHeading - self.mapView.rotationDegree;
            self.userLocationAnnotationView.transform = CGAffineTransformMakeRotation(degree * M_PI / 180.f );
            
        }];
    }
    
    NSDate *datenow = [NSDate date];
    NSString *timestamp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    NSNumber *error = @1;
    if (userLocation.coordinate.latitude && userLocation.coordinate.longitude) {
        error = @(0);
    }
    //取出当前位置的坐标
    NSMutableDictionary *dict =[NSMutableDictionary dictionaryWithCapacity:2];
    [dict setValue:[NSString stringWithFormat:@"%f",userLocation.coordinate.latitude] forKey:@"latitude"];
    [dict setValue:[NSString stringWithFormat:@"%f",userLocation.coordinate.longitude] forKey:@"longitude"];
    [dict setValue:timestamp forKey:@"timestamp"];
    
    switch (self.locationStatus) {
        case GettingCurrentPosition:
            self.locationStatus=ContinuousLocationDisabled;
            self.mapView.showsUserLocation=NO;
            [self callbackJsonWithName:@"cbGetCurrentLocation" Object:dict];
            [self.func executeWithArguments:ACArgsPack(error,[dict copy])];
            self.func = nil;
            break;
        case GettingCurrentPositionWhileLocating:
            self.locationStatus=ContinuousLocationEnabled;
            [self callbackJsonWithName:@"cbGetCurrentLocation" Object:dict];
            [self.func executeWithArguments:ACArgsPack(error,[dict copy])];
            self.func = nil;
            break;
        case GettingCurrentPositionWhileMarking:
            self.locationStatus=ContinuousLocationEnabledWithMarker;
            [self callbackJsonWithName:@"cbGetCurrentLocation" Object:dict];
            [self.func executeWithArguments:ACArgsPack(error,[dict copy])];
            self.func = nil;
            break;
                
        default:
            if(updatingLocation){
            [self callbackJsonWithName:@"onReceiveLocation" Object:dict];
            }
            break;
        
    }
}

/*
 ###cbGeocode
 uexGaodeMap.cbGeocode(json);
 var json = {
 longitude:,//当前位置经度
 latitude://当前位置纬度
 }
 */

- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest*)request response:(AMapGeocodeSearchResponse *)response
{
    NSMutableDictionary *dict =[NSMutableDictionary dictionary];
    [dict setValue:request.address forKey:@"address"];
    NSNumber *error = @(1);
    if (response.geocodes && [response.geocodes count] > 0) {
        error = @(0);
    }
    if(request.city){
        [dict setValue:request.city forKey:@"city"];
    }
    if([response.geocodes count] > 0) {
        AMapGeocode  *geocode =response.geocodes[0];
        NSString *longitude =[NSString stringWithFormat:@"%f",geocode.location.longitude];
        NSString *latitude =[NSString stringWithFormat:@"%f",geocode.location.latitude];
        
        [dict setValue:longitude forKey:@"longitude"];
        [dict setValue:latitude  forKey:@"latitude"];
    }

    [self callbackJsonWithName:@"cbGeocode" Object:dict];
    [self.func executeWithArguments:ACArgsPack(error,[dict copy])];
    self.func = nil;
}


/*
 ###cbReverseGeocode
 uexGaodeMap.cbReverseGeocode(json);

 var json = {
 address://具体地址
 }
 */

- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    NSMutableDictionary *dict =[NSMutableDictionary dictionary];
    NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
    NSNumber *error = @(1);
    if(response.regeocode != nil) {
        [dict setValue:@0 forKey:@"errorCode"];
        [dict setValue:response.regeocode.formattedAddress forKey:@"address"];
        
        [resultDic setValue:response.regeocode.formattedAddress forKey:@"address"];
        [resultDic setValue:@(request.location.latitude) forKey:@"latitude"];
        [resultDic setValue:@(request.location.longitude) forKey:@"longitude"];
         error = @(0);
        
    }else{
        [dict setValue:@-1 forKey:@"errorCode"];
         error = @(1);
    }
    [dict setValue:@(request.location.latitude) forKey:@"latitude"];
    [dict setValue:@(request.location.longitude) forKey:@"longitude"];
    
    
    [self callbackJsonWithName:@"cbReverseGeocode" Object:dict];
    [self.func executeWithArguments:ACArgsPack(error,resultDic)];
    self.func = nil;
}


/*
 ###cbPoiSearch
 uexGaodeMap.cbPoiSearch(json);
 var json = {
 errorCode: 0， //错误码，0-成功，非0-失败
 data: [//搜索结果集合
 {
 address:,//地址详情
 cityCode:,//城市编码
 cityName:,//城市名称
 website:,//网址
 email:,//邮箱
 id:,//poiId
 point: {//位置坐标
 latitude:,//经度
 longitude://纬度
 },
 postcode:,//邮编
 provinceCode:,//省/自治区/直辖市/特别行政区编码
 provinceName:,//省/自治区/直辖市/特别行政区名称
 tel:,//电话号码
 title:,//名称
 typeDes:,//类型描述
 distance://距离中心点的距离
 }
 ]
 }
 */


/* POI 搜索回调. */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response{
    
    if (response.pois.count == 0){
        [self poiErrorCallBack:@"Empty respons!"];
        [self.func executeWithArguments:ACArgsPack(@(1),@"Empty respons!")];
        return;
    }
    
    NSMutableDictionary *dict =[NSMutableDictionary dictionary];
    [dict setValue:@"0" forKey:@"errorCode"];
    NSMutableArray *data =[NSMutableArray array];

    for(int i=0;i<[response.pois count];i++) {
        AMapPOI *poi=response.pois[i];
        if(poi){
            NSMutableDictionary *poiData=[NSMutableDictionary dictionary];
            [poiData setValue:poi.address forKey:@"address"];
            [poiData setValue:poi.citycode forKey:@"cityCode"];
            [poiData setValue:poi.city forKey:@"cityName"];
            [poiData setValue:poi.website forKey:@"website"];
            [poiData setValue:poi.email forKey:@"email"];
            [poiData setValue:poi.uid forKey:@"id"];
            [poiData setValue:poi.postcode forKey:@"postcode"];
            [poiData setValue:poi.pcode forKey:@"provinceCode"];
            [poiData setValue:poi.province forKey:@"provinceName"];
            [poiData setValue:poi.tel forKey:@"tel"];
            [poiData setValue:poi.type forKey:@"typeDes"];
            [poiData setValue:poi.name forKey:@"title"];
            [poiData setValue:[NSString stringWithFormat:@"%ld",(long)poi.distance] forKey:@"distance"];
            NSMutableDictionary *point =[NSMutableDictionary dictionary];
            [point setValue:[NSString stringWithFormat:@"%f",poi.location.latitude] forKey:@"latitude"];
            [point setValue:[NSString stringWithFormat:@"%f",poi.location.longitude] forKey:@"longitude"];
            [poiData setValue:point forKey:@"point"];
            [data addObject:poiData];
        }
    }

    [dict setValue:data forKey:@"data"];
    [self callbackJsonWithName:@"cbPoiSearch" Object:dict];
    
    [self.func executeWithArguments:ACArgsPack(@(0),[data copy])];
    self.func = nil;
    
}

/*
 ###onMapLoadedListener
 
 */


- (void)mapViewDidFinishLoadingMap:(MAMapView *)mapView{
    [self callbackJsonWithName:@"onMapLoadedListener" Object:nil];
}
    


/*
 ###onMarkerClickListener
 uexGaodeMap.onMarkerClickListener(json);
 var json = {
 id://被点击的标注的id
 }
 */


- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view{
    NSMutableDictionary *dict =[NSMutableDictionary dictionary];
    [dict setValue:view.reuseIdentifier forKey:@"id"];
    [self callbackJsonWithName:@"onMarkerClickListener" Object:dict];
}




/*
 ###onReceiveLocation
 
 */


- (void) callbackJsonWithName:(NSString *)name Object:(id)obj{
    id result;
    if([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]]){
        result = obj;
    }else{
        result = [obj ac_JSONFragment];
    }
    NSString *cbStr = [NSString stringWithFormat:@"uexGaodeMap.%@",name];
    [self.webViewEngine callbackWithFunctionKeyPath:cbStr arguments:ACArgsPack(result)];
    
}



//2015-6-30 新增 by lkl
#pragma mark - 3.0.1新增API

- (void)removeMarkersOverlays:(NSMutableArray *)inArguments{
    
    if([inArguments count]<1){
        [self.mapView removeAnnotations:self.annotations];
        [self.annotations removeAllObjects];
        return;
    }
    ACArgsUnpack(NSArray*info) = inArguments;
    if(![info isKindOfClass:[NSArray class]]) return;
    if([info count]==0){
        [self.mapView removeAnnotations:self.annotations];
        [self.annotations removeAllObjects];
    }

    for(id idInfo in info){
        
        NSString *identifier =nil;
        if([idInfo isKindOfClass:[NSNumber class]]){
            identifier=[idInfo stringValue];
        }
        if([idInfo isKindOfClass:[NSString class]]){
            identifier=idInfo;
        }
        
        if([idInfo isKindOfClass:[NSDictionary class]]&&[idInfo getStringForKey:@"id"]){
            identifier=[idInfo getStringForKey:@"id"];
            
        }
        if(identifier&&[identifier length]>0){
            [self clearMarkersOverlay:identifier];
        }
        
        
    }

}
- (void)removeOverlays:(NSMutableArray *)inArguments{
    if([inArguments count]<1){
        [self.mapView removeOverlays:self.overlays];
        [self.overlays removeAllObjects];

        return;
    }
    
    ACArgsUnpack(NSArray*info) = inArguments;
    if(![info isKindOfClass:[NSArray class]]) return;
    
    for(id data in info){
        NSString *identifier = [NSString stringWithFormat:@"%@",data];
            [self clearOverlayById:identifier];
        }
    
}
- (void)setScaleVisible:(NSMutableArray *)inArguments{
    if([inArguments count]<1) return;
    
    ACArgsUnpack(NSDictionary*info) = inArguments;
    if([info isKindOfClass:[NSDictionary class]]){
        id result=[info objectForKey:@"visible"];
        if([result boolValue]==YES || [result isEqual:@"true"]){
            self.mapView.showsScale=YES;
        }else if([result boolValue]==NO || [result isEqual:@"false"]){
            self.mapView.showsScale=NO;
        }
    }
}

- (void)handleGesture:(GaodeGestureType)type withCoordinate:(CLLocationCoordinate2D)coordinate{
     NSMutableDictionary *dict =[NSMutableDictionary dictionary];
     [dict setValue:@(coordinate.latitude) forKey:@"latitude"];
     [dict setValue:@(coordinate.longitude) forKey:@"longitude"];
    
    switch (type) {
        case GaodeGestureTypeClick:
            [self callbackJsonWithName:@"onMapClickListener" Object:dict];
            break;
        case GaodeGestureTypeLongPress:
            [self callbackJsonWithName:@"onMapLongClickListener" Object:dict];
            break;
            
        default:
            break;
    }
}
- (void)clear:(NSMutableArray *)inArguments{
    [self removeMarkersOverlays:nil];
    [self removeOverlays:nil];
}


#pragma mark - OfflineMap
//20150714 by lkl


- (void)download:(NSMutableArray *)inArguments{
     self.sharedInstance.offlineMgr.delegate=self;
    if([inArguments count]<1) return;
    //id dlInfo =[self getDataFromJson:inArguments[0]];
    ACArgsUnpack(NSArray *dlInfo) = inArguments;
    ACJSFunctionRef *func = JSFunctionArg(inArguments.lastObject);
    if([dlInfo isKindOfClass:[NSArray class]]){
        for(NSDictionary *downloadDict in dlInfo){
            NSString *searchKey=nil;
            if([downloadDict objectForKey:@"city"]){
                searchKey=[downloadDict getStringForKey:@"city"];
            }else if([downloadDict objectForKey:@"province"]){
                searchKey=[downloadDict getStringForKey:@"province"];
            }
            if(searchKey){
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self.sharedInstance.offlineMgr sendDownloadGaodeOfflineMapItemRequestByKey:searchKey callback:^(GaodeOfflineDownloadRequest reqCB) {
                        NSString* errorStr=nil;
                        NSNumber* errorCode;
                        
                        switch (reqCB) {
                            case GaodeOfflineRequestAlreadyFinish:
                                errorStr=@"已经下载完成，请到已下载列表查看！";
                                errorCode=@-3;
                                break;
                            case GaodeOfflineRequestDumplicate:
                                errorCode=@-2;
                                errorStr=@"已经存在列表中！";
                                break;
                                
                            case GaodeOfflineRequestNotExist:
                                errorStr=@"城市或省名称错误！";
                                errorCode=@-1;
                                break;
                            case GaodeOfflineRequestSuccess:
                                errorCode=@0;
                            default:
                                
                                break;
                        }
                        NSMutableDictionary *dict =[NSMutableDictionary dictionary];
                        [dict setValue:searchKey forKey:@"name"];
                        [dict setValue:errorCode forKey:@"errorCode"];
                        if(errorStr)[dict setValue:errorStr forKey:@"errorStr"];
                        [self callbackJsonWithName:@"cbDownload" Object:dict];
                        
                        NSMutableDictionary *resultDic =[NSMutableDictionary dictionary];
                        [resultDic setValue:searchKey forKey:@"name"];
                        if (errorCode) {
                            [resultDic setValue:errorStr forKey:@"errorStr"];
                        }
                        [func executeWithArguments:ACArgsPack(errorCode,resultDic)];
                    }];

                });
            }

        }
    }
}
//onDownload
/* 当downloadStatus == MAOfflineMapDownloadStatusProgress 时, info参数是个NSDictionary,
 如下两个key用来获取已下载和总和的数据大小(单位byte), 对应的是NSNumber(long long) 类型. */
//extern NSString * const MAOfflineMapDownloadReceivedSizeKey;
//extern NSString * const MAOfflineMapDownloadExpectedSizeKey;

- (void)offlineItem:(MAOfflineItem *)item downloadStatusDidChange:(GaodeOfflineDownloadStatus)status info:(id)info{
   

    NSNumber *completeCode=@0;
    NSNumber *statusCode;
    switch (status) {
        case GaodeOfflineDownloadDownloading:
            completeCode=[NSNumber numberWithFloat:((float)[[info objectForKey:MAOfflineMapDownloadReceivedSizeKey] floatValue]/(float)[[info objectForKey:MAOfflineMapDownloadExpectedSizeKey] floatValue]*100)];
            statusCode=@0;
            
            break;
        case GaodeOfflineDownloadPause:
            completeCode=[NSNumber numberWithFloat:((float)item.downloadedSize/(float)item.size*100)];
            statusCode=@3;
            
            break;
        case GaodeOfflineDownloadError:
            completeCode=@0;
            statusCode=@-1;
            
            break;
        case GaodeOfflineDownloadSuccess:
            completeCode=@100;
            statusCode=@4;
            
            break;
        case GaodeOfflineDownloadUnzip:
            completeCode=@100;
            statusCode=@1;
            
            break;
        case GaodeOfflineDownloadWaiting:
            completeCode=[NSNumber numberWithFloat:((float)item.downloadedSize/(float)item.size*100)];
            statusCode=@2;
            
            break;
        default:
            break;
            
    }
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    [dict setValue:item.name forKey:@"name"];
    [dict setValue:completeCode forKey:@"completeCode"];
    if(statusCode)[dict setValue:statusCode forKey:@"status"];
    [self callbackJsonWithName:@"onDownload" Object:dict];

}


- (void)pause:(NSMutableArray *)inArguments{
    if([inArguments count]<1) return;
    //id info=[self getDataFromJson:inArguments[0]];
    ACArgsUnpack(NSArray *info) = inArguments;
    if([info isKindOfClass:[NSArray class]]){
        for(NSString *keyStr in info){
                [self.sharedInstance.offlineMgr pauseDownloadByKey:keyStr];

        }
    }
}
- (void)restart:(NSMutableArray *)inArguments{
     self.sharedInstance.offlineMgr.delegate=self;
    if([inArguments count]<1) return;
    //id info=[self getDataFromJson:inArguments[0]];
    ACArgsUnpack(NSArray *info) = inArguments;
    if([info isKindOfClass:[NSArray class]]){
        for(NSString *keyStr in info){

                [self.sharedInstance.offlineMgr restartDownloadByKey:keyStr];

            
        }
    }
}


- (void)getAvailableCityList:(NSMutableArray *)inArguments{
    NSMutableArray *result=[NSMutableArray array];
    ACJSFunctionRef *func = nil;
    if (inArguments.count > 0) {
        func = JSFunctionArg(inArguments.lastObject);
    }
    NSNumber *error = @(1);
    if (self.sharedInstance.offlineMgr.offlineMap.cities.count > 0) {
        error = @(0);
    }
         for(MAOfflineItem *item in self.sharedInstance.offlineMgr.offlineMap.cities){
             
             [result addObject:[self.sharedInstance.offlineMgr parseCity:item]];
             
             
         }
         [self callbackJsonWithName:@"cbGetAvailableCityList" Object:result];
         [func executeWithArguments:ACArgsPack(error,result)];
    
         


    
}

- (void)getAvailableProvinceList:(NSMutableArray *)inArguments{
    NSMutableArray *result=[NSMutableArray array];
    ACJSFunctionRef *func = nil;
    if (inArguments.count > 0) {
        func = JSFunctionArg(inArguments.lastObject);
    }
     NSNumber *error = @(1);
    if (self.sharedInstance.offlineMgr.offlineMap.provinces.count > 0) {
        error = @(0);
    }
    for(MAOfflineItem *item in self.sharedInstance.offlineMgr.offlineMap.provinces){
            [result addObject:[self.sharedInstance.offlineMgr parseProvince:item]];
    }
    [self callbackJsonWithName:@"cbGetAvailableProvinceList" Object:result];
    [func executeWithArguments:ACArgsPack(error,result)];
}

- (void)getDownloadList:(NSMutableArray *)inArguments{
    NSMutableArray *result=[NSMutableArray array];
    ACJSFunctionRef *func = nil;
    if (inArguments.count > 0) {
        func = JSFunctionArg(inArguments.lastObject);
    }
    NSNumber *error = @(1);
    if ( self.sharedInstance.offlineMgr.offlineMap.cities || self.sharedInstance.offlineMgr.offlineMap.provinces) {
        error = @(0);
    }
        for(MAOfflineItem *item in self.sharedInstance.offlineMgr.offlineMap.cities){
            if(item.itemStatus == MAOfflineItemStatusInstalled||item.itemStatus==MAOfflineItemStatusExpired){
                NSMutableDictionary *dict=[NSMutableDictionary dictionary];
                [dict setValue:@1 forKey:@"type"];
                [dict setValue:item.name forKey:@"name"];
                [dict setValue:[NSNumber numberWithLongLong:item.size] forKey:@"size"];
                [dict setValue:@100 forKey:@"completeCode"];
                [result addObject:dict];
            }
        }
        for(MAOfflineItem *item in self.sharedInstance.offlineMgr.offlineMap.provinces){
            if(item.itemStatus == MAOfflineItemStatusInstalled||item.itemStatus==MAOfflineItemStatusExpired){
                NSMutableDictionary *dict=[NSMutableDictionary dictionary];
                [dict setValue:@2 forKey:@"type"];
                [dict setValue:item.name forKey:@"name"];
                [dict setValue:[NSNumber numberWithLongLong:item.size] forKey:@"size"];
                [dict setValue:@100 forKey:@"completeCode"];
                [result addObject:dict];
            }
        }
        [self callbackJsonWithName:@"cbGetDownloadList" Object:result];
    [func executeWithArguments:ACArgsPack(error,result)];

    

}
- (void)getDownloadingList:(NSMutableArray *)inArguments{
    ACJSFunctionRef *func = nil;
    if (inArguments.count > 0) {
       func = JSFunctionArg(inArguments.lastObject);
    }
    NSNumber *error = @(1);
    NSArray *resultArr = [self.sharedInstance.offlineMgr getDownloadingList];
    if (resultArr) {
        error = @(0);
    }
    [self callbackJsonWithName:@"cbGetDownloadingList" Object:resultArr];
    [func executeWithArguments:ACArgsPack(error,resultArr)];
}
- (void)isUpdate:(NSMutableArray *)inArguments{
    if([inArguments count]<1) return;
    ACArgsUnpack(NSDictionary *info) = inArguments;
    ACJSFunctionRef *func = JSFunctionArg(inArguments.lastObject);
    NSString *searchKey=nil;
    if([info objectForKey:@"city"]){
        searchKey=[info getStringForKey:@"city"];
    }else if([info objectForKey:@"province"]){
        searchKey=[info getStringForKey:@"province"];
    }
    NSMutableArray *result=[NSMutableArray array];
    for(MAOfflineItem *item in self.sharedInstance.offlineMgr.offlineMap.cities){
        if(item.itemStatus == MAOfflineItemStatusInstalled||item.itemStatus==MAOfflineItemStatusExpired){
            [result addObject:item.name];
        }
    }
    for(MAOfflineItem *item in self.sharedInstance.offlineMgr.offlineMap.provinces){
        if(item.itemStatus == MAOfflineItemStatusInstalled||item.itemStatus==MAOfflineItemStatusExpired){
            [result addObject:item.name];
        }
    }


    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    NSNumber *error = @(1);
    BOOL isExist = NO;
    MAOfflineItem *item=[self.sharedInstance.offlineMgr searchItem:searchKey];
    if (!item) {
        [dict setValue:searchKey forKey:@"name"];
        [dict setValue:@"城市或省名称错误!" forKey:@"result"];
        [func executeWithArguments:ACArgsPack(error,dict)];
    }else{
        for (NSString *key in result) {
            if ([key isEqualToString:item.name]) {
                isExist = YES;
            }
        }
        if(isExist){
            error = @(0);
            [dict setValue:item.name forKey:@"name"];
            [dict setValue:item.itemStatus==MAOfflineItemStatusExpired?@0:@1 forKey:@"result"];
            [self callbackJsonWithName:@"cbIsUpdate" Object:dict];
        }else{
            [dict setValue:item.name forKey:@"name"];
            [dict setValue:@"请先下载该地图!" forKey:@"result"];
        }
        [func executeWithArguments:ACArgsPack(error,dict)];
    }
    
    
}
- (void)delete:(NSMutableArray *)inArguments{
    if([inArguments count]<3){
        [self.sharedInstance.offlineMgr.offlineMap cancelAll];
        [self.sharedInstance.offlineMgr.offlineMap clearDisk];
        [self.sharedInstance.offlineMgr clearQueue];
        [self.mapView reloadMap];
        //ACJSFunctionRef *func = JSFunctionArg(inArguments.lastObject);
        //[self callbackJsonWithName:@"cbDelete" Object:nil Function:func];

    }
    
}


#pragma mark - Custom Buttons

-(NSString*)setCustomButton:(NSMutableArray *)inArguments{
    if([inArguments count]<1) return nil;
    //id info=[self getDataFromJson:inArguments[0]];
    ACArgsUnpack(NSDictionary *info) = inArguments;
    if(![info isKindOfClass:[NSDictionary class]]) return nil;
    NSString *identifier,*title=nil;
    UIColor *titleColor=[UIColor blackColor];
    UIImage *bgImage=nil;
    CGFloat x,y,w,h;
    CGFloat titleSize=-1;
    if([info objectForKey:@"x"]){
        x=[[info objectForKey:@"x"] floatValue];
    }else return nil;
    if([info objectForKey:@"y"]){
        y=[[info objectForKey:@"y"] floatValue];
    }else return nil;
    if([info objectForKey:@"width"]){
        w=[[info objectForKey:@"width"] floatValue];
    }else return nil;
    if([info objectForKey:@"height"]){
        h=[[info objectForKey:@"height"] floatValue];
    }else return nil;
    if([info objectForKey:@"id"]){
        identifier=[info getStringForKey:@"id"];
    }else{
        identifier = newUUID();
    };
    if([info objectForKey:@"bgImage"]){
        NSString* imageUrl=[info objectForKey:@"bgImage"];
        NSData *imageData = [NSData dataWithContentsOfFile:[self absPath:imageUrl]];
        if(!imageData){
            imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[self absPath:imageUrl]]];
        }
        bgImage=[UIImage imageWithData:imageData];
    }else return nil;
    if([info objectForKey:@"title"]){
        title=[info objectForKey:@"title"];
    }
    
    if([info objectForKey:@"titleColor"]){
        NSString *colorStr=[info objectForKey:@"titleColor"];
        titleColor=[GaodeUtility UIColorFromHTMLStr:colorStr];
    }
    if([info objectForKey:@"titleSize"]){
        titleSize=[[info objectForKey:@"titleSize"] floatValue];
    }
    __block NSString *returnIdentifier = nil;
    [self.sharedInstance.buttonMgr addButtonWithId:identifier
                                          andX:x
                                          andY:y
                                      andWidth:w
                                     andHeight:h
                                      andTitle:title
                                 andTitleColor:titleColor
                                  andTitleSize:titleSize
                                    andBGImage:bgImage
                                    completion:^(NSString *identifier, BOOL result) {
                                        NSMutableDictionary *dict=[NSMutableDictionary dictionary];
                                        if(result){
                                            [dict setValue:@YES forKey:@"isSuccess"];
                                            returnIdentifier = identifier;
                                        }else{
                                            [dict setValue:@NO forKey:@"isSuccess"];
                                            returnIdentifier = nil;
                                        }
                                        [self callbackJsonWithName:@"cbSetCustomButton" Object:dict];
                                    }];
    
    return returnIdentifier;
}

-(NSNumber*)deleteCustomButton:(NSMutableArray *)inArguments{
    if([inArguments count]<1) return nil;
    ACArgsUnpack(NSString*identifier) = inArguments;
    __block BOOL res;
    [self.sharedInstance.buttonMgr deleteButtonWithId:identifier completion:^(NSString *identifier, BOOL result) {
        NSMutableDictionary *dict=[NSMutableDictionary dictionary];
        [dict setValue:identifier forKey:@"id"];
        if(result){
            [dict setValue:@YES forKey:@"isSuccess"];
            res = YES;
        }else{
            [dict setValue:@NO forKey:@"isSuccess"];
            res = NO;
        }
        [self callbackJsonWithName:@"cbDeleteCustomButton" Object:dict];
    }];
    return @(res);
}
-(NSDictionary*)showCustomButtons:(NSMutableArray *)inArguments{
    if([inArguments count]<1) return nil;
    //id info=[self getDataFromJson:inArguments[0]];
    ACArgsUnpack(NSArray *info) = inArguments;
    if(![info isKindOfClass:[NSArray class]]) return nil;
    __weak typeof(self) weakself=self;
     NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    [self.sharedInstance.buttonMgr showButtons:info
                                completion:^(NSArray *succArr, NSArray *failArr) {
                                   
                                    [dict setValue:succArr forKey:@"successfulIds"];
                                    [dict setValue:failArr forKey:@"failedIds"];
                                    [self callbackJsonWithName:@"cbShowCustomButtons" Object:dict];
                                }
                                   onClick:^(NSString *identifier) {
                                       if(weakself) [weakself callbackJsonWithName:@"onCustomButtonClick" Object:identifier];
                                       
                                   }];
    return [dict copy];
}


-(NSDictionary*)hideCustomButtons:(NSMutableArray *)inArguments{
     NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    if([inArguments count] < 1){
        [self.sharedInstance.buttonMgr hideButtons:[self.sharedInstance.buttonMgr.buttonDict allKeys] completion:^(NSArray *succArr, NSArray *failArr) {
           
            [dict setValue:succArr forKey:@"successfulIds"];
            [dict setValue:failArr forKey:@"failedIds"];
            [self callbackJsonWithName:@"cbHideCustomButtons" Object:dict];
        }];
    }else{
        //id info=[self getDataFromJson:inArguments[0]];
        ACArgsUnpack(NSArray *info) = inArguments;
        if(![info isKindOfClass:[NSArray class]]) return nil;
        [self.sharedInstance.buttonMgr hideButtons:info completion:^(NSArray *succArr, NSArray *failArr) {
          
            [dict setValue:succArr forKey:@"successfulIds"];
            [dict setValue:failArr forKey:@"failedIds"];
            [self callbackJsonWithName:@"cbHideCustomButtons" Object:dict];
            
        }];
    }
    return [dict copy];
}





#pragma mark - AMapSearchDelegate
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    ACLogDebug(@"%s: searchRequest = %@, errInfo= %@", __func__, [request class], error);
    
    if ([request isKindOfClass:[AMapRouteSearchBaseRequest class]] && [request uexCallbackBlock]) {
        [request uexCallbackBlock](error,nil);
    }
    
    
}



- (void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response{
    if (request.uexCallbackBlock) {
        request.uexCallbackBlock(nil,response);
    }
}





#pragma mark - RouteSearch



- (void)drivingRouteSearch:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSDictionary *info,ACJSFunctionRef *callback) = inArguments;
    AMapDrivingRouteSearchRequest *request = [[AMapDrivingRouteSearchRequest alloc] init];
    request.requireExtension = YES;
    request.strategy = numberArg(info[@"strategy"]).integerValue;
    request.origin = [AMapGeoPoint uexGaode_pointFromJSON:dictionaryArg(info[@"origin"])];
    request.destination = [AMapGeoPoint uexGaode_pointFromJSON:dictionaryArg(info[@"destination"])];
    request.avoidroad = stringArg(info[@"avoidRoad"]);
    request.uexCallbackBlock = ^(NSError *error,AMapRouteSearchResponse *response){
        if (error) {
            UEX_ERROR e = uexErrorMake(error.code,error.localizedDescription);
            [callback executeWithArguments:ACArgsPack(e,error.localizedDescription)];
        }else{
            NSMutableArray *paths = [NSMutableArray array];
            for (AMapPath *path in response.route.paths){
                [paths addObject:path.uexGaode_JSONPresentation];
            }
            NSDictionary *result = @{
                                     @"paths": paths,
                                     @"taxiCost": @(response.route.taxiCost),
             };
            [callback executeWithArguments:ACArgsPack(kUexNoError,result)];
        }
    };
    [self.search AMapDrivingRouteSearch:request];
    
}

- (void)walkingRouteSearch:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSDictionary *info,ACJSFunctionRef *callback) = inArguments;
    AMapWalkingRouteSearchRequest *request = [[AMapWalkingRouteSearchRequest alloc] init];
    request.multipath = 1;
    request.origin = [AMapGeoPoint uexGaode_pointFromJSON:dictionaryArg(info[@"origin"])];
    request.destination = [AMapGeoPoint uexGaode_pointFromJSON:dictionaryArg(info[@"destination"])];
    request.uexCallbackBlock = ^(NSError *error,AMapRouteSearchResponse *response){
        if (error) {
            UEX_ERROR e = uexErrorMake(error.code,error.localizedDescription);
            [callback executeWithArguments:ACArgsPack(e,error.localizedDescription)];
        }else{
            NSMutableArray *paths = [NSMutableArray array];
            for (AMapPath *path in response.route.paths){
                [paths addObject:path.uexGaode_JSONPresentation];
            }
            NSDictionary *result = @{
                                     @"paths": paths,
                                     @"taxiCost": @(response.route.taxiCost),
                                     };
            [callback executeWithArguments:ACArgsPack(kUexNoError,result)];
        }
    };
    [self.search AMapWalkingRouteSearch:request];
}

- (void)ridingRouteSearch:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSDictionary *info,ACJSFunctionRef *callback) = inArguments;
    AMapRidingRouteSearchRequest *request = [[AMapRidingRouteSearchRequest alloc] init];
    request.origin = [AMapGeoPoint uexGaode_pointFromJSON:dictionaryArg(info[@"origin"])];
    request.destination = [AMapGeoPoint uexGaode_pointFromJSON:dictionaryArg(info[@"destination"])];
    request.uexCallbackBlock = ^(NSError *error,AMapRouteSearchResponse *response){
        if (error) {
            UEX_ERROR e = uexErrorMake(error.code,error.localizedDescription);
            [callback executeWithArguments:ACArgsPack(e,error.localizedDescription)];
        }else{
            NSMutableArray *paths = [NSMutableArray array];
            for (AMapPath *path in response.route.paths){
                [paths addObject:path.uexGaode_JSONPresentation];
            }
            NSDictionary *result = @{
                                     @"paths": paths,
                                     @"taxiCost": @(response.route.taxiCost),
                                     };
            [callback executeWithArguments:ACArgsPack(kUexNoError,result)];
        }
    };
    [self.search AMapRidingRouteSearch:request];
}
- (void)transitRouteSearch:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSDictionary *info,ACJSFunctionRef *callback) = inArguments;
    AMapTransitRouteSearchRequest *request = [[AMapTransitRouteSearchRequest alloc] init];
    request.city = stringArg(info[@"city"]);
    request.strategy = numberArg(info[@"strategy"]).integerValue;
    request.origin = [AMapGeoPoint uexGaode_pointFromJSON:dictionaryArg(info[@"origin"])];
    request.destination = [AMapGeoPoint uexGaode_pointFromJSON:dictionaryArg(info[@"destination"])];
    request.requireExtension = YES;
    request.uexCallbackBlock = ^(NSError *error,AMapRouteSearchResponse *response){
        if (error) {
            UEX_ERROR e = uexErrorMake(error.code,error.localizedDescription);
            [callback executeWithArguments:ACArgsPack(e,error.localizedDescription)];
        }else{
            NSMutableArray *paths = [NSMutableArray array];
            for (AMapTransit *transit in response.route.transits){
                [paths addObject:transit.uexGaode_JSONPresentation];
            }
            NSDictionary *result = @{
                                     @"paths": paths,
                                     @"taxiCost": @(response.route.taxiCost),
                                     };
            [callback executeWithArguments:ACArgsPack(kUexNoError,result)];
        }
    };
    [self.search AMapTransitRouteSearch:request];
}



- (void)queryProcessedTrace:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSDictionary *info,ACJSFunctionRef *callback) = inArguments;

    NSArray *traceList = arrayArg(info[@"traceList"]);
    NSNumber *coordinateType = numberArg(info[@"coordinateType"]);
    UEX_PARAM_GUARD_NOT_NIL(traceList);
    UEX_PARAM_GUARD_NOT_NIL(coordinateType);
    UEX_PARAM_GUARD_NOT_NIL(callback);
    
    AMapCoordinateType type = -1;
    switch (coordinateType.integerValue) {
        case 2:
            type = AMapCoordinateTypeGPS;
            break;
        case 3:
            type = AMapCoordinateTypeBaidu;
            break;
        default:
            break;
    }
    
    NSMutableArray<MATraceLocation *> *tracePoints = [NSMutableArray array];
    for (NSInteger i = 0; i < traceList.count; i++) {
        NSDictionary *traceInfo = dictionaryArg(traceList[i]);
        if (!traceInfo) {
            continue;
        }
        NSNumber *latitude = numberArg(traceInfo[@"latitude"]);
        NSNumber *longitude = numberArg(traceInfo[@"longitude"]);
        if (!latitude || !longitude) {
            continue;
        }
        NSNumber *bearing = numberArg(traceInfo[@"bearing"]);
        NSNumber *time = numberArg(traceInfo[@"time"]);
        NSNumber *speed = numberArg(traceInfo[@"speed"]);
        
        MATraceLocation *location = [[MATraceLocation alloc]init];
        location.loc = CLLocationCoordinate2DMake(latitude.doubleValue, longitude.doubleValue);
        if (bearing) {
            location.angle = bearing.doubleValue;
        }
        if (time) {
            location.time = time.doubleValue;
        }
        if (speed) {
            location.speed = speed.doubleValue;
        }
        [tracePoints addObject:location];
    }
    
    [self.sharedInstance queryProcessedTraceWith:tracePoints type:type finishCallback:^(NSArray<MATracePoint *> *points, double distance) {
        NSMutableArray *linePoints = [NSMutableArray array];
        for (MATracePoint *p in points ) {
            NSMutableDictionary *pointDict = [NSMutableDictionary dictionary];
            [pointDict setValue:@(p.latitude) forKey:@"latitude"];
            [pointDict setValue:@(p.longitude) forKey:@"longitude"];
            [linePoints addObject:pointDict];
        }
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:linePoints forKey:@"linePoints"];
        [dict setValue:@(distance) forKey:@"distance"];
        [callback executeWithArguments:ACArgsPack(kUexNoError,dict)];
        
        
    } failedCallback:^(int errorCode, NSString *errorDesc) {
        UEX_ERROR error = uexErrorMake(1,errorDesc);
        [callback executeWithArguments:ACArgsPack(error,errorDesc)];
    }];
    
}




@end







