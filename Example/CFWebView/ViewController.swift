//
//  ViewController.swift
//  CFWebView
//
//  Created by chengfei.heng on 11/22/2016.
//  Copyright (c) 2016 chengfei.heng. All rights reserved.
//

import UIKit
import CFWebView

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func didClickGotoWebView(){
        let webView = CFWebViewController.init(url: "https://www.baidu.com", swiped: false, callbackHandlerName: nil, callbackHandler: nil)
        
        webView.backImage = UIImage(named: "h5_back")
       
        
        self.navigationController?.pushViewController(webView, animated: true)
    }
}

