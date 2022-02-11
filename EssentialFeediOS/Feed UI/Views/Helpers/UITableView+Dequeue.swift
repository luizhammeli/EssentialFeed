//
//  UITableView+Dequeue.swift
//  EssentialFeediOS
//
//  Created by Luiz Hammerli on 05/02/22.
//

import UIKit

extension UITableView {
    func dequeueCell<T: UITableViewCell>(with identifier: String) -> T? {
        return self.dequeueReusableCell(withIdentifier: identifier) as? T
    }
}
