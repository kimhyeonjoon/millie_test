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

extension UIImageView {
    
    func cacheImage(urlString: String?) {
        
        // url 에러인 경우 nil
        guard let urlString, let url = URL(string: urlString) else {
            self.image = nil
            return
        }
        
        if let image = CoreDataManager.shared.getImage(url: urlString) {
             // 로컬 저장된 이미지가 있는 경우 사용
            self.image = image
        } else {
            // api 호출
            NetworkManager.shared.downloadImage(url: url) { [weak self] image in
                if let image {
                    // 이미지 CoreData 저장
                    CoreDataManager.shared.saveImage(url: urlString, image: image)
                }
                // api에서 가져온 이미지 적용
                self?.image = image
            }
        }
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

extension Array {
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}
