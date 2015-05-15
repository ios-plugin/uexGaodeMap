//
//  EUExGaodeMap+JsonIO.h
//  AppCanPlugin
//
//  Created by AppCan on 15/5/7.
//  Copyright (c) 2015年 zywx. All rights reserved.
//

#import "EUExGaodeMap.h"
#import "JSON.h"


@interface EUExGaodeMap (JsonIO)
-(id)getDataFromJson:(NSString *)jsonData;
-(void) returnJSonWithName:(NSString *)name Object:(id)obj;

@end
