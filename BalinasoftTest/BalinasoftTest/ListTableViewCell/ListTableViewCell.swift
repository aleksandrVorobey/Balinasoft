//
//  ListTableViewCell.swift
//  BalinasoftTest
//
//  Created by admin on 24.09.2023.
//

import UIKit

class ListTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var listImageView: UIImageView!
    
    static let identifier = "ListTableViewCell"
    static func nib() -> UINib {
        return UINib(nibName: "ListTableViewCell", bundle: nil)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.listImageView.image = nil
    }

    func setupCell(with model: Content) {
        nameLabel.text = model.name
        NetworkManager.shared.getImageFrom(url: model.image ?? "") { [weak self] data in
            self?.listImageView.image = UIImage(data: data)
        }
    }
    
}
