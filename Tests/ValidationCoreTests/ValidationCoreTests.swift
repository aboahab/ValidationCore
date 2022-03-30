import Foundation
import Quick
import Nimble
import OHHTTPStubsSwift
import OHHTTPStubs
import XCTest
import ValidationCore


class ValidationCoreSpec: QuickSpec {
    
    override func spec() {
        describe("Compatibility Test") {
            
            var validationCore : ValidationCore!
            let testDataProvider : TestDataProvider! = TestDataProvider()
            
            for testData in testDataProvider.testData {
                it(testData.testContext.description) {
                    let dateService = TestDateService(testData)
                    let trustlistService = TestTrustlistService(testData, dateService: dateService)
                    validationCore = ValidationCore(trustlistService: trustlistService, dateService: dateService)
                    guard let prefixedEncodedCert = testData.prefixed else {
                        XCTFail("QR code payload missing")
                        return
                    }
                    validationCore.validate(encodedData: prefixedEncodedCert) { result in
                        if let error = result.error {
                            self.map(error, to: testData.expectedResults)
                        } else {
                            self.map(result, to: testData)
                        }
                    }
                }
            }
        }
        
        describe("Functionality Test") {
            var validationCore: ValidationCore!
            let testDataProvider : TestDataProvider! = TestDataProvider()
            
            it("can verify signature using X509TrustlistService") {
                let testData = testDataProvider.x509TestData
                let dateService = TestDateService(testData)
                let keyId = Data([172, 54, 144, 238, 131, 97, 204, 150])
                let signatureCerts = [keyId:testData.testContext.signingCertificate!]
                let x509TrustService = X509TrustlistService(base64Encoded: signatureCerts, dateService: dateService)
                validationCore = ValidationCore(trustlistService: x509TrustService, dateService: dateService)
                validationCore.validate(encodedData: testData.prefixed!) { result in
                    expect(result.error).toEventually(beNil())
                }
            }
            
            it("does not crash on malformed payload") {
                let testData = testDataProvider.malformedCoseInTestData
                let dateService = TestDateService(testData)
                let trustlistService = TestTrustlistService(testData, dateService: dateService)
                validationCore = ValidationCore(trustlistService: trustlistService, dateService: dateService)
                validationCore.validate(encodedData: testData.prefixed!) { result in
                    expect(result.error).toEventually(beError(ValidationError.COSE_DESERIALIZATION_FAILED))
                }
            }
        }
        
        describe("Austrian Exemption Test") {
            var validationCore: ValidationCore!
            let testDataProvider: ExemptionTestDataProvider! = ExemptionTestDataProvider()
            
            it("can verify signature of valid exemption") {
                let testData = testDataProvider.validVe
                let dateService = TestDateService(testData)
                let trustlistService = TestTrustlistService(testData, dateService: dateService)
                validationCore = ValidationCore(trustlistService: trustlistService, dateService: dateService)
                validationCore.validateExemption(encodedData: testData.prefixed!) { result in
                    expect(result.isValid).toEventually(beTrue())
                    expect(result.error).toEventually(beNil())
                }
            }
            
            it("does not verify invalid signature") {
                let testData = testDataProvider.invalidSignedVe
                let dateService = TestDateService(testData)
                let trustlistService = TestTrustlistService(testData, dateService: dateService)
                validationCore = ValidationCore(trustlistService: trustlistService, dateService: dateService)
                validationCore.validateExemption(encodedData: testData.prefixed!) { result in
                    expect(result.isValid).toEventually(beFalse())
                    expect(result.error).toEventually(beError(.UNSUITABLE_PUBLIC_KEY_TYPE))
                }
            }
            
            it("does not verify invalid signature") {
                let testData = testDataProvider.invalidVeWithoutKey
                let dateService = TestDateService(testData)
                let keyId = Data([72, 208, 143, 36, 68, 105, 165, 177, 200])
                let trustlistService = X509TrustlistService(base64Encoded: [keyId:testData.testContext.signingCertificate!], dateService: dateService, enableValidityChecks: false)
                validationCore = ValidationCore(trustlistService: trustlistService, dateService: dateService)
                validationCore.validateExemption(encodedData: testData.prefixed!) { result in
                    expect(result.isValid).toEventually(beFalse())
                    expect(result.error).toEventually(beError(.KEY_NOT_IN_TRUST_LIST))
                }
            }
            
            context("does not deserialize") {
                it("entries containing multiple vaccination exemptions") {
                    let testData = testDataProvider.invalidMultipleVe
                    let dateService = TestDateService(testData)
                    let trustlistService = TestTrustlistService(testData, dateService: dateService)
                    validationCore = ValidationCore(trustlistService: trustlistService, dateService: dateService)
                    validationCore.validateExemption(encodedData: testData.prefixed!) { result in
                        expect(result.isValid).toEventually(beFalse())
                        expect(result.error).toEventually(beError(.CBOR_DESERIALIZATION_FAILED))
                    }
                }
                
                it("entries containing austrian vaccination exemption and vaccination/recovery/test") {
                    let testData = testDataProvider.invalidMixedVe
                    let dateService = TestDateService(testData)
                    let trustlistService = TestTrustlistService(testData, dateService: dateService)
                    validationCore = ValidationCore(trustlistService: trustlistService, dateService: dateService)
                    validationCore.validateExemption(encodedData: testData.prefixed!) { result in
                        expect(result.isValid).toEventually(beFalse())
                        expect(result.error).toEventually(beError(.CBOR_DESERIALIZATION_FAILED))
                    }
                }
                
                
                it("HC1 containing austrian vaccination exemption") {
                    let testData = testDataProvider.invalidHc1SignedWithAtCert
                    let dateService = TestDateService(testData)
                    let trustlistService = TestTrustlistService(testData, dateService: dateService)
                    validationCore = ValidationCore(trustlistService: trustlistService, dateService: dateService)
                    validationCore.validateExemption(encodedData: testData.prefixed!) { result in
                        expect(result.isValid).toEventually(beFalse())
                        expect(result.error).toEventually(beError(.INVALID_SCHEME_PREFIX))
                    }
                }
                
            }
            
        }
    }
    
    private func map(_ validationResult: ValidationResult, to testData: EuTestData){
        let expectedResults = testData.expectedResults
        if true == expectedResults.isSchemeValidatable {
            expect(validationResult.greenpass).to(beHealthCert(testData.jsonContent))
        }
        
        if let verifiable = expectedResults.isVerifiable {
            expect(validationResult.isValid == verifiable).to(beTrue())
        }
    }
    
    private func map(_ error: ValidationError, to expectedResults: ExpectedResults){
        if false == expectedResults.isUnprefixed {
            expect(error).to(beError(.INVALID_SCHEME_PREFIX))
        }
        if false == expectedResults.isBase45Decodable {
            expect(error).to(beError(.BASE_45_DECODING_FAILED))
        }
        if false == expectedResults.isExpired {
            expect(error).to(beError(.CWT_EXPIRED))
        }
        if false == expectedResults.isVerifiable {
            expect(error).to(satisfyAnyOf(beError(.COSE_DESERIALIZATION_FAILED), beError(.SIGNATURE_INVALID)))
        }
        if false == expectedResults.isDecodable {
            expect(error).to(beError(.CBOR_DESERIALIZATION_FAILED))
        }
        if false == expectedResults.isKeyUsageMatching {
            expect(error).to(beError(.UNSUITABLE_PUBLIC_KEY_TYPE))
        }
    }
    
}
