//
//  NSDictionary+getString.m
//  AppCanPlugin
//
//  Created by AppCan on 15/5/14.
//  Copyright (c) 2015年 zywx. All rights reserved.
//

#import "NSDictionary+getString.h"

@implementation NSDictionary (getString)
-(NSString*)getStringForKey:(id)key{
    id strData=[self objectForKey:key];
    if(strData){
        return [NSString stringWithFormat:@"%@",strData];
    }else{
        return nil;
    }
    
    
}
@end
