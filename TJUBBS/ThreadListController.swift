//
//  ThreadListController.swift
//  TJUBBS
//
//  Created by Halcao on 2017/5/9.
//  Copyright © 2017年 twtstudio. All rights reserved.
//

import UIKit
import ObjectMapper
import MJRefresh
import Kingfisher
import PKHUD

class ThreadListController: UIViewController {
    
    var tableView: UITableView?
    var board: BoardModel?
    var threadList: [ThreadModel] = []
    var curPage: Int = 0
    
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
        
        // 右侧按钮
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
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
        
        // 把返回换成空白
        let backItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        self.navigationItem.backBarButtonItem = backItem

        
        self.tableView?.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(self.refresh))
        self.tableView?.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(self.load))
        self.tableView?.mj_footer.isAutomaticallyHidden = true
        self.tableView?.mj_header.beginRefreshing()
    }
    
    func addButtonTapped() {
        let addVC = AddThreadViewController()
        addVC.selectedBoard = self.board
        addVC.tableView.allowsSelection = false
        self.navigationController?.pushViewController(addVC, animated: true)
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
        let thread = threadList[indexPath.row]
        cell.initUI(thread: thread)

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
        let detailVC = PostDetailViewController(thread: threadList[indexPath.row])
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}


extension ThreadListController {
    func refresh() {
        
        BBSJarvis.getThreadList(boardID: board!.id, page: 0) {
            dict in
            if let data = dict["data"] as? Dictionary<String, Any>,
                let threads = data["thread"] as? Array<Dictionary<String, Any>> {
                if (self.tableView?.mj_header.isRefreshing())! {
                    self.tableView?.mj_header.endRefreshing()
                }
                self.curPage = 0
                self.threadList = Mapper<ThreadModel>().mapArray(JSONArray: threads) ?? self.threadList
            }
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
        }
    }
    
    func load() {
        self.curPage += 1
        BBSJarvis.getThreadList(boardID: board!.id, page: curPage, failure: { error in
            HUD.flash(.labeledError(title: "网络错误...", subtitle: nil), onView: self.view, delay: 1.2, completion: nil)
            if (self.tableView?.mj_footer.isRefreshing())! {
                self.tableView?.mj_footer.endRefreshing()
            }
        }) {
            dict in
            if let data = dict["data"] as? Dictionary<String, Any>,
                let threads = data["thread"] as? Array<Dictionary<String, Any>> {
                if (self.tableView?.mj_footer.isRefreshing())! {
                    self.tableView?.mj_footer.endRefreshing()
                }
                let newList = Mapper<ThreadModel>().mapArray(JSONArray: threads) ?? []
                if newList.count == 0 {
                    self.tableView?.mj_footer.endRefreshingWithNoMoreData()
                }
                self.threadList += newList
            }
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
        }
    }
}
