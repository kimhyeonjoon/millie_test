//
//  NetworkManager.swift
//  millie_test
//
//  Created by Hyeonjoon Kim_M1 on 2024/04/18.
//

import UIKit

import RxSwift
import RxCocoa

let appKey = "70e5767cbd9d42efb00528575e6dae95"

class NetworkManager {
    
    static let shared = NetworkManager()
    
    func request<T: Decodable>() -> Observable<T> {
        
        let url = "https://newsapi.org/v2/top-headlines?country=kr&apiKey=\(appKey)&pageSize=50"
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        
        return URLSession.shared.rx.data(request: request)
            .map {
                try JSONDecoder().decode(T.self, from: $0)
            }
    }
}
