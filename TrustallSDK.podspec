Pod::Spec.new do |s|
  s.name         = "TrustallSDK"
  s.version      = "0.7.2"
  s.summary      = "TrustallSDK"
  s.description  = "TrustallSDK iOS SDK"
  s.homepage     = "https://www.gogolook.com/"
  s.license      = { :type => 'Apache-2.0', :file => 'LICENSE' }
  s.author       = 'GOGOLOOK Co., Ltd.'

  s.ios.deployment_target = '16'
  s.swift_version = '5.9'

  s.source = { 
    :http => 'https://github.com/Gogolook-Inc/trustall-ios-sdk/releases/download/0.7.2/TrustallSDK.xcframework.zip',
    :sha256 => 'aad610cf6a176d664ef7de6d45d99694bf3c36366291f71676375f75c51e910d'
  }

  s.vendored_frameworks = 'TrustallSDK.xcframework'

  s.prepare_command = <<-CMD
    # Download the XCFramework
    curl -L -o TrustallSDK.xcframework.zip 'https://github.com/Gogolook-Inc/trustall-ios-sdk/releases/download/0.7.2/TrustallSDK.xcframework.zip'
    
    # Verify checksum
    echo "aad610cf6a176d664ef7de6d45d99694bf3c36366291f71676375f75c51e910d  TrustallSDK.xcframework.zip" | shasum -a 256 -c || exit 1
    
    # Extract the XCFramework
    unzip -o TrustallSDK.xcframework.zip
    
    # Clean up
    rm -f TrustallSDK.xcframework.zip
  CMD
end