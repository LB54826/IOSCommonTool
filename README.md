# IOSCommonTool
iOS实用的UI控件，显示内容可完全自定义，Banner,TanTanCard,SuperLink,WaterFlow,瀑布流,自定义Banner,高仿探探左滑右滑卡片,超链接和富文本

# 自定义Banner
1、支持横向或竖向滚动切换，支持淡入淡出动效切换
2、支持高度/宽度（横向时高度自适应，竖向时宽度自适应）跟随内容自适应变化，也可设置为固定宽高
3、支持设置自定义样式的指示器，指示器位置也支持横向显示或者竖向显示，指示器位置也可自定义设置

# 高仿探探卡片左滑右滑动效（LikeTanTanCardView）
1、卡片和卡片之间的间隙（即左右缩进去的距离和底部露出的距离或者上部露出的距离）
2、卡片突出的方向
3、卡片圆角
4、移动的灵敏度（卡片宽度一半的百分比，越小灵敏度越高，默认是 1.0 / 3.0），即移动卡片宽度一半的百分之多少后，一松手，卡片则消失
5、卡片是否只支持水平向左或水平向右划走，即移动卡片时是否需要没有旋转动效
6、显示卡片上内容时是否需要渐变动画
7、设置卡片阴影样式

# 自定义瀑布流（LBCollectionViewLayout）
1、支持设置分组
2、支持设置每一组的header和footer
3、支持设置某一组的header是否悬停
4、支持设置某一组的某一个item是否全屏显示
5、支持自定义某一组的header和footer单独的padding
6、支持设置具体某一组item之间的间隙

# 超链接（TextViewForSuperLinkTool）和富文本（NSObject+Tool中的#pragma mark - 富文本相关）
1、支持设置不同的样式和字体
2、支持设置行间距
3、支持设置NSLineBreakMode
4、支持设置NSTextAlignment
5、支持设置NSUnderlineStyle下划线样式
