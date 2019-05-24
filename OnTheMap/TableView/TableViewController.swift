//
//  TableViewController.swift
//  OnTheMap
//
//  Created by mitch on 5/13/19.
//  Copyright © 2019 mitch. All rights reserved.
//

import UIKit

class TableViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    let tableReuseIdentifier = "tcell" // table cell identifier
    
    @IBOutlet weak var tableview: UITableView!
    
    // back button view map
    @IBAction func dismissView(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.dataSource = self
        tableview.delegate = self
    }
    
    func viewWillLoad() {
        self.tableview!.reloadData()
    }
    
    // tell the table view how many rows to make
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return studentLocations?.results.count ?? 0
    }
    
    // make a row for each meme struct in appDelegate array
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // get a reference to our storyboard cell
        let cell = tableView.dequeueReusableCell(withIdentifier: tableReuseIdentifier, for: indexPath as IndexPath) as! TableViewCell
        
        // Use the outlet in our custom class to get a reference to the UIImage in the cell
        cell.location.text = studentLocations?.results[indexPath.row].mapString ?? "Unknown"
        cell.urlLabel.text = studentLocations?.results[indexPath.row].mediaURL ?? "Unknown"
        
        return cell
    }
    
    // set up when cell is pressed
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // get url and placename by indexing studentLocations by row number
        let urlValue = studentLocations!.results[indexPath.row].mediaURL
        let placeName = studentLocations!.results[indexPath.row].mapString
        // alert wether to open url from safari
        let ac = UIAlertController(title: placeName, message: urlValue, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Open in Safari", style: .default, handler: {(action: UIAlertAction!) in
            guard let url = URL(string: urlValue!) else { return }
            UIApplication.shared.open(url)
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .default, handler: {(action: UIAlertAction!) in
            
        }))
        present(ac, animated: true)
    }
}
