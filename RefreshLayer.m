//
//  RefreshLayer.m
//  NSSTour
//
//  Created by 严道秋 on 15-3-4.
//  Copyright (c) 2015年 com.handsmap. All rights reserved.
//

#import "RefreshLayer.h"
@interface RefreshLayer ()
{
    id  _target;
    SEL     _action;
}

@end
@implementation RefreshLayer

- (instancetype)initWithLayer:(id)layer
{
    if (self = [super initWithLayer:layer])
    {
        if ([layer isKindOfClass:[RefreshLayer class]])
        {
            RefreshLayer *otherLayer = layer;
            self.layerShawodColor = otherLayer.layerShawodColor;
            self.layerTintColor = otherLayer.layerTintColor;
            self.skinColor = otherLayer.skinColor;
            
            self.toPoint = self.startPoint = CGPointMake(self.frame.size.width / 2,
                                                 self.frame.size.height / 2);
        }
    }
    return self;
}

+ (BOOL)needsDisplayForKey:(NSString *)key
{
    if ([key isEqualToString:@"loading"])
    {
        return YES;
    }
    else
    {
        return [super needsDisplayForKey:key];
    }
}


- (void)setStartPoint:(CGPoint)startPoint
{
    if (CGPointEqualToPoint(self.startPoint, startPoint))
    {
        return;
    }
    if (_refreshState == STATE_DEFAULT)
    {
        _startPoint = startPoint;
        [self setNeedsDisplay];
    }
}

- (void)setToPoint:(CGPoint)toPoint
{
    if (CGPointEqualToPoint(self.toPoint, toPoint))
    {
        return;
    }
    if (_refreshState == STATE_DEFAULT)
    {
        _toPoint = toPoint;
        [self setNeedsDisplay];
    }
}


- (void)setPullApartTarget:(id)target
                    action:(SEL)action
{
    _target = target;
    _action = action;
}

- (void)drawInContext:(CGContextRef)ctx
{
    switch (self.refreshState)
    {
        case STATE_DEFAULT:
        {
            CGFloat percent = 1 - distansBetween(self -> _startPoint , self -> _toPoint) / kVISCOUS;
             if (percent == 1)
             {
                 UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(self -> _startPoint.x - kRADIUS, self -> _startPoint.y - kRADIUS, 2 * kRADIUS, 2 * kRADIUS) cornerRadius:kRADIUS];
                 
                 [self setContext:ctx path:path];
                 CGContextDrawPath(ctx, kCGPathFillStroke);
             }
             else
             {
                 //正在被拉伸,但是还没有达到加载的长度
                 CGFloat startRadius = kRADIUS * (kSTARTTO + (1 - kSTARTTO)*percent);
                 CGFloat endRadius = kRADIUS * (kENDTO + (1 - kENDTO)*percent);
                 UIBezierPath *path = [self bodyPath:startRadius
                                                 end:endRadius
                                             percent:percent];
                 
                 [self setContext:ctx path:path];
                 CGContextDrawPath(ctx, kCGPathFillStroke);
                 if (percent <= 0)
                 {
                     self.refreshState = STATE_SHORTENING;
                     
                     #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                     if(_action && _target)
                     {
                         [_target performSelector:_action withObject:self];
                     }
                     
                     #pragma clang diagnostic pop
                     [self performSelector:@selector(scaling)
                                withObject:nil
                                afterDelay:kAnimationInterval
                                   inModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
                 }
             }
            break;
        }
        case STATE_SHORTENING:
        {
            _toPoint = CGPointMake((self->_toPoint.x - self->_startPoint.x) * 0.8 + self->_startPoint.x,
                                   (self->_toPoint.y - self->_startPoint.y) * 0.8 + self->_startPoint.y);
            CGFloat p = distansBetween(self->_startPoint, self->_toPoint) / kVISCOUS;
            CGFloat percent = 1 -p;
            CGFloat r = kRADIUS * p;
            if (p > 0.01)
            {
                CGFloat startRadius = r * (kSTARTTO + (1-kSTARTTO)*percent);
                
                CGFloat endRadius = r * (kENDTO + (1-kENDTO)*percent) * (1+percent / 2);
                UIBezierPath *path = [self bodyPath:startRadius
                                                end:endRadius
                                            percent:percent];
                [self setContext:ctx path:path];
                CGContextDrawPath(ctx, kCGPathFillStroke);
            }
            else
            {
//                [self needsDisplay];
                self.refreshState = STATE_MISS;
            }

            break;
        }
        default:
            break;
    }
}

