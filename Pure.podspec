Pod::Spec.new do |s|
  s.name             = "Pure"
  s.version          = "0.1.0"
  s.summary          = "Pure DI for Swift"
  s.homepage         = "https://github.com/devxoul/Pure"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = { "Suyeol Jeon" => "devxoul@gmail.com" }
  s.source           = { :git => "https://github.com/devxoul/Pure.git",
                         :tag => s.version.to_s }
  s.source_files = "Sources/**/*.{swift,h,m}"

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.11"
  s.tvos.deployment_target = "9.0"
  s.watchos.deployment_target = "2.0"
end
