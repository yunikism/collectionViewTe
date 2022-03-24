//
//  ProductTableViewCell.swift
//  collectionViewTe
//
//  Created by 이호엽 on 2022/03/15.
//

import UIKit

class ProductTableViewCell: UITableViewCell {

    @IBOutlet weak var productListImage: UIImageView!
    @IBOutlet weak var productTitleLabel: UILabel!
    @IBOutlet weak var productSubTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