- (void)setContext:(CGContextRef)context path:(UIBezierPath *)path
{
    if (self.layerShawodColor)
    {
        CGContextSetShadowWithColor(context, CGSizeZero, 1.0f, self.layerShawodColor.CGColor);
    }
    CGContextSetFillColorWithColor(context, self.layerTintColor.CGColor);
    CGContextFillPath(context);
    
    CGContextSetLineWidth(context, 1.5f);
    CGContextSetStrokeColorWithColor(context, self.skinColor.CGColor);
    
    CGContextAddPath(context, path.CGPath);
}

- (UIBezierPath*)bodyPath:(CGFloat)startRadius end:(CGFloat)endRadius percent:(float)percent
{
    UIBezierPath *path = [[UIBezierPath alloc] init];
    
    float angle1 = M_PI/3 + (M_PI / 6 /*M_PI/2 - M_PI/3*/) * percent;
    
    CGPoint sp1 = pointLineToArc(_startPoint, _toPoint,
                                 angle1, startRadius),
    sp2 = pointLineToArc(_startPoint, _toPoint,
                         -angle1, startRadius),
    ep1 = pointLineToArc(_toPoint, _startPoint,
                         M_PI/2, endRadius),
    ep2 = pointLineToArc(_toPoint, _startPoint,
                         -M_PI/2, endRadius);
    
#define kMiddleP    0.6
    CGPoint mp1 = CGPointMake(sp2.x*kMiddleP + ep1.x*(1-kMiddleP), sp2.y*kMiddleP + ep1.y*(1-kMiddleP)),
    mp2 = CGPointMake(sp1.x*kMiddleP + ep2.x*(1-kMiddleP), sp1.y*kMiddleP + ep2.y*(1-kMiddleP)),
    mm = CGPointMake((mp1.x + mp2.x)/2, (mp1.y + mp2.y)/2);
    float p = distansBetween(mp1, mp2) / 2 / endRadius * (0.9 + percent/10);
    mp1 = CGPointMake((mp1.x - mm.x)/p + mm.x, (mp1.y - mm.y)/p + mm.y);
    mp2 = CGPointMake((mp2.x - mm.x)/p + mm.x, (mp2.y - mm.y)/p + mm.y);
    
    [path moveToPoint:sp1];
    float angleS = atan2f(_toPoint.y - _startPoint.y,
                          _toPoint.x - _startPoint.x);
    [path addArcWithCenter:_startPoint
                    radius:startRadius
                startAngle:angleS + angle1
                  endAngle:angleS + M_PI*2 - angle1
                 clockwise:YES];
    [path addQuadCurveToPoint:ep1
                 controlPoint:mp1];
    angleS = atan2f(_startPoint.y - _toPoint.y,
                    _startPoint.x - _toPoint.x);
    [path addArcWithCenter:_toPoint
                    radius:endRadius
                startAngle:angleS + M_PI/2
                  endAngle:angleS + M_PI*3/2
                 clockwise:YES];
    [path addQuadCurveToPoint:sp1
                 controlPoint:mp2];
    
    return path;
}

- (void)scaling
{
    if (self->_refreshState == STATE_SHORTENING)
    {

        [self setNeedsDisplay];
        [self performSelector:@selector(scaling)
                   withObject:nil
                   afterDelay:kAnimationInterval
                      inModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
    }
}
- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    if (!hidden)
    {
        self.transform = CATransform3DIdentity;
        [self setNeedsDisplay];
    }
}
- (void)setState:(RefreshState)state
{
    _refreshState = state;
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(scaling)
                                               object:nil];
}
- (void)dealloc
{
    self.layerShawodColor = nil;
    self.layerTintColor = nil;
}
@end
