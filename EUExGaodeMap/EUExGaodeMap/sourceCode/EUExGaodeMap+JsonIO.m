//
//  EUExGaodeMap+JsonIO.m
//  AppCanPlugin
//
//  Created by AppCan on 15/5/7.
//  Copyright (c) 2015年 zywx. All rights reserved.
//

#import "EUExGaodeMap+JsonIO.h"



@implementation EUExGaodeMap (JsonIO)

/*
 回调方法name(data)  方法名为name，参数为 字典dict的转成的json字符串
 
 */
-(void) returnJSonWithName:(NSString *)name Object:(id)obj{

    NSString *result=[obj JSONFragment];
    NSString *jsSuccessStr = [NSString stringWithFormat:@"if(uexGaodeMap.%@ != null){uexGaodeMap.%@('%@');}",name,name,result];
    
    [self performSelectorOnMainThread:@selector(callBack:) withObject:jsSuccessStr waitUntilDone:YES];
    
}
-(void)callBack:(NSString *)str{
    [self performSelector:@selector(delayedCallBack:) withObject:str afterDelay:0.01];
    //[meBrwView stringByEvaluatingJavaScriptFromString:str];
}

-(void)delayedCallBack:(NSString *)str{
    [meBrwView stringByEvaluatingJavaScriptFromString:str];
}



//从json字符串中获取数据
- (id)getDataFromJson:(NSString *)jsonData{

    NSError *error = nil;
    
    
    
    NSData *jsonData2= [jsonData dataUsingEncoding:NSUTF8StringEncoding];
    
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData2
                     
                                                    options:NSJSONReadingMutableContainers
                     
                                                      error:&error];
  
    if (jsonObject != nil && error == nil){

        return jsonObject;
    }else{
        
        // 解析錯誤
        
        return nil;
    }
    
}


@end
