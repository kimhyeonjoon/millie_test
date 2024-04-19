//
//  WebViewController.swift
//  millie_test
//
//  Created by Hyeonjoon Kim_M1 on 2024/04/19.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    
    var model: ArticleModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = model?.title
        
        if let url = URL(string: model?.url ?? "") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        // Do any additional setup after loading the view.
    }
    
    deinit {
        print("deinit WebViewController")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
