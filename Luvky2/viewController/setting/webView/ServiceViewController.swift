//
//  ServiceViewController.swift
//  Luvky2
//
//  Created by 황준섭 on 1/15/24.
//

import UIKit
import WebKit

class ServiceViewController: UIViewController {
    
    
    @IBOutlet var serviceWebView: WKWebView!
    
    func loadWebPage(_ url: String){
        let myUrl = URL(string: url)
        let myRequest = URLRequest(url: myUrl!)
        serviceWebView.load(myRequest)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadWebPage("https://pinlib.tistory.com/entry/서비스-이용약관")
    }
}
