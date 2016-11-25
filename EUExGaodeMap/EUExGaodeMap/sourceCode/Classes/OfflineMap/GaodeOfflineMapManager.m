//
//  GaodeOfflineMapManager.m
//  EUExGaodeMap
//
//  Created by AppCan on 15/7/8.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//

#import "GaodeOfflineMapManager.h"

NSString *const cGaodeDownloadQueueKey=@"cGaodeDownloadQueueKey";
NSString *const cGaodeBackgroundDownloadKey=@"cGaodeBackgroundDownloadKey";

@interface GaodeOfflineMapManager()
@property (nonatomic,assign)BOOL isDownloading;
@end

@implementation GaodeOfflineMapManager



-(instancetype)initWithMapView:(MAMapView *)mapView{
    self=[super init];
    if(self){
        self.isDownloading=NO;
        self.mapView=mapView;
        self.offlineMap=[MAOfflineMap sharedOfflineMap];
        self.bgDownload=NO;
        self.isQueueChanged=NO;
        
        [self loadData];
    }
    return self;
}

-(void)loadData{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    self.bgDownload=[userDefaultes boolForKey:cGaodeBackgroundDownloadKey];
    self.downloadQueue = [NSMutableArray arrayWithArray:[self loadQueueFromString:[userDefaultes stringForKey:cGaodeDownloadQueueKey]]];

}

-(void)saveData{
    if(!self.isQueueChanged) return;
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    [userDefaultes setObject:[self saveQueueToString:self.downloadQueue] forKey:cGaodeDownloadQueueKey];
    [userDefaultes setBool:self.bgDownload forKey:cGaodeBackgroundDownloadKey];
    [userDefaultes synchronize];
    self.isQueueChanged=NO;
}
-(NSDictionary*)parseCity:(MAOfflineItem*)city{

   // if([city isKindOfClass:[MAOfflineItemCommonCity class]]){
        NSMutableDictionary *result=[NSMutableDictionary dictionary];
        [result setValue:city.name forKey:@"city"];
        [result setValue:[NSNumber numberWithLongLong:city.size] forKey:@"size"];
        NSNumber *completeCode;
        switch (city.itemStatus) {
            case MAOfflineItemStatusNone:
                completeCode=@0;
                break;
            case MAOfflineItemStatusCached:
                completeCode=[NSNumber numberWithFloat:((float)city.downloadedSize/(float)city.size*100)];
                break;
            default:
                completeCode=@100;
                break;
        }
        [result setValue:completeCode forKey:@"completeCode"];
        //[result setValue:status forKey:@"status"];
        return result;
   // }
    
    
    return nil;
}

-(NSDictionary*)parseProvince:(MAOfflineItem *)item{
    if([item isKindOfClass:[MAOfflineItemMunicipality class]]||[item isKindOfClass:[MAOfflineProvince class]]){
        NSMutableDictionary *result=[NSMutableDictionary dictionary];
        [result setValue:item.name forKey:@"city"];
        [result setValue:[NSNumber numberWithLongLong:item.size] forKey:@"size"];
        NSNumber *completeCode;
        switch (item.itemStatus) {
            case MAOfflineItemStatusNone:
                completeCode=@0;
                break;
            case MAOfflineItemStatusCached:
                completeCode=[NSNumber numberWithFloat:((float)item.downloadedSize/(float)item.size*100)];
                break;
            default:
                completeCode=@100;
                break;
        }
        [result setValue:completeCode forKey:@"completeCode"];
        if([item isKindOfClass:[MAOfflineProvince class]]){
            MAOfflineProvince* province=(MAOfflineProvince*)item;
            NSMutableArray * cityArray=[NSMutableArray array];
            for(MAOfflineItemCommonCity *city in province.cities){
                [cityArray addObject:[self parseCity:city]];
            }
            [result setValue:cityArray forKey:@"cityList"];
        }
        //[result setValue:status forKey:@"status"];
        return result;
    }
    return nil;
}

-(void)sendDownloadGaodeOfflineMapItemRequestByKey:(NSString *)keyStr callback:(void (^)(GaodeOfflineDownloadRequest))reqCB{
    MAOfflineItem *item=[self searchItem:keyStr];
    if(!item){
        if(reqCB) reqCB(GaodeOfflineRequestNotExist);
        return;
    }
    if([self searchInQueueByKey:item.name] != -1){
        if(reqCB) reqCB(GaodeOfflineRequestDumplicate);
        return;
    }
    if(item.itemStatus == MAOfflineItemStatusInstalled){
        if(reqCB) reqCB(GaodeOfflineRequestAlreadyFinish);
        return;
    }
    GaodeOfflineInQueueItem *inQueueItem=[[GaodeOfflineInQueueItem alloc]initWithName:item.name Status:GaodeInQueueItemWaiting];
    [self.downloadQueue addObject:inQueueItem];
    self.isQueueChanged=YES;
    [self run];
    if(reqCB) reqCB(GaodeOfflineRequestSuccess);
}

