//
//  MessageDetailViewController.swift
//  TJUBBS
//
//  Created by JinHongxu on 2017/5/9.
//  Copyright © 2017年 twtstudio. All rights reserved.
//

import UIKit
import PKHUD
import Kingfisher

class MessageDetailViewController: UIViewController {
    
    var tableView: UITableView?
    var model: MessageModel! = nil
//    var replyButton: UIButton?
    var replyButton = FakeTextFieldView(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height-64-45, width: UIScreen.main.bounds.size.width, height: 45))
    
    
    convenience init(model: MessageModel) {
        self.init()
        view.backgroundColor = .lightGray
        UIApplication.shared.statusBarStyle = .lightContent
        self.hidesBottomBarWhenPushed = true
        self.title = "详情"
        self.model = model
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView = UITableView(frame: .zero, style: .grouped)
        self.navigationController?.navigationBar.isTranslucent = false
        self.tableView?.contentInset.top = -35

        view.addSubview(tableView!)
        tableView?.snp.makeConstraints {
            make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-45)
        }

        tableView?.dataSource = self
        tableView?.rowHeight = UITableViewAutomaticDimension
        tableView?.estimatedRowHeight = 100
        tableView?.allowsSelection = false
        
//        replyButton = UIButton()
//        self.view.addSubview(replyButton!)
//        replyButton?.setBackgroundImage(UIImage(named: "inputBar"), for: .normal)
//        replyButton?.snp.makeConstraints { make in
//            make.top.equalTo(tableView!.snp.bottom)
//            make.left.right.bottom.equalToSuperview()
//        }
//        replyButton.adjustsImageWhenHighlighted = false
        self.view.addSubview(replyButton)
//        replyButton.frame = CGRect(x: 0, y: self.view.height-64-45, width: self.view.width, height: 45)
        replyButton.draw(replyButton.frame)
//        replyButton.snp.makeConstraints { make in
//            make.top.equalTo(tableView!.snp.bottom)
//            make.left.right.bottom.equalToSuperview()
//        }
        replyButton.addTapGestureRecognizer { btn in
            self.replyButtonDidTap(sender: UIButton())
        }
