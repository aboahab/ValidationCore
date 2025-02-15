Pod::Spec.new do |spec|

    spec.name         = "ValidationCore"
    spec.version      = "0.0.1"
    spec.summary      = "Validating EHN health certificates from QR codes"
    spec.description  = <<-DESC
  Core functionality for validating EHN health certificates from QR codes. Suitable QR codes can be generated using https://dev.a-sit.at/certservice
  Implements a very basic validation chain:
  - Decode Base45-encoded QR code
  - Remove scheme prefix
  - Decompress with ZLib
  - Verify COSE signature
                     DESC
  
    spec.homepage     = "https://github.com/aboahab/ValidationCore"
    spec.license      = "Apache License"
    spec.authors            = { "abanob boles" => "abanob.boles@itsv.at" }
    spec.ios.deployment_target = "12.0"
    spec.swift_version = '5.0'
    spec.source       = { :git => "https://github.com/aboahab/ValidationCore.git", :tag => "#{spec.version}" }
    spec.source_files  = "Sources/**/*.{swift}"
    spec.dependency "SwiftCBOR"
    spec.dependency "GzipSwift"
    spec.dependency "base45-swift"
    spec.dependency "ASN1Decoder"
  end