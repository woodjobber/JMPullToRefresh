# JMPullToRefresh
简单的下拉刷新-- pull to refresh
# 如何使用
```
//使用下面两个接口
- (void)addPullToRefreshWithActionHandler:(PullToRefreshActionHandler)actionHandler showActivityIndicatoInView:(UIView *)superView postion:(CGRect)postion;

- (void)addPullToRefreshWithActionHandler:(PullToRefreshActionHandler)actionHandler showActivityIndicatoInView:(UIView *)superView;
//例子
 __weak __typeof(self) weakSelf = self;
    [self.tableView addPullToRefreshWithActionHandler:^{
        __strong __typeof(weakSelf) strongSelf = self;
        [strongSelf insertRowAtTop];
    } showActivityIndicatoInView:self.topTabBar];
 

```
//刷新完成后调用 

```
- (void)stopAnimation;
```
# 效果图
![image](https://github.com/woodjobber/JMPullToRefresh/blob/master/jmpulltorefresh.gif)

![image](https://github.com/woodjobber/JMPullToRefresh/blob/master/jmpulltorefresh_exp.gif)

