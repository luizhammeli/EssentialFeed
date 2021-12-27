//
//  ViewController.swift
//  Prototype
//
//  Created by Luiz Diniz Hammerli on 26/12/21.
//

import UIKit

class FeedViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FeedImageViewModel.prototypeFeed.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedImageCell
        cell.setData(viewModel: FeedImageViewModel.prototypeFeed[indexPath.row])
        return cell
    }
}

