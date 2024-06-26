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
    
    private var sessions: [String : URLSession] = [:]
    
    func request<T: Decodable>() -> Observable<T> {
        
        guard NetworkMonitorManager.shared.isConnected else {
            return .empty()
        }
        
        let url = "https://newsapi.org/v2/top-headlines?country=kr&apiKey=\(appKey)"
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        
        return URLSession.shared.rx.data(request: request)
            .map {
                try JSONDecoder().decode(T.self, from: $0)
            }
    }
    
    func downloadImage(url: URL, completed: @escaping ((UIImage?) -> Void)) {
        
        guard NetworkMonitorManager.shared.isConnected else {
            completed(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let session: URLSession = URLSession(configuration: .ephemeral)
        session.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                
                if let data = data, let image = UIImage(data: data) {
                    CoreDataManager.shared.saveImage(url: url.absoluteString, image: image)
                    completed(image)
                } else {
                    completed(nil)
                }
            }
            
        }.resume()
        
        sessions.updateValue(session, forKey: url.absoluteString)
    }
    
    func cancelSession(urlString: String) {
        if let session = sessions[urlString] {
            session.invalidateAndCancel()
        }
    }
    
    func cancelAllSession() {
        sessions.forEach { _, session in
            session.invalidateAndCancel()
        }
    }
}
