//
//  NewsViewController.swift
//  handbalapp
//
//  Created by Marko Heijnen on 1/29/17.
//  Copyright © 2017 CodeKitchen B.V. All rights reserved.
//

import Carlos
import UIKit

class NewsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: Properties

    let PostCellIdentifier = "PostCell"
    let PullToRefreshString = "Pull to Refresh"
    let cache = CacheProvider.imageCache()

    var newsItems: [NewsItem]! = []
    var retrieving: Bool!
    var refreshControl: UIRefreshControl!

    @IBOutlet weak var tableView: UITableView!

    // MARK: Structs

    struct NewsItem {
        let title: String
        let url: String
        let image: String?
    }

    // MARK: Initialization

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        newsItems = []
        retrieving = false
        refreshControl = UIRefreshControl()
    }

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        retrieveNewsItems()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Functions

    func configureUI() {
        refreshControl.addTarget(self, action: #selector(self.retrieveNewsItems), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: PullToRefreshString)
        tableView.insertSubview(refreshControl, at: 0)
    }

    func retrieveNewsItems() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        retrieving = true

         HandbalProvider.request(.getNews) { result in
            switch result {
                case let .success(response):
                    do {
                        if let json = try response.mapJSON() as? NSArray {
                            var newsItems: [NewsItem]! = []

                            for item in json {
                                newsItems.append(self.extractNewsItem(item as! Dictionary))
                            }
                            
                            self.newsItems = newsItems
                            self.tableView.reloadData()
                        } else {
                            
                        }
                    } catch {
                        
                    }

                    self.retrieveNewsItemsDone()
                case let .failure(error):
                    guard let error = error as? CustomStringConvertible else {
                        break
                    }
                
                    self.retrieveNewsItemsDone()
            }
        }
    }
    
    func retrieveNewsItemsDone() {
        self.refreshControl.endRefreshing()
        self.retrieving = false
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }

    func extractNewsItem(_ item: Dictionary<String, Any>) -> NewsItem {
        let title = item["title"] as! String
        let url = item["link"] as! String
        let image = item["image"] as? String
        
        return NewsItem(title: title, url: url, image: image)
    }


    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PostCellIdentifier) as UITableViewCell!

        let item = newsItems[indexPath.row]
        cell?.textLabel?.text = item.title

        cache.get(NSURL(string: item.image!)! as URL).onSuccess { value in
            let image = UIImageView(image: value)

            DispatchQueue.main.async {
                cell?.imageView?.image = image.image
                //self.tableView.reloadRows(at: [indexPath], with: .none)
            }
        }

        return cell!
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        //let newsItem = newsItems[indexPath.row]
    }

}

