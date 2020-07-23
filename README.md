<p align="center" >
<img src="https://upload-images.jianshu.io/upload_images/4490624-904c1ed2a18ab850.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240.png" alt="PSImageEditors" title="PSImageEditors">
</p>

# PSImageEditors（简而至美的一个图片编辑器 ）
开源一个图片编辑组件，样式参照微信与钉钉的图片编辑效果，支持包括涂鸦，添加文字，添加马赛克，裁剪等功能，内部线上项目已使用此组件。

## 功能
- 画笔
![1.jpg](https://upload-images.jianshu.io/upload_images/4490624-933bcfcb7fa9568d.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 文字（支持更换文字背景颜色）
![2.jpg](https://upload-images.jianshu.io/upload_images/4490624-11568807eed88d2c.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![3.jpg](https://upload-images.jianshu.io/upload_images/4490624-a81108912887243d.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 马赛克（两种马赛克样式）
![4.jpg](https://upload-images.jianshu.io/upload_images/4490624-230458e6f237b8e3.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 裁剪
![5.jpg](https://upload-images.jianshu.io/upload_images/4490624-72123212cd454a56.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## Installation 安装
### 1，手动安装
`下载Demo后,将子文件夹PSImageEditors拖入到项目中, 导入头文件PSImageEditors.h开始使用,注意: 项目中需要有Masonry.1.1.0!`
### 2，CocoaPods安装
`pod 'PSImageEditors'`
如果发现pod search PSImageEditors 不是最新版本，可在终端执行 pod repo update 更新本地仓库，更新完成重新搜索即可。

### 3，导入头文件 #import "PSImageEditors.h"

````
UIImage *image = [UIImage imageNamed:@"localImage_06@2x.jpg"];
PSImageEditor *imageEditor = [[PSImageEditor alloc] initWithImage:image
													 delegate:self
												   dataSource:self];
[self.navigationController pushViewController:imageEditor animated:YES];
````

### 4，PSImageEditorDelegate
````
#pragma mark - PSImageEditorDelegate

- (void)imageEditor:(PSImageEditor *)editor didFinishEdittingWithImage:(UIImage *)image {
	self.imageView.image = image;
	[editor dismiss];
	NSLog(@"%s",__func__);
}

- (void)imageEditorDidCancel {
	NSLog(@"%s",__func__);
}
````

### 5，参数设置
````
#pragma mark - PSImageEditorDelegate

- (UIColor *)imageEditorDefaultColor {
    return [UIColor redColor];
}

- (PSImageEditorMode)imageEditorDefalutEditorMode {
	return PSImageEditorModeDraw;
}

- (CGFloat)imageEditorDrawPathWidth {
    return 5;
}

- (UIFont *)imageEditorTextFont {
	return [UIFont boldSystemFontOfSize:24];
}
````


## Requirements 要求
* iOS 8+
* Xcode 8+

## 更新日志
```
- 2018.06.14 (tag:0.1.0)：提交0.1.0版本
- 2020.07.16 (tag:0.2.0): 修复编辑图片模糊的问题，UI更新
- 2020.07.23 (tag:0.2.1): 增加默认选中编辑选项功能
```