-(void)run{
    [self saveData];
    if(self.isDownloading) return;
    NSInteger next=[self getNextQueueIndex];
    if(next ==-1)return;
    GaodeOfflineInQueueItem *nextQueueItem=[self getInQueueItem:next];
    if(!nextQueueItem) return;
    MAOfflineItem *item=[self searchItem:nextQueueItem.name];

    

    [_offlineMap downloadItem:item shouldContinueWhenAppEntersBackground:self.bgDownload downloadBlock:^(MAOfflineMapDownloadStatus downloadStatus, id info) {
        switch (downloadStatus) {
            case MAOfflineMapDownloadStatusCancelled:
                nextQueueItem.status=GaodeInQueueItemPaused;
                self.isQueueChanged=YES;
                self.isDownloading=NO;
                [self onDownloadFromOfflineItem:item Status:GaodeOfflineDownloadPause info:info];
                break;
            case MAOfflineMapDownloadStatusCompleted:
                break;
            
            case MAOfflineMapDownloadStatusError:
                self.isDownloading=NO;
                nextQueueItem.status=GaodeInQueueItemError;
                 self.isQueueChanged=YES;
                [self onDownloadFromOfflineItem:item Status:GaodeOfflineDownloadError info:info];
                break;
            case MAOfflineMapDownloadStatusFinished:
                self.isDownloading=NO;
                [self onDownloadFromOfflineItem:item Status:GaodeOfflineDownloadSuccess info:info];
                [self.downloadQueue removeObject:[self getInQueueItem:[self searchInQueueByKey:item.name]]];
                self.isQueueChanged=YES;
                [_mapView reloadMap];
                break;
            case MAOfflineMapDownloadStatusProgress:
                self.isDownloading=YES;
                [self onDownloadFromOfflineItem:item Status:GaodeOfflineDownloadDownloading info:info];
                break;
            case MAOfflineMapDownloadStatusStart:
                break;
            case MAOfflineMapDownloadStatusUnzip:
                self.isDownloading=YES;
                [self onDownloadFromOfflineItem:item Status:GaodeOfflineDownloadUnzip info:info];
                break;
            case MAOfflineMapDownloadStatusWaiting:
                nextQueueItem.status=GaodeInQueueItemWaiting;
                 self.isQueueChanged=YES;
                self.isDownloading=NO;
                [self onDownloadFromOfflineItem:item Status:GaodeOfflineDownloadWaiting info:info];
                
            default:
                break;
        }
        [self run];
    }];
    
    
}

-(void)pauseDownloadByKey:(NSString*)keyStr{
    MAOfflineItem *item=[self searchItem:keyStr];
    
    if(!item||[self searchInQueueByKey:item.name] == -1){
        return;
    }
    [_offlineMap pauseItem:item];
    GaodeOfflineInQueueItem* inQueueItem=[self getInQueueItem:[self searchInQueueByKey:item.name]];
    inQueueItem.status=GaodeInQueueItemPaused;
    [self run];
}

-(void)restartDownloadByKey:(NSString*)keyStr{
    MAOfflineItem *item=[self searchItem:keyStr];
    
    if(!item||[self searchInQueueByKey:item.name] == -1){
        return;
    }

    GaodeOfflineInQueueItem* inQueueItem=[self getInQueueItem:[self searchInQueueByKey:item.name]];
    inQueueItem.status=GaodeInQueueItemWaiting;
    [self run];
}



-(void)onDownloadFromOfflineItem:(MAOfflineItem*)item Status:(GaodeOfflineDownloadStatus)status info:(id)info {
    if([self.delegate respondsToSelector:@selector(offlineItem:downloadStatusDidChange:info:)]){
        [self.delegate offlineItem:item downloadStatusDidChange:status info:info];
    }
}
/*
-(void)searchItem:(NSString*)searchKey result:(void (^)(MAOfflineItem* item, GaodeOfflineMapItemType type))resultBlock{
    for(int i=0;i< [_offlineMap.cities count];i++){
        if([[_offlineMap.cities objectAtIndex:i] isKindOfClass:[MAOfflineItem class]]){
            MAOfflineItem *item =[_offlineMap.cities objectAtIndex:i];
            if([@[item.pinyin,item.adcode,item.jianpin,item.name] indexOfObject:searchKey] != NSNotFound){
                resultBlock(item,GaodeOfflineMapItemCity);
                return;
            }
        }
        
    }
    for(int i=0;i< [_offlineMap.provinces count];i++){
        if([[_offlineMap.provinces objectAtIndex:i] isKindOfClass:[MAOfflineItem class]]){
            MAOfflineItem *item =[_offlineMap.provinces objectAtIndex:i];
            if([@[item.pinyin,item.adcode,item.jianpin,item.name] indexOfObject:searchKey] != NSNotFound){
                resultBlock(item,GaodeOfflineMapItemCity);
                return;
            }
        }
        
    }
    resultBlock(nil,GaodeOfflineMapItemError);
    
    
}
 */
