//
//  NetworkMonitorManager.swift
//  millie_test
//
//  Created by Hyeonjoon Kim_M1 on 2024/04/19.
//

import Foundation
import Network

class NetworkMonitorManager {
    
    static let shared = NetworkMonitorManager()
    
    private let monitor = NWPathMonitor()
    var isConnected: Bool = false
    
    func startMonitor() {
        monitor.start(queue: DispatchQueue.global())
        monitor.pathUpdateHandler = { [weak self] path in
            print("update network status = \(path.status)")
            self?.isConnected = path.status == .satisfied
        }
    }
}
