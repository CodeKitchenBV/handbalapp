//
//  NewsItemController.swift
//  handbalapp
//
//  Created by Marko Heijnen on 2/5/17.
//  Copyright © 2017 CodeKitchen B.V. All rights reserved.
//

import Carlos
import Foundation
import UIKit

class NewsItemController: UIViewController, UIWebViewDelegate {
    let cache = CacheProvider.sharedImageCache

    var item:NewsItem!

    @IBOutlet weak var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "News"
        
        var content = "<div style='margin: 10px'><h2 style='margin: 0'>" + item.title + "</h2>" + item.content + "</div>";

        cache.get(NSURL(string: item.image!)! as URL).onSuccess { value in
            let imageData = NSData(data: UIImagePNGRepresentation(value)!).base64EncodedString()
            
            content = "<img src='data:image/png;base64,\(imageData)'/>" + content
            self.setWebViewContent(content: content)
        }

        setWebViewContent(content: content)
    }
    
    func setWebViewContent(content: String) {
        let content = "<style>img {max-width:100%; height: auto} iframe {max-width:100%; height: 200px}</style><body style='margin: 0; padding: 0'>" + content + "</body>"
        webView.loadHTMLString(content, baseURL: Bundle.main.bundleURL)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        webView.frame.size.height = 1.0
        webView.sizeToFit()
    }

}
