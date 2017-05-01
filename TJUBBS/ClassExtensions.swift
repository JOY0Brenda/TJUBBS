//
//  ClassExtensions.swift
//  TJUBBS
//
//  Created by JinHongxu on 2017/4/30.
//  Copyright © 2017年 twtstudio. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    convenience init(title: String, color: UIColor = .black, fontSize: Int = 15, isConfirmButton: Bool = false) {
        self.init()
        if isConfirmButton == false {
            self.setTitle(title, for: .normal)
            self.setTitleColor(color, for: .normal)
            self.titleLabel?.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
        } else {
            var spaceTitle = title
            let index = title.index(after: title.startIndex)
            spaceTitle.insert(contentsOf: "  ".characters, at: index)
            self.setTitle(spaceTitle, for: .normal)
            self.setTitleColor(UIColor.white, for: .normal)
            self.setBackgroundImage(UIImage.init(color: UIColor.lightGray), for: .disabled)
            self.setBackgroundImage(UIImage.init(color: UIColor.BBSBlue), for: .normal)
            self.titleLabel?.font = UIFont.systemFont(ofSize: 18)
            self.layer.cornerRadius = 5.0
            self.clipsToBounds = true
        }
    }
}

extension UIButton {
    typealias newDataBlock = (UIButton) -> Void
    
    // 关联属性的key
    private struct associatedKeys {
        static var newDataBlockKey = "newDataBlockKey"
    }
    
    private class BlockContainer: NSObject, NSCopying {
        var newDataBlock: newDataBlock?
        func copy(with zone: NSZone? = nil) -> Any {
            return self
        }
    }
    
    private var blockm: BlockContainer? {
        get {
            if let newDataBlock = objc_getAssociatedObject(self, &associatedKeys.newDataBlockKey) as? BlockContainer {
                return newDataBlock
            }
            return nil
        }
        set(newValue) {
            objc_setAssociatedObject(self, &associatedKeys.newDataBlockKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    func addTarget(for controlEvents: UIControlEvents = .touchUpInside, withBlock block: @escaping newDataBlock) {
        self.blockm = BlockContainer()
        blockm?.newDataBlock = block
        self.addTarget(self, action: #selector(self.callback(sender:)), for: controlEvents)
    }
    
    func callback(sender: UIButton) {
        self.blockm?.newDataBlock?(sender)
    }
}

extension UILabel {
    convenience init(text: String, color: UIColor = UIColor.black, fontSize: Int = 15) {
        self.init()
        self.text = text
        self.textColor = color
        self.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
        self.sizeToFit()
    }
}


extension UIColor {
    open class var BBSBlue: UIColor {
        return UIColor.init(red: 25.0/255, green: 126.0/255, blue: 225.0/255, alpha: 1.0)
    }
}

extension UIViewController {
    func keyboardWillShow() {
        UIView.animate(withDuration: 0.5, animations: {
            self.view.frame.origin.y = -40
        })
    }
    
    func keyboardWillHide() {
        UIView.animate(withDuration: 0.5, animations: {
            self.view.frame.origin.y = 0
        })
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UIImage {
    
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
    
    static func resizedImage(image: UIImage, scaledToSize newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}
