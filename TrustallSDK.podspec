Pod::Spec.new do |s|
  s.name         = "TrustallSDK"
  s.version      = "1.1.5"
  s.summary      = "TrustallSDK"
  s.description  = "TrustallSDK iOS SDK"
  s.homepage     = "https://www.gogolook.com/"
  s.license      = { :type => 'Apache-2.0', :file => 'LICENSE' }
  s.author       = 'GOGOLOOK Co., Ltd.'

  s.ios.deployment_target = '16'
  s.swift_version = '5.9'

  s.source = { 
    :http => 'https://github.com/Gogolook-Inc/trustall-ios-sdk/releases/download/1.1.5/TrustallSDK.xcframework.zip',
    :sha256 => '22e08ca429c33a5df362e5d291dff6a1416156f0a96794bbdbc3dfbb91c16a23'
  }

  s.vendored_frameworks = 'TrustallSDK.xcframework'

  s.prepare_command = <<-CMD
    # Download the XCFramework
    curl -L -o TrustallSDK.xcframework.zip 'https://github.com/Gogolook-Inc/trustall-ios-sdk/releases/download/1.1.5/TrustallSDK.xcframework.zip'
    
    # Verify checksum
    echo "22e08ca429c33a5df362e5d291dff6a1416156f0a96794bbdbc3dfbb91c16a23  TrustallSDK.xcframework.zip" | shasum -a 256 -c || exit 1
    
    # Extract the XCFramework
    unzip -o TrustallSDK.xcframework.zip
    
    # Clean up
    rm -f TrustallSDK.xcframework.zip
  CMD
end