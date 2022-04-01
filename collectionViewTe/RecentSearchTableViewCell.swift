//
//  RecentSearchTableViewCell.swift
//  collectionViewTe
//
//  Created by 이호엽 on 2022/04/01.
//

import UIKit

class RecentSearchTableViewCell: UITableViewCell {

    @IBOutlet weak var recentSearchLabel: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
