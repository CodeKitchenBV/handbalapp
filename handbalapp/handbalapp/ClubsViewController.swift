//
//  ClubsViewController.swift
//  handbalapp
//
//  Created by Marko Heijnen on 1/29/17.
//  Copyright © 2017 CodeKitchen B.V. All rights reserved.
//

import UIKit

struct Club {
    let id: String
    let name: String
    let website: String
    let facility_address: String
    let facility_zipcode: String
    let facility_city: String
}

class ClubsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Properties
    
    let PostCellIdentifier = "ClubCell"
    let PullToRefreshString = "Pull to Refresh"
    let dateFormatter = DateFormatter()

    var sections: [String]! = []
    var clubs: [[Club]]! = []
    var retrieving: Bool!
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        clubs = []
        retrieving = false
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveClubs()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        retrieveClubs()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func retrieveClubs() {
        if ( retrieving || clubs.count > 0 ) {
            return
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        retrieving = true
        
        HandbalProvider.request(.getClubs) { result in
            switch result {
            case let .success(response):
                do {
                    if let json = try response.mapJSON() as? Dictionary<String, NSArray> {
                        for (key, items) in json.sorted(by: { $0.0 < $1.0 }) {
                            var clubs: [Club]! = []

                            for item in items {
                                clubs.append(self.extractClub(item as! Dictionary))
                            }

                            self.sections.append( key )
                            self.clubs.append( clubs )
                        }

                        self.tableView.reloadData()
                    }
                } catch {
                    
                }
                
                self.retrieveClubsDone()
            case let .failure(error):
                guard let error = error as? CustomStringConvertible else {
                    break
                }
                
                self.retrieveClubsDone()
            }
        }
    }
    
    func retrieveClubsDone() {
        self.retrieving = false
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func extractClub(_ item: Dictionary<String, Any>) -> Club {
        let id = item["id"] as! String
        let name = item["name"] as! String
        let website = item["website"] as! String
        let facility_address = item["facility_address"] as! String
        let facility_zipcode = item["facility_zipcode"] as! String
        let facility_city = item["facility_city"] as! String
        
        return Club(id: id, name: name, website: website, facility_address: facility_address, facility_zipcode: facility_zipcode, facility_city: facility_city)
    }
    
    
    // MARK: UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ( clubs.count > 0 ) {
            return clubs[section].count
        }
        
        return 0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PostCellIdentifier) as UITableViewCell!
        cell?.tag = indexPath.row
        
        let item = clubs[indexPath.section][indexPath.row]
        let formattedString = NSMutableAttributedString()
        formattedString.bold(item.name).normal(" " + item.facility_city)

        cell?.textLabel?.attributedText = formattedString

        return cell!
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sections
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ClubView", sender: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if ( segue.identifier == "ClubView" ) {
            if let viewController:ClubViewController = segue.destination as? ClubViewController {
                let indexPath = self.tableView.indexPathForSelectedRow
                print("1")
                viewController.club = clubs[(indexPath?.section)!][(indexPath?.row)!]
            }
        }
    }

}

