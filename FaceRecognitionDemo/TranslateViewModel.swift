//
//  TranslateViewModel.swift
//  FanYi
//
//  Created by Jorn on 2019/3/20.
//  Copyright © 2019 Jorn Wu(jornwucn@gmail.com). All rights reserved.
//

import UIKit
import CommonCrypto


let kMAIN_URL = "https://bda.tencentcloudapi.com"
let kMAIN_REGION = "ap-shanghai"

let kPROJECT_ID = 1139572
let kPROJECT_SECRET_ID = "AKIDPdaHhqjLgla8RTEiwsXv1rRkmZ5KI0Rb"
let kPROJECT_SECRET_KEY = "uXu1rQjlcQyF3av2sRjlZ6MM5XhaKvIO"

let kPUBLIC_REQUEST_PARAM_ACTION = "X-TC-Action"
let kPUBLIC_REQUEST_PARAM_REGION = "X-TC-Region"
let kPUBLIC_REQUEST_PARAM_TIMESTAMP = "X-TC-Timestamp"
let kPUBLIC_REQUEST_PARAM_VERSION = "X-TC-Version"
let kPUBLIC_REQUEST_PARAM_AUTHORIZATION = "X-TC-Authorization"
let kPUBLIC_REQUEST_PARAM_TOKEN = "X-TC-Token"

let kPUBLIC_VALUE_X_WWW_FORM_URLENCODED = "application/x-www-form-urlencoded"
let kPUBLIC_VALUE_JSON = "application/json"
let kPUBLIC_VALUE_FORM_DATA = "multipart/form-data"
let kPUBLIC_VALUE_HOST = "bda.tencentcloudapi.com"
let kPUBLIC_VALUE_SERVICE = "tmt"
let kPUBLIC_VALUE_VERSION = "2020-03-24"
let kPUBLIC_VALUE_REGION = "ap-shanghai"

final class TranslateViewModel: NSObject {
    
    
    @objc public func createPublicParam_V1(imageStr: String) -> [String: Any] {
//        var publicParam = (baseParam as NSDictionary).copy() as! [String: Any]
        var publicParam = NSDictionary.init() as! [String: Any]

        publicParam["Action"] = "SegmentCustomizedPortraitPic"
        publicParam["Version"] = kPUBLIC_VALUE_VERSION
        publicParam["Region"] = kPUBLIC_VALUE_REGION
        publicParam["SecretId"] = kPROJECT_SECRET_ID
        publicParam["Nonce"] = arc4random_uniform(UInt32.max)
        publicParam["Timestamp"] = NSInteger(Date().timeIntervalSince1970)
        publicParam["Url"] = imageStr
        publicParam["SegmentationOptions.Head"] = "true"
        publicParam["Language"] = "zh-CN"
//        publicParam["Image"] = imageStr


        let sortedParam = publicParam.sorted { (arg0, arg1) -> Bool in
            let (key0, _) = arg0
            let (key1, _) = arg1
            
             return key0 < key1
        }
        
        let hash = HMAC_Sign(algorithm: CCHmacAlgorithm(kCCHmacAlgSHA1),
                             keyBytes: kPROJECT_SECRET_KEY.data(using: .utf8)! as NSData,
                             dataString: pairs2SignString(sortedParam)!)
            
        publicParam["Signature"] = urlEncode(base64Encode(hash.bytes, count: hash.length))
        publicParam["getUrl"] = pairs2SignString(sortedParam)

        return publicParam
    }
    
