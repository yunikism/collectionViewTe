//
//  ProductDetailViewController.swift
//  collectionViewTe
//
//  Created by 이호엽 on 2022/03/16.
//

import UIKit
import WebKit

class ProductDetailViewController: UIViewController {

    @IBOutlet weak var productWebView: WKWebView!
    var link_url : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "TV요리레시피"
        self.navigationController?.navigationBar.topItem?.title=""
        
        let url = URL(string: link_url)
        let request = URLRequest(url: url!)
        productWebView.configuration.preferences.javaScriptEnabled = true
        productWebView.load(request)

    }
    
}
