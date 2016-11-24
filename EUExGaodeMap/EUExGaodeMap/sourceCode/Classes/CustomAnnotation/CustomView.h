//
//  CustomView.h
//  EUExGaodeMap
//
//  Created by wang on 16/11/24.
//  Copyright © 2016年 AppCan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomView : UIView
@property(nonatomic,strong)NSDictionary *dataDict;
-(BOOL)loadData;
@end
