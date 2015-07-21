//
//  GaodeError.m
//  EUExGaodeMap
//
//  Created by lkl on 15/7/9.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//

#import "GaodeError.h"

@implementation GaodeError


+(NSError*)CACalloutTypeError{
    return [NSError errorWithDomain:@"uexGaodeMapCustomAnnotation" code:20001 userInfo:@{NSLocalizedDescriptionKey:@"ERROR!UNDEFINED CALLOUT TYPE!"}];
}
+(NSError*)CACalloutDataError{
    return [NSError errorWithDomain:@"uexGaodeMapCustomAnnotation" code:20002 userInfo:@{NSLocalizedDescriptionKey:@"ERROR!CANNOT LOAD DATA!"}];
}
+(NSError*)CACalloutDataEmpty{
    return [NSError errorWithDomain:@"uexGaodeMapCustomAnnotation" code:20003 userInfo:@{NSLocalizedDescriptionKey:@"INVALID DATA"}];
}

@end
