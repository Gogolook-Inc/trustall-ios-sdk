Pod::Spec.new do |s|
  s.name         = "TrustallSDK"
  s.version      = "2.0.3"
  s.summary      = "TrustallSDK"
  s.description  = "TrustallSDK iOS SDK"
  s.homepage     = "https://www.gogolook.com/"
  s.license      = { :type => 'Apache-2.0', :file => 'LICENSE' }
  s.author       = 'GOGOLOOK Co., Ltd.'

  s.ios.deployment_target = '16'
  s.swift_version = '5.9'

  s.source = { 
    :http => 'https://github.com/Gogolook-Inc/trustall-ios-sdk/releases/download/2.0.3/TrustallSDK.xcframework.zip',
    :sha256 => 'ff622403b51d82e6d250269cb0025e2d549d4058ea25af95ec2df0fb202a4ccc'
  }

  s.vendored_frameworks = 'TrustallSDK.xcframework'

  s.prepare_command = <<-CMD
    # Download the XCFramework
    curl -L -o TrustallSDK.xcframework.zip 'https://github.com/Gogolook-Inc/trustall-ios-sdk/releases/download/2.0.3/TrustallSDK.xcframework.zip'
    
    # Verify checksum
    echo "ff622403b51d82e6d250269cb0025e2d549d4058ea25af95ec2df0fb202a4ccc  TrustallSDK.xcframework.zip" | shasum -a 256 -c || exit 1
    
    # Extract the XCFramework
    unzip -o TrustallSDK.xcframework.zip
    
    # Clean up
    rm -f TrustallSDK.xcframework.zip
  CMD
end