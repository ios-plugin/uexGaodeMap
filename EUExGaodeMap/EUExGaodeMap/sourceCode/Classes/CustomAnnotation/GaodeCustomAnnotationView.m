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
/***改变响应者链****/
//-(UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
//    UIView *view = [super hitTest:point withEvent:event];
//    if(view == nil) {
//        CGPoint tempPoint = [self convertPoint:point toView:self];
//        if (CGRectContainsPoint(self.bounds, tempPoint)) {
//           view = self;
//        }
//    }
//    return view;
//}
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    NSLog(@"hitTest----%@", [self class]);
    CGPoint yellowPoint = [self convertPoint:point toView:_yellowView];
    if ([_yellowView pointInside:yellowPoint withEvent:event]) {
        return _yellowView;
    }
    
    return [super hitTest:point withEvent:event];
}


//- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
//    CGPoint yellowPoint =[_yellowView convertPoint:point fromView:self];
//    if ([_yellowView pointInside:yellowPoint withEvent:event]) return NO;
//    
//    return [super pointInside:point withEvent:event];
//}
//- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
//    return NO;
//}
@end
