//
//  PageCollectionViewCell.swift
//  collectionViewTe
//
//  Created by 이호엽 on 2022/03/14.
//

import UIKit
import Kingfisher

class PageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var productTableView: UITableView!
    open var refreshControl : UIRefreshControl?

    var productInfoDic : Dictionary<String , [ProductInfo]> = [:] {
        didSet{
            DispatchQueue.main.async {
                self.productTableView.reloadData()
            }
        }
    }
    
    var productInfoArr : [ProductInfo] = []
    var tabInfoArr : [TabInfo] = []
    
    var contentDiv : String = ""
    var indexCell : IndexPath = IndexPath()
    
    var currentPageDic : Dictionary<String , Int> = [:]
    var cellHeights : [IndexPath:CGFloat] = [:]
    
    var lastKnowContentOfsset : CGFloat = 0.0
    
    

    override func awakeFromNib() {
         self.productTableView.delegate = self
         self.productTableView.dataSource = self
         self.productTableView.reloadData()
         self.productTableView.refreshControl = UIRefreshControl()
    
        self.productTableView.refreshControl?.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        
    }

    @objc func handleRefresh(_ sender: Any){
        
        self.currentPageDic.updateValue(1, forKey: self.contentDiv)
        self.productInfoDic[self.contentDiv] = []
        self.lastKnowContentOfsset = 0.0
        addProduct()
        
        self.productTableView.refreshControl?.endRefreshing()
    }

}


extension PageCollectionViewCell : UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate{
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
//        print("contentDiv : \(contentDiv) /////// \(self.productInfoDic[contentDiv]?.count)")
        return self.productInfoDic[contentDiv]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = self.productTableView.dequeueReusableCell(withIdentifier: "ProductTableViewCell") as? ProductTableViewCell else {
            return UITableViewCell()
        }
        
        cell.productTitleLabel.text = productInfoDic[contentDiv]?[indexPath.row].title
        cell.productSubTitle.text = productInfoDic[contentDiv]?[indexPath.row].sub_title
        
        
        if let imagePath = productInfoDic[contentDiv]?[indexPath.row].img_path {
            let imageUrl = URL(string : imagePath)
            cell.productListImage.kf.setImage(with: imageUrl)
        }
        
        
        return cell
    }
    
//    //table height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    //테이블 리스트 클릭
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NotificationCenter.default.post(
            name: NSNotification.Name("hiddenNaviBar")
            , object: nil
            , userInfo: [
                "barHiddenBool" : true
            ])

        NotificationCenter.default.post(
            name: NSNotification.Name("MoveWebView")
            , object: nil
            , userInfo: [
                "link_url" : self.productInfoDic[contentDiv]?[indexPath.row].link_url as Any
            ])
    }
    
    //스크롤 마지막 감지
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + 1) >= (scrollView.contentSize.height - scrollView.frame.size.height) {

            if let currentPage = self.currentPageDic[self.contentDiv] {
            print("currentPage : \(currentPage)")
                self.currentPageDic.updateValue(currentPage + 1, forKey: self.contentDiv)
            } else {
            print("else!")
                self.currentPageDic.updateValue(2, forKey: self.contentDiv)
            }
            addProduct()

        }
    }
    
    //스크롤 감지하기
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        scrollView.bounces = scrollView.contentOffset.y <= 0

        if(self.lastKnowContentOfsset <= 0 || self.lastKnowContentOfsset > scrollView.contentOffset.y){
            //위로스크롤
            NotificationCenter.default.post(
                name: NSNotification.Name("hiddenNaviBar")
                , object: nil
                , userInfo: [
                    "barHiddenBool" : true
                ])
        } else if (self.lastKnowContentOfsset < scrollView.contentOffset.y){
            //아래로스크롤
            NotificationCenter.default.post(
                name: NSNotification.Name("hiddenNaviBar")
                , object: nil
                , userInfo: [
                    "barHiddenBool" : false
                ])
        }

        self.lastKnowContentOfsset = scrollView.contentOffset.y

    }

    //스크롤 튐 현상 방지
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellHeights[indexPath] = cell.frame.size.height
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath] ?? UITableView.automaticDimension
    }
    //스크롤 튐 현상 방지 끝
    
}


extension PageCollectionViewCell {
    
    func addProduct(){

        var urlString = ""
        
        guard let currentPage = self.currentPageDic[self.contentDiv] else { return }

        if self.contentDiv == "000"{
            urlString = "https://rprecipe.com/api/content/selectContentList?appVer=11&current_page=\(currentPage)"
        }else{
            urlString = "https://rprecipe.com/api/content/selectContentList?appVer=11&contentDivCd=\(self.contentDiv)&current_page=\(currentPage)"
        }

        let task = URLSession.shared.dataTask(with: URL(string:urlString)!){
            data, response,error in

            if let dataJson = data{

                do{
                    let json = try JSONSerialization.jsonObject(with: dataJson, options: []) as! Dictionary<String,Any>


                    let articles = json["data"] as! Array<Dictionary<String, Any>>

                    var productInfoArr : [ProductInfo] = []

                    for productInfo in articles {
                        guard let content_no = productInfo["content_no"] as? Int else {return}
                        guard let sub_title = productInfo["sub_title"] as? String else {return}
                        guard let sold_out_flag = productInfo["sold_out_flag"] as? String else {return}
                        guard let fvr_cnt = productInfo["fvr_cnt"] as? Int else {return}
                        guard let main_img_path = productInfo["main_img_path"] as? String else {return}
                        guard let title = productInfo["title"] as? String else {return}
                        guard let comment_cnt = productInfo["comment_cnt"] as? Int else {return}
                        guard let reg_date = productInfo["reg_date"] as? String else {return}
                        guard let content_div_cd = productInfo["content_div_cd"] as? String else {return}
                        guard let img_path = productInfo["img_path"] as? String else {return}
                        guard let best_order = productInfo["best_order"] as? Int else {return}
                        guard let hit_cnt = productInfo["hit_cnt"] as? Int else {return}
                        guard let link_url = productInfo["link_url"] as? String else {return}


                        let pI : ProductInfo = ProductInfo(
                            content_no: content_no
                            , sub_title: sub_title
                            , sold_out_flag: sold_out_flag
                            , fvr_cnt: fvr_cnt
                            , main_img_path: main_img_path
                            , title: title
                            , comment_cnt: comment_cnt
                            , reg_date: reg_date
                            , content_div_cd: content_div_cd
                            , img_path: img_path
                            , best_order: best_order
                            , hit_cnt: hit_cnt
                            , link_url: link_url
                        )

                        productInfoArr.append(pI)
                    }

                
                    self.productInfoDic[self.contentDiv]? += productInfoArr
                    
//                    print ("productInfoDic : \(self.productInfoDic[self.contentDiv])")
                    print("self.contentDiv : \(self.contentDiv)  ///////// self.current_page : \(currentPage)" )
                    

//                    DispatchQueue.main.async {
//                        self.productTableView.reloadData()
//                    }

                }
                catch{}

            }

        }
        task.resume()

    }

}
    


