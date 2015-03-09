//
//  HTRefreshControl.h
//  NSSTour
//
//  Created by 严道秋 on 15-3-4.
//  Copyright (c) 2015年 com.handsmap. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RefreshLayer.h"



@interface HTRefreshControl : UIView

//UI
//中间图标
@property (nonatomic,strong,readonly)UIImageView *refleshView;
//奔跑的菊花
@property (nonatomic,strong,readonly)UIActivityIndicatorView *activityIndicatorView;


//是否刷新中
@property (nonatomic,assign,readonly) BOOL loading;


//主体颜色
@property (nonatomic,strong)UIColor *tintColor UI_APPEARANCE_SELECTOR;
//阴影色
@property (nonatomic,strong)UIColor *shawodColor UI_APPEARANCE_SELECTOR;
//外边框颜色
@property (nonatomic,strong)UIColor *skinColor UI_APPEARANCE_SELECTOR;
//显示的文字
@property (nonatomic,retain) NSAttributedString *attributedTitle UI_APPEARANCE_SELECTOR;
//Top内距
@property (nonatomic,assign)CGFloat topInset UI_APPEARANCE_SELECTOR;

/*!
 *  @author 严道秋, 15-03-04 17:03:52
 *
 *  @brief  监听滑动事件
 *
 *  @param statrtRefreshBlock 处理请求
 *
 *  @since 1.0
 */

- (void)addRefreshControl:(UIScrollView*)view
         withRefreshBlock:(StartRefreshBlock)statrtRefreshBlock;


/*!
 *  @author 严道秋, 15-03-05 15:03:11
 *
 *  @brief  拖拽调用 - (void)scrollViewDidScroll:(UIScrollView *)scrollView
 *
 *  @since 1.0
 */
- (void)refreshDidScroll;

/*!
 *  @author 严道秋, 15-03-05 15:03:56
 *
 *  @brief  结束调用 - (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
 *
 *  @since 1.0
 */
- (void)refreshDidEndDraging;

/*!
 *  @author 严道秋, 15-03-04 17:03:56
 *
 *  @brief  手动结束刷新(注意:当前是否正在加载中，否则调用无效)
 *
 *  @since 1.0
 */
- (void)endRefreshing;
@end
