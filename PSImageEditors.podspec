Pod::Spec.new do |s|

s.name         = "PSImageEditors"
s.version      = "0.1.0"
s.summary      = "一个简而至美的图片编辑器"

s.homepage     = "https://github.com/paintingStyle/PSImageEditors"
s.license      = "MIT"
s.author       = { "paintingStyle" => "sfdeveloper@163.com" }
s.platform     = :ios,'8.0'

s.source       = { :git => "https://github.com/paintingStyle/PSImageEditors.git", :tag => "#{s.version}" }
s.source_files = "PSImageEditors/**/*.{h,m}"

prefix_header_contents = <<-EOS
#import "PSImageEditorsDefine.h"
EOS
s.prefix_header_contents = prefix_header_contents

s.resource_bundles = {
	'PSImageEditors' => ['SPPersonalCardModule/Resources/**/*']
}

s.framework    = "UIKit"
s.dependency   "SDWebImage"
s.dependency   "SDWebImage/GIF"
s.dependency   "FLAnimatedImage"
s.requires_arc = true

end
