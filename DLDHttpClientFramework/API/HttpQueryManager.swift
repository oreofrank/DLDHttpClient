//
//  HttpQueryManager.swift
//  Duliday
//
//  Created by liaohai on 2018/1/24.
//  Copyright © 2018年 Duliday. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import HandyJSON

public typealias HttpSuccess<E:HandyJSON> = (_ model:E?, _ base:BaseModel?) -> Swift.Void
public typealias HttpSuccessArray<E:HandyJSON> = (_ model:[E]?, _ base:BaseModel?) -> Swift.Void
public typealias HttpCache<E:HandyJSON> = (_ model:E?) -> Swift.Void
public typealias HttpCacheArray<E:HandyJSON> = (_ model:[E]?) -> Swift.Void
public typealias HttpError = (_ errorMsg:String, _ errorCode:Int) -> Swift.Void
public typealias HttpReponseError = (_ errorCode:Int?) -> Swift.Void

public class QueryManager<T: RequestTargetType> {
    init() {
    }
    
    public class func createQuery() -> QueryBall<T> {
        
        return QueryBall<T>()
    }
    
}

//调试信息解析
private func JSONResponseDataFormatter(_ data: Data) -> Data {
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data)
        let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return prettyData
    } catch {
        return data // fallback to original data if it can't be serialized.
    }
}

//MARK:LOG 调试信息
private func ReversedPrintClosure(_ separator: String, terminator: String, items: Any...) {
    for item in items {
        if let itemStr = item as? String {
            if itemStr.contains("Request Body") ||
                itemStr.contains("Request: http") ||
                itemStr.contains("Request Method") {
                if isOpenConsoleOutput {
                    print(item, separator: separator, terminator: terminator)
                }
            } else if !itemStr.contains("Moya_Logger"){
                let time = Int(NSDate().timeIntervalSince1970).moyaTimeStr()
                let timeStr = String(format: "Moya_Logger: [%@] HTTP Response", time)
                if isOpenConsoleOutput {
                    print(timeStr, item, separator: separator, terminator: terminator)
                }
            }
        }
    }
}

//MARK:LOG 请求失败打印
public func RequestErrorClosure(_ errorMsg:String, _ errorCode:Int) -> Swift.Void {
    print("QueryManager error:", errorMsg, ",code:", errorCode)
}

private extension String {
    var urlEscaped: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
}

private func url(_ route: TargetType) -> String {
    return route.baseURL.appendingPathComponent(route.path).absoluteString
}

// MARK: - Response Handlers
extension Moya.Response {
    func mapNSArray() throws -> NSArray {
        let any = try self.mapJSON()
        guard let array = any as? NSArray else {
            throw MoyaError.jsonMapping(self)
        }
        return array
    }
    
}

public class QueryBall<T:RequestTargetType> {
    
    var sProvider:MoyaProvider<T>
    var reactive:Reactive<MoyaProvider<T>>
    
    let sDisposeBag: DisposeBag = DisposeBag()
    
    init() {
        sProvider = MoyaProvider<T>()
        reactive = Reactive(sProvider)
    }
    
    private func initProvider(_ httpHeaderFields:[String: String]?) {
        
        let endpoint = { (target: T) -> Endpoint in
            let newUrl = url(target)
            let endpoint:Endpoint = Endpoint(url: newUrl, sampleResponseClosure: {.networkResponse(200, target.sampleData)}, method: target.method, task: target.task, httpHeaderFields:httpHeaderFields)
            
            return endpoint
        }
        
        // 设置超时时常等
        let requestClosure = {(endpoint: Endpoint, closure: MoyaProvider<T>.RequestResultClosure) -> Void in
            
            do {
                var urlRequest =  try endpoint.urlRequest()
                urlRequest.timeoutInterval = 30// 超时时长 // TODO: 修改超时时长
                closure(.success(urlRequest))
            } catch  {
                closure(.failure(MoyaError.requestMapping(endpoint.url)))
            }
            
        }
        
        sProvider = MoyaProvider<T>(endpointClosure: endpoint,
                                    requestClosure: requestClosure,
                                    plugins: [NetworkLoggerPlugin(verbose: isOpenConsoleOutput,
                                                                  output: ReversedPrintClosure,
                                                                  responseDataFormatter: JSONResponseDataFormatter)])
        reactive = Reactive(sProvider)
        
    }
    
    private func headerMerge(_ tagHeader: [String: String]?, _ headers: [String: String]?) -> [String: String]? {
        
        var newHTTPHeaderFields = headers ?? [:]
        if let unwrappedHeaders = tagHeader {
            if unwrappedHeaders.isEmpty == false  {
                unwrappedHeaders.forEach { (arg) in
                    let (key, value) = arg
                    newHTTPHeaderFields[key] = value
                }
            }
        }
        
        return newHTTPHeaderFields
    }
    
