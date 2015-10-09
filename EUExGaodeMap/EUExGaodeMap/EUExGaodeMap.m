//
//  EUExGaodeMap.m
//  AppCanPlugin
//
//  Created by AppCan on 15/5/5.
//  Copyright (c) 2015年 zywx. All rights reserved.
//

#import "EUExGaodeMap.h"
#import "EUExGaodeMapInstance.h"
#import "JSON.h"






@interface EUExGaodeMap ()<MAMapViewDelegate,AMapSearchDelegate,GaodeGestureDelegate,GaodeOfflineDelegate> {
}
@property(nonatomic,weak)MAMapView *mapView;
@property(nonatomic,weak)AMapSearchAPI *search;
@property(nonatomic,weak)EUExGaodeMapInstance *sharedInstance;
@property(nonatomic,assign) BOOL isInitialized;
@property(nonatomic,assign) float zoom;

@property(nonatomic,assign) UserLocationStatus locationStatus;

@property(nonatomic,weak) NSMutableArray *annotations;
@property(nonatomic,weak) NSMutableArray *overlays;
@property(nonatomic,strong) GaodeLocationStyle *locationStyleOptions;

@end

@implementation EUExGaodeMap

-(id)initWithBrwView:(EBrowserView *) eInBrwView{
    if (self = [super initWithBrwView:eInBrwView]) {
         _sharedInstance=[EUExGaodeMapInstance sharedInstance];
        self.annotations=_sharedInstance.annotations;
        self.overlays=_sharedInstance.overlays;
        self.locationStatus =ContinuousLocationDisabled;

        _mapView.showsUserLocation=NO;

        
    }
    return self;
}

-(void)dealloc{
    [self clean];

}