-(MAOfflineItem*)searchItem:(NSString*)searchKey{
    for(int i=0;i< [_offlineMap.cities count];i++){
        if([[_offlineMap.cities objectAtIndex:i] isKindOfClass:[MAOfflineItem class]]){
            MAOfflineItem *item =[_offlineMap.cities objectAtIndex:i];
            if([@[item.pinyin,item.adcode,item.jianpin,item.name] indexOfObject:searchKey] != NSNotFound){
                
                return item;
            }
        }
        
    }
    for(int i=0;i< [_offlineMap.provinces count];i++){
        if([[_offlineMap.provinces objectAtIndex:i] isKindOfClass:[MAOfflineItem class]]){
            MAOfflineItem *item =[_offlineMap.provinces objectAtIndex:i];
            if([@[item.pinyin,item.adcode,item.jianpin,item.name] indexOfObject:searchKey] != NSNotFound){
                
                return item;
            }
        }
        
    }

    return nil;
}

-(NSArray*)getDownloadingList{
    
    if(self.downloadQueue){
        NSMutableArray *result=[NSMutableArray array];
        for(int i=0;i<[self.downloadQueue count];i++){
            GaodeOfflineInQueueItem *queueItem=self.downloadQueue[i];
            MAOfflineItem *item=[self searchItem:queueItem.name];
            NSMutableDictionary *dict=[NSMutableDictionary dictionary];
            [dict setValue:item.name forKey:@"name"];
            [dict setValue:[NSNumber numberWithLongLong:item.size] forKey:@"size"];
            [dict setValue:[item isKindOfClass:[MAOfflineProvince class]]?@2:@1 forKey:@"type"];
            NSNumber *completeCode;
            switch (item.itemStatus) {
                case MAOfflineItemStatusNone:
                    completeCode=@0;
                    break;
                case MAOfflineItemStatusCached:
                    completeCode=[NSNumber numberWithFloat:((float)item.downloadedSize/(float)item.size*100)];
                    break;
                default:
                    completeCode=@100;
                    break;
            }
            [dict setValue:completeCode forKey:@"completeCode"];
            [result addObject:dict];
        }
        return result;
    }

    
    
    
    
    
    return nil;
}

-(void)clearQueue{
    [self.downloadQueue removeAllObjects];
    self.isQueueChanged=YES;
    [self saveData];
}

#pragma mark - Download Queue Method

-(NSArray*)loadQueueFromString:(NSString*)str{
    NSArray *tmp=nil;
    if([str JSONValue]&&[[str JSONValue] isKindOfClass:[NSArray class]]){
        tmp=[str JSONValue];
    }else return nil;
    
    
    NSMutableArray *result=[NSMutableArray array];
    for(int i=0;i<[tmp count];i++){
        if([tmp[i]isKindOfClass:[NSDictionary class]]){
            NSDictionary* tmpDict=tmp[i];
            GaodeOfflineInQueueItem *item=[GaodeOfflineInQueueItem parseToItem:tmpDict];
            if(item) [result addObject:item];
        }
    }
    
    return result;
}

-(NSString*)saveQueueToString:(NSArray*)arr{
    NSMutableArray *tmp=[NSMutableArray array];
    for(int i=0;i<[arr count];i++){
        GaodeOfflineInQueueItem *item=arr[i];
        [tmp addObject:[item saveToDict]];
    }
    return [tmp JSONFragment];
}

-(NSInteger)searchInQueueByKey:(NSString*)key{
    if(self.downloadQueue){
        for(int i=0;i<[self.downloadQueue count];i++){
            GaodeOfflineInQueueItem *item=self.downloadQueue[i];
            if([item.name isEqual:key]){
                return i;
            }
        }
    }
    
    return -1;
}

-(NSInteger)getNextQueueIndex{
    if(self.downloadQueue){
        for(int i=0;i<[self.downloadQueue count];i++){
            GaodeOfflineInQueueItem *item=self.downloadQueue[i];
            if(item.status==GaodeInQueueItemWaiting){
                return i;
            }
        }
    }
    return -1;
}
-(GaodeOfflineInQueueItem*)getInQueueItem:(NSInteger)index{
    if(self.downloadQueue&&[self.downloadQueue count]>=index){
        GaodeOfflineInQueueItem *item=self.downloadQueue[index];
        return item;
    }
    return nil;
}
@end
