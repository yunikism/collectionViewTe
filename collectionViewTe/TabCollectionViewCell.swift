//
//  TabCollectionViewCell.swift
//  collectionViewTe
//
//  Created by 이호엽 on 2022/03/14.
//

import UIKit

class TabCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var tabTitleLabel: UILabel!
    
    
    override var isSelected : Bool{
        willSet {
            if newValue{
                self.tabTitleLabel.textColor = .black
            }else{
                self.tabTitleLabel.textColor = .lightGray
            }
        }
    }
    
}

