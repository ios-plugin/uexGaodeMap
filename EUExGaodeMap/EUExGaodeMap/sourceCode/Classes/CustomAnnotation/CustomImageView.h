//
//  CustomImageView.h
//  EUExGaodeMap
//
//  Created by wang on 16/8/8.
//  Copyright © 2016年 AppCan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EUExGaodeMap;
@interface CustomImageView : UIImageView
@property(nonatomic,strong) EUExGaodeMap *uexObj;
@property(nonatomic,strong) NSString *identifier;
@end
