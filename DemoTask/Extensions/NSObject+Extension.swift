//
//  NSObject+Extension.swift
//
//  Created by Surjeet on 14/07/20.
//  Copyright © 2020 Surjeet. All rights reserved.
//

import UIKit

extension NSObject {
    var className: String {
        return String(describing: type(of: self))
    }
    
    class var className: String {
        return String(describing: self)
    }
}
