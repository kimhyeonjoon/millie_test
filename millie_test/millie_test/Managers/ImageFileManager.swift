//
//  ImageFileManager.swift
//  millie_test
//
//  Created by Hyeonjoon Kim_M1 on 2024/04/19.
//

import Foundation
import UIKit

class ImageFileManager {
    
    static let shared = ImageFileManager()
    let fileManager = FileManager.default
    
    func getImage(urlString: String, img: @escaping ((UIImage?) -> Void)) {
        
        // url 에러인 경우 nil
        guard let url = URL(string: urlString) else {
            return
        }
        
        // api 호출
        NetworkManager.shared.requestImage(url: url) { image in
            if let image {
                // 이미지 CoreData 저장
                CoreDataManager.shared.saveImage(url: urlString, image: image)
                // api에서 가져온 이미지 적용
                img(image)
            } else {
                // 없으면 CoreData 에서 가져옴
                let image = CoreDataManager.shared.getImage(url: urlString)
                img(image)
            }
        }
        
    }
}
