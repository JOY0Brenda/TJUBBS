//
//  SearchViewController.swift
//  TJUBBS
//
//  Created by Halcao on 2017/10/3.
//  Copyright © 2017年 twtstudio. All rights reserved.
//

import UIKit
import Kingfisher
import PKHUD

fileprivate typealias User = UserWrapper

fileprivate enum SearchType: Int {
    case thread = 0
    case user
}

class SearchViewController: UIViewController {
    var searchBar: UISearchBar!
    var tableView: UITableView!
    var threadList: [ThreadModel] = []
    fileprivate var searchType: SearchType = .thread
    fileprivate var userList: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 设置 searchBar 样式
        searchBar = UISearchBar()
        searchBar.showsScopeBar = true
        searchBar.barTintColor = .white
//        searchBar.prompt = "搜索"
        searchBar.placeholder = "搜索"
        searchBar.scopeButtonTitles = ["主题", "用户"]
        searchBar.delegate = self
//        searchBar.becomeFirstResponder()
        
        // KVC 注意了 面试一定会问
        if let searchField = searchBar.value(forKey: "searchField") as? UITextField {
            searchField.backgroundColor = UIColor(colorLiteralRed: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1)
            searchField.becomeFirstResponder()
//            searchField.text = "搜点什么吧！"
        }

        tableView = UITableView(frame: self.view.bounds, style: .plain)
//        tableView = UITableView(frame: self.view.bounds, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PostCell.self, forCellReuseIdentifier: "postCell")
        tableView.register(MessageCell.self, forCellReuseIdentifier: "friendCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200

        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBarTextDidEndEditing(searchBar)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//    }
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let searchText = searchBar.text?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            return
        }
        
        switch searchType {
        case .thread:
            BBSJarvis.getThread(by: searchText, page: 0, failure: { error in
                HUD.flash(.label("获取主题信息失败..."), delay: 1.2)
            }, success: { threadList in
                self.threadList = threadList
                self.tableView.reloadData()
            })
        case .user:
            BBSJarvis.getUser(by: searchText, failure: { error in
                HUD.flash(.label("获取用户信息失败..."), delay: 1.2)
            }, success: { userList in
                self.userList = userList
                self.tableView.reloadData()
            })
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        // 如果失败等于原值
//        searchType = SearchType(rawValue: selectedScope) ?? searchType
        if let type = SearchType(rawValue: selectedScope) {
            searchType = type
            tableView.reloadData()
            searchBarTextDidEndEditing(searchBar)
        }
    }

}


// MARK: UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return searchBar
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch searchType {
        case .thread:
            let thread = threadList[indexPath.row]
            let threadVC = ThreadDetailViewController(tid: thread.id)
            self.navigationController?.pushViewController(threadVC, animated: true)
        case .user:
            let user = userList[indexPath.row]
            let userVC = UserDetailViewController(uid: user.uid ?? 0)
            self.navigationController?.pushViewController(userVC, animated: true)
        }

    }
}

// MARK: UITableViewDataSource
extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch searchType {
        case .thread:
            let cell = tableView.dequeueReusableCell(withIdentifier: "postCell") as! PostCell
            let data = threadList[indexPath.row]
            cell.initUI(thread: data)
            cell.boardButton.isHidden = true
            cell.boardButton.addTarget { _ in
                let boardVC = ThreadListController(bid: data.boardID)
                self.navigationController?.pushViewController(boardVC, animated: true)
            }
            if data.anonymous == 0 { // exclude anonymous user
                cell.usernameLabel.addTapGestureRecognizer { _ in
                    let userVC = UserDetailViewController(uid: data.authorID)
                    self.navigationController?.pushViewController(userVC, animated: true)
                }
                cell.portraitImageView.addTapGestureRecognizer { _ in
                    let userVC = UserDetailViewController(uid: data.authorID)
                    self.navigationController?.pushViewController(userVC, animated: true)
                }
            } else {
                cell.usernameLabel.gestureRecognizers?.removeAll()
                cell.portraitImageView.gestureRecognizers?.removeAll()
            }
            return cell
        case .user:
            let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell") as! MessageCell
            let model = userList[indexPath.row]
            
            cell.initUI(portraitImage: nil, username: model.username ?? "好友", time: "0", detail: model.signature ?? "")
            let portraitImage = UIImage(named: "default")
            let url = URL(string: BBSAPI.avatar(uid: model.id ?? 0))
            let cacheKey = "\(model.id ?? 0)" + Date.today
            cell.portraitImageView.kf.setImage(with: ImageResource(downloadURL: url!, cacheKey: cacheKey), placeholder: portraitImage)
            cell.timeLabel.isHidden = true
            if model.id != 0 { // exclude anonymous user
                cell.portraitImageView.addTapGestureRecognizer { _ in
                    let userVC = UserDetailViewController(uid: model.id ?? 0)
                    self.navigationController?.pushViewController(userVC, animated: true)
                }
            }
            return cell
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchType == .thread ? threadList.count : userList.count
    }
}
