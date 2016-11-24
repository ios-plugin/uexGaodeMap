//
//  GaodeCACalloutTextBox.m
//  EUExGaodeMap
//
//  Created by lkl on 15/7/9.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//

#import "CustomView.h"
#import "GaodeUtility.h"
#define kArrowHeight 8
@interface CustomView()
@property(nonatomic,assign)CGFloat mainWidth;
@property(nonatomic,assign)CGFloat margin;
@property(nonatomic,assign)CGFloat distance;
@property(nonatomic,strong)UIColor *bgColor;
@property(nonatomic,strong)UIColor *shadowColor;
@property(nonatomic,assign)CGFloat shadowOffsetX;
@property(nonatomic,assign)CGFloat shadowOffsetY;
@property(nonatomic,assign)CGFloat shadowRadius;

@property(nonatomic,strong)UILabel *titleView;
@property(nonatomic,strong)UIColor *titleColor;
@property(nonatomic,strong)UIFont *titleFont;
@property(nonatomic,copy)NSString *titleStr;

@property(nonatomic,strong)UILabel *textView;
@property(nonatomic,strong)UIColor *textColor;
@property(nonatomic,strong)UIFont *textFont;
@property(nonatomic,copy)NSString *textStr;


@end


@implementation CustomView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.


- (void)drawRect:(CGRect)rect {
    [self drawInContext:UIGraphicsGetCurrentContext()];
    
    //设置阴影
    self.layer.shadowColor = self.shadowColor.CGColor;
    self.layer.shadowOpacity = 1.0;
    self.layer.shadowRadius=self.shadowRadius;
    self.layer.shadowOffset = CGSizeMake(self.shadowOffsetX, self.shadowOffsetY);
}
- (void)drawInContext:(CGContextRef)context {
    CGContextSetLineWidth(context, 2.0);
    CGContextSetFillColorWithColor(context, self.bgColor.CGColor);
    CGRect rrect = self.bounds;
    CGFloat radius = 6.0;
    CGFloat minx = CGRectGetMinX(rrect),
    midx = CGRectGetMidX(rrect),
    maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect),
    maxy = CGRectGetMaxY(rrect)-kArrowHeight;
    CGContextMoveToPoint(context, midx+kArrowHeight, maxy);
    CGContextAddLineToPoint(context,midx, maxy+kArrowHeight);
    CGContextAddLineToPoint(context,midx-kArrowHeight, maxy);
    CGContextAddArcToPoint(context, minx, maxy, minx, miny, radius);
    CGContextAddArcToPoint(context, minx, minx, maxx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, maxx, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextClosePath(context);
    CGContextFillPath(context);
}





- (void)initSubViews {
    CGRect titleRect = [self sizeWithString:self.titleStr Font:self.titleFont];
    CGFloat textWidth = 0.f;
    CGRect textRect;
    if (![self.textStr isEqualToString:@""]) {
        textRect =  [self sizeWithString:self.textStr Font:self.textFont];
        textWidth = textRect.size.width;
    }
    
    CGFloat titleWidth = titleRect.size.width;
   
    self.mainWidth=titleWidth >= textWidth ? titleWidth : textWidth;
    CGFloat minWidth = titleWidth <= textWidth ? titleWidth : textWidth;
    
    
    //设置title
    NSMutableAttributedString *title=[[NSMutableAttributedString alloc]initWithString:self.titleStr];
    [title setAttributes:@{NSForegroundColorAttributeName:self.titleColor,NSFontAttributeName:self.titleFont} range:NSMakeRange(0, [title length])];
    self.titleView=[[UILabel alloc] init];
    self.titleView.attributedText=title;
    
    self.titleView.backgroundColor=[UIColor clearColor];
    self.titleView.lineBreakMode=NSLineBreakByWordWrapping;
    self.titleView.numberOfLines=0;
    self.titleView.lineBreakMode=NSLineBreakByCharWrapping;
    CGSize titleSize = [self sizeWithString:self.titleStr width:self.mainWidth Font:self.titleFont];
    if (titleWidth>=textWidth) {
        self.titleView.frame = CGRectMake(_margin, _distance,titleSize.width,titleSize.height);
    } else {
        self.titleView.frame = CGRectMake(_margin+(self.mainWidth-minWidth)/2, _distance,titleSize.width,titleSize.height);
    }
    
    
    self.titleView.textAlignment = NSTextAlignmentCenter;
    //self.titleView.backgroundColor = [UIColor redColor];
    
     [self addSubview:self.titleView];
    //设置text
    if (![self.textStr isEqualToString:@""]) {
        NSMutableAttributedString *text=[[NSMutableAttributedString alloc]initWithString:self.textStr];
        [text setAttributes:@{NSForegroundColorAttributeName:self.textColor,NSFontAttributeName:self.textFont} range:NSMakeRange(0, [text length])];
        self.textView=[[UILabel alloc]init];
        self.textView.attributedText=text;
        self.textView.textAlignment = NSTextAlignmentCenter;
        self.textView.backgroundColor=[UIColor clearColor];
        self.textView.lineBreakMode=NSLineBreakByWordWrapping;
        self.textView.numberOfLines=0;
        self.textView.frame=CGRectMake(_margin, _distance+self.titleView.frame.size.height,self.mainWidth,textRect.size.height);
        //self.textView.backgroundColor = [UIColor greenColor];
        self.bounds=CGRectMake(0, 0, self.mainWidth+2*_margin, _distance*3+2*self.titleView.frame.size.height);
        //self.backgroundColor=[UIColor blackColor];
         [self addSubview:self.textView];
    }else{
        self.bounds=CGRectMake(0, 0, self.mainWidth+2*_margin, 4+self.titleView.frame.size.height+kArrowHeight);
    }
    
    
    
    
    
    
   
   
    [self setNeedsDisplay];
    
    
    
    
    
}

