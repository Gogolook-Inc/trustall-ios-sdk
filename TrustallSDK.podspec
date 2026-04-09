Pod::Spec.new do |s|
  s.name         = "TrustallSDK"
  s.version      = "1.0.0"
  s.summary      = "TrustallSDK"
  s.description  = "TrustallSDK iOS SDK"
  s.homepage     = "https://www.gogolook.com/"
  s.license      = { :type => 'Apache-2.0', :file => 'LICENSE' }
  s.author       = 'GOGOLOOK Co., Ltd.'

  s.ios.deployment_target = '16'
  s.swift_version = '5.9'

  s.source = { 
    :http => 'https://github.com/Gogolook-Inc/trustall-ios-sdk/releases/download/1.0.0/TrustallSDK.xcframework.zip',
    :sha256 => '0bb9e2d09f2a5e6f30e1d86ac80d1b6bbafb1c1c548fd043d3b5200f3f02ee13'
  }

  s.vendored_frameworks = 'TrustallSDK.xcframework'

  s.prepare_command = <<-CMD
    # Download the XCFramework
    curl -L -o TrustallSDK.xcframework.zip 'https://github.com/Gogolook-Inc/trustall-ios-sdk/releases/download/1.0.0/TrustallSDK.xcframework.zip'
    
    # Verify checksum
    echo "0bb9e2d09f2a5e6f30e1d86ac80d1b6bbafb1c1c548fd043d3b5200f3f02ee13  TrustallSDK.xcframework.zip" | shasum -a 256 -c || exit 1
    
    # Extract the XCFramework
    unzip -o TrustallSDK.xcframework.zip
    
    # Clean up
    rm -f TrustallSDK.xcframework.zip
  CMD
end