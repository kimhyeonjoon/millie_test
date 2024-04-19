//
//  Extensions.swift
//  millie_test
//
//  Created by Hyeonjoon Kim_M1 on 2024/04/19.
//

import Foundation
import UIKit

extension String {
    func toArticleModel() -> ArticleModel? {
        return try? JSONDecoder().decode(ArticleModel.self, from: self.data(using: .utf8)!)
    }
}


extension UIColor {
    convenience init(_ red: Int, _ green: Int, _ blue: Int) {
        let newRed = CGFloat(red)/255
        let newGreen = CGFloat(green)/255
        let newBlue = CGFloat(blue)/255
        
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
    }
}
