//
//  GaodeCACalloutBase.m
//  EUExGaodeMap
//
//  Created by lkl on 15/7/9.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//

#import "GaodeCACalloutBase.h"







@implementation GaodeCACalloutBase








/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(instancetype)initWithData:(NSDictionary*)dataDict error:(NSError **)error{
    self=[super init];

    if(self){
        self.dataDict=dataDict;
        if(![self loadData]){
            *error =[GaodeError CACalloutDataError];
        }
        
    }
    return self;
}


-(BOOL)loadData{

    return YES;
}

- (void)getDrawPath:(CGContextRef)context {
    CGRect rrect = self.bounds;
    CGFloat radius = 6.0;
    CGFloat minx = CGRectGetMinX(rrect),
    midx = CGRectGetMidX(rrect),
    maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect),
    maxy = CGRectGetMaxY(rrect)-kArrowHeight;
    CGContextMoveToPoint(context, midx+kArrowHeight, maxy);
    CGContextAddLineToPoint(context,midx, maxy+kArrowHeight);
    CGContextAddLineToPoint(context,midx-kArrowHeight, maxy);
    CGContextAddArcToPoint(context, minx, maxy, minx, miny, radius);
    CGContextAddArcToPoint(context, minx, minx, maxx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, maxx, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextClosePath(context);
}

+(GaodeCACalloutType)parseCACalloutType:(NSDictionary*)calloutDict{
    if(calloutDict&&[calloutDict objectForKey:@"type"]){
        id type=[calloutDict objectForKey:@"type"];
        if([type isEqual:@"textBox"]||[type integerValue]==1) return GaodeCACalloutTypeTextBox;
    }
    
    
    return GaodeCACalloutTypeUndefined;
}
-(UIColor *)getColorForKey:(NSString*)key ifEmpty:(void (^)(void))block{
    if([self.dataDict objectForKey:key]&&[[self.dataDict objectForKey:key] isKindOfClass:[NSString class]]){
        return [GaodeUtility returnUIColorFromHTMLStr:[self.dataDict objectForKey:key]];
    }else{
        if(block) block();
        return [UIColor clearColor];
    }
}
-(CGFloat)getFloatForKey:(NSString*)key ifEmpty:(void (^)(void))block{
    if([self.dataDict objectForKey:key]){
        return [[self.dataDict objectForKey:key] floatValue];
    }else{
        if(block) block();
        
        return 0;
    }
}

-(NSString*)getStringForKey:(NSString*)key ifEmpty:(void (^)(void))block{
    if([self.dataDict objectForKey:key]&&[[self.dataDict objectForKey:key] isKindOfClass:[NSString class]]){
        return [self.dataDict objectForKey:key];
    }else{
        if(block) block();
        return nil;
    }
}
@end
