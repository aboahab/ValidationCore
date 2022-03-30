//
//  TestDataProvider.swift
//  
//
//  Created by Dominik Mocher on 16.04.21.
//

import Foundation
import ValidationCore

class TestDataProvider {
    var testData = [EuTestData]()
    let malformedCoseInTestData = EuTestData(jsonContent: nil, cborHex: nil, coseHex: nil, base45EncodedAndCompressed: nil, prefixed:    "HC1:K:3N01000000J00TW2HM7YUOL43K$CXAD090%S02T1 7W-1WN5HW8AXFU7FHICK17FE238AP8 N.S2U129V37DOBT1SD2288UNO8123IC6Y9/.QOL601A*5E:5TC39PWEH$T8UF43VBEJWX1SD9U9RLAQGUBHYNXW37R0-IAD*P LFD2D-8KDNPAGEYS1PTN.ACYB9.HCYN0WR05.M+UR9J18$V.KDLM2I:E/DHS55FO37HS. S75N38VCX1HGNLV408JD.HD.DE3E/KLSTG%XPHHLDC4Q2K+$40*BQ5C/PA48DJMRZIECVF+OV%E4GBMLUR940*42QHQGP9$GV..BGUIRIF09M%-JB1GWX8QU2OBW8V2V+LCLKPFDB%2Y-2CWJYYDTCDAXE. KIKLNZD-2VX00X34V%CH4EENC1103OAZ+9+FMDOQOBJ+0765LDW7.-VD.OLOG5BC7KNL%89%F6TQRZJUXPD254I0ADBF.C0JLA.5SDNE S/KPW5EX8Q6Y3Q3WLCELBJDVQG-O*NDQ7QB30C*OPRQV5000", base64BarcodeImage: nil, testContext: TestContext(version: nil, schemaVersion: nil, signingCertificate: nil, validationClock: nil, description: ""), expectedResults: ExpectedResults(isValidObject: nil, isSchemeValidatable: nil, isEncodable: nil, isDecodable: nil, isVerifiable: nil, isUnprefixed: nil, isValidJson: nil, isBase45Decodable: nil, isImageDecodable: nil, isExpired: nil, isKeyUsageMatching: nil))
    
    init(){
        testData = loadTestdata()
        addAdditionalTests()
    }
    
