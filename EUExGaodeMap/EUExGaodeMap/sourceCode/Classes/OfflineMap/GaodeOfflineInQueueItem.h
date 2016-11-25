//
//  GaodeOfflineInQueueItem.h
//  EUExGaodeMap
//
//  Created by Cerino on 15/7/16.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSON.h"
typedef NS_ENUM(NSInteger, GaodeInQueueItemStatus) {
    GaodeInQueueItemWaiting=0,
    GaodeInQueueItemPaused,
    GaodeInQueueItemError,

};
@interface GaodeOfflineInQueueItem : NSObject
@property(nonatomic,copy)NSString * name;
@property(nonatomic,assign)GaodeInQueueItemStatus status;

-(NSDictionary*)saveToDict;

+(instancetype)parseToItem:(NSDictionary*)dict;


-(instancetype)initWithName:(NSString *)name Status:(GaodeInQueueItemStatus)status;
@end
