//
//  GaodeCustomAnnotationView.m
//  EUExGaodeMap
//
//  Created by lkl on 15/7/9.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//

#import "GaodeCustomAnnotationView.h"

@implementation GaodeCustomAnnotationView
-(void)setupWithCalloutDict:(NSDictionary*)calloutDict{
    self.calloutData=[calloutDict objectForKey:@"data"];
    self.calloutType=[GaodeCACalloutBase parseCACalloutType:calloutDict];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    if (self.selected == selected) {
        return;
    }
    if (selected) {
        if (self.callout == nil){
            NSError *error=nil;
            [self createCalloutWithError:&error];
            if(!error){
                self.callout.center = CGPointMake(CGRectGetWidth(self.bounds) / 2.f +
                                                      self.calloutOffset.x,
                                                      -CGRectGetHeight(self.callout.bounds) / 2.f + self.calloutOffset.y);
            }else{
                return;
            }
        }
        [self addSubview:self.callout];
        
    }else if(self.callout){
        [self.callout removeFromSuperview];
    }
    [super setSelected:selected animated:animated];
}

-(void)createCalloutWithError:(NSError **)Error{
    
    switch (_calloutType) {
        case GaodeCACalloutTypeTextBox:
            self.callout=[[GaodeCACalloutTextBox alloc]initWithData:_calloutData error:Error];
            self.callout.father=self;

            break;

        case GaodeCACalloutTypeUndefined:
            *Error =[GaodeError CACalloutTypeError];
            break;
            
        default:
            *Error =[GaodeError CACalloutTypeError];
            break;
    }
}



@end