    private func requestBase<F:HandyJSON>(_ params:T,
                                          _ progress:Bool,
                                          _ progressView:UIView? = nil,
                                          _ cache: Bool,
                                          _ error: @escaping HttpError,
                                          _ success: @escaping HttpSuccess<F>)
    {
        if let headerTagField = headerTagField {
            let tagHeader:[String : String] = [headerTagField : ResponseGetTag(params: params) ?? ""]
            let headers = self.headerMerge(tagHeader, params.headers)
            initProvider(headers)
        } else {
            initProvider(params.headers)
        }
        
        DispatchQueue.main.async {
            HttpProgressManager.showProgressHUD(progress, view:progressView)
        }
        
        reactive.request(params).subscribe(onSuccess: { (response) in
            let headerfileds: Dictionary<AnyHashable, Any> = response.response?.allHeaderFields ?? [:]
            if let dateString = headerfileds["Date"] as? String {
                let locale = NSLocale(localeIdentifier: "en_US_POSIX")
                let dateFormatter = DateFormatter()
                dateFormatter.locale = locale as Locale
                dateFormatter.timeZone = TimeZone.init(secondsFromGMT: 0)
                dateFormatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss zzz"
                diffientTimeInterval = dateFormatter.date(from: dateString)!.timeIntervalSince(Date())
            }
            
            Single<Response>.just(response).filterSuccessfulStatusCodes().mapJSON().subscribe(onSuccess: { (data) in
                if HttpQueryUnmind.commend(data: data) {
                    DispatchQueue.main.async {
                        HttpProgressManager.hiddenProcessHUD(progress, view:progressView)
                        success(nil, nil)
                    }
                    return
                }
                let tagChange = self.httpTagFilter(params, headerfileds)
                
                // sso数据处理
                var validData = data
                var base:BaseModel? = nil
                if let data = data as? NSDictionary {
                    base = BaseModel.deserialize(from: data)
                    if let bm = base, bm.code != Int.defaultValue, bm.code != successCode {
                        DispatchQueue.main.async {
                            HttpProgressManager.hiddenProcessHUD(progress, view:progressView)
                            success(nil, base)
                            if let reponseError = reponseError {
                                reponseError(base?.code)
                            }
                        }
                        return
                    }
                }
                if let data = data as? NSDictionary, let ssoData = data["data"] as? NSDictionary {
                    validData = ssoData
                } else if let data = data as? NSDictionary, let ssoData = data["data"], ssoData is NSNull {
                    DispatchQueue.main.async {
                        HttpProgressManager.hiddenProcessHUD(progress, view:progressView)
                        if cache {
                            let cacheModel = HttpCacheModel()
                            cacheModel.result = nil
                            self.cacheRestore(params, cacheModel)
                        }
                        success(nil, base)
                    }
                    return
                }
                
                guard let data = validData as? NSDictionary else { //数据异常
                    DispatchQueue.main.async {
                        HttpProgressManager.hiddenProcessHUD(progress, view:progressView)
                    }
                    if !tagChange { //tag没有变化，本地读取
                        self.cacheExtract(params) { (data) in
                            guard let data = data as? HttpCacheModel, let result = data.result as? NSDictionary else {
                                success(nil, base)
                                return
                            }
                            let f:F? = F.deserialize(from: result)
                            DispatchQueue.main.async {
                                success(f, base)
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            success(nil, base)
                        }
                    }
                    return
                }
                
                // handyJson转换
                let f = F.deserialize(from: data)
                if cache {
                    let cacheModel = HttpCacheModel()
                    cacheModel.result = data
                    self.cacheRestore(params, cacheModel)
                }
                DispatchQueue.main.async {
                    HttpProgressManager.hiddenProcessHUD(progress, view:progressView)
                    success(f, base)
                }
                return
                
            }, onError: { (e) in
                DispatchQueue.main.async {
                    HttpProgressManager.hiddenProcessHUD(progress, view:progressView)
                    let moyaError:MoyaError = e as! MoyaError
                    if let code = moyaError.response?.statusCode, code == 304 {
                        self.cacheExtract(params) { (data) in
                            guard let data = data as? HttpCacheModel, let result = data.result as? NSDictionary else {
                                success(nil, nil)
                                return
                            }
                            let f:F? = F.deserialize(from: result)
                            success(f, nil)
                        }
                        return
                    }
                    if let code = moyaError.response?.statusCode, code == 200 {
                        success(nil, nil)
                        return
                    }
                    self.moyaErrorDes(moyaError, error)
                }
                
            }).disposed(by: self.sDisposeBag)
            
        }) { (e) in
            DispatchQueue.main.async {
                HttpProgressManager.hiddenProcessHUD(progress, view:progressView)
                let moyaError:MoyaError = e as! MoyaError
                self.moyaErrorDes(moyaError, error)
            }
            }.disposed(by: sDisposeBag)
    }
    
    private func requestArray<F:HandyJSON>(_ params:T,
                                           _ progress:Bool,
                                           _ progressView:UIView? = nil,
                                           _ cache: Bool,
                                           _ error: @escaping HttpError,
                                           _ success: @escaping HttpSuccessArray<F>)
    {
        if let headerTagField = headerTagField {
            let tagHeader:[String : String] = [headerTagField : ResponseGetTag(params: params) ?? ""]
            let headers = self.headerMerge(tagHeader, params.headers)
            initProvider(headers)
        } else {
            initProvider(params.headers)
        }
        
        DispatchQueue.main.async {
            HttpProgressManager.showProgressHUD(progress, view:progressView)
        }
        
        reactive.request(params).subscribe(onSuccess: { (response) in
            let headerfileds: Dictionary<AnyHashable, Any> = response.response?.allHeaderFields ?? [:]
            if let dateString = headerfileds["Date"] as? String {
                let locale = NSLocale(localeIdentifier: "en_US_POSIX")
                let dateFormatter = DateFormatter()
                dateFormatter.locale = locale as Locale
                dateFormatter.timeZone = TimeZone.init(secondsFromGMT: 0)
                dateFormatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss zzz"
                diffientTimeInterval = dateFormatter.date(from: dateString)!.timeIntervalSince(Date())
            }
            Single<Response>.just(response).filterSuccessfulStatusCodes().mapJSON().subscribe(onSuccess: { (data) in
                if HttpQueryUnmind.commend(data: data) {
                    DispatchQueue.main.async {
                        HttpProgressManager.hiddenProcessHUD(progress, view:progressView)
                        success(nil, nil)
                    }
                    return
                }
                let tagChange = self.httpTagFilter(params, headerfileds)
                
                // sso数据处理
                var validData = data
                var base:BaseModel? = nil
                if let data = data as? NSDictionary {
                    base = BaseModel.deserialize(from: data)
                    if let bm = base, bm.code != Int.defaultValue, bm.code != successCode {
                        DispatchQueue.main.async {
                            HttpProgressManager.hiddenProcessHUD(progress, view:progressView)
                            success(nil, base)
                            if let reponseError = reponseError {
                                reponseError(base?.code)
                            }
                        }
                        return
                    }
                }
                if let data = data as? NSDictionary, let ssoData = data["data"] as? [Any] {
                    validData = ssoData
                } else if let data = data as? NSDictionary, let ssoData = data["data"], ssoData is NSNull {
                    DispatchQueue.main.async {
                        HttpProgressManager.hiddenProcessHUD(progress, view:progressView)
                        if cache {
                            let cacheModel = HttpCacheModel()
                            cacheModel.result = nil
                            self.cacheRestore(params, cacheModel)
                        }
                        success(nil, base)
                    }
                    return
                }
                
                guard let data = validData as? [Any] else { //数据异常
                    DispatchQueue.main.async {
                        HttpProgressManager.hiddenProcessHUD(progress, view:progressView)
                    }
                    if !tagChange { //tag没有变化，本地读取
                        self.cacheExtract(params) { (data) in
                            guard let data = data as? HttpCacheModel, let result = data.result as? [Any] else {
                                success(nil, base)
                                return
                            }
                            let f:[F]? = [F].deserialize(from: result) as? [F]
                            DispatchQueue.main.async {
                                success(f, base)
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            success(nil, base)
                        }
                    }
                    return
                }
                
                let f:[F]? = [F].deserialize(from: data) as? [F]
                if cache {
                    let cacheModel = HttpCacheModel()
                    cacheModel.result = data
                    self.cacheRestore(params, cacheModel)
                }
                DispatchQueue.main.async {
                    HttpProgressManager.hiddenProcessHUD(progress, view:progressView)
                    success(f, base)
                }
                return
                
                
            }, onError: { (e) in
                DispatchQueue.main.async {
                    HttpProgressManager.hiddenProcessHUD(progress, view:progressView)
                    let moyaError:MoyaError = e as! MoyaError
                    if let code = moyaError.response?.statusCode, code == 304 {
                        self.cacheExtract(params) { (data) in
                            guard let data = data as? HttpCacheModel, let result = data.result as? [Any] else {
                                success(nil, nil)
                                
                                return
                            }
                            
                            let f:[F]? = [F].deserialize(from: result) as? [F]
                            success(f, nil)
                        }
                        return
                    }
                    if let code = moyaError.response?.statusCode, code == 200 {
                        success(nil, nil)
                        return
                    }
                    self.moyaErrorDes(moyaError, error)
                }
            }).disposed(by: self.sDisposeBag)
            
        }) { (e) in
            DispatchQueue.main.async {
                HttpProgressManager.hiddenProcessHUD(progress, view:progressView)
                let moyaError:MoyaError = e as! MoyaError
                self.moyaErrorDes(moyaError, error)
            }
            }.disposed(by: sDisposeBag)
    }
    
    /* 网络请求，缓存本地，转换数组
     * model需要支持HandyJSON协议和NSCoding协议
     * params：包含方法，url，parmater
     * progress：是否显示加载动画
     * progressView：加载动画显示地方，默认显示在window上
     * cache：开启缓存，以及本地数据读取
     * error：失败回调
     * success：成功回调
     */
    public func request<F: HandyJSON>(_ params:T,
                                      progress:Bool,
                                      progressView:UIView? = nil,
                                      cache: HttpCache<F>? = nil,
                                      error: @escaping HttpError = RequestErrorClosure,
                                      _ success: @escaping HttpSuccess<F>) {
        var cacheFlag = false
        if let cache = cache { //本地读取
            cacheFlag = true
            cacheExtract(params) { (data) in
                guard let data = data as? HttpCacheModel, let result = data.result as? NSDictionary else {
                    return
                }
                let f:F? = F.deserialize(from: result)
                DispatchQueue.main.async {
                    cache(f)
                }
            }
        }
        
        requestBase(params, progress, progressView, cacheFlag, error, success)
    }
    
    /* 网络请求，缓存本地，转换数组
     * model需要支持HandyJSON协议和NSCoding协议
     * params：包含方法，url，parmater
     * progress：是否显示加载动画
     * progressView：加载动画显示地方，默认显示在window上
     * cache：开启缓存，以及本地数据读取
     * error：失败回调
     * success：成功回调
     */
    public func request<F: HandyJSON>(_ params:T,
                                      progress:Bool,
                                      progressView:UIView? = nil,
                                      cache: HttpCacheArray<F>? = nil,
                                      error: @escaping HttpError = RequestErrorClosure,
                                      _ success: @escaping HttpSuccessArray<F>) {
        var cacheFlag = false
        if let cache = cache { //本地读取
            cacheFlag = true
            cacheExtract(params) { (data) in //本地读取
                guard let data = data as? HttpCacheModel, let result = data.result as? [Any] else {
                    return
                }
                
                let f:[F]? = [F].deserialize(from: result) as? [F]
                DispatchQueue.main.async {
                    cache(f)
                }
            }
        }
        
        requestArray(params, progress, progressView, cacheFlag, error, success)
        
    }
    
    /* 网络请求，返回json数据
     * params：包含方法，url，parmater
     * progress：是否显示加载动画
     * progressView：加载动画显示地方，默认显示在window上
     * error：失败回调
     * success：成功回调
     */
    public func request(_ params:T,
                        progress:Bool,
                        progressView:UIView? = nil,
                        error: @escaping HttpError = RequestErrorClosure,
                        _ success: @escaping ((_ response:Any?, _ base:BaseModel?)->())) {
        
        if let headerTagField = headerTagField {
            let tagHeader:[String : String] = [headerTagField : ResponseGetTag(params: params) ?? ""]
            let headers = self.headerMerge(tagHeader, params.headers)
            initProvider(headers)
        } else {
            initProvider(params.headers)
        }
        
        DispatchQueue.main.async {
            HttpProgressManager.showProgressHUD(progress, view:progressView)
        }
        
        reactive.request(params).subscribe(onSuccess: { (response) in
            Single<Response>.just(response).filterSuccessfulStatusCodes().mapJSON().subscribe(onSuccess: { (data) in
                if HttpQueryUnmind.commend(data: data) {
                    DispatchQueue.main.async {
                        HttpProgressManager.hiddenProcessHUD(progress, view:progressView)
                        success(nil, nil)
                    }
                    return
                }
                
                // sso数据处理
                var validData = data
                var base:BaseModel? = nil
                if let data = data as? NSDictionary {
                    base = BaseModel.deserialize(from: data)
                    if let bm = base, bm.code != Int.defaultValue, bm.code != successCode {
                        DispatchQueue.main.async {
                            HttpProgressManager.hiddenProcessHUD(progress, view:progressView)
                            success(nil, base)
                            if let reponseError = reponseError {
                                reponseError(base?.code)
                            }
                        }
                        return
                    }
                }
                if let data = data as? NSDictionary, let ssoData = data["data"] {
                    validData = ssoData
                } else if let data = data as? NSDictionary, let ssoData = data["data"], ssoData is NSNull {
                    DispatchQueue.main.async {
                        HttpProgressManager.hiddenProcessHUD(progress, view:progressView)
                        success(nil, base)
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    HttpProgressManager.hiddenProcessHUD(progress, view:progressView)
                    success(validData, base)
                }
                return
            }, onError: { (e) in
                DispatchQueue.main.async {
                    HttpProgressManager.hiddenProcessHUD(progress, view:progressView)
                    let moyaError:MoyaError = e as! MoyaError
                    if let code = moyaError.response?.statusCode, code == 200 {
                        success(nil, nil)
                        return
                    }
                    self.moyaErrorDes(moyaError, error)
                }
                
            }).disposed(by: self.sDisposeBag)
            
        }) { (e) in
            DispatchQueue.main.async {
                HttpProgressManager.hiddenProcessHUD(progress, view:progressView)
                let moyaError:MoyaError = e as! MoyaError
                self.moyaErrorDes(moyaError, error)
            }
            }.disposed(by: sDisposeBag)
    }
    
    /* 网络下载
     * params：包含方法，url，parmater
     * progress：下载进度
     * success：失败成功回调
     */
    public func uploadfile(_ params:T,
                           progress: @escaping (_ progress:Double)->(),
                           _ success: @escaping ((_ success:Bool)->())) {
        
        if let headerTagField = headerTagField {
            let tagHeader:[String : String] = [headerTagField : ResponseGetTag(params: params) ?? ""]
            let headers = self.headerMerge(tagHeader, params.headers)
            initProvider(headers)
        } else {
            initProvider(params.headers)
        }
        sProvider.request(params, progress: { (response) in
            progress(response.progress)
        }) { (result) in
            if case let .success(response) = result {
                //解析数据
                let data = try? response.mapString()
                print(data ?? "")
                success(true)
            } else {
                success(false)
            }
        }
    }
    
    //本地获取
    private func cacheExtract(_ params:T, _ extract:(_ data: Any?)->()) {
        
        let httpCacheManager = HttpCacheManager()
        let cache = httpCacheManager.retrive(fileName: cacheUrl(params))
        extract(cache)
        return
    }
    
    //url+参数
    private func cacheUrl(_ params:T) -> String {
        let keys = Array(params.parames.keys).sorted(by: <)
        let paramsStr = keys.joined(separator: ",")
        return params.path + paramsStr
    }
    
    //缓存本地
    private func cacheRestore(_ params: T, _ object: AnyObject) {
        let cache = HttpCacheManager()
        
        cache.store(fileName: cacheUrl(params), object: object) { (status) in
            guard status else {
                if isOpenConsoleOutput {
                    print("QueryManager Error. cache error, path:\(params.path)")
                }
                return
            }
        }
    }
    
    //错误处理
    private func moyaErrorDes(_ moyaError:MoyaError, _ error: HttpError) {
        let errorDes = moyaError.errorDescription ?? "NULL"
        let errorCode:Int = moyaError.response?.statusCode ?? -1
        
        if let reponseError = reponseError {
            reponseError(errorCode)
        }
        guard let resData = moyaError.response?.data else {
            error(errorDes, errorCode)
            return
        }
        let serverMsg = (NSString(data: resData, encoding: String.Encoding.utf8.rawValue) ?? "") as String
        error(serverMsg, errorCode)
    }
    
    //tag处理
    private func httpTagFilter(_ params:T, _ headerFileds:[AnyHashable : Any]?) -> Bool {
        guard let headerFileds = headerFileds else {
            return false
        }
        
        guard let headerTag:String = headerFileds[headerTagField] as? String, headerTag != "" else {
            return false
        }
        
        let tag = ResponseGetTag(params: params)
        if tag != headerTag {
            ResponseSetTag(params: params, tag: headerTag)
            return true
        }
        return false
    }
    
    //设置接口tag
    private func ResponseSetTag(params:T, tag:String) {
        let interface = cacheUrl(params)
        let key = interface + "-Tag"
        HttpTagManagerInstance.setTag(tag: tag, key: key.cm_MD5())
    }
    
    //获取接口Tag
    private func ResponseGetTag(params:T) -> (String?) {
        let interface = cacheUrl(params)
        let key = interface + "-Tag"
        return HttpTagManagerInstance.getTag(key: key.cm_MD5())
    }
    
}
