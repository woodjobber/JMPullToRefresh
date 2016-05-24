//
//  UIScrollView+Direction.m
//  JuMei
//
//  Created by chengbin on 16/5/3.
//  Copyright © 2016年 Jumei Inc. All rights reserved.
//

#import "UIScrollView+DirectionAndPullToRefresh.h"
#import <objc/runtime.h>
#import "UIView+JM360Rotate.h"

@class JMPullToRefreshView;

static const void * horizontalScrollingDirectionKey      = &horizontalScrollingDirectionKey;
static const void * verticalScrollingDirectionKey        = &verticalScrollingDirectionKey;
static const void * scrollViewDirectiondKey              = &scrollViewDirectiondKey;
static const void * UISCrollViewDirectionChangedBlockKey = &UISCrollViewDirectionChangedBlockKey;
static const void * JMPullToRefreshViewKey               = &JMPullToRefreshViewKey;
static const void * UISCrollViewMinOffsetKey             = &UISCrollViewMinOffsetKey;
static const void * ShowPullToRefreshKey                 = &ShowPullToRefreshKey;


void *observerContext = "UIScrollViewDirection";

@interface UIScrollView ()

@property (assign ,nonatomic) UIScrollViewDirection horizontalScrollingDirection;

@property (assign ,nonatomic) UIScrollViewDirection verticalScrollingDirection;

@property (assign ,nonatomic) UIScrollViewDirection scrollViewDirection;

@property (strong ,nonatomic) JMPullToRefreshView *pullToRefreshView;

@end

/////////////////////////////////////////////////////////////////////////////////////

@interface JMPullToRefreshView ()

@property (assign, nonatomic) JMPullToRefreshState state;

@property (strong, nonatomic) UIImageView *circleImageView;

@property (copy, nonatomic) PullToRefreshActionHandler pullToRefreshActionHandler;

@property (assign, nonatomic) BOOL isRefreshing;

@property (copy, nonatomic) NSDate *lastFreshDate;

- (void)jm_startAnimationing;
- (void)jm_stopAnimationing;

@end


@implementation UIScrollView (Direction)

#pragma mark - Observing Direction

