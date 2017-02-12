//
//  NewsViewController.swift
//  handbalapp
//
//  Created by Marko Heijnen on 1/29/17.
//  Copyright © 2017 CodeKitchen B.V. All rights reserved.
//

import Carlos
import UIKit

// MARK: Structs

struct NewsItem {
    let title: String
    let content: String
    let date: Date?
    let url: String
    let thumbnail: String?
    let image: String?
    let source: String
}

class NewsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: Properties

    let PostCellIdentifier = "NewsCell"
    let PullToRefreshString = "Pull to Refresh"
    let cache = CacheProvider.sharedImageCache
    let dateFormatter = DateFormatter()

    var newsItems: [NewsItem]! = []
    var retrieving: Bool!
    var refreshControl: UIRefreshControl!

    @IBOutlet weak var tableView: UITableView!

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
        let content = item["content"] as! String
        let date = dateFormatter.date(from: item["date"] as! String)
        let url = item["link"] as! String
        let source = item["source"] as! String
        let thumbnail = item["thumbnail"] as? String
        let image = item["image"] as? String
        
        return NewsItem(title: title, content: content, date: date, url: url, thumbnail: thumbnail, image: image, source: source)
    }


    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PostCellIdentifier) as UITableViewCell!
        cell?.tag = indexPath.row

        let item = newsItems[indexPath.row]
        cell?.textLabel?.text = item.title
        cell?.imageView?.image = nil

        cache.get(NSURL(string: item.thumbnail!)! as URL).onSuccess { value in
            if (cell?.tag == indexPath.row) {
                cell?.imageView?.image = value
                cell?.setNeedsLayout()
            }
        }

        return cell!
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "NewsView", sender: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if ( segue.identifier == "NewsView" ) {
            if let viewController:NewsItemController = segue.destination as? NewsItemController {
                let indexPath = self.tableView.indexPathForSelectedRow
                viewController.item = newsItems[(indexPath?.row)!]
            }
        }
    }

}

