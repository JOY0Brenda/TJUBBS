//
//  ThreadListController.swift
//  TJUBBS
//
//  Created by Halcao on 2017/5/9.
//  Copyright © 2017年 twtstudio. All rights reserved.
//

import UIKit
import ObjectMapper
//class ThreadListController: UIViewController {
//    var currentPage = 1
//    var threads: [ThreadModel] = []
//    var tableView: UITableView! = nil
//    var listName: String = ""
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        tableView = UITableView(frame: self.view.bounds, style: .grouped)
//        tableView?.delegate = self
//        tableView?.dataSource = self
//        self.title = listName
//
//        
//        // 把返回换成空白
//        let backItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
//        self.navigationItem.backBarButtonItem = backItem
//
//        // Do any additional setup after loading the view.
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//}
//
//extension ThreadListController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//    }
//}
//
//extension ThreadListController: UITableViewDataSource {
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return threads.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        return UITableViewCell()
//    }
//}



class ThreadListController: UIViewController {
    
    var tableView: UITableView?
//    var dataList = [
//        [
//            "image": "portrait",
//            "username": "wangcong",
//            "category": "全站热点",
//            "title": "厉害了word天大！4项成果获得了2016年国家科技奖",
//            "detail": "今天我突然想到天外天，天大bbs，上来看看，好多年没上了，竟然还能用！我 98 级的，一晃这么多年过去了，想当年，这里多热闹啊！",
//            "replyNumber": "20",
//            "time": "1494061223"
//        ],
//        [
//            "image": "portrait",
//            "username": "yqzhufeng",
//            "title": "3月26日周日百人狼人单身趴",
//            "replyNumber": "20",
//            "time": "1494061223"
//        ],
//        [
//            "image": "portrait",
//            "username": "yqzhufeng",
//            "title": "3月26日周日百人狼人单身趴",
//            "replyNumber": "20",
//            "time": "1494061223"
//        ],
//        [
//            "image": "portrait",
//            "username": "wangcong",
//            "category": "全站热点",
//            "title": "厉害了word天大！4项成果获得了2016年国家科技奖",
//            "detail": "今天我突然想到天外天，天大bbs，上来看看，好多年没上了，竟然还能用！我 98 级的，一晃这么多年过去了，想当年，这里多热闹啊！",
//            "replyNumber": "20",
//            "time": "1494061223"
//        ],
//        [
//            "image": "portrait",
//            "username": "yqzhufeng",
//            "title": "3月26日周日百人狼人单身趴",
//            "replyNumber": "20",
//            "time": "1494061223"
//        ]
//        ] as Array<Dictionary<String, String>>
    var board: BoardModel?
    var threadList: [ThreadModel] = []
    
    convenience init(board: BoardModel?) {
        self.init()
        self.board = board
        view.backgroundColor = .lightGray
        UIApplication.shared.statusBarStyle = .lightContent
        self.hidesBottomBarWhenPushed = true
        initUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        BBSJarvis.getThreadList(boardID: board!.id, page: 0) {
            dict in
            if let data = dict["data"] as? Dictionary<String, Any>,
                let threads = data["thread"] as? Array<Dictionary<String, Any>> {
                self.threadList = Mapper<ThreadModel>().mapArray(JSONArray: threads) ?? []
            }
            self.tableView?.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func initUI() {
        tableView = UITableView(frame: .zero, style: .grouped)
        view.addSubview(tableView!)
        tableView?.snp.makeConstraints {
            make in
            make.top.equalToSuperview().offset(0)
            make.left.right.bottom.equalToSuperview()
        }
        tableView?.register(PostCell.self, forCellReuseIdentifier: "postCell")
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.rowHeight = UITableViewAutomaticDimension
        tableView?.estimatedRowHeight = 300
    }
}

extension ThreadListController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return threadList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell") as! PostCell
        let data = threadList[indexPath.row]
        //        print(data["username"]!)
        let portraitImage = UIImage(named: "头像")
        cell.initUI(portraitImage: portraitImage, username: data.authorName, category: data.category, favor: false, title: data.title, detail: data.content, replyNumber: String(data.replyNumber), time: String(data.createTime))
        
        return cell
    }
    
    //TODO: Better way to hide first headerView
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
}

extension ThreadListController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detailVC = PostDetailViewController()
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}