   private func loadTestdata() -> [EuTestData] {
        var fileContents = [EuTestData]()
        let decoder = jsonTestDecoder()
        let url = Bundle.module.bundleURL.appendingPathComponent("Testdata")
        if let dirContent = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isDirectoryKey]) {
            for dir in dirContent.filter({ path in (try? path.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true }) {
                if let jsonFiles = try? FileManager.default.contentsOfDirectory(at: dir.appendingPathComponent("/2DCode/raw"), includingPropertiesForKeys: nil) {
                    let countryPrefix = dir.lastPathComponent
                    for file in jsonFiles.filter({ path in path.lastPathComponent.hasSuffix("json")}) {
                        if let content = FileManager.default.contents(atPath: file.path) {
                            do {
                                let filename = file.lastPathComponent.split(separator: ".")[0]
                                var testData = try decoder.decode(EuTestData.self, from: content)
                                testData.testContext.description = "\(countryPrefix)-\(filename)-\(testData.testContext.description)"
                                fileContents.append(testData)
                            } catch (let error) {
                                print("Parsing error in file \(file.path): \(error)")
                            }
                        }
                    }
                }
            }
        }
        return fileContents
    }
    
    private func addAdditionalTests() {
        if let additionalTests = decodeTests(from: additionalTestData) {
            self.testData.append(contentsOf: additionalTests)
        }
    }

    func decodeTests(from jsonText: String) -> [EuTestData]? {
    if let data = jsonText.data(using: .utf8) {
        return try? jsonTestDecoder().decode([EuTestData].self, from: data)
    }
    return nil
}
    
    let additionalTestData = """
[{
                "PREFIX": "HC1:6BF%RN%TSMAHN-HVUOEJPJ-QNT3BNN0II4WFC9B:OQW.7LQCCJ9T$U+OCDTU--M:UC*GP-S4FT5D75W9AAABE34L/5R3FMIA5.BR9E+-C2+86LF4MH7DANI94JBTC96FM:3DK196LFGD9+PBLTL8KES/F-1JZ.KDKL6JKX2M0ECGGBYPLR-S:G10EQ928GEQW2DVJ55M8G1A9L5TM8/H0QF6IS6G%64.U4G6PF5RBQ746B46O1N646RM93O5RF6$T61R64IM646-3AQ$95:UENEUW6646C46846OR6UF5 QVCCOE700OP D9M1MPHN6D7LLK*2HG%89UV-0LZ 2.A5:01395*CBVZ0K1H$$0VON./GZJJQU2K+5MV0GX89LN8EFJH1PCDJ*3TFH2V4IF1D 8EC7CEF172BWF4 NIREK%C-KN+JSJEU:XQ$NJMO07VBM$FW8Q:/TH7GXUU%BTMZMTKHSP5NWBZ/EOKI0*SXB1L7M$Y34IECEC7$MAWD.BO7NC.AR100000FGWZJS0MF",
                "TESTCTX": {
                    "VERSION": 1,
                    "SCHEMA": "1.0.0",
                    "CERTIFICATE": "MIIBWDCB/6ADAgECAgRsvRZ/MAoGCCqGSM49BAMCMBAxDjAMBgNVBAMMBUVDLU1lMB4XDTIxMDUwMzE4MDAwMFoXDTIxMDYwMjE4MDAwMFowEDEOMAwGA1UEAwwFRUMtTWUwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAQRS4GeBpNxSbvnbLY56NvXZ26gCJ2SwairBKQOuGqDTO3QMmyfNTH1sMg39aFDon51grJOyhKvEXXUaWD1LOLEo0cwRTAOBgNVHQ8BAf8EBAMCBaAwMwYDVR0lBCwwKgYMKwYBBAEAjjePZQEBBgwrBgEEAQCON49lAQIGDCsGAQQBAI43j2UBAzAKBggqhkjOPQQDAgNIADBFAiBjECR5mdD4++CGQGlV51CEhXjneiMvvVybCYrCjfES4QIhAMNHse2P4I9AokcT9D8pLEDdbbbTxjEvnjB/DFOb9Tho",
                    "VALIDATIONCLOCK": "2021-09-07T12:01:00Z",
                    "DESCRIPTION": "IE float doses special case"
                },
                "EXPECTEDRESULTS": {
                    "EXPECTEDVALIDOBJECT": true,
                    "EXPECTEDVERIFY": false
                }
            }]
"""
    
    
    public var x509TestData : EuTestData {
        get {
            let jsonData = """
            {
                "PREFIX": "HC1:NCFTW2BM75VOO10KHHCUGEE45HB/J0DUIXEUKPAKGSITRD4PH.L0+6R.6USQN$9Q39V$K B9N3B2J7E31UN7ECHOXN5HM9QN$L9L-OWE4UNN88RTCVDCQF1E  NDLSUMBG%RVPBX*O4LT0B8NKF2WTR:5Z3EA-ND9IW$2:U7U$FOU6UVT2Y2/URB2NFPDT2J112748%F1+FNZDAI627U66I07VH7/BHE1E33CGCHGCD61Y6B JD1GINNG2Q39613E1Q-9B8G.SM1M8-EF1R8I64+E06/96QS9YP1D2%XK0SCBQRDFIBEGID1W34THEKFL36PX:G9TAB5F6UE/*SD3M4.BOLJ62WL23.4MXWN41BW37$DM:7E.QL%QLNDQN5NG8LWTD4KP8DB47TZX4-:P%E64NIJNOTYQNUAKL19TTZ/KM+D.%O+THCSL:%D%R41A65$GX720QRUE9K3M-UJ:/AWYBV3Q-L67VP1CN*GFN$VQ K9XLYQ81QUNOC4WR6NJK1OCUD2UT3XPY5MG6LW:B0GWU5N$J7QMNPAWX-1EQAMAFVZV4:M/*0:.943BX*PO7KIXRR7LG46Y%V WHMKH",
                "TESTCTX": {
                    "VERSION": 1,
                    "SCHEMA": "1.0.0",
                    "CERTIFICATE": "MIIBWDCB/6ADAgECAgRsvRZ/MAoGCCqGSM49BAMCMBAxDjAMBgNVBAMMBUVDLU1lMB4XDTIxMDUwMzE4MDAwMFoXDTIxMDYwMjE4MDAwMFowEDEOMAwGA1UEAwwFRUMtTWUwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAQRS4GeBpNxSbvnbLY56NvXZ26gCJ2SwairBKQOuGqDTO3QMmyfNTH1sMg39aFDon51grJOyhKvEXXUaWD1LOLEo0cwRTAOBgNVHQ8BAf8EBAMCBaAwMwYDVR0lBCwwKgYMKwYBBAEAjjePZQEBBgwrBgEEAQCON49lAQIGDCsGAQQBAI43j2UBAzAKBggqhkjOPQQDAgNIADBFAiBjECR5mdD4++CGQGlV51CEhXjneiMvvVybCYrCjfES4QIhAMNHse2P4I9AokcT9D8pLEDdbbbTxjEvnjB/DFOb9Tho",
                    "VALIDATIONCLOCK": "2021-05-03T18:01:00Z",
                    "DESCRIPTION": "VALID: EC 256 key"
                },
                "EXPECTEDRESULTS": {
                    "EXPECTEDEXPIRATIONCHECK": false
                }
            }
            """.data(using: .utf8)!
            return try! jsonTestDecoder().decode(EuTestData.self, from: jsonData)
        }
    }
}

