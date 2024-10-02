//
//  UserInfoViewController.swift
//  Luvky2
//
//  Created by 황준섭 on 1/15/24.
//

import UIKit
import WebKit

class UserInfoViewController: UIViewController {
    
    @IBOutlet var userInfoWebView: WKWebView!
    
    func loadWebPage(_ url: String){
        let myUrl = URL(string: url)
        let myRequest = URLRequest(url: myUrl!)
        userInfoWebView.load(myRequest)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadWebPage("https://pinlib.tistory.com/entry/개인정보-취급방침")
    }
}
