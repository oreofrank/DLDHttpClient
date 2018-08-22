import Foundation

let UpdateWindow:UIWindow = UIWindow()
let UpdateVC = ForceUpdateViewController()

class HttpQueryUnmind {
    
    class func commend(data: Any?) -> Bool {
        guard let dic = data as? NSDictionary  else {
            return false
        }
        let statusCode = dic.object(forKey: "code") as? Int
        if statusCode == 600 {
            let message = dic.object(forKey: "message") as? String ?? ""
          
            UpdateVC.view.backgroundColor = UIColor.clear
            UpdateVC.message = message
            UpdateWindow.rootViewController = UpdateVC
            UpdateWindow.makeKeyAndVisible()
            UpdateWindow.backgroundColor = UIColor.clear
            
            return true
        } else if statusCode == 700 {
//            MaintainWebInstance.add(urlStr: Http_error)
            return true
        }
        return false
    }
    
}

class ForceUpdateViewController:UIViewController {
    var message:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showAlertController()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ForceUpdateViewController.applicationDidBecomeActive(_:)), name: .UIApplicationDidBecomeActive, object: nil)
    }
    
    @objc func applicationDidBecomeActive(_ application: UIApplication) {
        self.showAlertController()
    }
    
    func showAlertController() {
        let alertController = UIAlertController(title: "系统提示",
                                                message: message, preferredStyle: .alert)
        alertController.view.backgroundColor = UIColor.clear
        let okAction = UIAlertAction(title: "立即更新", style: .default, handler: {
            action in
//            OpenUrl.open(scheme: Url_to_dulidayC)
        })
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
}
