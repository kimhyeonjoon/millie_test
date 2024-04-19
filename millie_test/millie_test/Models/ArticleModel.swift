//
//  ArticleModel.swift
//  millie_test
//
//  Created by Hyeonjoon Kim_M1 on 2024/04/19.
//

import Foundation

struct ArticleModel: Codable, Hashable {
    
    let source: SourceModel?
    let author: String?
    let title: String?
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String?
    let content: String?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(publishedAt)
    }
    
    static func == (lhs: ArticleModel, rhs: ArticleModel) -> Bool {
        return lhs.title == rhs.title && lhs.publishedAt == rhs.publishedAt
    }
}

extension ArticleModel {
    
    func toString() -> String? {
        let jsonData = try! JSONEncoder().encode(self)
        return String(data: jsonData, encoding: .utf8)!
    }
    
    func date() -> String? {
        
        if let publishedAt {
            let dateFormatter = DateFormatter()
            let tempLocale = dateFormatter.locale
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            let date = dateFormatter.date(from: publishedAt)
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            dateFormatter.locale = tempLocale
            let dateString = dateFormatter.string(from: date ?? Date())
            return dateString
        } else {
            return nil
        }
    }
}
