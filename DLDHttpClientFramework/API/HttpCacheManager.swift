//
//  HttpCache.swift
//  Duliday
//  http 缓存
//  Created by liaohai on 2018/1/23.
//  Copyright © 2018年 Duliday. All rights reserved.
//

import Foundation
import HandyJSON

class HttpCacheModel:NSObject, NSCoding {
    var result:Any!
    
    required override init() {
        super.init()
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.result, forKey: "HttpCacheResult")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.result = aDecoder.decodeObject(forKey: "HttpCacheResult")
    }
}

public class HttpCacheManager {
    
    private let ioQueue: DispatchQueue
    private var fileManager: FileManager!
    var diskCachePath:String
    
    public init() {
        ioQueue = DispatchQueue(label: "DLD.HttpCache.ioQueue")
        
        //获取缓存目录
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        
        diskCachePath = (paths.first! as NSString).appendingPathComponent("HttpCache")
        
        ioQueue.sync {
            self.fileManager = FileManager()
            //先创建好对象的文件夹
            do {
                try self.fileManager.createDirectory(atPath: self.diskCachePath, withIntermediateDirectories: true, attributes: nil)
            } catch _ {}
        }
    }
    
    //MD5文件
    func fileMd5(_ file: String) -> String {
        
        return (diskCachePath as NSString).appendingPathComponent(file.hc_MD5())
    }
    
    //MARK: 归档的方法
    func store(fileName: String, object: AnyObject, _ completeHandler:@escaping ((_ status:Bool)->())) {
        let name = fileMd5(fileName)
        ioQueue.async {
            let status = NSKeyedArchiver.archiveRootObject(object, toFile: name )
            completeHandler(status)
        }
    }
    
    //MARK: 解档的方法
    func retrive(fileName: String) -> Any? {
        let name = fileMd5(fileName)
        
        return NSKeyedUnarchiver.unarchiveObject(withFile: name)
    }
    
    public func cleanCatch() {
        do {
            try self.fileManager.removeItem(atPath: self.diskCachePath)
        } catch {
            print("HttpCacheManager removeItem error")
        }
    }
}

let HttpTagManagerInstance = HttpTagManager.sharedInstance

class HttpTagManager {
    
    static let sharedInstance = HttpTagManager()
    
    private let ioQueue: DispatchQueue
    private var fileManager: FileManager!
    var diskTagPath:String
    let diskTagfile:String = "cacheTag.plist"
    
    init() {
        ioQueue = DispatchQueue(label: "DLD.HttpTag.ioQueue")
        
        //获取缓存目录
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        
        diskTagPath = (paths.first! as NSString).appendingPathComponent("HttpTag")
        
        ioQueue.sync {
            self.fileManager = FileManager()
            //先创建好对象的文件夹
            do {
                try self.fileManager.createDirectory(atPath: self.diskTagPath, withIntermediateDirectories: true, attributes: nil)
            } catch _ {}
        }
        
    }
    
    /**
     创建文件
     - parameter name:        文件名
     - parameter fileBaseUrl: url
     - returns: 文件路径
     */
    private func creatNewFiles(name:String) -> String {
        if !fileManager.fileExists(atPath: diskTagPath) {
            do {
                try self.fileManager.createDirectory(atPath: self.diskTagPath, withIntermediateDirectories: true, attributes: nil)
            } catch _ {}
        }
        let file:URL = URL(string: diskTagPath)!.appendingPathComponent(name)
        
        let exist = fileManager.fileExists(atPath: file.path)
        if !exist {
            let createFilesSuccess = fileManager.createFile(atPath: file.path, contents: nil, attributes: nil)
            print("文件创建结果: \(createFilesSuccess)")
        }
        return String(describing: file)
    }
    
    //设置接口tag
    func setTag(tag:String, key:String) {
        let filePath = creatNewFiles(name: diskTagfile)
        let diskTagDataInfo = NSMutableDictionary(contentsOfFile: filePath) ?? [:]
        diskTagDataInfo.setObject(tag, forKey: key as NSString)
        diskTagDataInfo.write(to: URL.init(fileURLWithPath: filePath), atomically: true)
    }
    
    //获取接口Tag
    func getTag(key:String) -> String? {
        let filePath = creatNewFiles(name: diskTagfile)
        let diskTagDataInfo = NSMutableDictionary(contentsOfFile: filePath) ?? [:]
        return diskTagDataInfo[key] as? String
    }
}
