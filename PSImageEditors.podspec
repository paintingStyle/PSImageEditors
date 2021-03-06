# pod trunk push PSImageEditors.podspec --allow-warnings --verbose

Pod::Spec.new do |s|
	
    s.name         = "PSImageEditors"
    s.version      = "0.2.5"
    s.summary      = "一个简而至美的图片编辑器"
    s.homepage     = "https://github.com/paintingStyle/PSImageEditors"
    s.license      = "MIT"
    s.author       = { "paintingStyle" => "sfdeveloper@163.com" }
    s.platform     = :ios,'8.0'
    s.source       = { :git => "https://github.com/paintingStyle/PSImageEditors.git", :tag => "#{s.version}" }
    s.source_files = "PSImageEditors/Classes/**/*.{h,m}"

    prefix_header_contents = <<-EOS
		#import <Masonry/Masonry.h>
    #import "PSImageEditorDefine.h"
		#import "UIImage+PSImageEditors.h"
    EOS
    s.prefix_header_contents = prefix_header_contents

    s.resource_bundles = {
        'PSImageEditors' => ['PSImageEditors/Assets/**/*']
    }

    s.framework    = "UIKit"
    s.dependency   'Masonry'
    s.dependency   "TOCropViewController"
    s.requires_arc = true
end
