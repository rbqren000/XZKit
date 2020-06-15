//
//  APIError.swift
//  HTTP
//
//  Created by Xezun on 2018/7/3.
//  Copyright © 2018年 XEZUN INC. All rights reserved.
//

import Foundation

extension APIError {
    
    /// 错误码 0 ，表示没有错误发生。
    /// - Note: 除非希望提前结束正常流程，否则请不要抛出 noError 错误。
    public static let noError = APIError(code: 0, message: "No error.")
    
    /// 错误码 -1 ，未定义的错误。
    public static let undefined = APIError(code: -1, message: "An undefined error occurred.")
    
    /// 错误码 -2 ，请求被取消了。
    public static let cancelled = APIError(code: -2, message: "The request was cancelled.")
    
    /// 错误码 -3 ，请求被忽略了。
    public static let ignored = APIError(code: -3, message: "The request was ignored.")
    
    /// 错误码 -4 ，请求超截止时间，非网络响应的超时。
    public static let overtime = APIError(code: -4, message: "The request is out of the limited time.")
    
    /// 错误码 -100 ，因为无网络而发生的错误。
    /// - Note: 建议网络错误 -100 ~ -199 。
    public static let unreachable = APIError(code: -100, message: "The network was unreachable.")
    
    /// 错误码 - 200 ，无效的接口请求。
    /// - Note: 建议 request 错误 -200 ~ -299 。
    public static let invalidRequest = APIError(code: -200, message: "The api request is invalid.")
    
    /// 错误码 -300 ，请求结果无法解析。
    /// - Note: 建议 response 错误 -300 ~ -399 。
    public static let unexpectedResponse = APIError(code: -300, message: "The response data can not be parsed.")
    
}


/// 描述接口请求、解析过程中产生的错误。
/// - Note: 根据 HTTP 规范，HTTP 状态码在 100 ~ 999 之间。
/// - Note: 本框架内部错误在 -1 ~ -999 之间，请参见预定义的枚举。
/// - Note: 业务逻辑错误码，建议定义在上述范围之外的数值。
/// - Note: 如果错误码相同，即表示为相同的错误。
public struct APIError: Error, CustomStringConvertible {
    
    /// APIError 错误码。
    public let code: Int
    
    /// APIError 错误信息描述。
    public let message: String
    
    /// 自定义错误信息。
    public private(set) var userInfo: [UserInfoKey: Any]
    
    /// APIError 初始化。
    ///
    /// - Parameters:
    ///   - code: 错误码
    ///   - message: 描述
    public init(code: Int, message: String, userInfo: [UserInfoKey: Any] = [:]) {
        self.code = code
        self.message = message
        self.userInfo = userInfo
    }
    
    public init(code: Int) {
        switch code {
        case 0:
            self = .noError
        case -1:
            self = .undefined
        case -2:
            self = .cancelled
        case -3:
            self = .ignored
        case -4:
            self = .overtime
        case -100 ... -199:
            self.init(code: code, message: APIError.unreachable.message)
        case -200 ... -299:
            self.init(code: code, message: APIError.invalidRequest.message)
        case -300 ... -399:
            self.init(code: code, message: APIError.unexpectedResponse.message)
        default:
            self.init(code: code, message: "An unknown error with code \(code).")
        }
    }
    
    public init(code: Int, message: String, userInfo: [String: Any]) {
        self.code = code
        self.message = message
        self.userInfo = userInfo.reduce([UserInfoKey: Any](), { (result, item) -> [UserInfoKey: Any] in
            return [UserInfoKey(rawValue: item.key): item.value]
        })
    }
    
    /// 错误描述信息。
    public var description: String {
        return "XZKit.APIError(code: \(code), message: \(message))"
    }
    
    public struct UserInfoKey: RawRepresentable, ExpressibleByStringLiteral, Hashable {
        
        public static let numberOfRetries = UserInfoKey(rawValue: APIError.Domain + ".numberOfRetries")
        
        public typealias RawValue = String
        public typealias StringLiteralType = String
        
        public let rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(stringLiteral value: String) {
            self.rawValue = value
        }
        
        public var hashValue: Int {
            return rawValue.hashValue
        }
    }
    
    public var numberOfRetries: Int {
        get {
            if let number = userInfo[.numberOfRetries] as? Int {
                return number
            }
            return 0
        }
        set {
            userInfo[.numberOfRetries] = newValue
        }
    }
}

extension APIError: Equatable {
    
    public static func ==(lhs: APIError, rhs: APIError) -> Bool {
        return lhs.code == rhs.code
    }
    
    /// 提供通过 APIError.code 与 APIError 直接比较的方法。
    ///
    /// - Parameters:
    ///   - lhs: Error Code.
    ///   - rhs: APIError
    /// - Returns: The number is equal to the error code or not.
    public static func ==(lhs: Int, rhs: APIError) -> Bool {
        return lhs == rhs.code
    }
    
}


extension APIError {
    
    public typealias _ObjectiveCType = NSError
    
    /// APIError 的错误域，在桥接到 Objective-C NSError 时使用。
    /// - Note: 实际值为 com.xezun.XZKit.Networking 字符串。
    public static let Domain = "com.xezun.XZKit.Networking"
    
    public init(_ error: Error) {
        if let apiError = error as? APIError {
            self = apiError
            return
        }
        let nsError  = error as NSError
        let code     = nsError.code
        let message  = nsError.localizedDescription
        let userInfo = nsError.userInfo
        self = APIError.init(code: code, message: message, userInfo: userInfo)
    }
    
}