//
//  HttpRequestPSEUrl.swift
//  Duliday
//
//  Created by Frank liao on 2018/8/1.
//  Copyright © 2018年 Duliday. All rights reserved.
//

import Foundation

// 域名 baseRequestPSEURL
public enum RequestPSEUrl:String {
    public typealias RawValue = String
    
    case urlPse = "persistence" // persistence域名
    
    case jobFilters = "/c/mvp/job/filters" // 筛选项
    case jobListMVP = "/c/mvp/job/list" // 工作列表
    case jobDetailKeeper = "/c/mvpJob/%@" // 工作详情(单个工作)
    case saveUserProfile = "/c/resume/userprofile/save" // 新增或修改用户profile
    case getUserProfile = "/c/resume/userprofile/rigid" // 查询求职意向信息 （硬性，第一步，第二步）
    case updateJobIntention = "/c/resume/userprofile/jobIntention/update" //     修改用户求职意向
    case getButlerList = "/c/butler/query/getlist" // 管家列表查询
    case userprofileFlexible = "/c/resume/userprofile/flexible" //求职意向信息查询
    case updateDefaultAddress = "/c/resume/userprofile/defaultAddress/update" // 修改用户默认地址
    case jobCommentTotal = "/c/jobcomment/query/gettotal" // 咨询数
    case checkmvp = "/c/resume/userprofile/checkmvp" // 新老用户
    case resource = "/c/mvp/%@/resource/%@" //信息流，启动弹窗，常驻
}

