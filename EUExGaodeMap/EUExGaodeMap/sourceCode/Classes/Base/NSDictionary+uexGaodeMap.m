//
//  NSDictionary+uexGaodeMap.m
//  EUExGaodeMap
//
//  Created by CeriNo on 15/10/9.
//  Copyright © 2015年 AppCan. All rights reserved.
//

#import "NSDictionary+uexGaodeMap.h"

@implementation NSDictionary (uexGaodeMap)
-(NSString*)getStringForKey:(id)key{
    id strData=[self objectForKey:key];
    if(strData){
        return [NSString stringWithFormat:@"%@",strData];
    }else{
        return nil;
    }
    
    
}

@end
