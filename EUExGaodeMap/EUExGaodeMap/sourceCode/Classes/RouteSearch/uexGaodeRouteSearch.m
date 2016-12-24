/**
 *
 *	@file   	: uexGaodeRouteSearch.m  in EUExGaodeMap
 *
 *	@author 	: CeriNo
 * 
 *	@date   	: 2016/12/23
 *
 *	@copyright 	: 2016 The AppCan Open Source Project.
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Lesser General Public License for more details.
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */


#import "uexGaodeRouteSearch.h"
#import <objc/runtime.h>

@implementation AMapRouteSearchBaseRequest(uexGaodeRouteSearch)

static void * _uexCallbackBlockKey;


- (void (^)(NSError *, AMapRouteSearchResponse *))uexCallbackBlock{
    return objc_getAssociatedObject(self, &_uexCallbackBlockKey);
}

- (void)setUexCallbackBlock:(void (^)(NSError *, AMapRouteSearchResponse *))uexCallbackBlock{
    objc_setAssociatedObject(self, &_uexCallbackBlockKey, uexCallbackBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end


@implementation AMapGeoPoint (uexGaodeRouteSearch)

- (NSDictionary *)uexGaode_JSONPresentation{
    return @{
             @"latitude": @(self.latitude),
             @"longitude": @(self.longitude)
             };
}

+ (instancetype)uexGaode_pointFromJSON:(NSDictionary *)json{
    return [self locationWithLatitude:numberArg(json[@"latitude"]).floatValue
                            longitude:numberArg(json[@"longitude"]).floatValue];
}
@end



@implementation AMapStep (uexGaodeRouteSearch)

- (NSDictionary *)uexGaode_JSONPresentation{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@(self.duration) forKey:@"duration"];
    [dict setValue:@(self.distance) forKey:@"distance"];
    [dict setValue:@(self.tolls) forKey:@"tolls"];
    [dict setValue:self.instruction forKey:@"instruction"];
    [dict setValue:self.action forKey:@"action"];
    [dict setValue:self.orientation forKey:@"orientation"];
    [dict setValue:self.road forKey:@"road"];
    NSMutableArray<NSDictionary *> *points = [NSMutableArray array];
#pragma warning TODO
    NSArray *pointStrings = [self.polyline componentsSeparatedByString:@";"];
    [pointStrings enumerateObjectsUsingBlock:^(NSString * data, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *pointData = [data componentsSeparatedByString:@","];
        ACArgsUnpack(NSNumber *lng,NSNumber *lat) = pointData;
        if (lng && lat) {
            AMapGeoPoint *point = [AMapGeoPoint locationWithLatitude:lat.floatValue longitude:lng.floatValue];
            [points addObject:point.uexGaode_JSONPresentation];
        }
    }];
    [dict setValue:points forKey:@"points"];
    return dict;
}
@end




@implementation AMapPath(uexGaodeRouteSearch)

- (NSDictionary *)uexGaode_JSONPresentation{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:self.strategy forKey:@"strategy"];
    [dict setValue:@(self.duration) forKey:@"duration"];
    [dict setValue:@(self.tolls) forKey:@"tolls"];
    [dict setValue:@(self.distance) forKey:@"distance"];
    NSMutableArray *steps = [NSMutableArray array];
    for (AMapStep *step in self.steps){
        [steps addObject:step.uexGaode_JSONPresentation];
    }
    [dict setValue:steps forKey:@"steps"];
    return dict;
}

@end


@implementation AMapBusLine (uexGaodeRouteSearch)

- (NSDictionary *)uexGaode_JSONPresentation{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [dict setValue:self.uid forKey:@"uid"];
    [dict setValue:self.type forKey:@"type"];
    [dict setValue:self.name forKey:@"name"];
    [dict setValue:self.startStop forKey:@"startStop"];
    [dict setValue:self.endStop forKey:@"endStop"];
    [dict setValue:self.departureStop.name forKey:@"departureStop"];
    [dict setValue:self.arrivalStop.name forKey:@"arrivalStop"];
    NSMutableArray *viaStops = [NSMutableArray array];
    for (AMapBusStop *stop in self.viaBusStops) {
        [viaStops addObject:stop.name];
    }
    [dict setValue:viaStops forKey:@"viaStops"];
    [dict setValue:self.startTime forKey:@"startTime"];
    [dict setValue:self.endTime forKey:@"endTime"];
    [dict setValue:@(self.distance) forKey:@"distance"];
    [dict setValue:@(self.duration) forKey:@"duration"];
    [dict setValue:@(self.totalPrice) forKey:@"price"];
    
    return dict;
}

@end

@interface AMapWalking (uexGaodeRouteSearch)<uexGaodeJSONPresentation>

@end

@implementation AMapWalking (uexGaodeRouteSearch)

- (NSDictionary *)uexGaode_JSONPresentation{

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:self.origin.uexGaode_JSONPresentation forKey:@"origin"];
    [dict setValue:self.destination.uexGaode_JSONPresentation forKey:@"destination"];
    [dict setValue:@(self.distance) forKey:@"distance"];
    [dict setValue:@(self.duration) forKey:@"duration"];
    NSMutableArray *steps = [NSMutableArray array];
    for (AMapStep *step in self.steps){
        [steps addObject:step.uexGaode_JSONPresentation];
    }
    [dict setValue:steps forKey:@"steps"];
    return dict;
}

@end

@implementation AMapSegment (uexGaodeRouteSearch)


- (NSDictionary *)uexGaode_JSONPresentation{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:self.walking.uexGaode_JSONPresentation forKey:@"walking"];
    [dict setValue:self.enterName forKey:@"enterName"];
    [dict setValue:self.enterLocation.uexGaode_JSONPresentation forKey:@"enterPoint"];
    [dict setValue:self.exitName forKey:@"exitName"];
    [dict setValue:self.exitLocation.uexGaode_JSONPresentation forKey:@"exitPoint"];
    NSMutableArray *buslines = [NSMutableArray array];
    for (AMapBusLine *line in self.buslines){
        [buslines addObject:line.uexGaode_JSONPresentation];
    }
    [dict setValue:buslines forKey:@"buslines"];
    return dict;
}

@end

@implementation AMapTransit(uexGaodeRouteSearch)

- (NSDictionary *)uexGaode_JSONPresentation{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@(self.cost) forKey:@"cost"];
    [dict setValue:@(self.duration) forKey:@"duration"];
    [dict setValue:@(self.nightflag) forKey:@"nightFlag"];
    [dict setValue:@(self.walkingDistance) forKey:@"walkingDistance"];
    [dict setValue:@(self.distance) forKey:@"distance"];
    NSMutableArray *segments = [NSMutableArray array];
    for (AMapSegment *seg in self.segments){
        [segments addObject:seg.uexGaode_JSONPresentation];
    }
    [dict setValue:segments forKey:@"segments"];
    return dict;
}

@end

