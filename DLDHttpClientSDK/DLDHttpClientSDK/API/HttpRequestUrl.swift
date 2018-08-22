
//  BaseInfoApi.swift
//  Duliday
//
//  Created by tanglin on 04/01/2018.
//  Copyright © 2018 Duliday. All rights reserved.
//

import Foundation

// 域名 baseRequestURL
public enum RequestUrl:String {
    public typealias RawValue = String
    
    //基本配置信息
    case metaInfo = "/api/common/meta"   //元信息
    case cities = "/api/common/cities"     //获取城市列表
    case jobTypes = "/api/common/job/profiles"   //获取兼职类型大类
    case jobList = "/api/c/jobs"    //兼职列表查询
    case brandjob = "/api/common/organizations"    //品牌兼职列表
    case banner = "/api/c/event/byid"   //首页轮播图
    case cash = "/api/c/wallet/cash"    //申请提现
    case advertcs = "/api/c/advertcs"    //广告
    case advertcsFlow = "/api/c/advertxs"    //信息流
    case userResume = "/api/c/resume" // 个人信息
    case register = "/api/auth/sign-up" // 注册    
	
	case messageCount = "/api/c/messagelogcount" // 未读消息个数
	case messageLogs = "/api/c/messagelogs" // 查询消息
    
    case jobUrl = "/api/common/job/url" //兼职链接
    case jobEnquiry = "/api/c/job/enquiry"  //报名状态
    case jobDetail = "/api/c/job" //兼职详情
    case jobContacts = "/api/c/job/contacts" //联系方式
    case signProgress = "/api/c/sign-up/progress"  //报名进度
    case signLogs = "/api/c/sign-up/logs"  //报名日志
    
    case brandOrganization = "/api/common/organization"   //品牌商家
    case organizationEvaluete = "/api/c/organization/evaluates"  //商家评价
    case organizationShareUrl = "/api/common/organization/url"   //品牌分享url
    case companyProfile = "/api/b/profile" //企业资料
    
    case jobStatistics = "/api/common/job/statistics" //统计兼职浏览
    case jobAddressByorder = "/api/c/job/addresses/byorder"  //多地址工作详情地址
    case jobAddressSubway = "/api/c/job/address/subway"  //距离地铁站距离
    
    case jobCollectionDel = "/api/c/job/collection/delete"  //取消工作收藏
    case jobCollectionAdd = "/api/c/job/collect"  //添加工作收藏
    case jobSinupValid = "/api/c/sign-up/available"  //能否报名
    case insuranceCreate = "/api/c/mvp/insurance/create" //保险
    
    case jobSignUp = "/api/c/sign-up" //申请报名
    case jobUpdate = "/api/c/sign-up/update" //更新
    case resumeUpdate = "/api/c/resume/update" //修改个人简历
    case jobComments = "/api/c/job/comments"   //工作评论列表
    case mvpResume = "/api/c/mvp/resume" //专属审核

}
