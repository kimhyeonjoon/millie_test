//
//  APIModel.swift
//  millie_test
//
//  Created by Hyeonjoon Kim_M1 on 2024/04/18.
//

import Foundation

struct ApiModel: Codable {
    let status: String?
    let totalResults: Int?
    let articles: [ArticleModel]?
}

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
}

extension String {
    func toArticleModel() -> ArticleModel? {
        return try? JSONDecoder().decode(ArticleModel.self, from: self.data(using: .utf8)!)
    }
}

struct SourceModel: Codable {
    let id: String?
    let name: String?
}
