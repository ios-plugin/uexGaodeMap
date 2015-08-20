//
//  GaodeCustomButton.m
//  EUExGaodeMap
//
//  Created by Cerino on 15/8/18.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//

#import "GaodeCustomButton.h"

@implementation GaodeCustomButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
+(instancetype)buttonWithType:(UIButtonType)buttonType identifier:(NSString*)identifier manager:(GaodeCustomButtonManager*)mgr{
    GaodeCustomButton * button=[super buttonWithType:buttonType];
    if(button){
        button.identifier=identifier;
        button.GaodeCBMgr=mgr;
        button.isShown=NO;
        
        [button addTarget:button action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
        return button;
        
    }
    return nil;
}



-(void)onClick:(id)sender{
    GaodeCustomButton *button=(GaodeCustomButton*)sender;
    if(button.clickBlock){
        button.clickBlock(button.identifier);
    }
}

@end
