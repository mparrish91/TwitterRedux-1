//
//  HamburgerMenuViewController.swift
//  SimpleTwitter2
//
//  Created by Jonathan Cheng on 11/6/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit

protocol HamburgerMenuViewContollerDatasource: class {
    // Model
    func menu() -> NSArray
}
protocol HamburgerMenuViewControllerDelegate: class {
    func didSelectRow(_ row: Int)
}

class HamburgerMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let kHamburgerTableViewCellID = "HamburgerTableViewCell"
    
    @IBOutlet weak var rightMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    
    weak var delegate: HamburgerMenuViewControllerDelegate?
    weak var datasource: HamburgerMenuViewContollerDatasource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
// MARK- tableView protocol methods
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HamburgerTableViewCell", for: indexPath)
        cell.textLabel?.text = datasource?.menu()[indexPath.row] as! String?
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (datasource?.menu().count)!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.didSelectRow(indexPath.row)
    }
}
