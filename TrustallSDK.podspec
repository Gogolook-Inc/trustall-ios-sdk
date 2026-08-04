Pod::Spec.new do |s|
  s.name         = "TrustallSDK"
  s.version      = "1.1.9"
  s.summary      = "TrustallSDK"
  s.description  = "TrustallSDK iOS SDK"
  s.homepage     = "https://www.gogolook.com/"
  s.license      = { :type => 'Apache-2.0', :file => 'LICENSE' }
  s.author       = 'GOGOLOOK Co., Ltd.'

  s.ios.deployment_target = '16'
  s.swift_version = '5.9'

  s.source = { 
    :http => 'https://github.com/Gogolook-Inc/trustall-ios-sdk/releases/download/1.1.9/TrustallSDK.xcframework.zip',
    :sha256 => 'f5b4f878d3b011e922ec44545291c2b948b5cc2b5c4449108fef8bb6affd08bf'
  }

  s.vendored_frameworks = 'TrustallSDK.xcframework'

  s.prepare_command = <<-CMD
    # Download the XCFramework
    curl -L -o TrustallSDK.xcframework.zip 'https://github.com/Gogolook-Inc/trustall-ios-sdk/releases/download/1.1.9/TrustallSDK.xcframework.zip'
    
    # Verify checksum
    echo "f5b4f878d3b011e922ec44545291c2b948b5cc2b5c4449108fef8bb6affd08bf  TrustallSDK.xcframework.zip" | shasum -a 256 -c || exit 1
    
    # Extract the XCFramework
    unzip -o TrustallSDK.xcframework.zip
    
    # Clean up
    rm -f TrustallSDK.xcframework.zip
  CMD
end