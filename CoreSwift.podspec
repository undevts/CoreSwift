Pod::Spec.new do |spec|

  spec.name         = "CoreSwift"
  spec.version      = "0.1.2"
  spec.summary      = "A fundamental library for Swift programming."
  spec.homepage     = "https://github.com/undevts/CoreSwift"
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { "Nan Yang" => "qazyn951230@gmail.com" }

  spec.source       = { :git => "https://github.com/undevts/CoreSwift.git", :tag => spec.version.to_s }

  spec.static_framework = true
  spec.prefix_header_file = false

  spec.swift_version = "5.3"
  spec.ios.deployment_target = "9.0"
  spec.macos.deployment_target = "10.12"
  spec.tvos.deployment_target = "9.0"
  spec.watchos.deployment_target = "2.0"

  spec.pod_target_xcconfig = {
    "GCC_C_LANGUAGE_STANDARD" => "gnu11",
    "CLANG_CXX_LANGUAGE_STANDARD" => "gnu++17"
  }

  spec.default_subspec = "CoreCxx", "CoreSwift"

  spec.subspec 'CoreCxx' do |cs|
    cs.public_header_files = "Sources/CoreCxx/include/*.h"
    cs.source_files  = "Sources/CoreCxx/**/*.{h,cpp}"
  end

  spec.subspec 'CoreSwift' do |cs|
    cs.source_files  = "Sources/CoreSwift/**/*.swift"
  end

end
