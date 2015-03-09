//
//  HTRefreshControl.m
//  NSSTour
//
//  Created by 严道秋 on 15-3-4.
//  Copyright (c) 2015年 com.handsmap. All rights reserved.
//

#import "HTRefreshControl.h"

@interface HTRefreshControl ()

@property (nonatomic,strong)UIScrollView *scrollView;

@property (nonatomic,strong)StartRefreshBlock block;


//变量
//拖拽的时候 临时记录上一次的长度
@property (nonatomic,assign)CGFloat oldLength;
//是否断开了
@property (nonatomic,assign)BOOL apart;


@end
@implementation HTRefreshControl

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [self initVars];

    return self;
}

/*!
 *  @author 严道秋, 15-03-04 16:03:51
 *
 *  @brief  初始化属性
 *
 *  @since 1.0
 */
- (instancetype)initVars
{
    CGRect frame =  CGRectMake(0, -kHeight, CGRectGetWidth([UIScreen mainScreen].bounds), kHeight);
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        //默认主体颜色
        self.tintColor = [UIColor blackColor];
        //默认阴影色
        self.shawodColor = [UIColor darkGrayColor];
        //默认外边框色
        self.skinColor = [UIColor whiteColor];
        
        //添加 中间图标
        UIImage *refreshImage = [UIImage imageNamed:@"sr_refresh"];
        _refleshView = [[UIImageView alloc] initWithImage:refreshImage];
        _refleshView.center = CGPointMake(self.frame.size.width / 2,
                                          self.frame.size.height / 2);
        _refleshView.bounds = CGRectMake(0.0f, 0.0f, refreshImage.size.width * 0.7, refreshImage.size.height * 0.7);
        [self addSubview:_refleshView];
        
        _activityIndicatorView = [[UIActivityIndicatorView alloc]
                                  initWithActivityIndicatorStyle:
                                  UIActivityIndicatorViewStyleGray];
        [_activityIndicatorView stopAnimating];
        _activityIndicatorView.center = _refleshView.center;
        [self addSubview:_activityIndicatorView];
        
    }
    return self;
}


- (void)addRefreshControl:(UIScrollView *)view
         withRefreshBlock:(StartRefreshBlock)statrtRefreshBlock
{
    [view addSubview:self];
    RefreshLayer *layer = (RefreshLayer*)self.layer;
    
    [layer setStartPoint:CGPointMake(self.frame.size.width / 2,
                                     self.frame.size.height / 2)];
    [layer setToPoint:CGPointMake(self.frame.size.width / 2,
                                     self.frame.size.height / 2)];
    [layer setPullApartTarget:self action:@selector(pullApart:)];
    _block = statrtRefreshBlock;
}


- (void)pullApart:(RefreshLayer **)refreshLayer
{
    //拉断了
    self.apart = YES;
    self.loading = YES;
    //回调
    if (self.block)
    {
        self.block();
    }
}

- (void)setLoading:(BOOL)loading
{
    if (_loading == loading)
    {
        return;
    }
    self->_loading = loading;
//    RefreshLayer *layer = (RefreshLayer*)self.layer;
    if (_loading)
    {
        [self.activityIndicatorView startAnimating];
        CAKeyframeAnimation *aniamtion = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        
        aniamtion.values = [NSArray arrayWithObjects:
                            [NSValue valueWithCATransform3D:
                             CATransform3DRotate(CATransform3DMakeScale(0.01, 0.01, 0.1),
                                                 -M_PI, 0, 0, 1)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.6, 1.6, 1)],
                            [NSValue valueWithCATransform3D:CATransform3DIdentity],nil];
        aniamtion.keyTimes = [NSArray arrayWithObjects:
                              [NSNumber numberWithFloat:0],
                              [NSNumber numberWithFloat:0.6],
                              [NSNumber numberWithFloat:1], nil];
        aniamtion.timingFunctions = [NSArray arrayWithObjects:
                                     [CAMediaTimingFunction functionWithName:
                                      kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:
                                      kCAMediaTimingFunctionEaseInEaseOut],
                                     nil];
        aniamtion.duration = 0.7;
        self.activityIndicatorView.layer.transform = CATransform3DIdentity;
        [self.activityIndicatorView.layer addAnimation:aniamtion
                                            forKey:@""];
        self.refleshView.hidden = YES;
        if (!self.scrollView.isDragging)
        {
            UIEdgeInsets inset = _scrollView.contentInset;
            inset.top = self->_topInset + kHeight;
            _scrollView.contentInset = inset;
        }
    }
    else
    {
        [self.activityIndicatorView stopAnimating];
        
        self.refleshView.hidden = NO;
        self.refleshView.layer.transform = CATransform3DIdentity;
        
        [UIView transitionWithView:self->_scrollView
                          duration:0.3f
                           options:UIViewAnimationOptionCurveEaseOut
                        animations:^{
                            UIEdgeInsets inset = _scrollView.contentInset;
                            inset.top = self->_topInset;
                            self.scrollView.contentInset = inset;
                            if (self.scrollView.contentOffset.y == - self->_topInset)
                            {
                                
                            }
                        } completion:^(BOOL finished)
                        {
                            //_notSetFrame = NO;
                        }];
        
    }
}


