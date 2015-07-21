//
//  GaodeOfflineInQueueItem.m
//  EUExGaodeMap
//
//  Created by Cerino on 15/7/16.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//

#import "GaodeOfflineInQueueItem.h"

@implementation GaodeOfflineInQueueItem

-(instancetype)initWithName:(NSString *)name Status:(GaodeInQueueItemStatus)status{
    self=[super init];
    if(self){
        self.name=name;
        self.status=status;
    }
    return self;
}




+(instancetype)parseToItem:(NSDictionary *)dict{
    BOOL isError=NO;
    NSString *name;
    GaodeInQueueItemStatus status;
    if([dict objectForKey:@"name"]&&[[dict objectForKey:@"name"] isKindOfClass:[NSString class]]){
        name=[dict objectForKey:@"name"];
    }else{
        isError=YES;
    }
    if([dict objectForKey:@"status"]){
        status=(GaodeInQueueItemStatus)[[dict objectForKey:@"status"] integerValue];
    }else{
        isError=YES;
    }
    
    if(isError){
        return nil;
    }else{
        GaodeOfflineInQueueItem *item=[[GaodeOfflineInQueueItem alloc] init];
        item.status=status;
        item.name=name;
        return item;
        
    }
}


-(NSDictionary *)saveToDict{
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    [dict setValue:self.name forKey:@"name"];
    [dict setValue:[NSNumber numberWithInteger:self.status] forKey:@"status"];
    return dict;
}

@end

