//
//  GaodeOfflineMapManager.h
//  EUExGaodeMap
//
//  Created by AppCan on 15/7/8.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//
#import "GaodeOfflineInQueueItem.h"
typedef NS_ENUM(NSInteger,GaodeOfflineDownloadStatus) {
    GaodeOfflineDownloadError,
    GaodeOfflineDownloadDownloading,
    GaodeOfflineDownloadUnzip,
    GaodeOfflineDownloadWaiting,
    GaodeOfflineDownloadPause,
    GaodeOfflineDownloadSuccess
};

typedef NS_ENUM(NSInteger,GaodeOfflineDownloadRequest) {
    GaodeOfflineRequestSuccess=0,
    GaodeOfflineRequestDumplicate,
    GaodeOfflineRequestAlreadyFinish,
    GaodeOfflineRequestNotExist,

};




@protocol GaodeOfflineDelegate <NSObject>

@optional
-(void)offlineItem:(MAOfflineItem *)item downloadStatusDidChange:(GaodeOfflineDownloadStatus)status info:(id)info;

@end


@interface GaodeOfflineMapManager : NSObject
@property(nonatomic,weak)MAMapView *mapView;
@property(nonatomic,weak)MAOfflineMap *offlineMap;
@property(nonatomic,assign)BOOL bgDownload;
@property(nonatomic,assign)BOOL isQueueChanged;
@property(nonatomic,strong)NSMutableArray *downloadQueue;
@property(nonatomic,weak)id<GaodeOfflineDelegate>delegate;






-(instancetype)initWithMapView:(MAMapView *)mapView;
-(void)loadData;
-(void)saveData;

-(NSDictionary*)parseCity:(MAOfflineItem*)city;
-(NSDictionary*)parseProvince:(MAOfflineItem*)item;


//-(void)searchItem:(NSString*)searchKey result:(void (^)(MAOfflineItem* item, GaodeOfflineMapItemType type))resultBlock;
-(MAOfflineItem*)searchItem:(NSString*)searchKey;


-(void)sendDownloadGaodeOfflineMapItemRequestByKey:(NSString *)keyStr
                                          callback:(void (^)(GaodeOfflineDownloadRequest request))reqCB;

-(void)pauseDownloadByKey:(NSString*)keyStr;
-(void)restartDownloadByKey:(NSString*)keyStr;
-(NSArray*)getDownloadingList;
-(void)clearQueue;
@end
