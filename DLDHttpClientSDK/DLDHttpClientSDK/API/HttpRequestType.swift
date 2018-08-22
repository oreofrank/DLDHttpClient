//
//  HttpRequestType.swift
//  Duliday
//
//  Created by Frank liao on 2018/6/20.
//  Copyright © 2018年 Duliday. All rights reserved.
//

import Foundation
import Moya
import RxSwift

var headerFields: Dictionary<String, String> = [:]
var dulidayToken: String?

enum HttpServerType {
    case base  //原始
    case sso    //SSO
    case pse    //persistence
}

class RequestType {
    
    let basePath:String
    let md:Moya.Method
    let parames:[String : Any]?
    let baseUrl:String
    
    init(path:String, md:Moya.Method, parames:[String : Any]? = nil, type:HttpServerType = .base) {
        self.basePath = path
        self.parames = parames
        self.md = md
        self.baseUrl = ""
//        switch type {
//        case .base:
//            self.baseUrl = baseRequestURL
//        case .sso:
//            self.baseUrl = baseRequestSSOURL
//        case .pse:
//            self.baseUrl = baseRequestPSEURL
//        }
    }
    
    class func get(type:RequestUrl, parames:[String : Any]? = nil,_ args:Any...) -> RequestType {
        let cvargs = args.map { (arg) -> String in
            if let arg = arg as? Int {
                return String(arg)
            } else if let arg = arg as? String {
                return arg
            } else if let arg = arg as? Float {
                return String(arg)
            } else if let arg = arg as? Double {
                return String(arg)
            }
            return ""
        }
        let pathFormat = String(format: type.rawValue, arguments: cvargs as [CVarArg] )
        
        return RequestType(path: pathFormat, md: .get, parames: parames, type: .base)
    }
    
    class func post(type:RequestUrl, parames:[String : Any]? = nil, _ args:Any...) -> RequestType {
        
        let cvargs = args.map { (arg) -> String in
            if let arg = arg as? Int {
                return String(arg)
            } else if let arg = arg as? String {
                return arg
            } else if let arg = arg as? Float {
                return String(arg)
            } else if let arg = arg as? Double {
                return String(arg)
            }
            return ""
        }
        let pathFormat = String(format: type.rawValue, arguments: cvargs as [CVarArg] )
        
        return RequestType(path: pathFormat, md: .post, parames: parames, type: .base)
    }
    
    class func get(type:RequestSSOUrl, parames:[String : Any]? = nil,_ args:Any...) -> RequestType {
        let cvargs = args.map { (arg) -> String in
            if let arg = arg as? Int {
                return String(arg)
            } else if let arg = arg as? String {
                return arg
            } else if let arg = arg as? Float {
                return String(arg)
            } else if let arg = arg as? Double {
                return String(arg)
            }
            return ""
        }
        let pathFormat = String(format: type.rawValue, arguments: cvargs as [CVarArg] )
        
        return RequestType(path: pathFormat, md: .get, parames: parames, type: .sso)
    }
    
    class func post(type:RequestSSOUrl, parames:[String : Any]? = nil,_ args:Any...) -> RequestType {
        
        let cvargs = args.map { (arg) -> String in
            if let arg = arg as? Int {
                return String(arg)
            } else if let arg = arg as? String {
                return arg
            } else if let arg = arg as? Float {
                return String(arg)
            } else if let arg = arg as? Double {
                return String(arg)
            }
            return ""
        }
        let pathFormat = String(format: type.rawValue, arguments: cvargs as [CVarArg] )
        
        return RequestType(path: pathFormat, md: .post, parames: parames, type: .sso)
    }
    
    class func get(type:RequestPSEUrl, parames:[String : Any]? = nil,_ args:Any...) -> RequestType {
        let cvargs = args.map { (arg) -> String in
            if let arg = arg as? Int {
                return String(arg)
            } else if let arg = arg as? String {
                return arg
            } else if let arg = arg as? Float {
                return String(arg)
            } else if let arg = arg as? Double {
                return String(arg)
            }
            return ""
        }
        let pathFormat = String(format: type.rawValue, arguments: cvargs as [CVarArg] )
        
        return RequestType(path: pathFormat, md: .get, parames: parames, type: .pse)
    }
    
    class func post(type:RequestPSEUrl, parames:[String : Any]? = nil,_ args:Any...) -> RequestType {
        
        let cvargs = args.map { (arg) -> String in
            if let arg = arg as? Int {
                return String(arg)
            } else if let arg = arg as? String {
                return arg
            } else if let arg = arg as? Float {
                return String(arg)
            } else if let arg = arg as? Double {
                return String(arg)
            }
            return ""
        }
        let pathFormat = String(format: type.rawValue, arguments: cvargs as [CVarArg] )
        
        return RequestType(path: pathFormat, md: .post, parames: parames, type: .pse)
    }
}

extension RequestType: TargetType {
    public var headers: [String : String]? {
        headerFields.updateValue(dulidayToken ?? "", forKey: "Duliday-Token")
        return headerFields
    }

    public var baseURL: URL {
        return URL(string: self.baseUrl+"?timestamp=\(NSDate.currentLocalTimestamp()!)")!
    }

    public var path: String {
        return self.basePath
    }

    public var method: Moya.Method {
        return md
    }

    public var task: Task {

        if md == .get {
            return .requestPlain
        }
        guard let parames = parames else {
            return .requestParameters(parameters: [String: AnyObject](), encoding: JSONEncoding.default)
        }
        return .requestParameters(parameters: parames, encoding: JSONEncoding.default)
    }

    public var validate: Bool {
        return false
    }

    public var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }

}
