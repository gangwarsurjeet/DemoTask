//
//  ViewController+Extension.swift
//  DemoTask
//
//  Created by Surjeet on 06/07/21.
//

import UIKit
import ProgressHUD

extension UIViewController {
    func showLoadingIndicator(_ text: String? = nil) {
        DispatchQueue.main.async {
            ProgressHUD.animationType = .lineScaling
            ProgressHUD.colorStatus = UIColor.lightGray
            ProgressHUD.colorBackground = .clear
            ProgressHUD.show(text, interaction: false)
        }
    }
    
    func hideLoadingIndicator() {
        DispatchQueue.main.async {
            ProgressHUD.dismiss()
        }
    }
}
