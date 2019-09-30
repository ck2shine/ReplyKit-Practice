//
//  UIView+extensions.swift
//  ReplyKit-Practice
//
//  Created by i9400503 on 2019/9/30.
//  Copyright © 2019 BrilleShine. All rights reserved.
//

import UIKit

extension UIView
{
    @IBInspectable var cornerRadius : CGFloat
       {
        get {
            return self.cornerRadius
        }
        set
        {
            layer.cornerRadius = newValue
        }
    }
}
