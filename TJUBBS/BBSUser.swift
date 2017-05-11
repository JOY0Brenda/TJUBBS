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

class BBSUser {
    private init() {}
    static let shared = BBSUser()
    var username: String?
    var token: String?
    var uid: Int?
    var group: Int?
    
    func save() {
        let dic: [String : Any] = ["username": username ?? "", "token": token ?? "", "uid": uid ?? -1, "group": group ?? -1]
        UserDefaults.standard.set(NSDictionary(dictionary: dic), forKey: BBSUSERSHAREDKEY)
    }
    
    func load() {
        if let dic = UserDefaults.standard.object(forKey: BBSUSERSHAREDKEY) as? NSDictionary,
            let username = dic["username"] as? String,
            let token = dic["token"] as? String,
            let uid = dic["uid"] as? Int,
            let group = dic["group"] as? Int {
            self.username = username
            self.uid = (uid == -1) ? nil : uid
            self.token = (token == "") ? nil : token
            self.group = (group == -1) ? nil : group
        }
    }
    
    func delete() {
        BBSUser.shared.username = nil
        BBSUser.shared.token = nil
        BBSUser.shared.uid = nil
        BBSUser.shared.group = nil
        UserDefaults.standard.removeObject(forKey: BBSUSERSHAREDKEY)
    }
}
