/**
 *
 *	@file   	: uexGaodeRouteSearch.h  in EUExGaodeMap
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


#import <Foundation/Foundation.h>



@interface AMapRouteSearchBaseRequest(uexGaodeRouteSearch)

@property (nonatomic,strong)void (^uexCallbackBlock)(NSError *, AMapRouteSearchResponse *);

@end



@protocol uexGaodeJSONPresentation <NSObject>
@property (nonatomic,readonly)NSDictionary *uexGaode_JSONPresentation;
@end

@interface AMapGeoPoint(uexGaodeRouteSearch)<uexGaodeJSONPresentation>

+ (instancetype)uexGaode_pointFromJSON:(NSDictionary *)json;
@end

@interface AMapSegment(uexGaodeRouteSearch)<uexGaodeJSONPresentation>
@end

@interface AMapBusLine(uexGaodeRouteSearch)<uexGaodeJSONPresentation>
@end

@interface AMapStep(uexGaodeRouteSearch)<uexGaodeJSONPresentation>

@end

@interface AMapPath(uexGaodeRouteSearch)<uexGaodeJSONPresentation>
@end

@interface AMapTransit(uexGaodeRouteSearch)<uexGaodeJSONPresentation>
@end