-(void)clean{
    
    if(self.annotations){
        self.annotations =nil;
    }
    if(self.overlays){
        self.overlays =nil;
    }

    if (_mapView){
        _mapView.delegate=nil;
        _mapView =nil;
    }
    if(_search){
        _search =nil;
        
    }
    [_sharedInstance clearAll];

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

-(void)open:(NSMutableArray *)inArguments{
    if([inArguments count]<1) return;

    id initInfo = [self getDataFromJson:inArguments[0]];

    CGFloat left=0;
    CGFloat top=0;
    CGFloat width=CGRectGetWidth(meBrwView.bounds);
    CGFloat height=CGRectGetHeight(meBrwView.bounds);
    BOOL isScrollWithWeb=false;
    if([initInfo getStringForKey:@"left"]){
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
    
   

    
    [_sharedInstance clearAll];
    [_sharedInstance loadGaodeMapWithDataLeft:left top:top width:width height:height];
    _mapView=_sharedInstance.gaodeView;

  

    _search=_sharedInstance.searchAPI;
    _search.delegate = self;
    _mapView.delegate = self;
    _sharedInstance.offlineMgr.delegate=self;
     _sharedInstance.delegate=self;
    _mapView.customizeUserLocationAccuracyCircleRepresentation = YES;
    self.annotations=_sharedInstance.annotations;
    self.overlays=_sharedInstance.overlays;
    self.locationStyleOptions=_sharedInstance.locationStyleOptions;
    _mapView.showTraffic= NO;
    _mapView.mapType=MAMapTypeStandard;
    //_mapView.showsScale= NO;
   
    
    if(isScrollWithWeb){
        [EUtility brwView:meBrwView addSubviewToScrollView:_mapView];
    }else{
        [EUtility brwView:meBrwView addSubview:_mapView];
    }
    


    
    
    if([initInfo getStringForKey:@"latitude"]){
        if([initInfo getStringForKey:@"longitude"]){
            NSString *latitude=[initInfo getStringForKey:@"latitude"];
            NSString *longitude=[initInfo getStringForKey:@"longitude"];
            double lat=[latitude doubleValue];

           

            double lon=[longitude doubleValue];
           CLLocationCoordinate2D center=CLLocationCoordinate2DMake(lat,lon);
            
          // CLLocationCoordinate2D center=CLLocationCoordinate2DMake(30.475798000000000001,114.4028150001);

            [_mapView setCenterCoordinate:center animated:NO];
            

        }
        
    }
    
    [self callbackJsonWithName:@"cbOpen" Object:@"Initialize GaodeMap successfully!"];
      
    
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
-(void)close:(NSMutableArray *)inArguments{
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
-(void)setMapType:(NSMutableArray *)inArguments{
    if([inArguments count]<1) return;
    id mapType = [self getDataFromJson:inArguments[0]];
    NSInteger MAMapType;
    NSString *type = [mapType getStringForKey:@"type"];
    if([type isEqual:@"2"]){
        MAMapType=MAMapTypeSatellite;
    }else if ([type isEqual:@"3"]){
        MAMapType=MAMapTypeStandardNight;
        
    }else if([type isEqual:@"1"]){
        MAMapType =MAMapTypeStandard;
    }
    _mapView.mapType = MAMapType;
    
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
-(void)setTrafficEnabled:(NSMutableArray *)inArguments{
    if([inArguments count]<1) return;
    id info =[self getDataFromJson:inArguments[0]];
    NSString *traffic=[info getStringForKey:@"type"];
    if([traffic isEqual:@"1"]){
        _mapView.showTraffic= YES;
    }else if([traffic isEqual:@"0"]){
        _mapView.showTraffic= NO;
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
-(void)setCenter:(NSMutableArray *)inArguments{
    if([inArguments count]<1) return;
    id info =[self getDataFromJson:inArguments[0]];
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
      [_mapView setCenterCoordinate:CLLocationCoordinate2DMake([latitude floatValue], [longitude floatValue]) animated:YES];
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
-(void)mapZoom:(float)zoom{
    zoom=(zoom>19)?19.0:zoom;
    zoom=(zoom<3)?3.0:zoom;
    self.zoom=zoom;
    [_mapView setZoomLevel:zoom];
    
}
-(void)setZoomLevel:(NSMutableArray *)inArguments{
    if([inArguments count]<1) return;
    id info =[self getDataFromJson:inArguments[0]];
    float zoom =[[info getStringForKey:@"level"] floatValue];
    [self mapZoom:zoom];

    
}



/*
 ###zoomIn
  放大一个地图级别
 */



-(void)zoomIn:(NSMutableArray *)inArguments{
    
    [self mapZoom:(self.zoom+1)];
    
    
}



/*
 ###zoomOut
  缩小一个地图级别
 */



-(void)zoomOut:(NSMutableArray *)inArguments{
    
    
    [self mapZoom:(self.zoom-1)];
    
}



/*
 ###rotate
  旋转地图
 params:
 angle://（必选）旋转角度，正北方向到地图方向逆时针旋转的角度，范围(0,360)。
 
 */



-(void)rotate:(NSMutableArray *)inArguments{
    
    if([inArguments count]<1) return;
    id info =[self getDataFromJson:inArguments[0]];
    NSString *angle=nil;
    if([info getStringForKey:@"angle"]){
        angle=[info getStringForKey:@"angle"];
    }else return;
     [_mapView setRotationDegree:[angle floatValue] animated:YES duration:0.5];
    
    
}



/*
 ###overlook
 倾斜地图
 params:
 angle://(必选)地图倾斜度，范围(0,45)。
 
 */



-(void)overlook:(NSMutableArray *)inArguments{
    
    if([inArguments count]<1) return;
    id info =[self getDataFromJson:inArguments[0]];
    NSString *angle=nil;
    if([info getStringForKey:@"angle"]){
        angle=[info getStringForKey:@"angle"];
    }else return;
    
    [_mapView setCameraDegree:[angle floatValue] animated:YES duration:0.5];
    
}



/*
 ###setZoomEnable
 开启或关闭手势缩放
 params:
 type://（必选） 0-关闭，1-开启
 
 */



-(void)setZoomEnable:(NSMutableArray *)inArguments{
    
    if([inArguments count]<1) return;
    id info =[self getDataFromJson:inArguments[0]];
    NSString *type=nil;
    if([info getStringForKey:@"type"]){
        type=[info getStringForKey:@"type"];
    }else return;
    
    if([type isEqual:@"1"]) _mapView.zoomEnabled = YES;
    if([type isEqual:@"0"]) _mapView.zoomEnabled = NO;
    
}



/*
 ###setRotateEnable
 params:
 type
 
 */



-(void)setRotateEnable:(NSMutableArray *)inArguments{
    
    if([inArguments count]<1) return;
    id info =[self getDataFromJson:inArguments[0]];
    NSString *type=nil;
    if([info getStringForKey:@"type"]){
        type=[info getStringForKey:@"type"];
    }else return;
    if([type isEqual:@"1"]) _mapView.rotateEnabled = YES;
    if([type isEqual:@"0"]) _mapView.rotateEnabled = NO;
    
    
    
}



/*
 ###setCompassEnable
 params:
 type
 
 */



-(void)setCompassEnable:(NSMutableArray *)inArguments{
    
    if([inArguments count]<1) return;
    id info =[self getDataFromJson:inArguments[0]];
    NSString *type=nil;
    if([info getStringForKey:@"type"]){
        type=[info getStringForKey:@"type"];
    }else return;
    if([type isEqual:@"1"]) _mapView.showsCompass= YES;
    if([type isEqual:@"0"]) _mapView.showsCompass= NO;
    
    
}



/*
 ###setScrollEnable
 params:
 type
 
 */



-(void)setScrollEnable:(NSMutableArray *)inArguments{
    
    if([inArguments count]<1) return;
    id info =[self getDataFromJson:inArguments[0]];
    NSString *type=nil;
    if([info getStringForKey:@"type"]){
        type=[info getStringForKey:@"type"];
    }else return;
    
    if([type isEqual:@"1"])_mapView.scrollEnabled = YES;
    if([type isEqual:@"0"])_mapView.scrollEnabled = NO;
    
}


#pragma mark AnnotationDelegate


- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation{
    
    
    
    //大头针标注
    if ([annotation isKindOfClass:[GaodePointAnnotation class]]) {
        GaodePointAnnotation *pointAnnotation=annotation;
        if(pointAnnotation.isCustomCallout){
            GaodeCustomAnnotationView *annotationView;
            if([_mapView dequeueReusableAnnotationViewWithIdentifier:pointAnnotation.identifier]&&[[_mapView dequeueReusableAnnotationViewWithIdentifier:pointAnnotation.identifier] isKindOfClass:[GaodeCustomAnnotationView class]]){
                annotationView=(GaodeCustomAnnotationView*)[_mapView dequeueReusableAnnotationViewWithIdentifier:pointAnnotation.identifier];
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
            MAPinAnnotationView *annotationView = (MAPinAnnotationView*)[_mapView dequeueReusableAnnotationViewWithIdentifier:pointAnnotation.identifier];
            
            
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
        if(self.locationStatus == ContinuousLocationEnabledWithMarker){
            return nil;
        }
             MAAnnotationView *annotationView = [_mapView dequeueReusableAnnotationViewWithIdentifier:self.locationStyleOptions.identifier];
            if (annotationView == nil) {
                annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation
                                                              reuseIdentifier:self.locationStyleOptions.identifier];
            }

            return annotationView;
        }
    
        
    
    
    return nil;
}
#pragma mark OverlayDelegate
- (MAOverlayView *)mapView:(MAMapView *)mapView viewForOverlay:(id<MAOverlay>)overlay{
    
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
        MAPolylineView *polylineView = [[MAPolylineView alloc] initWithPolyline:polyline];
        polylineView.lineWidth = polyline.lineWidth;
        polylineView.strokeColor = polyline.color;
        polylineView.lineJoinType = polyline.lineJoinType;//连接类型
        polylineView.lineCapType = polyline.lineCapType;//端点类型
        return polylineView;
    }
    
    //多边形
    if ([overlay isKindOfClass:[GaodePolygon class]]) {
        GaodePolygon *polygon =(GaodePolygon *)overlay;
        MAPolygonView *polygonView = [[MAPolygonView alloc] initWithPolygon:polygon];
        polygonView.lineWidth = polygon.lineWidth;
        polygonView.strokeColor = polygon.strokeColor;
        polygonView.fillColor = polygon.fillColor;
        polygonView.lineJoinType = polygon.lineJoinType;//连接类型
        return polygonView;
    }
    //圆
    if ([overlay isKindOfClass:[GaodeCircle class]]) {
        GaodeCircle *circle =(GaodeCircle *)overlay;
        MACircleView *circleView = [[MACircleView alloc] initWithCircle:overlay];
        
        circleView.lineWidth = circle.lineWidth;
        circleView.strokeColor = circle.strokeColor;
        circleView.fillColor = circle.fillColor;
        circleView.lineDash = circle.lineDash;
        return circleView;
    }
    
    //自定义图片
    if ([overlay isKindOfClass:[GaodeGroundOverlay class]])
    {
        MAGroundOverlayView *groundOverlayView = [[MAGroundOverlayView alloc]
                                                  initWithGroundOverlay:overlay];
        
        return groundOverlayView;
    }
    /* 自定义定位精度对应的 MACircleView. */
    
    if (overlay == mapView.userLocationAccuracyCircle) {
        if(self.locationStatus == ContinuousLocationEnabled){
            return nil;
        }

        MACircleView  *accuracyCircleView = [[MACircleView alloc] initWithCircle:overlay];
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



-(void)addMarkersOverlay:(NSMutableArray *)inArguments{
    
    if([inArguments count]<1) return;
    NSArray *markerArray =[self getDataFromJson:inArguments[0]];
    for(NSDictionary *info in markerArray)
    {
        
        NSString *identifier=nil;
        if([info getStringForKey:@"id"]){
            identifier=[info getStringForKey:@"id"];
        }else return;
        NSString *longitude=nil;
        if([info getStringForKey:@"longitude"]){
        longitude=[info getStringForKey:@"longitude"];
        }else return;
        NSString *latitude=nil;
        if([info getStringForKey:@"latitude"]){
            latitude=[info getStringForKey:@"latitude"];
        }else return;
        NSString *icon=nil;
        if([info getStringForKey:@"icon"]){
            icon=[info getStringForKey:@"icon"];
            icon=[self absPath:icon];
        }
        NSDictionary *bubble=nil;
        if([info objectForKey:@"bubble"]&&[[info objectForKey:@"bubble"] isKindOfClass:[NSDictionary class]]){
            bubble=[info objectForKey:@"bubble"];
        }
        NSDictionary *customBubble=nil;
                                           if([info objectForKey:@"customBubble"]&&[[info objectForKey:@"customBubble"] isKindOfClass:[NSDictionary class]]){
            customBubble=[info objectForKey:@"customBubble"];
                                               
        }

        if([self searchAnnotationById:identifier])return;

        GaodePointAnnotation *pointAnnotation =[[GaodePointAnnotation alloc] init];
        pointAnnotation.identifier =identifier;
        pointAnnotation.coordinate=CLLocationCoordinate2DMake([latitude floatValue], [longitude floatValue]);
        if(icon){
            [pointAnnotation createIconImage:icon];
        }
        if(customBubble){
            pointAnnotation.isCustomCallout=YES;
            pointAnnotation.customCalloutData=customBubble;
        }
        if(bubble&&!pointAnnotation.isCustomCallout){
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
        
        [_mapView addAnnotation:pointAnnotation];
        [self.annotations addObject:pointAnnotation];

    }
    
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


-(void)setMarkerOverlay:(NSMutableArray *)inArguments{
    
    if([inArguments count]<1) return;
    id info =[self getDataFromJson:inArguments[0]];
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

    [_mapView removeAnnotation:pointAnnotation];


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
    [_mapView addAnnotation:pointAnnotation];

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



-(void)addPolylineOverlay:(NSMutableArray *)inArguments{
    
    if([inArguments count]<1) return;
    id info =[self getDataFromJson:inArguments[0]];
    NSString *identifier=nil;
    if([info getStringForKey:@"id"]){
        identifier=[info getStringForKey:@"id"];
    }else return;
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
    }else return;


    NSInteger count =[property count];
    CLLocationCoordinate2D commonPolylineCoords[count];
    
    for(int i = 0;i<count;i++){
        NSDictionary *location =property[i];
        
        commonPolylineCoords[i].latitude = [[location getStringForKey:@"latitude"] floatValue];
        commonPolylineCoords[i].longitude = [[location getStringForKey:@"longitude"] floatValue];
    }
    [self clearOverlayById:identifier];
    GaodePolyline *polyline = [GaodePolyline polylineWithCoordinates:commonPolylineCoords count:count];
    polyline.identifier =identifier;
    [polyline dataInit];
    if(fillColor){
        [polyline setFillC:fillColor];
    }
    
    if(lineWidth){
        polyline.lineWidth=[lineWidth floatValue];
    }
    [_mapView addOverlay: polyline];
    [self.overlays addObject:polyline];
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

-(void)clearOverlayById:(NSString *)identifier{
    id<MAOverlay> overlay=[self searchOverlayById:identifier];
    if(overlay){
        [_mapView removeOverlay:overlay];
        [self.overlays removeObject:overlay];
    }

}
-(void)removeOverlay:(NSMutableArray *)inArguments{
    
    if([inArguments count]<1) return;
    id info =[self getDataFromJson:inArguments[0]];
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



-(void)addCircleOverlay:(NSMutableArray *)inArguments{
    
    if([inArguments count]<1) return;
    id info =[self getDataFromJson:inArguments[0]];
    NSString *identifier=nil;
    if([info getStringForKey:@"id"]){
        identifier=[info getStringForKey:@"id"];
    }else return;
    NSString *longitude=nil;
    if([info getStringForKey:@"longitude"]){
        longitude=[info getStringForKey:@"longitude"];
    }else return;
    NSString *latitude=nil;
    if([info getStringForKey:@"latitude"]){
        latitude=[info getStringForKey:@"latitude"];
    }else return;
    NSString *radius=nil;
    if([info getStringForKey:@"radius"]){
        radius=[info getStringForKey:@"radius"];
    }else return;
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
    
    [self clearOverlayById:identifier];
    
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
    [_mapView addOverlay: circle];

    [self.overlays addObject:circle];
    
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



-(void)addPolygonOverlay:(NSMutableArray *)inArguments{
    
    if([inArguments count]<1) return;
    id info =[self getDataFromJson:inArguments[0]];
    NSString *identifier=nil;
    if([info getStringForKey:@"id"]){
        identifier=[info getStringForKey:@"id"];
    }else return;
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
    }else return;
    
    NSInteger count =[property count];
    CLLocationCoordinate2D coordinates[count];
    
    for(int i = 0;i<count;i++){
        NSDictionary *location =property[i];
        
        coordinates[i].latitude = [[location getStringForKey:@"latitude"] floatValue];
        coordinates[i].longitude = [[location getStringForKey:@"longitude"] floatValue];
    }
    [self clearOverlayById:identifier];
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

    [_mapView addOverlay:polygon];
    [self.overlays addObject:polygon];
    
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


-(void)addGroundOverlay:(NSMutableArray *)inArguments{
    
    if([inArguments count]<1) return;
    id info =[self getDataFromJson:inArguments[0]];
    NSString *identifier=nil;
    if([info getStringForKey:@"id"]){
        identifier=[info getStringForKey:@"id"];
    }else return;
    NSString *imageUrl=nil;
    if([info getStringForKey:@"imageUrl"]){
        imageUrl=[info objectForKey:@"imageUrl"];
    }else return;

    NSArray *property=nil;
    if([info objectForKey:@"property"]){
        property=[info objectForKey:@"property"];
    }else return;
    
    if([property count] < 2) return;
    NSDictionary *southWestDict =property[0];
    NSDictionary *northEastDict =property[1];
    
    
    CLLocationCoordinate2D northEastEPoint =CLLocationCoordinate2DMake([[northEastDict getStringForKey:@"latitude"] floatValue],[[northEastDict getStringForKey:@"longitude"] floatValue]);
    CLLocationCoordinate2D southWestPoint =CLLocationCoordinate2DMake([[southWestDict getStringForKey:@"latitude"] floatValue],[[southWestDict getStringForKey:@"longitude"] floatValue]);
    
    MACoordinateBounds coordinateBounds = MACoordinateBoundsMake(northEastEPoint,southWestPoint);
    
    NSData *overlayImageData = [NSData dataWithContentsOfFile:[self absPath:imageUrl]];
    if(!overlayImageData){
        overlayImageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[self absPath:imageUrl]]];
    }
    [self clearOverlayById:identifier];
    GaodeGroundOverlay *groundOverlay = [GaodeGroundOverlay groundOverlayWithBounds:coordinateBounds icon:[UIImage imageWithData:overlayImageData]];
    groundOverlay.identifier =identifier;
    [_mapView addOverlay:groundOverlay];
    _mapView.visibleMapRect = groundOverlay.boundingMapRect;
    [self.overlays addObject:groundOverlay];
    
    
    
}



/*
 ###removeMarkersOverlay
 params:
id://(必选) 唯一标识符
 
 */

-(void)clearMarkersOverlay:(NSString *)identifier{
    if(!identifier) return;
    if([self searchAnnotationById:identifier]){
        GaodePointAnnotation *annotation=[self searchAnnotationById:identifier];
        [_mapView removeAnnotation:annotation];
        [self.annotations removeObject:annotation];
    }
    
}

-(void)removeMarkersOverlay:(NSMutableArray *)inArguments{
    
    if([inArguments count]<1) return;
    id info =[self getDataFromJson:inArguments[0]];
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



-(void)poiErrorCallBack:(NSString*)errorString{
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    [dict setValue:@"1" forKey:@"errorCode"];
    [dict setValue:errorString forKey:@"errorInfo" ];
    [self callbackJsonWithName:@"cbPoiSearch" Object:dict];
}


-(void)poiSearch:(NSMutableArray *)inArguments{
    
    if([inArguments count]<1) return;
    id info =[self getDataFromJson:inArguments[0]];
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
    if([info getStringForKey:@"city"]){
        pageNum=[info getStringForKey:@"city"];
    }
    NSDictionary *searchBound=nil;
    if([info objectForKey:@"searchBound"]){
        searchBound=[info objectForKey:@"searchBound"];
    }
    AMapPlaceSearchRequest *request = [[AMapPlaceSearchRequest alloc] init];
    request.requireExtension=YES;
    request.offset=30;
    if(pageNum){
        request.page=([pageNum integerValue]+1);
    }
    
    
    BOOL isKeyEmpty=YES;
    if(searchKey){
        request.keywords =searchKey;
        isKeyEmpty=NO;
    }
    if(poiTypeSet){
        request.types=@[poiTypeSet];
        isKeyEmpty =NO;
    }
    if(isKeyEmpty){
        [self poiErrorCallBack:@"Missing searchKey or poiTypeSet!"];
        return;
    }
    
    
    BOOL isPlaceEmpty=YES;
    if(city){
        request.city =@[city];
        isPlaceEmpty=NO;
    }
    BOOL searchBoundAvailable = NO;
    if(searchBound){
        NSString *type = nil;
        if([searchBound getStringForKey:@"type"]){
            type=[searchBound getStringForKey:@"type"];
            type=[type lowercaseString];
            if([type isEqual:@"circle"]){
                request.searchType =AMapSearchType_PlaceAround;

                if([searchBound objectForKey:@"dataInfo"]){
                    NSDictionary *dataInfo=[searchBound objectForKey:@"dataInfo"];
                    NSDictionary *center=[dataInfo objectForKey:@"center"];
                    request.location = [AMapGeoPoint locationWithLatitude:[[center getStringForKey:@"latitude"] floatValue] longitude:[[center getStringForKey:@"longitude"] floatValue]];
                    request.radius =[[dataInfo getStringForKey:@"radius"] integerValue];
                    searchBoundAvailable =YES;
                    isPlaceEmpty=NO;
                }else{
                    [self poiErrorCallBack:@"Missing dataInfo!"];
                   return;
                }
            }else if([type isEqual:@"rectangle"]){
                
                request.searchType =AMapSearchType_PlacePolygon;
                if([searchBound objectForKey:@"dataInfo"]){
                    NSDictionary *dataInfo=[searchBound objectForKey:@"dataInfo"];
                    NSDictionary *lowerLeft=[dataInfo objectForKey:@"lowerLeft"];
                    NSDictionary *upperRight=[dataInfo objectForKey:@"upperRigh"];
                    
                    AMapGeoPoint *leftTopPoint =[AMapGeoPoint locationWithLatitude:[[upperRight getStringForKey:@"latitude"] floatValue]
                                                                        longitude:[[lowerLeft getStringForKey:@"longitude"] floatValue]];
                    
                     AMapGeoPoint *rightButtomPoint =[AMapGeoPoint locationWithLatitude:[[lowerLeft getStringForKey:@"latitude"] floatValue]
                                                                             longitude:[[upperRight getStringForKey:@"longitude"] floatValue]
                                                      ];
                    
                    
                    request.polygon = [AMapGeoPolygon polygonWithPoints:@[leftTopPoint,rightButtomPoint]];
                    searchBoundAvailable =YES;
                    isPlaceEmpty=NO;
                }else{
                    [self poiErrorCallBack:@"Missing dataInfo!"];
                    return;
                }
          
            }else if([type isEqual:@"polygon"]){
                
                request.searchType =AMapSearchType_PlacePolygon;
                if([searchBound objectForKey:@"dataInfo"]){
                    NSArray *dataInfo=[searchBound objectForKey:@"dataInfo"];
                    NSMutableArray *polygonPoints=[NSMutableArray array];
                    for(int i=0;i<[dataInfo count];i++){
                        NSDictionary *pointDict=dataInfo[i];
                        AMapGeoPoint *point =[AMapGeoPoint locationWithLatitude:[[pointDict getStringForKey:@"latitude"] floatValue]
                                                                             longitude:[[pointDict getStringForKey:@"longitude"] floatValue]];
                        
                        [polygonPoints addObject:point];
                    }
                    NSInteger pointCount = [polygonPoints count];
                    if(![polygonPoints[0] isEqual:polygonPoints[pointCount]]){
                        [polygonPoints addObject:polygonPoints[0]];
                    }
                    
                    

                    
                    
                    request.polygon = [AMapGeoPolygon polygonWithPoints:polygonPoints];
                    searchBoundAvailable =YES;
                    isPlaceEmpty=NO;
                }else{
                    [self poiErrorCallBack:@"Missing dataInfo!"];
                    return;
                }
            }

        }
        if(!searchBoundAvailable){
            request.searchType = AMapSearchType_PlaceKeyword;
        }
        
    }
    if(isPlaceEmpty){
        [self poiErrorCallBack:@"Missing city or searchBound!"];
        return;
    }
    
    [_search AMapPlaceSearch:request];
}



/*
 ###geocode
 params:
 city
 address
 
 */



-(void)geocode:(NSMutableArray *)inArguments{
    
    if([inArguments count]<1) return;
    id info =[self getDataFromJson:inArguments[0]];
    NSString *city=nil;
    if([info getStringForKey:@"city"]){
        city=[info getStringForKey:@"city"];
    }
    NSString *address=nil;
    if([info getStringForKey:@"address"]){
        address=[info getStringForKey:@"address"];
    }else return;
    
    AMapGeocodeSearchRequest *geoRequest = [[AMapGeocodeSearchRequest alloc] init];
    geoRequest.searchType =AMapSearchType_Geocode;
    geoRequest.address = address;


    if(city){
        geoRequest.city =@[city];
    }
    
    [_search AMapGeocodeSearch: geoRequest];
}



/*
 ###reverseGeocode
 params:
 longitude
 latitude
 
 */



-(void)reverseGeocode:(NSMutableArray *)inArguments{
    
    if([inArguments count]<1) return;
    id info =[self getDataFromJson:inArguments[0]];
    NSString *longitude=nil;
    if([info getStringForKey:@"longitude"]){
        longitude=[info getStringForKey:@"longitude"];
    }else return;
    NSString *latitude=nil;
    if([info getStringForKey:@"latitude"]){
        latitude=[info getStringForKey:@"latitude"];
    }else return;
    AMapReGeocodeSearchRequest *regeoRequest = [[AMapReGeocodeSearchRequest alloc] init];
    regeoRequest.searchType = AMapSearchType_ReGeocode;
    regeoRequest.location = [AMapGeoPoint locationWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
    regeoRequest.radius = 10000;
    regeoRequest.requireExtension = YES;
    
    [_search AMapReGoecodeSearch: regeoRequest];

}

#warning 源码调试定位功能时，需要在info.plist 中追加NSLocationAlwaysUsageDescription 字段,以申请相应的权限。

/*
 ###getCurrentLocation
 
 */



-(void)getCurrentLocation:(NSMutableArray *)inArguments{
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


    _mapView.showsUserLocation = YES;


    
    
    
    
}


/*
 ###startLocation
 
 */



-(void)startLocation:(NSMutableArray *)inArguments{
    self.locationStatus =ContinuousLocationEnabled;
    _mapView.showsUserLocation = YES;

    
}



/*
 ###stopLocation
 
 */



-(void)stopLocation:(NSMutableArray *)inArguments{
    self.locationStatus=ContinuousLocationDisabled;
    _mapView.showsUserLocation = NO;

}



/*
 ###setMyLocationEnable
   显示或隐藏我的位置
 params:
 type
 
 */



-(void)setMyLocationEnable:(NSMutableArray *)inArguments{
    
    if([inArguments count]<1) return;
    if(self.locationStatus == ContinuousLocationDisabled) return;
    id info =[self getDataFromJson:inArguments[0]];
    NSString *type=nil;
    if([info getStringForKey:@"type"]){
        type=[info getStringForKey:@"type"];
    }else return;
    
    if([type isEqual:@"0"]){
        self.locationStatus= ContinuousLocationEnabled;
        _mapView.showsUserLocation = NO;
        _mapView.showsUserLocation = YES;
        

    }
    if([type isEqual:@"1"]){
        self.locationStatus=ContinuousLocationEnabledWithMarker;
        _mapView.showsUserLocation = NO;
        _mapView.showsUserLocation = YES;

    }

    
    
    
}



/*
 ###setUserTrackingMode
 params:
 type://(必选) 模式，1-只在第一次定位移动到地图中心点；
 2-定位、移动到地图中心点并跟随；
 3-定位、移动到地图中心点，跟踪并根据方向
 
*/


-(void)setUserTrackingMode:(NSMutableArray *)inArguments{
    
    if([inArguments count]<1) return;
    id info =[self getDataFromJson:inArguments[0]];
    NSString *type=nil;
    if([info getStringForKey:@"type"]){
        type=[info getStringForKey:@"type"];
    }else return;
    if ([type  isEqual:@"1"]){
        [_mapView setUserTrackingMode:MAUserTrackingModeNone  animated:YES];
    }
    if ([type  isEqual:@"2"]){
        [_mapView setUserTrackingMode:MAUserTrackingModeFollow  animated:YES];
    }
    if ([type  isEqual:@"3"]){
        [_mapView setUserTrackingMode:MAUserTrackingModeFollowWithHeading  animated:YES];
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

-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation
updatingLocation:(BOOL)updatingLocation
{
    
    NSDate *datenow = [NSDate date];
    NSString *timestamp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    //取出当前位置的坐标
    NSMutableDictionary *dict =[NSMutableDictionary dictionaryWithCapacity:2];
    [dict setValue:[NSString stringWithFormat:@"%f",userLocation.coordinate.latitude] forKey:@"latitude"];
    [dict setValue:[NSString stringWithFormat:@"%f",userLocation.coordinate.longitude] forKey:@"longitude"];
    [dict setValue:timestamp forKey:@"timestamp"];
    switch (self.locationStatus) {
        case GettingCurrentPosition:
            self.locationStatus=ContinuousLocationDisabled;
            _mapView.showsUserLocation=NO;
            [self callbackJsonWithName:@"cbGetCurrentLocation" Object:dict];
            break;
        case GettingCurrentPositionWhileLocating:
            self.locationStatus=ContinuousLocationEnabled;
            [self callbackJsonWithName:@"cbGetCurrentLocation" Object:dict];

            break;
        case GettingCurrentPositionWhileMarking:
            self.locationStatus=ContinuousLocationEnabledWithMarker;
            [self callbackJsonWithName:@"cbGetCurrentLocation" Object:dict];
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
    if(request.city && [request.city count]>0){
        [dict setValue:request.city[0] forKey:@"city"];
    }
    if([response.geocodes count] > 0) {
        AMapGeocode  *geocode =response.geocodes[0];
        NSString *longitude =[NSString stringWithFormat:@"%f",geocode.location.longitude];
        NSString *latitude =[NSString stringWithFormat:@"%f",geocode.location.latitude];
        
        [dict setValue:longitude forKey:@"longitude"];
        [dict setValue:latitude  forKey:@"latitude"];
    }

    [self callbackJsonWithName:@"cbGeocode" Object:dict];
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
    if(response.regeocode != nil) {
        [dict setValue:@0 forKey:@"errorCode"];
        [dict setValue:response.regeocode.formattedAddress forKey:@"address"];
        
        
    }else{
        [dict setValue:@-1 forKey:@"errorCode"];
    }
    [dict setValue:@(request.location.latitude) forKey:@"latitude"];
    [dict setValue:@(request.location.longitude) forKey:@"longitude"];
    [self callbackJsonWithName:@"cbReverseGeocode" Object:dict];
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


-(void)onPlaceSearchDone:(AMapPlaceSearchRequest *)request
                response:(AMapPlaceSearchResponse *)respons{
    
    if (respons.pois.count == 0){
        [self poiErrorCallBack:@"Empty respons!"];
        return;
    }
    
    NSMutableDictionary *dict =[NSMutableDictionary dictionary];
    [dict setValue:@"0" forKey:@"errorCode"];
    NSMutableArray *data =[NSMutableArray array];

    for(int i=0;i<[respons.pois count];i++) {
        AMapPOI *poi=respons.pois[i];
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
    
}

/*
 ###onMapLoadedListener
 
 */


- (void)mapViewDidFinishLoadingMap:(MAMapView *)mapView dataSize:(NSInteger)dataSize{
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

//见 cbGetCurrentLocation
-(void) callbackJsonWithName:(NSString *)name Object:(id)obj{
    NSString *result;
    if([obj isKindOfClass:[NSString class]]){
        result=(NSString *)obj;
    }else{
        result=[obj JSONFragment];
    }

    NSString *jsSuccessStr = [NSString stringWithFormat:@"if(uexGaodeMap.%@ != null){uexGaodeMap.%@('%@');}",name,name,result];
    
    [self performSelectorOnMainThread:@selector(callBack:) withObject:jsSuccessStr waitUntilDone:YES];
    
}
-(void)callBack:(NSString *)str{
    [self performSelector:@selector(delayedCallBack:) withObject:str afterDelay:0.01];
    //[meBrwView stringByEvaluatingJavaScriptFromString:str];
}

-(void)delayedCallBack:(NSString *)str{
    [meBrwView stringByEvaluatingJavaScriptFromString:str];
}

- (id)getDataFromJson:(NSString *)jsonData{
    
    NSError *error = nil;
    
    
    
    NSData *jsonData2= [jsonData dataUsingEncoding:NSUTF8StringEncoding];
    
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData2
                     
                                                    options:NSJSONReadingMutableContainers
                     
                                                      error:&error];
    
    if (jsonObject != nil && error == nil){
        
        return jsonObject;
    }else{
        
        // 解析錯誤
        
        return nil;
    }
    
}

//2015-6-30 新增 by lkl
#pragma mark - 3.0.1新增API

-(void)removeMarkersOverlays:(NSMutableArray *)inArguments{
    
    if([inArguments count]<1){
        [_mapView removeAnnotations:self.annotations];
        [self.annotations removeAllObjects];
        return;
    }
    id info =[self getDataFromJson:inArguments[0]];
    if(![info isKindOfClass:[NSArray class]]) return;
    if([info count]==0){
        [_mapView removeAnnotations:self.annotations];
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
-(void)removeOverlays:(NSMutableArray *)inArguments{
    if([inArguments count]<1){
        [_mapView removeOverlays:self.overlays];
        [self.overlays removeAllObjects];

        return;
    }
    id info =[self getDataFromJson:inArguments[0]];
    if(![info isKindOfClass:[NSArray class]]) return;
    
    for(NSDictionary *infoDict in info){
        if([infoDict getStringForKey:@"id"]){
            NSString *identifier=[infoDict getStringForKey:@"id"];
            [self clearOverlayById:identifier];
        }
    }
}
-(void)setScaleVisible:(NSMutableArray *)inArguments{
    if([inArguments count]<1) return;
    id info =[self getDataFromJson:inArguments[0]];
    if([info isKindOfClass:[NSDictionary class]]){
        id result=[info objectForKey:@"visible"];
        if([result boolValue]==YES || [result isEqual:@"true"]){
            _mapView.showsScale=YES;
        }else if([result boolValue]==NO || [result isEqual:@"false"]){
            _mapView.showsScale=NO;
        }
    }
}

-(void)handleGesture:(GaodeGestureType)type withCoordinate:(CLLocationCoordinate2D)coordinate{
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
-(void)clear:(NSMutableArray *)inArguments{
    [self removeMarkersOverlays:nil];
    [self removeOverlays:nil];
}


#pragma mark - OfflineMap
//20150714 by lkl


-(void)download:(NSMutableArray *)inArguments{
     _sharedInstance.offlineMgr.delegate=self;
    if([inArguments count]<1) return;
     id dlInfo =[self getDataFromJson:inArguments[0]];
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
                    [_sharedInstance.offlineMgr sendDownloadGaodeOfflineMapItemRequestByKey:searchKey callback:^(GaodeOfflineDownloadRequest reqCB) {
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
                        NSMutableDictionary *dict=[NSMutableDictionary dictionary];
                        [dict setValue:searchKey forKey:@"name"];
                        [dict setValue:errorCode forKey:@"errorCode"];
                        if(errorStr)[dict setValue:errorStr forKey:@"errorStr"];
                        [self callbackJsonWithName:@"cbDownload" Object:dict];
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

-(void)offlineItem:(MAOfflineItem *)item downloadStatusDidChange:(GaodeOfflineDownloadStatus)status info:(id)info{
   

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


-(void)pause:(NSMutableArray *)inArguments{
    if([inArguments count]<1) return;
    id info=[self getDataFromJson:inArguments[0]];
    if([info isKindOfClass:[NSArray class]]){
        for(NSString *keyStr in info){

                [_sharedInstance.offlineMgr pauseDownloadByKey:keyStr];

            
        }
    }
}
-(void)restart:(NSMutableArray *)inArguments{
     _sharedInstance.offlineMgr.delegate=self;
    if([inArguments count]<1) return;
    id info=[self getDataFromJson:inArguments[0]];
    if([info isKindOfClass:[NSArray class]]){
        for(NSString *keyStr in info){

                [_sharedInstance.offlineMgr restartDownloadByKey:keyStr];

            
        }
    }
}


-(void)getAvailableCityList:(NSMutableArray *)inArguments{
    NSMutableArray *result=[NSMutableArray array];

         for(MAOfflineItem *item in _sharedInstance.offlineMgr.offlineMap.cities){
             
             [result addObject:[_sharedInstance.offlineMgr parseCity:item]];
             
             
         }
         [self callbackJsonWithName:@"cbGetAvailableCityList" Object:result];
         
         


    
}

-(void)getAvailableProvinceList:(NSMutableArray *)inArguments{
    NSMutableArray *result=[NSMutableArray array];

    for(MAOfflineItem *item in _sharedInstance.offlineMgr.offlineMap.provinces){
            [result addObject:[_sharedInstance.offlineMgr parseProvince:item]];
    }
    [self callbackJsonWithName:@"cbGetAvailableProvinceList" Object:result];
}

-(void)getDownloadList:(NSMutableArray *)inArguments{
    NSMutableArray *result=[NSMutableArray array];

        for(MAOfflineItem *item in _sharedInstance.offlineMgr.offlineMap.cities){
            if(item.itemStatus == MAOfflineItemStatusInstalled||item.itemStatus==MAOfflineItemStatusExpired){
                NSMutableDictionary *dict=[NSMutableDictionary dictionary];
                [dict setValue:@1 forKey:@"type"];
                [dict setValue:item.name forKey:@"name"];
                [dict setValue:[NSNumber numberWithLongLong:item.size] forKey:@"size"];
                [dict setValue:@100 forKey:@"completeCode"];
                [result addObject:dict];
            }
        }
        for(MAOfflineItem *item in _sharedInstance.offlineMgr.offlineMap.provinces){
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

        

}
-(void)getDownloadingList:(NSMutableArray *)inArguments{
    [self callbackJsonWithName:@"cbGetDownloadingList" Object:[_sharedInstance.offlineMgr getDownloadingList]];
}
-(void)isUpdate:(NSMutableArray *)inArguments{
    if([inArguments count]<1) return;
    id info=[self getDataFromJson:inArguments[0]];
    
    
    NSString *searchKey=nil;
    if([info objectForKey:@"city"]){
        searchKey=[info getStringForKey:@"city"];
    }else if([info objectForKey:@"province"]){
        searchKey=[info getStringForKey:@"province"];
    }
    MAOfflineItem *item=[_sharedInstance.offlineMgr searchItem:searchKey];
    if(item){
        NSMutableDictionary *dict=[NSMutableDictionary dictionary];
        [dict setValue:item.name forKey:@"name"];
        [dict setValue:item.itemStatus==MAOfflineItemStatusExpired?@0:@1 forKey:@"result"];
        [self callbackJsonWithName:@"cbIsUpdate" Object:dict];
    }
    
    
}
-(void)delete:(NSMutableArray *)inArguments{
    if([inArguments count]<1){
        [_sharedInstance.offlineMgr.offlineMap cancelAll];
        [_sharedInstance.offlineMgr.offlineMap clearDisk];
        [_sharedInstance.offlineMgr clearQueue];
        [_mapView reloadMap];
        [self callbackJsonWithName:@"cbDelete" Object:nil];

    }
    
}


#pragma mark - Custom Buttons

-(void)setCustomButton:(NSMutableArray *)inArguments{
    if([inArguments count]<1) return;
    //id info=[self getDataFromJson:inArguments[0]];
    id info =[inArguments[0] JSONValue];
    if(![info isKindOfClass:[NSDictionary class]]) return;
    NSString *identifier,*title=nil;
    UIColor *titleColor=[UIColor blackColor];
    UIImage *bgImage=nil;
    CGFloat x,y,w,h;
    CGFloat titleSize=-1;
    if([info objectForKey:@"x"]){
        x=[[info objectForKey:@"x"] floatValue];
    }else return;
    if([info objectForKey:@"y"]){
        y=[[info objectForKey:@"y"] floatValue];
    }else return;
    if([info objectForKey:@"width"]){
        w=[[info objectForKey:@"width"] floatValue];
    }else return;
    if([info objectForKey:@"height"]){
        h=[[info objectForKey:@"height"] floatValue];
    }else return;
    if([info objectForKey:@"id"]){
        identifier=[info objectForKey:@"id"];
    }else return;
    if([info objectForKey:@"bgImage"]){
        NSString* imageUrl=[info objectForKey:@"bgImage"];
        NSData *imageData = [NSData dataWithContentsOfFile:[self absPath:imageUrl]];
        if(!imageData){
            imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[self absPath:imageUrl]]];
        }
        bgImage=[UIImage imageWithData:imageData];
    }else return;
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
    [_sharedInstance.buttonMgr addButtonWithId:identifier
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
                                        [dict setValue:identifier forKey:@"id"];
                                        if(result){
                                            [dict setValue:@YES forKey:@"isSuccess"];
                                        }else{
                                            [dict setValue:@NO forKey:@"isSuccess"];
                                        }
                                        [self callbackJsonWithName:@"cbSetCustomButton" Object:dict];
                                    }];
    
    
}

-(void)deleteCustomButton:(NSMutableArray *)inArguments{
    if([inArguments count]<1) return;
    
    NSString *identifier=inArguments[0];
    
    
    [_sharedInstance.buttonMgr deleteButtonWithId:identifier completion:^(NSString *identifier, BOOL result) {
        NSMutableDictionary *dict=[NSMutableDictionary dictionary];
        [dict setValue:identifier forKey:@"id"];
        if(result){
            [dict setValue:@YES forKey:@"isSuccess"];
        }else{
            [dict setValue:@NO forKey:@"isSuccess"];
        }
        [self callbackJsonWithName:@"cbDeleteCustomButton" Object:dict];
    }];
}
-(void)showCustomButtons:(NSMutableArray *)inArguments{
    if([inArguments count]<1) return;
    id info=[self getDataFromJson:inArguments[0]];
    if(![info isKindOfClass:[NSArray class]]) return;
    __weak typeof(self) weakself=self;
    [_sharedInstance.buttonMgr showButtons:info
                                completion:^(NSArray *succArr, NSArray *failArr) {
                                    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
                                    [dict setValue:succArr forKey:@"successfulIds"];
                                    [dict setValue:failArr forKey:@"failedIds"];
                                    [self callbackJsonWithName:@"cbShowCustomButtons" Object:dict];
                                }
                                   onClick:^(NSString *identifier) {
                                       if(weakself) [weakself callbackJsonWithName:@"onCustomButtonClick" Object:identifier];
                                       
                                   }];
    
}


-(void)hideCustomButtons:(NSMutableArray *)inArguments{
    if([inArguments count]<1){
        [_sharedInstance.buttonMgr hideButtons:[_sharedInstance.buttonMgr.buttonDict allKeys] completion:^(NSArray *succArr, NSArray *failArr) {
            NSMutableDictionary *dict=[NSMutableDictionary dictionary];
            [dict setValue:succArr forKey:@"successfulIds"];
            [dict setValue:failArr forKey:@"failedIds"];
            [self callbackJsonWithName:@"cbHideCustomButtons" Object:dict];
        }];
    }else{
        id info=[self getDataFromJson:inArguments[0]];
        if(![info isKindOfClass:[NSArray class]]) return;
        [_sharedInstance.buttonMgr hideButtons:info completion:^(NSArray *succArr, NSArray *failArr) {
            NSMutableDictionary *dict=[NSMutableDictionary dictionary];
            [dict setValue:succArr forKey:@"successfulIds"];
            [dict setValue:failArr forKey:@"failedIds"];
            [self callbackJsonWithName:@"cbHideCustomButtons" Object:dict];
            
        }];
    }
}

@end

