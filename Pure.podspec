Pod::Spec.new do |s|
  s.name             = "Pure"
  s.version          = "1.1.3"
  s.summary          = "Pure DI for Swift"
  s.homepage         = "https://github.com/devxoul/Pure"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = { "Suyeol Jeon" => "devxoul@gmail.com" }
  s.source           = { :git => "https://github.com/devxoul/Pure.git",
                         :tag => s.version.to_s }
  s.swift_version    = "5.0"

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.11"
  s.tvos.deployment_target = "9.0"
  s.watchos.deployment_target = "2.0"

  s.default_subspec = "Core"

  s.subspec "Core" do |ss|
    ss.source_files = "Sources/Pure/**/*.{swift,h,m}"
  end

  s.subspec "Stub" do |ss|
    ss.source_files = "Sources/PureStub/**/*.{swift,h,m}"
    ss.dependency "Pure/Core"
  end
end
