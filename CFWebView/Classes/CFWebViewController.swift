//
//  CFWebViewController.swift
//
//
//  Created by 衡成飞 on 10/25/16.
//  Copyright © 2016 qianwang. All rights reserved.
//

import UIKit
import WebKit

open class CFWebViewController: UIViewController,WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler {

    /**
     初始化一个Web Controller
     
     - 注意导航栏的titile是否居中，和左右侧的barbuttonitem有关系，如果存在，但是隐藏，也会占位置
     
     - parameter url:                 url地址
     - parameter swiped:              是否可以滑动返回（true：可以手势左滑动，false：h5内可以滑动，但是不能手势返回到前一个页面）
     - parameter callbackHandlerName: JavaScript调用App时，定义的名字
     - parameter callbackHandler:     App收到Javascript时的回调方法
     
     - returns: controller实例
     */
    public init(url:String?,swiped:Bool? = true,callbackHandlerName:[String]? = nil,callbackHandler:((_ handlerName:String,_ sendData:String,_ vc:UIViewController) -> Void)? = nil){
        self.url = url
        self.swiped = swiped

        self.callbackHandlerName = callbackHandlerName
        self.callbackHandler = callbackHandler
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open var backImage : UIImage!
    open var isCloseShow:Bool = true
    open var closeButtonColor:UIColor = UIColor.black
    open var progressColor:UIColor = UIColor.black
    
    fileprivate var url : String?
    fileprivate var shareURL:String?
    fileprivate var swiped:Bool?
    
    fileprivate var callbackHandlerName:[String]?
    fileprivate var callbackHandler:((_ handlerName:String,_ sendData:String,_ vc:UIViewController) -> Void)?
    
    fileprivate var webView:WKWebView!
    fileprivate var progressView:UIProgressView!
    fileprivate var request:URLRequest!
    var shareEnable = false
    var shareTitle:String?
    var shareContent:String?
    
    fileprivate var backButton:UIButton!
    
    fileprivate var closeButton:UIButton!
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        
        backButton = UIButton()
        backButton.frame = CGRect(x: 0, y: 0, width: 48, height: 20)
        backButton.setImage(self.backImage, for: .normal)
        
        closeButton = UIButton()
        closeButton.frame = CGRect(x: 0, y: 0, width: 45, height: 30)
        closeButton.setTitle("关闭", for: UIControlState())
        closeButton.setTitleColor(closeButtonColor, for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
        closeButton.contentHorizontalAlignment = .left
        
        self.automaticallyAdjustsScrollViewInsets = false

        progressView = UIProgressView(progressViewStyle: UIProgressViewStyle.bar)
        progressView.frame = CGRect(x: 0, y: 64, width: UIScreen.main.bounds.size.width, height: 1)
        progressView.tintColor = progressColor
        view.addSubview(progressView)
        
        let conf = WKWebViewConfiguration()
        
        //JavaScript回调APP
        if let handler = self.callbackHandlerName , handler.count > 0 {
            for j in handler {
                conf.userContentController.add(self, name: j)
            }
        }
        webView = WKWebView(frame: self.view.frame, configuration: conf)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(webView, belowSubview: progressView)
        
        let vfl_h = "H:|-0-[webview]-0-|"
        let vfl_v = "V:|-0-[webview]-0-|"
        let views:[String:UIView] = ["webview":webView]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: vfl_h, options: NSLayoutFormatOptions.alignAllLastBaseline, metrics: nil, views: views))
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: vfl_v, options: .alignAllLastBaseline, metrics: nil, views: views))
        
        webView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.scrollView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        
        //不可左滑时，添加关闭
        if swiped == nil || swiped! ==  false {
            backButton.addTarget(self, action: #selector(back), for: UIControlEvents.touchUpInside)
            closeButton.addTarget(self, action: #selector(close), for: UIControlEvents.touchUpInside)
            self.navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: backButton)]
            self.navigationItem.hidesBackButton = true
            webView.allowsBackForwardNavigationGestures = true        // 支持滑动返回
        }
        
        
        //调用本地的html5
        //let url = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("h5", ofType:"html")!)
        
        if let ur = url, let uu = URL(string: ur){
            var request = URLRequest(url: uu, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 20)
            
            
            let cookie = UserDefaults.standard.object(forKey: "Cookie") as? String
            if let cook = cookie {
                request.addValue(cook, forHTTPHeaderField: "Cookie")
            }
            
            self.webView.load(request)
        }
        
    }

    func back(){
        if webView.canGoBack {
            webView.goBack()
        }else{
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    func close(){
        _ = self.navigationController?.popViewController(animated: true)
    }
   
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "title" {
            self.title = webView.title
        }
        
        if keyPath == "loading" {
        }
        
        if keyPath == "estimatedProgress" {
            progressView.isHidden = webView.estimatedProgress == 1
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        }
        
        if webView.canGoBack {
            self.navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: backButton),UIBarButtonItem(customView: closeButton)]
        }else{
            self.navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: backButton)]
        }
    }

    open func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        //this is a 'new window action' (aka target="_blank") > open this URL externally. If we´re doing nothing here, WKWebView will also just do nothing. Maybe this will change in a later stage of the iOS 8 Beta
        if navigationAction.targetFrame != nil {
            let url = navigationAction.request.url!
            
            if url.absoluteString.hasPrefix("https://itunes.apple.com") {
                let app = UIApplication.shared
                if app.canOpenURL(url){
                    if #available(iOS 10.0, *) {
                        app.open(url, options: [:], completionHandler: nil)
                    } else {
                        app.openURL(url)
                    }
                }
            }else if url.absoluteString.hasPrefix("http"){
                //新的URL（删除所有的参数）
                self.shareURL = url.absoluteString + "?share=1"

                let newQuerys = url.query?.components(separatedBy: "&")
                if let qs = newQuerys {
                    var ss:[String] = []
                    for q in qs {
                        if !q.hasPrefix("uid=") && !q.hasPrefix("pkey=")  && !q.hasPrefix("tok"){
                            ss.append(q)
                        }
                    }
                    if ss.count > 0 {
                        self.shareURL = self.shareURL! + "&" + ss.joined(separator: "&")
                    }
                }
                
            }
        }
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    
   open func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView.setProgress(0.0, animated: false)
    }
    
    deinit{
        webView.removeObserver(self, forKeyPath: "title")
        webView.removeObserver(self, forKeyPath: "loading")
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        webView.navigationDelegate = nil
        webView.uiDelegate = nil
    }
    
    // MARK: -  WKScriptMessageHandler
   open func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if callbackHandler != nil {
            callbackHandler!(message.name,message.body as! String,self)
        }
    }
}
 
