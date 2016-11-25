//
//  GaodeCustomButtonManager.m
//  EUExGaodeMap
//
//  Created by Cerino on 15/8/18.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//

#import "GaodeCustomButtonManager.h"

@implementation GaodeCustomButtonManager


/*
 
 

 

 -(void)showButtons:(NSArray*)ids;
 -(void)hideButtons:(NSArray*)ids;
 -(void)clearAll;
 */

-(instancetype)initWithMapView:(MAMapView *)mapView{
    self=[super init];
    if(self){
        _buttonDict=[NSMutableDictionary dictionary];
        _mapView=mapView;
    }
    return self;
}

-(void)addButtonWithId:(NSString*)identifier
                  andX:(CGFloat)x
                  andY:(CGFloat)y
              andWidth:(CGFloat)width
             andHeight:(CGFloat)height
              andTitle:(NSString *)title
         andTitleColor:(UIColor *)titleColor
          andTitleSize:(CGFloat)titleSize
            andBGImage:(UIImage *)bgImg
            completion:(void (^)(NSString *, BOOL))completion{
    if([self.buttonDict objectForKey:identifier]){
        if(completion) completion(identifier,NO);
        return;
    }
    GaodeCustomButton *button=[GaodeCustomButton buttonWithType:UIButtonTypeCustom identifier:identifier manager:self];
    if(button){
        button.frame=CGRectMake(x, y,width , height);
        [button setBackgroundImage:bgImg forState:UIControlStateNormal];
        if(title&&[title length]>0){
            [button setTitle:title forState:UIControlStateNormal];
            [button setTitleColor:titleColor forState:UIControlStateNormal];
            if(titleSize != -1) button.titleLabel.font=[UIFont systemFontOfSize:titleSize];
        }
        [self.buttonDict setValue:button forKey:identifier];
        if(completion)completion(identifier,YES);
    }else{
        if(completion) completion(identifier,NO);
    }
    
    
}
-(void)deleteButtonWithId:(NSString *)identifier completion:(void (^)(NSString *, BOOL))completion{
    if(![self.buttonDict objectForKey:identifier]){
        if(completion) completion(identifier,NO);
    }else{

        [self hideButtons:@[identifier] completion:NULL];
        [self.buttonDict removeObjectForKey:identifier];
        if(completion)completion(identifier,YES);
    }
    
}

-(void)hideButtons:(NSArray *)ids completion:(void (^)(NSArray *, NSArray *))completion{
    NSMutableArray *succArr=[NSMutableArray array];
    NSMutableArray *failArr=[NSMutableArray array];
    for(id ident in ids){
        NSString *identifier = [NSString stringWithFormat:@"%@",ident];
        if([self.buttonDict objectForKey:identifier]){
            GaodeCustomButton *button =[self.buttonDict objectForKey:identifier];
            if(button.isShown){
                [button removeFromSuperview];
                button.clickBlock=nil;
                button.isShown=NO;
                [succArr addObject:identifier];
            }else{
                [failArr addObject:identifier];
            }
        }else{
            [failArr addObject:identifier];
        }
    }
    
    if(completion)completion(succArr,failArr);
}


-(void)showButtons:(NSArray *)ids completion:(void (^)(NSArray *, NSArray *))completion onClick:(eventBlock)clickBlock{
    NSMutableArray *succArr=[NSMutableArray array];
    NSMutableArray *failArr=[NSMutableArray array];
    for(id ident in ids){
        NSString *identifier = [NSString stringWithFormat:@"%@",ident];
        if([self.buttonDict objectForKey:identifier]){
           GaodeCustomButton *button =[self.buttonDict objectForKey:identifier];
            if(button.isShown){
                [failArr addObject:identifier];
            }else{
                [self.mapView addSubview:button];
                button.clickBlock=clickBlock;
                button.isShown=YES;
                [succArr addObject:identifier];
            }
            
        }else{
            [failArr addObject:identifier];
        }
    }
    if(completion)completion(succArr,failArr);
}


-(void)hideAllButtons{
    [self hideButtons:[self.buttonDict allKeys] completion:NULL];
}

@end