struct TestData {
    let encodedEhnCert : String
    let keyId : String
    let encodedSigningCert : String
}

struct EuTestData : Decodable {
    let jsonContent: HealthCert?
    let cborHex: String?
    let coseHex: String?
    let base45EncodedAndCompressed: String?
    let prefixed: String?
    let base64BarcodeImage: String?
    var testContext: TestContext
    let expectedResults: ExpectedResults
    
    enum CodingKeys: String, CodingKey {
        case jsonContent = "JSON"
        case cborHex = "CBOR"
        case coseHex = "COSE"
        case base45EncodedAndCompressed = "BASE45"
        case prefixed = "PREFIX"
        case base64BarcodeImage = "2DCODE"
        case testContext = "TESTCTX"
        case expectedResults = "EXPECTEDRESULTS"
    }
}

struct TestContext : Decodable {
    let version: Int?
    let schemaVersion: String?
    let signingCertificate: String?
    let validationClock: Date?
    var description: String
    
    enum CodingKeys: String, CodingKey {
        case version = "VERSION"
        case schemaVersion = "SCHEMA"
        case signingCertificate = "CERTIFICATE"
        case validationClock = "VALIDATIONCLOCK"
        case description = "DESCRIPTION"
    }
}

struct ExpectedResults : Decodable {
    let isValidObject: Bool?
    let isSchemeValidatable : Bool?
    let isEncodable: Bool?
    let isDecodable: Bool?
    let isVerifiable: Bool?
    let isUnprefixed: Bool?
    let isValidJson: Bool?
    let isBase45Decodable: Bool?
    let isImageDecodable: Bool?
    let isExpired: Bool?
    let isKeyUsageMatching: Bool?
    
    enum CodingKeys: String, CodingKey {
        case isValidObject = "EXPECTEDVALIDOBJECT"
        case isSchemeValidatable  = "EXPECTEDSCHEMAVALIDATION"
        case isEncodable = "EXPECTEDENCODE"
        case isDecodable = "EXPECTEDDECODE"
        case isVerifiable = "EXPECTEDVERIFY"
        case isUnprefixed = "EXPECTEDUNPREFIX"
        case isValidJson = "EXPECTEDVALIDJSON"
        case isBase45Decodable = "EXPECTEDB45DECODE"
        case isImageDecodable = "EXPECTEDPICTUREDECODE"
        case isExpired = "EXPECTEDEXPIRATIONCHECK"
        case isKeyUsageMatching = "EXPECTEDKEYUSAGE"
    }
}