-(CGRect)sizeWithString:(NSString *)str Font:(UIFont*)font{
    CGSize maxSize = CGSizeMake(MAXFLOAT, CGFLOAT_MAX);
    CGRect rect=[str boundingRectWithSize:maxSize options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesFontLeading  |NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font}  context:nil];
    return rect;
}
-(CGSize)sizeWithString:(NSString *)str  width:(CGFloat)width Font:(UIFont*)font{
    CGSize maxSize = CGSizeMake(width, CGFLOAT_MAX);
    CGRect rect=[str boundingRectWithSize:maxSize options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesFontLeading  |NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font}  context:nil];
    return rect.size;
}

-(CGRect)calculateSizeWithFont:(NSInteger)Font Width:(NSInteger)Width Height:(NSInteger)Height Text:(NSString *)Text
{
    CGRect size;
    NSDictionary *attr = @{NSFontAttributeName : [UIFont systemFontOfSize:Font]};
    size= [Text boundingRectWithSize:CGSizeMake(Width, Height)
                             options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin
                          attributes:attr
                             context:nil];
    return size;
}

-(BOOL)loadData{
    self.margin=5.f;
    self.distance =2.0f;
    __block BOOL result=YES;
    NSError* empty=nil;
    if(![self.dataDict isKindOfClass:[NSDictionary class]]) return NO;
    
    if(empty) return NO;
    self.bgColor=[self getColorForKey:@"bgColor" ifEmpty:nil];
    self.shadowRadius=[self getFloatForKey:@"shadowRadius" ifEmpty:nil];
    self.shadowOffsetX=[self getFloatForKey:@"shadowOffsetX" ifEmpty:nil];
    self.shadowOffsetY=[self getFloatForKey:@"shadowOffsetY" ifEmpty:nil];
    self.shadowColor=[self getColorForKey:@"shadowColor" ifEmpty:nil];
    self.titleStr=[self getStringForKey:@"titleContent" ifEmpty:^{result = NO;}];
    self.titleFont=[UIFont systemFontOfSize:[self getFloatForKey:@"titleFontSize" ifEmpty:^{result = NO;}]];
    self.titleColor=[self getColorForKey:@"titleColor" ifEmpty:^{result = NO;}];
    self.textStr=[self getStringForKey:@"textContent" ifEmpty:nil];
    self.textFont=[UIFont systemFontOfSize:[self getFloatForKey:@"textFontSize" ifEmpty:nil]];
    self.textColor=[self getColorForKey:@"textColor" ifEmpty:nil];
    
    if(!result) return NO;
    [self initSubViews];
    //self.backgroundColor=self.bgColor;
    self.backgroundColor=[UIColor clearColor];
    return YES;
}

-(UIColor *)getColorForKey:(NSString*)key ifEmpty:(void (^)(void))block{
    if([self.dataDict objectForKey:key]&&[[self.dataDict objectForKey:key] isKindOfClass:[NSString class]]){
        return [GaodeUtility UIColorFromHTMLStr:[self.dataDict objectForKey:key]];
    }else{
        if(block) block();
        return [UIColor clearColor];
    }
}
-(CGFloat)getFloatForKey:(NSString*)key ifEmpty:(void (^)(void))block{
    if([self.dataDict objectForKey:key]){
        return [[self.dataDict objectForKey:key] floatValue];
    }else{
        if(block) block();
        
        return 0;
    }
}

-(NSString*)getStringForKey:(NSString*)key ifEmpty:(void (^)(void))block{
    if([self.dataDict objectForKey:key]&&[[self.dataDict objectForKey:key] isKindOfClass:[NSString class]]){
        return [self.dataDict objectForKey:key];
    }else{
        if(block) block();
        return nil;
    }
}

@end