- (void)refreshDidScroll
{
    RefreshLayer *layer = (RefreshLayer*)self.layer;
    //取滑动量
    CGPoint point = self->_scrollView.contentOffset;
    CGRect rect = self.frame;
    
    if (point.y <= - kHeight - self->_topInset)
    {
        rect.origin.y = point.y + self->_topInset;
        rect.size.height = - point.y;
        rect.size.height = ceilf(rect.size.height);
        self.frame = rect;
        
        //当前正在loading 不做处理
        if (!self->_loading)
        {
            [layer setNeedsDisplay];
        }
         //判断当前是否给拉断了
        if (!self->_apart)
        {
            float length = - (point.y + kHeight + self->_topInset);
            if(length <= self->_oldLength)
            {
                length = MIN(distansBetween(layer.startPoint, layer.toPoint), length);
                CGPoint ssp = layer.startPoint;
                layer.toPoint = CGPointMake(ssp.x, ssp.y + length);
                CGFloat pf = (1.0f-length/kVISCOUS) * (1.0f-kSTARTTO) + kSTARTTO;
                self.refleshView.layer.transform = CATransform3DMakeScale(pf, pf, 1);
            }
            else if (self->_scrollView.isDragging)
            {
                CGPoint ssp = layer.startPoint;
                layer.toPoint = CGPointMake(ssp.x, ssp.y + length);
                CGFloat pf = (1.0f-length/kVISCOUS) * (1.0f-kSTARTTO) + kSTARTTO;
                self.refleshView.layer.transform = CATransform3DMakeScale(pf, pf, 1);
            }
            _oldLength = length;
        }
        if (self.alpha != 1.0f) self.alpha = 1.0f;
    }
    else if(point.y < - _topInset)
    {
        rect.origin.y = -kHeight;
        rect.size.height = kHeight;
        self.frame = rect;
        [layer setNeedsDisplay];
        layer.toPoint = layer.startPoint;
    }
}

- (void)refreshDidEndDraging
{
    if (_apart)
    {
        if (self.loading)
        {
            [UIView transitionWithView:_scrollView
                              duration:0.2
                               options:UIViewAnimationOptionCurveEaseOut
                            animations:^{
                                UIEdgeInsets inset = _scrollView.contentInset;
                                inset.top = _topInset + kHeight;
                                _scrollView.contentInset = inset;
                            } completion:^(BOOL finished)
                            {
                                self.apart = NO;
                            }];
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.2f];
            [UIView commitAnimations];
            

        }
        else
        {
            [self performSelector:@selector(setApart:)
                       withObject:nil afterDelay:0.2];
            self.loading = NO;
        }
    }
    
}

- (void)endRefreshing
{
    //结束刷新
    RefreshLayer *layer = (RefreshLayer*)self.layer;
    if (self->_loading)
    {
        layer.toPoint = layer.startPoint;
        
        [UIView transitionWithView:self->_activityIndicatorView duration:0.3f options:UIViewAnimationOptionCurveEaseIn animations:^{
            self->_activityIndicatorView.layer.transform = CATransform3DRotate(CATransform3DMakeScale(0.01f, 0.01f, 0.1f), -M_PI, 0, 0, 1);
        } completion:^(BOOL finished)
        {
            self.loading = NO;
            self->_oldLength = 0;
            layer.refreshState = STATE_DEFAULT;
        }];
    }
    else
    {
        self.loading = NO;
        self->_oldLength = 0;
        layer.refreshState = STATE_DEFAULT;
    }
    
    
}

- (void)drawRect:(CGRect)rect
{
    RefreshLayer *layer = (RefreshLayer*)self.layer;
    [layer drawInContext:UIGraphicsGetCurrentContext()];
}


- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    if ([self.superview isKindOfClass:[UIScrollView class]])
    {
        self.scrollView = (UIScrollView*)self.superview;
        CGRect rect = self.frame;
        rect.origin.y = -kHeight;
        rect.size.width = CGRectGetWidth([UIScreen mainScreen].bounds);
        self.frame = rect;
        UIEdgeInsets inset = self->_scrollView.contentInset;
        inset.top = self->_topInset;
        _scrollView.contentInset = inset;
    }
    else
    {
        NSLog(@"Error,HTRefreshControl just support scrollView");
    }
}

+ (Class)layerClass
{
    return [RefreshLayer class];
}

- (UIColor *)skinColor
{
    RefreshLayer *layer = (RefreshLayer*)self.layer;
    return layer.skinColor;
}

- (void)setSkinColor:(UIColor *)skinColor
{
    RefreshLayer *layer = (RefreshLayer*)self.layer;
    layer.skinColor = skinColor;
}

- (UIColor *)tintColor
{
    RefreshLayer *layer = (RefreshLayer*)self.layer;
    return layer.layerTintColor;
}

- (void)setTintColor:(UIColor *)tintColor
{
    NSAssert(tintColor != nil, @"Error,tintColor can not be null");
    RefreshLayer *layer = (RefreshLayer*)self.layer;
    layer.layerTintColor = tintColor;
}

- (UIColor *)shawodColor
{
    RefreshLayer *layer = (RefreshLayer*)self.layer;
    return layer.layerShawodColor;
}

- (void)setShawodColor:(UIColor *)shawodColor
{
    NSAssert(shawodColor != nil, @"Error,shawodColor can not be null");
    RefreshLayer *layer = (RefreshLayer*)self.layer;
    layer.layerShawodColor = shawodColor;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    RefreshLayer *layer = (RefreshLayer*)self.layer;
    if (layer)
    {
        if (layer.refreshState == STATE_DEFAULT)
        {
            layer.frame = frame;
            layer.startPoint = CGPointMake(frame.size.width / 2, kHeight / 2);
        }
        _refleshView.center = layer.startPoint;
        _activityIndicatorView.center = layer.startPoint;
    }

}
- (void)setTopInset:(CGFloat)topInset
{
    _topInset = topInset;
}

- (void)dealloc
{
    self.shawodColor = nil;
    self.tintColor = nil;
}
@end
