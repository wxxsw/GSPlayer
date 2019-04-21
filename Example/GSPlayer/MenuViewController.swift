//
//  MenuViewController.swift
//  GSPlayer_Example
//
//  Created by Gesen on 2019/4/21.
//  Copyright © 2019 Gesen. All rights reserved.
//

import UIKit

class MenuViewController: UITableViewController {

    enum Item: String {
        case basic
    }
    
    let items: [Item] = [.basic]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Menu"
        tableView.backgroundColor = .darkGray
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.tableFooterView = UIView()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = .darkGray
        cell.textLabel?.text = items[indexPath.row].rawValue.capitalized
        cell.textLabel?.textColor = .white
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch items[indexPath.row] {
        case .basic:
            navigationController?.pushViewController(BasicViewController(), animated: true)
        }
    }

}
