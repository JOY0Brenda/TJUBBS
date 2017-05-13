//
//  BBSUser.swift
//  TJUBBS
//
//  Created by Halcao on 2017/5/10.
//  Copyright © 2017年 twtstudio. All rights reserved.
//

import UIKit

let BBSUSERSHAREDKEY = "BBSUserSharedKey"

/*
 "name" : "用户名",
 "nickname" : "昵称",
 "real_name" : "真实姓名",
 "signature" : "个性签名",
 "post_count" : "发帖总数",
 "unread_count" : "未读消息总数",
 "points" : "积分",
 "level" : "等级",
 "c_online" : "上线次数",
 "group" : "用户组"
 */
//import ObjectMapper

class BBSUser {
    private init() {}
    static let shared = BBSUser()
    
    var username: String?
    var nickname: String?
    var realName: String?
    var signature: String?
    var postCount: String?
    var unreadCount: String?
    var points: String?
    var level: String?
    var token: String?
    var cOnline: String?
    var uid: Int?
    var group: Int?
    var avatar: UIImage?
    
//    required init?(map: Map) {}
//    
//    func mapping(map: Map) {
//        username <- map["username"]
//        nickname <- map["nickname"]
//        realName <- map["realName"]
//        signature <- map["signature"]
//        postCount <- map["postCount"]
//        unreadCount <- map["unreadCount"]
//        points <- map["points"]
//        level <- map["level"]
//        token <- map["token"]
//        cOnline <- map["cOnline"]
//        uid <- map["uid"]
//        group <- map["group"]
//    }
    
    
    
    static func save() {
        let dic: [String : Any] = ["username": BBSUser.shared.username ?? "", "token": BBSUser.shared.token ?? "", "uid": BBSUser.shared.uid ?? -1, "group": BBSUser.shared.group ?? -1]
        UserDefaults.standard.set(NSDictionary(dictionary: dic), forKey: BBSUSERSHAREDKEY)
    }
    
    static func load() {
        if let dic = UserDefaults.standard.object(forKey: BBSUSERSHAREDKEY) as? NSDictionary,
            let username = dic["username"] as? String,
            let token = dic["token"] as? String,
            let uid = dic["uid"] as? Int,
            let group = dic["group"] as? Int {
            BBSUser.shared.username = username
            BBSUser.shared.uid = (uid == -1) ? nil : uid
            BBSUser.shared.token = (token == "") ? nil : token
            BBSUser.shared.group = (group == -1) ? nil : group
        }
    }
    
    static func delete() {
        //TODO: ??????  delete "BBSUser.shared."
        BBSUser.shared.username = nil
        BBSUser.shared.token = nil
        BBSUser.shared.uid = nil
        BBSUser.shared.group = nil
        UserDefaults.standard.removeObject(forKey: BBSUSERSHAREDKEY)
    }
    
//    func getUserInfo()  {
//        BBSBeacon.request(withType: .get, url: BBSAPI.userInfo, token: token, parameters: nil, success: { dict in
//        }, failure: nil)
//    }
}

