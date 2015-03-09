//
//  HTRefreshDefine.h
//  NSSTour
//
//  Created by 严道秋 on 15-3-4.
//  Copyright (c) 2015年 com.handsmap. All rights reserved.
//


//拉伸长度
#define kVISCOUS    55.0f
//最大半径
#define kRADIUS     13.0f

#define kSTARTTO    0.7f
#define kENDTO      0.15f

//高度
#define kHeight     32.0f

#define kAnimationInterval  (1.0f/50.0f)

//开始刷新
typedef void (^StartRefreshBlock)();

NS_INLINE CGFloat distansBetween(CGPoint p1 , CGPoint p2)
{
    return sqrtf((p1.x - p2.x)*(p1.x - p2.x) + (p1.y - p2.y)*(p1.y - p2.y));
}

NS_INLINE CGPoint pointLineToArc(CGPoint center, CGPoint p2, float angle, CGFloat radius)
{
    float angleS = atan2f(p2.y - center.y, p2.x - center.x);
    float angleT = angleS + angle;
    float x = radius * cosf(angleT);
    float y = radius * sinf(angleT);
    return CGPointMake(x + center.x, y + center.y);
}
typedef NS_ENUM(NSUInteger, RefreshState)
{
    //初始化状态
    STATE_DEFAULT = 0,
    //缩短
    STATE_SHORTENING,
    //消失
    STATE_MISS,
};






