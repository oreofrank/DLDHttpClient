//
//  HttpClientManager.swift
//  bdcreditAppSwift
//
//  Created by TANG LIN on 2017/5/26.
//  Copyright © 2017年 贾仕琪. All rights reserved.
//

import Foundation
import RxSwift
import Moya

let dispose = DisposeBag()
let reponseError:HttpReponseError = { (errorCode) in
    if errorCode == 401 {
        //NotificationCenter.default.post(name: loginAgainNotification, object: nil)
    }
}

let HttpClient = HttpClientManager.sharedInstance

class HttpClientManager {
    
    static let sharedInstance = HttpClientManager().createQuery(dispose: dispose, reponseErrorCode: reponseError)
    
    init() {
    }
    
    func createQuery(dispose: DisposeBag, reponseErrorCode:@escaping HttpReponseError) -> QueryBall<RequestType> {
        
        return QueryManager<RequestType>.createQuery(dispose: dispose, reponseErrorCode:reponseErrorCode)
    }
    
}
