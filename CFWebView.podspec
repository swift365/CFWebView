Pod::Spec.new do |s|
s.name = 'CFWebView'
s.version = '0.1.1'  #此处为pod search 的版本
s.license= { :type => "MIT", :file => "LICENSE" }
s.summary = 'CFWebView is a Swift module for adding extension to uiview.'
s.homepage = 'https://github.com/swift365/CFWebView'
s.authors = { 'chengfei.heng' => 'hengchengfei@sina.com' }
s.source = { :git => 'https://github.com/swift365/CFWebView.git', :tag => "0.1.1"  }#tag指向的版本号，切记要先保证git服务器上，已经有此tag。
s.ios.deployment_target = '9.0' #支持的版本号
s.source_files = "CFWebView/Classes/*.swift", "CFWebView/Classes/**/*.swift"  #包含的source文件
# s.frameworks = 'UIKit', 'MapKit'
end
