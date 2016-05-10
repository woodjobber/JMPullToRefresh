//
//  UIScrollView+Direction.h
//  JuMei
//
//  Created by chengbin on 16/5/3.
//  Copyright © 2016年 Jumei Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JMPullToRefreshView;
typedef NS_ENUM(NSInteger, UIScrollViewDirection) {
    
    UIScrollViewDirectionNone,
    UIScrollViewDirectionRight,
    UIScrollViewDirectionLeft,
    UIScrollViewDirectionUp,
    UIScrollViewDirectionDown,
};

typedef void(^PullToRefreshActionHandler)(void);
typedef void (^UIScrollViewDirectionChangedBlock)(UIScrollViewDirection direction , CGPoint oldOffset, CGPoint newOffset);

@interface UIScrollView (Direction)

@property (readonly, nonatomic ,assign) UIScrollViewDirection horizontalScrollingDirection;

@property (readonly, nonatomic, assign) UIScrollViewDirection verticalScrollingDirection;

@property (readonly, nonatomic, assign) UIScrollViewDirection scrollViewDirection;

@property (strong, nonatomic, readonly) JMPullToRefreshView *pullToRefreshView;

@property (assign, nonatomic) CGFloat minOffsetToRefresh; //默认 -75.0f

@property (assign, nonatomic) BOOL showPullToRefresh; //是否需要下拉刷新功能.默认 YES

- (void)startObservingDirection:(UIScrollViewDirectionChangedBlock)direction;

- (void)startObservingDirection;

- (void)stopObservingDirection;

- (void)addPullToRefreshWithActionHandler:(PullToRefreshActionHandler)actionHandler showActivityIndicatoInView:(UIView *)superView postion:(CGRect)postion;

- (void)addPullToRefreshWithActionHandler:(PullToRefreshActionHandler)actionHandler showActivityIndicatoInView:(UIView *)superView;

@end


////////////////////////////////////////////////////////////////////////////////////////////////////////

typedef NS_ENUM(NSUInteger, JMPullToRefreshState){
    
    JMPullToRefreshViewStopped = 0,
    
    JMPullToRefreshViewLoading,

};

@interface JMPullToRefreshView : UIView

@property (assign, nonatomic,readonly) JMPullToRefreshState state;

- (void)startAnimation;

- (void)stopAnimation;

@end