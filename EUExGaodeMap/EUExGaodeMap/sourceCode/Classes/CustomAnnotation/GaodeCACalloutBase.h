//
//  GaodeCACalloutBase.h
//  EUExGaodeMap
//
//  Created by lkl on 15/7/9.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//

#import "GaodeUtility.h"


#define kArrowHeight 10


typedef NS_ENUM(NSInteger, GaodeCACalloutType){
    GaodeCACalloutTypeUndefined=0,
    GaodeCACalloutTypeTextBox,
};

@class GaodeCustomAnnotationView;
@interface GaodeCACalloutBase : UIView

@property(nonatomic,assign)GaodeCACalloutType type;
@property(nonatomic,strong)NSDictionary *dataDict;
@property(nonatomic,weak)GaodeCustomAnnotationView *father;

-(instancetype)initWithData:(NSDictionary*)dataDict error:(NSError **)error;
-(BOOL)loadData;
+(GaodeCACalloutType)parseCACalloutType:(NSDictionary*)dataDict;

- (void)getDrawPath:(CGContextRef)context;


-(UIColor*)getColorForKey:(NSString*)key ifEmpty:(void (^)(void))block;

-(CGFloat)getFloatForKey:(NSString*)key ifEmpty:(void (^)(void))block;


-(NSString*)getStringForKey:(NSString*)key ifEmpty:(void (^)(void))block;


@end
