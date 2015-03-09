//
//  RefreshLayer.h
//  NSSTour
//
//  Created by 严道秋 on 15-3-4.
//  Copyright (c) 2015年 com.handsmap. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "HTRefreshDefine.h"

@interface RefreshLayer : CALayer

//主体颜色
@property (nonatomic,strong)UIColor *layerTintColor;
//阴影颜色
@property (nonatomic,strong)UIColor *layerShawodColor;
//外边框颜色
@property (nonatomic,strong)UIColor *skinColor;
//当前的状态
@property (nonatomic,assign)RefreshState refreshState;


//设置起点
@property (nonatomic,readonly)CGPoint startPoint;
//设置拉到的点
@property (nonatomic,readonly)CGPoint toPoint;

/*!
 *  @author 严道秋, 15-03-05 09:03:08
 *
 *  @brief  设置启动点
 *
 *  @param startPoint 点坐标
 *
 *  @since 1.0
 */
- (void)setStartPoint:(CGPoint)startPoint;


/*!
 *  @author 严道秋, 15-03-05 09:03:47
 *
 *  @brief  设置滑动点
 *
 *  @param toPoint 点坐标
 *
 *  @since 1.0
 */
- (void)setToPoint:(CGPoint)toPoint;


/*!
 *  @author 严道秋, 15-03-05 16:03:16
 *
 *  @brief  拉断开
 *
 *  @param target target
 *  @param action 执行函数
 *
 *  @since 1.0
 */
- (void)setPullApartTarget:(id)target
                    action:(SEL)action;
@end