- (void)startObservingDirection:(UIScrollViewDirectionChangedBlock)direction {
  
    objc_setAssociatedObject(self, UISCrollViewDirectionChangedBlockKey, direction, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
   
    [self addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:observerContext];
}

- (void)startObservingDirection
{
    [self startObservingDirection:nil];
}

- (void)stopObservingDirection
{
    [self removeObserver:self forKeyPath:@"contentOffset"];
    objc_setAssociatedObject(self, UISCrollViewDirectionChangedBlockKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (![keyPath isEqualToString:@"contentOffset"]) return;
    
    if (context == observerContext) {
        
        CGPoint newContentOffset = [[change valueForKey:NSKeyValueChangeNewKey] CGPointValue];
        CGPoint oldContentOffset = [[change valueForKey:NSKeyValueChangeOldKey] CGPointValue];
        UIScrollViewDirectionChangedBlock changedBlock = objc_getAssociatedObject(self, UISCrollViewDirectionChangedBlockKey);
        
        if (oldContentOffset.x < newContentOffset.x) {
            self.horizontalScrollingDirection = UIScrollViewDirectionRight;
            self.scrollViewDirection = self.horizontalScrollingDirection;
        } else if (oldContentOffset.x > newContentOffset.x) {
            self.horizontalScrollingDirection = UIScrollViewDirectionLeft;
            self.scrollViewDirection = self.horizontalScrollingDirection;
        } else {
            self.horizontalScrollingDirection = UIScrollViewDirectionNone;
            self.scrollViewDirection = self.horizontalScrollingDirection;
        }
        
        if (oldContentOffset.y > newContentOffset.y) {
            self.verticalScrollingDirection = UIScrollViewDirectionDown;
            self.scrollViewDirection = self.verticalScrollingDirection;
        } else if (oldContentOffset.y < newContentOffset.y) {
            self.verticalScrollingDirection = UIScrollViewDirectionUp;
            self.scrollViewDirection = self.verticalScrollingDirection;
        } else {
             self.verticalScrollingDirection = UIScrollViewDirectionNone;
             self.scrollViewDirection = self.verticalScrollingDirection;
        }
       
        if (changedBlock) {
            changedBlock(self.scrollViewDirection, oldContentOffset,newContentOffset);
        }
        if (self.showPullToRefresh && self.pullToRefreshView) {
            [self jm_observePullToRefreshWithNewOffset:newContentOffset.y direction:self.scrollViewDirection];
        }
     
    }
    
}

#pragma mark - Properties For Direction

- (UIScrollViewDirection)horizontalScrollingDirection
{
    return [objc_getAssociatedObject(self, horizontalScrollingDirectionKey) integerValue];
}

- (void)setHorizontalScrollingDirection:(UIScrollViewDirection)horizontalScrollingDirection
{
    objc_setAssociatedObject(self, horizontalScrollingDirectionKey, [NSNumber numberWithInteger:horizontalScrollingDirection], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIScrollViewDirection)verticalScrollingDirection
{
    return [objc_getAssociatedObject(self, verticalScrollingDirectionKey) integerValue];
}

- (void)setVerticalScrollingDirection:(UIScrollViewDirection)verticalScrollingDirection
{
    objc_setAssociatedObject(self, verticalScrollingDirectionKey, [NSNumber numberWithInteger:verticalScrollingDirection], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIScrollViewDirection)scrollViewDirection {
    return [objc_getAssociatedObject(self, scrollViewDirectiondKey) integerValue];
}
- (void)setScrollViewDirection:(UIScrollViewDirection)scrollViewDirection {
    objc_setAssociatedObject(self, scrollViewDirectiondKey, [NSNumber numberWithInteger:scrollViewDirection], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


#pragma mark - Pull To Refresh

- (void)addPullToRefreshWithActionHandler:(PullToRefreshActionHandler)actionHandler showActivityIndicatoInView:(UIView *)superView postion:(CGRect)postion {
    if (!self.pullToRefreshView) {
        [self startObservingDirection];
        JMPullToRefreshView *view = [[JMPullToRefreshView alloc]initWithFrame:postion];
        if (superView) {
             [superView addSubview:view];
        }else {
             [self addSubview:view];
        }
        view.pullToRefreshActionHandler = actionHandler;
        self.pullToRefreshView = view;
        self.showPullToRefresh = YES;
        self.minOffsetToRefresh = -75.0f;
    }
}

- (void)addPullToRefreshWithActionHandler:(PullToRefreshActionHandler)actionHandler showActivityIndicatoInView:(UIView *)superView {
    [self addPullToRefreshWithActionHandler:actionHandler showActivityIndicatoInView:superView postion:CGRectMake(29.0f, 27.0f, 24.0f, 24.0f)];
}


- (void)jm_observePullToRefreshWithNewOffset:(CGFloat)Offset direction:(UIScrollViewDirection)direction {
    
   __weak __typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof (weakSelf) strongSelf = weakSelf;
        if (Offset >= 0.0f) {
            strongSelf.pullToRefreshView.isRefreshing = NO;
        }
        
        if (Offset <= self.minOffsetToRefresh && direction == UIScrollViewDirectionDown) {
            if (strongSelf.pullToRefreshView.isRefreshing || [self jm_preventRepeatRefresh]) {
                return;
            }
            strongSelf.pullToRefreshView.state = JMPullToRefreshViewLoading;
        }
    });

}

- (BOOL)jm_preventRepeatRefresh {
    if (!self.pullToRefreshView.lastFreshDate) {
        
       self.pullToRefreshView.lastFreshDate = [[NSDate alloc]init];
        
    }else {
        CGFloat value = [[NSDate date] timeIntervalSinceDate:self.pullToRefreshView.lastFreshDate] ;
        
        if (value < 2.5f && value > 0) {
            return YES;
        }else {
            self.pullToRefreshView.lastFreshDate = [[NSDate alloc]init];
        }
    }
    return NO;
}
- (void)setPullToRefreshView:(JMPullToRefreshView *)pullToRefreshView {
    [self willChangeValueForKey:@"pullToRefreshView"];
    
    objc_setAssociatedObject(self, JMPullToRefreshViewKey, pullToRefreshView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self didChangeValueForKey:@"pullToRefreshView"];
}

- (JMPullToRefreshView *)pullToRefreshView {
  
    return objc_getAssociatedObject(self, JMPullToRefreshViewKey);
}


- (void)setShowPullToRefresh:(BOOL)showPullToRefresh {
    objc_setAssociatedObject(self, ShowPullToRefreshKey, @(showPullToRefresh), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)showPullToRefresh {
    
    return [objc_getAssociatedObject(self, ShowPullToRefreshKey) boolValue];
}

- (void)setMinOffsetToRefresh:(CGFloat)minOffsetToRefresh {
    
  objc_setAssociatedObject(self, UISCrollViewMinOffsetKey, @(minOffsetToRefresh), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)minOffsetToRefresh {
    
  return [objc_getAssociatedObject(self, UISCrollViewMinOffsetKey) floatValue];
}

@end


@implementation JMPullToRefreshView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self jm_setup];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {

    if (self = [super initWithCoder:aDecoder]) {
       [self jm_setup];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self jm_setup];
    }
    
    return self;
}

- (void)jm_setup {
    self.backgroundColor = [UIColor clearColor];
    self.hidden = YES;
    [self.circleImageView.layer removeAllAnimations];
    self.state = JMPullToRefreshViewStopped;
    self.isRefreshing = NO;
}

- (UIImageView *)circleImageView {
    if (!_circleImageView) {
        _circleImageView = ({
            UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
            [imgView setImage:[UIImage imageNamed:@"Circle"]];
            [self addSubview:imgView];
            imgView;
        });
    }
    
    return _circleImageView;
}
- (void)startAnimation {
    [self jm_startAnimationing];
}
- (void)jm_startAnimationing {
    self.state = JMPullToRefreshViewLoading;
}

- (void)stopAnimation {
    [self jm_stopAnimationing];
}
- (void)jm_stopAnimationing {
   self.state = JMPullToRefreshViewStopped;
}

- (void)jm_start360RotateAnimation{
  self.hidden = NO;
  [self setNeedsDisplay];
  self.isRefreshing = YES;
  [self.circleImageView jm_360RotateWithDuration:1.0f repeatCount:INFINITY timingMode:JM360RotateTimingModeLinear];
}


-(void)setState:(JMPullToRefreshState)state {
    
    if (_state == state) {return;}
    _state = state;

    switch (state) {
        case JMPullToRefreshViewStopped: {
            __weak __typeof(self) weakSelf = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                __strong __typeof(weakSelf) strongSelf = weakSelf;
                strongSelf.hidden = YES;
                [self setNeedsDisplay];
                [strongSelf.circleImageView.layer removeAllAnimations];
            });

            break;
        }
            
        case JMPullToRefreshViewLoading: {
           
            [self performSelectorOnMainThread:@selector(jm_start360RotateAnimation) withObject:nil waitUntilDone:NO modes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
            if (self.pullToRefreshActionHandler) {
                self.pullToRefreshActionHandler();
            }
            
            break;
        }
    
    }
}

@end




