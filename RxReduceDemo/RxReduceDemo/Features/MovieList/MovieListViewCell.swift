//
//  DiscoveryListViewCell.swift
//  WarpFactorIOS
//
//  Created by Thibault Wittemberg on 18-04-09.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import UIKit
import Reusable

final class MovieListViewCell: UITableViewCell, NibReusable {

    @IBOutlet weak var poster: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var overview: UILabel!

    override func prepareForReuse() {
        self.imageView?.image = nil
    }
}