//        replyButton.addTarget(self, action: #selector(self.replyButtonDidTap(sender:)), for: .touchUpInside)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension MessageDetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = MessageCell()
            cell.initUI(portraitImage: nil, username: model.authorName, time: String(model.createTime), detail: "")
            let portraitImage = UIImage(named: "default")
            
            let url = URL(string: BBSAPI.avatar(uid: model.authorId))
            let cacheKey = "\(model?.authorId ?? 0000)" + Date.today
            cell.portraitImageView.kf.setImage(with: ImageResource(downloadURL: url!, cacheKey: cacheKey), placeholder: portraitImage)

            cell.timeLabel.isHidden = true
            return cell
        case 1:
            let cell = UITableViewCell()
            guard let detailedModel = model.detailContent else {
                let detailLabel = UILabel(text: model.content, fontSize: 16)
                cell.contentView.addSubview(detailLabel)
                detailLabel.snp.makeConstraints {
                    make in
                    make.top.equalToSuperview().offset(8)
                    make.left.equalToSuperview().offset(16)
                    make.right.equalToSuperview().offset(-16)
//                    make.bottom.equalToSuperview().offset(-8)
                }
                detailLabel.numberOfLines = 0
                let timeString = TimeStampTransfer.string(from: String(model.createTime), with: "MM-dd HH:mm")
                let timeLabel = UILabel(text: timeString, color: .lightGray)
                cell.contentView.addSubview(timeLabel)
                timeLabel.snp.makeConstraints {
                    make in
                    make.top.equalTo(detailLabel.snp.bottom).offset(8)
                    make.right.equalToSuperview().offset(-16)
                    make.bottom.equalToSuperview().offset(-8)
                }
                
                return cell
            }
            
            let summary = "回复了你:\n" + String.clearBBCode(string: detailedModel.content)
            let detailLabel = UILabel(text: summary, fontSize: 16)
            detailLabel.numberOfLines = 0
            cell.contentView.addSubview(detailLabel)
            detailLabel.snp.makeConstraints {
                make in
                make.top.equalToSuperview().offset(8)
                make.left.equalToSuperview().offset(16)
                make.right.equalToSuperview().offset(-16)
            }
            detailLabel.numberOfLines = 0
            
            let postLabel = UILabel(text: "原文：")
            postLabel.sizeToFit()
            cell.contentView.addSubview(postLabel)
            postLabel.snp.makeConstraints {
                make in
                make.top.equalTo(detailLabel.snp.bottom).offset(8)
                make.left.equalToSuperview().offset(16)
            }
            
            let postView = UIView()
            cell.contentView.addSubview(postView)
            let titleLabel = UILabel(text: "主题贴: " + detailedModel.thread_title)
            titleLabel.numberOfLines = 0

            postView.backgroundColor = UIColor(red:0.96, green:0.96, blue:0.97, alpha:1.00)
            postView.layer.cornerRadius = 3
            postView.layer.borderColor = UIColor(red:0.91, green:0.92, blue:0.92, alpha:1.00).cgColor
            postView.layer.borderWidth = 2
            
            postView.addSubview(titleLabel)
            titleLabel.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(8)
                make.left.equalToSuperview().offset(8)
                make.right.equalToSuperview().offset(-8)
                make.bottom.equalToSuperview().offset(-8)
            }
            
            postView.snp.makeConstraints { make in
                make.top.equalTo(postLabel.snp.bottom).offset(8)
                make.left.equalToSuperview().offset(16)
                make.right.equalToSuperview().offset(-16)
            }
            
            postView.addTapGestureRecognizer(block: { _ in
                print("bang!!!!!")
                let detailVC = ThreadDetailViewController(tid: detailedModel.thread_id)
                self.navigationController?.pushViewController(detailVC, animated: true)
            })
            
            let timeString = TimeStampTransfer.string(from: String(detailedModel.createTime), with: "MM-dd HH:mm")
            let timeLabel = UILabel(text: timeString, color: .lightGray)
            cell.contentView.addSubview(timeLabel)
            timeLabel.sizeToFit()
            timeLabel.snp.makeConstraints {
                make in
//                make.top.equalTo(postView.snp.bottom).offset(8)
                make.top.equalTo(postView.snp.bottom).offset(8)
                make.right.equalToSuperview().offset(-16)
                make.bottom.equalToSuperview().offset(-8)
            }
            
            //TODO: Input View
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func replyButtonDidTap(sender: UIButton) {
        guard let detailedModel = model.detailContent else {
            return
        }
        let editDetailVC = EditDetailViewController()
        editDetailVC.title = "回复 " + model.authorName
        // FIXME: 匿名回复
        editDetailVC.canAnonymous = detailedModel.allow_anonymous == 1
        editDetailVC.doneBlock = { [weak editDetailVC] string in
            let origin = detailedModel.content
            // cut secondary quotation
            let cutString = origin.replacingOccurrences(of: "> >.*", with: "", options: .regularExpression, range: nil)
            let resultString = string + "\n > 回复 #\(detailedModel.floor) \(self.model.authorName): \n" + cutString.replacingOccurrences(of: ">", with: "> >", options: .regularExpression, range: nil)
            
            BBSJarvis.reply(threadID: detailedModel.thread_id, content: resultString, anonymous: editDetailVC?.isAnonymous ?? false, failure: { error in
                HUD.flash(.label("出错了...请稍后重试"))
            }, success: { _ in
                HUD.flash(.success)
                let _ = self.navigationController?.popViewController(animated: true)
            })
        }
        self.navigationController?.pushViewController(editDetailVC, animated: true)
    }
    
}