    private func createPublicParam_V3(payload: String) -> [String: Any] {
        let timestamp = NSInteger(Date().timeIntervalSince1970)
        let algorithm = "TC3-HMAC-SHA256"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let utcDate = dateFormatter.string(from: Date())
        
        /// 步骤 1：拼接规范请求串
        let httpRequestMethod = "POST"
        let canonicalUri = "/"
        let canonicalQueryString = ""
        let canonicalHeaders = "content-type:\(kPUBLIC_VALUE_JSON)\n"
            + "host:" + kPUBLIC_VALUE_HOST + "\n"
        let signedHeaders = "content-type;host"
        let hashedRequestPayload = hexSHA256_sign(payload)
        let canonicalRequest = httpRequestMethod + "\n"
            + canonicalUri + "\n"
            + canonicalQueryString + "\n"
            + canonicalHeaders + "\n"
            + signedHeaders + "\n"
            + hashedRequestPayload
        
        print("canonicalRequest: " + canonicalRequest)
        
        /// 步骤 2：拼接待签名字符串
        let credentialScope = utcDate + "/" + kPUBLIC_VALUE_SERVICE + "/" + "tc3_request"
        let hashedCanonicalRequest = hexSHA256_sign(canonicalRequest)
        let stringToSign = algorithm + "\n"
            + "\(timestamp)" + "\n"
            + credentialScope + "\n"
            + hashedCanonicalRequest
        
        print("stringToSign: " + stringToSign)
        
        /// 步骤 3：计算签名
        let date = ("TC3" + kPROJECT_SECRET_KEY).data(using: .utf8)! as NSData
        let secretDate = HMAC_Sign(algorithm: CCHmacAlgorithm(kCCHmacAlgSHA256),
                                   keyBytes: date,
                                   dataString: utcDate)
        
        let secretService = HMAC_Sign(algorithm: CCHmacAlgorithm(kCCHmacAlgSHA256),
                                      keyBytes: secretDate,
                                      dataString: kPUBLIC_VALUE_SERVICE)
        
        let secretSigning = HMAC_Sign(algorithm: CCHmacAlgorithm(kCCHmacAlgSHA256),
                                      keyBytes: secretService,
                                      dataString: "tc3_request")
        
        let signature = hexEncode(HMAC_Sign(algorithm: CCHmacAlgorithm(kCCHmacAlgSHA256),
                                            keyBytes: secretSigning,
                                            dataString: stringToSign) as Data);
        
        print("signature: " + signature);
        
        /// 步骤 4：拼接 Authorization
        let authorization = algorithm + " "
            + "Credential=" + kPROJECT_SECRET_ID + "/"
            + credentialScope + ", "
            + "SignedHeaders=" + signedHeaders + ", "
            + "Signature=" + signature;
        
        print("authorization: " + authorization);
        
        return [kPUBLIC_REQUEST_PARAM_AUTHORIZATION: authorization,
//                kPUBLIC_REQUEST_PARAM_ACTION: action.rawValue,
                kPUBLIC_REQUEST_PARAM_REGION: kPUBLIC_VALUE_REGION,
                kPUBLIC_REQUEST_PARAM_TIMESTAMP: timestamp,
                kPUBLIC_REQUEST_PARAM_VERSION: kPUBLIC_VALUE_VERSION]
    }
    
    private func hexSHA256_sign(_ dataString: String) -> String {
        let data = dataString.data(using: .utf8)! as NSData
        var cSHA256 = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CC_SHA256(data.bytes, CC_LONG(data.count), &cSHA256)
        
        var hexString = ""
        for byte in cSHA256 {
            hexString += String(format: "%02x", byte)
        }
        
        return hexString
    }

    private func HMAC_Sign(algorithm: CCHmacAlgorithm,
                           keyBytes: NSData,
                           dataString: String) -> NSData {
        if algorithm != kCCHmacAlgSHA1 && algorithm != kCCHmacAlgSHA256 {
            print("Unsupport algorithm.")
            return NSData()
        }
        
        let data = dataString.data(using: .utf8)! as NSData
        let len = algorithm == CCHmacAlgorithm(kCCHmacAlgSHA1) ?
            CC_SHA1_DIGEST_LENGTH : CC_SHA256_DIGEST_LENGTH
        var cHMAC = [UInt8](repeating: 0, count: Int(len))
        
        CCHmac(algorithm, keyBytes.bytes, keyBytes.count,
               data.bytes, data.count, &cHMAC)
        
        return NSData(bytes: &cHMAC, length: cHMAC.count)
    }
    
    private func dec2bin(_ number: Int) -> String {
        var num = number
        var str = ""
        while num > 0 {
            str = "\(num % 2)" + str
            num /= 2
        }
        return str
    }
    
    private func pairs2SignString(_ pairs: [(String, Any)]) -> String? {
        var str = ""
        pairs.forEach { (key: String, value: Any) in
            str += "\(key)=\(value)" + "&"
        }
        
        let index = str.index(str.endIndex, offsetBy: -1)
//        str = "GETbda.tencentcloudapi.com/?" + String(str[..<index])
        str = "POSTbda.tencentcloudapi.com/?" + String(str[..<index])

        print("pairs2SignString:" + str)
        
        return str
    }
    
    private func base64Encode(_ bytes: UnsafeRawPointer, count: Int) -> String {
        let base64Data = Data(bytes: bytes, count: count)
        let base64String = base64Data.base64EncodedString()
        return base64String
    }
    
    private func hexEncode(_ data: Data) -> String {
        var hexString = ""
        for byte in data {
            hexString += String(format: "%02x", byte)
        }
        
        return hexString
    }
    
    private func urlEncode(_ string: String) -> String {
        let newString = string.addingPercentEncoding(withAllowedCharacters:
            CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[]{} ").inverted)
        
        return newString ?? ""
    }
}

