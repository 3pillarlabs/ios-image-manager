Pod::Spec.new do |s|
  s.name         = "ImageManager"
  s.version      = "1.0"
  s.summary      = "ImageManager"
  s.description  = "Image Manager is a Swift based iOS module that provides basic image manipulation features."
  s.homepage     = "https://github.com/3pillarlabs/ios-image-manager"
  s.license      = "MIT"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = "3Pillar Global"
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/3pillarlabs/ios-image-manager.git", :tag => "#{s.version}" }
  s.source_files  = "ImageManager", "ImageManager/**/*.{h,m}"
end
