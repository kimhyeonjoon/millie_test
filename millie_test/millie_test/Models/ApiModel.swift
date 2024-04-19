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






