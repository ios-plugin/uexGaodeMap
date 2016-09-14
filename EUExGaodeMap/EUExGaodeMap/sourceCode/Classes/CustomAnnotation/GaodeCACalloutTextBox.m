//
//  GaodeCACalloutTextBox.m
//  EUExGaodeMap
//
//  Created by lkl on 15/7/9.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//

#import "GaodeCACalloutTextBox.h"
@interface GaodeCACalloutTextBox()
@property(nonatomic,assign)CGFloat mainWidth;
@property(nonatomic,assign)CGFloat margin;

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


@implementation GaodeCACalloutTextBox


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
    [self getDrawPath:context];
    CGContextFillPath(context);
}





- (void)initSubViews {
    CGFloat innerWidth=self.mainWidth-2*self.margin;
    

    //设置title
    NSMutableAttributedString *title=[[NSMutableAttributedString alloc]initWithString:self.titleStr];
    [title setAttributes:@{NSForegroundColorAttributeName:self.titleColor,NSFontAttributeName:self.titleFont} range:NSMakeRange(0, [title length])];
    //CGFloat titleHeight=[self sizeWithString:title width:innerWidth options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesFontLeading  |NSStringDrawingUsesLineFragmentOrigin].height;
    CGFloat titleHeight=self.titleFont.pointSize*0.9f;
    self.titleView=[[UILabel alloc] init];
    self.titleView.attributedText=title;
    self.titleView.backgroundColor=[UIColor clearColor];
    self.titleView.numberOfLines=1;
    self.titleView.lineBreakMode=NSLineBreakByTruncatingTail;
    self.titleView.frame=CGRectMake(_margin, _margin, innerWidth, titleHeight);

    
    //设置text

    NSMutableAttributedString *text=[[NSMutableAttributedString alloc]initWithString:self.textStr];
    [text setAttributes:@{NSForegroundColorAttributeName:self.textColor,NSFontAttributeName:self.textFont} range:NSMakeRange(0, [text length])];
    NSArray *textArray=[text.string componentsSeparatedByString:@"\n"];
    NSInteger lineNum=[textArray count];
    CGFloat textHeight=0.f;
    for(int i=0;i<lineNum;i++){
        textHeight =textHeight+[self sizeWithString:textArray[i] width:innerWidth options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesFontLeading  |NSStringDrawingUsesLineFragmentOrigin].height+2;
    }
    //CGFloat textHeight=[self sizeWithString:title width:innerWidth options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesFontLeading  |NSStringDrawingUsesLineFragmentOrigin].height*lineNum;
    //CGFloat textHeight=self.textFont.pointSize*lineNum*0.9f;
    self.textView=[[UILabel alloc]init];
    self.textView.attributedText=text;
    self.textView.backgroundColor=[UIColor clearColor];
    self.textView.lineBreakMode=NSLineBreakByWordWrapping;
    self.textView.numberOfLines=0;
    self.textView.frame=CGRectMake(_margin, _margin+titleHeight,innerWidth,textHeight);
    //[self addSubview:self.textView];

    
    self.bounds=CGRectMake(0, 0, self.mainWidth, _margin*4+textHeight+titleHeight);
    
    self.backgroundColor=[UIColor blackColor];


    

    
    [self addSubview:self.titleView];
    [self addSubview:self.textView];
    [self setNeedsDisplay];
    
    

    
    
}

-(CGSize)sizeWithString:(NSString *)str  width:(CGFloat)width options:(NSStringDrawingOptions)opt{
    CGSize maxSize = CGSizeMake(width, CGFLOAT_MAX);
    CGRect rect=[str boundingRectWithSize:maxSize options:opt attributes:@{NSFontAttributeName:self.textFont}  context:nil];
    return rect.size;
}


-(BOOL)loadData{
    self.margin=5.f;
    __block BOOL result=YES;
    NSError* empty=nil;
    if(![self.dataDict isKindOfClass:[NSDictionary class]]) return NO;

    self.mainWidth=[self getFloatForKey:@"width" ifEmpty:^{result = NO;}];
    if(empty) return NO;
    self.bgColor=[self getColorForKey:@"bgColor" ifEmpty:nil];
    self.shadowRadius=[self getFloatForKey:@"shadowRadius" ifEmpty:nil];
    self.shadowOffsetX=[self getFloatForKey:@"shadowOffsetX" ifEmpty:nil];
    self.shadowOffsetY=[self getFloatForKey:@"shadowOffsetY" ifEmpty:nil];
    self.shadowColor=[self getColorForKey:@"shadowColor" ifEmpty:nil];
    self.titleStr=[self getStringForKey:@"titleContent" ifEmpty:^{result = NO;}];
    self.titleFont=[UIFont systemFontOfSize:[self getFloatForKey:@"titleFontSize" ifEmpty:^{result = NO;}]];
    self.titleColor=[self getColorForKey:@"titleColor" ifEmpty:^{result = NO;}];
    self.textStr=[self getStringForKey:@"textContent" ifEmpty:^{result = NO;}];
    self.textFont=[UIFont systemFontOfSize:[self getFloatForKey:@"textFontSize" ifEmpty:^{result = NO;}]];
    self.textColor=[self getColorForKey:@"textColor" ifEmpty:^{result = NO;}];
    if(!result) return NO;
    [self initSubViews];
    //self.backgroundColor=self.bgColor;
    self.backgroundColor=[UIColor clearColor];
    return YES;
}



@end
