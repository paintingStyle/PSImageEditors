<p align="center" >
  <img src="https://raw.github.com/PSImageEditors/Screenshot/logo.png" alt="PSImageEditors" title="PSImageEditors">
</p>


// https://raw.github.com/AFNetworking/AFNetworking/assets/afnetworking-logo.png
// https://raw.github.com/PSImageEditors/Screenshot/logo.png

# PSImageEditors
简而至美的一个图片编辑器
- 支持图片编辑，包括涂鸦，添加文字，添加马赛克，裁剪等功能

## 画笔
![image](https://raw.github.com/PSImageEditors/Screenshot/1.png)

## 文字（支持更换文字背景颜色）
![image](http://github.com/paintingStyle/PSImageEditors/raw/master/Screenshot/2.png)

## 马赛克（两种马赛克样式）
![image](http://github.com/paintingStyle/PSImageEditors/raw/master/Screenshot/3.png)

## 裁剪
![image](http://github.com/paintingStyle/PSImageEditors/raw/master/Screenshot/4.png)

## Requirements 要求
* iOS 8+
* Xcode 8+

## Installation 安装
### 1.手动安装:
`下载Demo后,将子文件夹PSImageEditors拖入到项目中, 导入头文件PSImageEditors.h开始使用,注意: 项目中需要有Masonry.1.1.0!`
### 2.CocoaPods安装:
`pod 'PSImageEditors'`
如果发现pod search PSImageEditors 不是最新版本，可在终端执行 pod repo update 更新本地仓库，更新完成重新搜索即可。

## Usage 使用方法

````
<key>NSAppTransportSecurity</key>
<dict>
<key>NSAllowsArbitraryLoads</key>
<true/>
</dict>
<key>NSCameraUsageDescription</key>
<string>App需要您的同意,才能访问相机</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>App需要您的同意,才能访问相册</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>App需要您的同意,才能访问相册</string>
````

## 使用方法

导入头文件 #import "PSImageEditors.h"

## 更新日志
```
• 2018.06.14(tag:0.1.0): 提交0.1.0版本
```
