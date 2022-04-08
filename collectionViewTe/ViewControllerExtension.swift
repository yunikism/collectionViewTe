////
////  ViewControllerExtension.swift
////  collectionViewTe
////
////  Created by 이호엽 on 2022/04/08.
////
//
//import Foundation
//import UIKit
//
//public extension UIViewController {
//    static func showToastMessage(_ message: String, font: UIFont = UIFont.systemFont(ofSize: 12, weight: .light)) {
//        let window = UIApplication.shared.windows.first!
//        let toastLabel = UILabel(frame: CGRect(x: window.frame.width / 2 - 150, y: window.frame.height - 150, width: 300, height: 60))
//
//        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
//        toastLabel.textColor = UIColor.white
//        toastLabel.numberOfLines = 2
//        toastLabel.font = font
//        toastLabel.text = message
//        toastLabel.textAlignment = .center
//        toastLabel.layer.cornerRadius = 10
//        toastLabel.clipsToBounds = true
//
//        guard let topController = UIApplication.shared.keyWindow?.rootViewController else { return }
//        topController.view.addSubview(toastLabel)
//
//        UIView.animate(withDuration: 1.5, delay: 0.3, options: .curveEaseOut) {
//            toastLabel.alpha = 0.0
//        } completion: { _ in
//            toastLabel.removeFromSuperview()
//        }
//    }
//}
