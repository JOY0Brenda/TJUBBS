//
//  BBSJarvis.swift
//  TJUBBS
//
//  Created by Halcao on 2017/5/10.
//  Copyright © 2017年 twtstudio. All rights reserved.
//

import UIKit
import ObjectMapper

struct BBSJarvis {
    
    static func login(username: String, password: String, failure: ((Error)->())? = nil, success:@escaping ()->()) {
        let para: [String : String] = ["username": username, "password": password]
        BBSBeacon.request(withType: .post, url: BBSAPI.login, parameters: para) { dict in
            if let data = dict["data"] as? [String: Any] {
                BBSUser.shared.uid = data["uid"] as? Int
                BBSUser.shared.group = data["group"] as? Int
                BBSUser.shared.token = data["token"] as? String
                BBSUser.shared.username = username
                // 用 UserDefaults 存起来 BBSUser.shared
                BBSUser.save()
            }
            success()
        }
    }
    
    static func register(parameters: [String : String], failure: ((Error)->())? = nil, success: @escaping ([String: Any])->()) {
        BBSBeacon.request(withType: .post, url: BBSAPI.register, parameters: parameters, failure: failure, success: success)
    }
    
    static func getHome(success: (()->())?, failure: @escaping ()->()) {
        BBSBeacon.request(withType: .get, url: BBSAPI.home, parameters: nil) { dict in
            if let data = dict["data"] as? [String: Any],
                let name = data["name"],
                let nickname = data["nickname"],
                //                let real_name = data["real_name"],
                let signature = data["signature"],
                let post_count = data["c_post"],
                let thread_count = data["c_thread"],
                let unread_count = data["c_unread"],
                let tCreate = data["t_create"],
                let points = data["points"],
                let level = data["level"],
                let c_online = data["c_online"],
                let group = data["group"] {
                BBSUser.shared.username = name as? String
                BBSUser.shared.nickname = (nickname as? String) ?? (name as? String)
                //                BBSUser.shared.realName = real_name as? String
                BBSUser.shared.signature = signature as? String
                BBSUser.shared.postCount = post_count as? Int
                BBSUser.shared.unreadCount = unread_count as? Int
                BBSUser.shared.points = points as? Int
                BBSUser.shared.level = level as? Int
                BBSUser.shared.cOnline = c_online as? Int
                BBSUser.shared.group = group as? Int
                BBSUser.shared.threadCount = thread_count as? Int
                BBSUser.shared.tCreate = tCreate as? Int
                BBSUser.save()
            } else if let err = dict["err"] as? Int, err == 0 {
                failure()
            }
        }
    }
    
    static func getAvatar(success:@escaping (UIImage)->(), failure: @escaping ()->()) {
        BBSBeacon.requestImage(url: BBSAPI.avatar, success: success)
    }
    
    static func setAvatar(image: UIImage, success:@escaping ()->(), failure: @escaping (Error)->()) {
        BBSBeacon.uploadImage(url: BBSAPI.setAvatar, image: image, failure: failure, success: success)
    }
    
    static func setInfo(para: [String : String], success: @escaping ()->(), failure: @escaping (Error)->()) {
        BBSBeacon.request(withType: .put, url: BBSAPI.home, parameters: para, failure: failure) { dict in
            success()
        }
    }

    static func getForumList(failure: ((Error)->())? = nil, success: @escaping ([String: Any])->()) {
        BBSBeacon.request(withType: .get, url: BBSAPI.forumList, token: nil, parameters: nil, failure: failure, success: success)
    }
    
    static func getBoardList(forumID: Int, failure: ((Error)->())? = nil, success: @escaping ([String: Any])->()) {
        BBSBeacon.request(withType: .get, url: BBSAPI.boardList(forumID: forumID), token: nil, parameters: nil, failure: failure, success: success)
    }
    
    static func getThreadList(boardID: Int, page: Int, type: String = "", failure: ((Error)->())? = nil, success: @escaping ([String: Any])->()) {
        print("API:\(BBSAPI.threadList(boardID: boardID, page: page, type: type))")
        BBSBeacon.request(withType: .get, url: BBSAPI.threadList(boardID: boardID, page: page, type: type), parameters: nil, success: success)
    }

    //TODO: cache Homepage
    static func getIndex(failure: ((Error)->())? = nil, success: @escaping ([String: Any])->()) {
        BBSBeacon.request(withType: .get, url: BBSAPI.index, parameters: nil, success: success)
    }
    
    static func getThread(threadID: Int, page: Int, failure: ((Error)->())? = nil, success: @escaping ([String: Any])->()) {
        BBSBeacon.request(withType: .get, url: BBSAPI.thread(threadID: threadID, page: page), parameters: nil, success: success)
    }

    
    static func postThread(boardID: Int, title: String, content: String, failure: ((Error)->())? = nil, success: @escaping ([String: Any])->()) {
        let parameters = [
            "title": title,
            "content": content
        ]
        print("API:\(BBSAPI.postThread(boardID: boardID))")
        print(parameters)
        BBSBeacon.request(withType: .post, url: BBSAPI.postThread(boardID: boardID), parameters: parameters, success: success)
    }
    
    static func getMsgList(page: Int, failure: ((Error)->())? = nil, success: @escaping ([MessageModel])->()) {
        BBSBeacon.request(withType: .get, url: BBSAPI.message(page: page), parameters: nil, failure: failure) { dict in
            if let data = dict["data"] as? [[String: Any]] {
                var msgList = Array<MessageModel>()
                for msg in data {
                    let model = MessageModel(JSON: msg)
                    if var model = model {
                        if (msg["content"] as? String) != nil {
                            msgList.append(model)
                        } else if let content = msg["content"] as? [String : Any] {
                            let contentModel = MessageContentModel(JSON: content)
                            model.detailContent = contentModel
                            msgList.append(model)
                        }
                    }
                }
                success(msgList)
            }
        }
    }
    

    static func reply(threadID: Int, content: String, toID: Int? = nil, failure: ((Error)->())? = nil, success: @escaping ([String: Any])->()) {
        var parameters = ["content": content]
        if let id = toID {
            parameters["reply"] = String(id)
        }
        BBSBeacon.request(withType: .post, url: BBSAPI.reply(threadID: threadID), parameters: parameters, success: success)
    }
    
    static func getMessage(page: Int, failure: ((Error)->())? = nil, success: @escaping ([String: Any])->()) {
        BBSBeacon.request(withType: .get, url: BBSAPI.reciveMessage(page: page), parameters: nil, success: success)
    }
    
    static func collect(threadID: Int, failure: ((Error)->())? = nil, success: @escaping ([String: Any])->()) {
        let parameters = ["tid": "\(threadID)"]
        BBSBeacon.request(withType: .post, url: BBSAPI.collect, parameters: parameters, success: success)
    }
    
    static func deleteCollect(threadID: Int, failure: ((Error)->())? = nil, success: @escaping ([String: Any])->()) {
        BBSBeacon.request(withType: .delete, url: BBSAPI.deleteCollection(threadID: threadID), parameters: nil, success: success)
    }
    
    static func getCollectionList(failure: ((Error)->())? = nil, success: @escaping ([String: Any])->()) {
        BBSBeacon.request(withType: .get, url: BBSAPI.collect, parameters: nil, success: success)
    }
    
    static func getMyThreadList(page: Int, failure: ((Error)->())? = nil, success: @escaping ([String: Any])->()) {
        BBSBeacon.request(withType: .get, url: BBSAPI.myThreadList(page: page), parameters: nil, success: success)
    }
}
