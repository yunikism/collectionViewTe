//
//  SearchViewController.swift
//  collectionViewTe
//
//  Created by 이호엽 on 2022/03/31.
//

import UIKit

class SearchViewController: UIViewController ,UITextFieldDelegate{

    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var recentSearchTableView: UITableView!
    @IBOutlet weak var searchProductTableView: UITableView!
    
    
    var recentSearchArr : [String] = []
    var searchText : String = ""
    var productInfoArr : [ProductInfo] = []
    var lastKnowContentOfsset : CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title=""
        if let userDefaultArr = UserDefaults.standard.array(forKey: "recentSearch") as? [String] {
            self.recentSearchArr = userDefaultArr
        }
        
        self.recentSearchTableView.delegate = self
        self.recentSearchTableView.dataSource = self
        
        self.searchProductTableView.delegate = self
        self.searchProductTableView.dataSource = self

        self.searchTextField.delegate = self
        
        self.searchTextField.addTarget(self, action: #selector(tapSearchTextField(_:)), for: .touchDown)
  
        statusBarStyle()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        setNeedsStatusBarAppearanceUpdate()
//    }
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        .lightContent
//    }
    
    private func statusBarStyle(){
        if #available(iOS 13.0, *) {
            let app = UIApplication.shared
            let statusBarHeight: CGFloat = app.statusBarFrame.size.height
            
            let statusbarView = UIView()
            statusbarView.backgroundColor = UIColor.orange
            view.addSubview(statusbarView)
          
            statusbarView.translatesAutoresizingMaskIntoConstraints = false
            statusbarView.heightAnchor
                .constraint(equalToConstant: statusBarHeight).isActive = true
            statusbarView.widthAnchor
                .constraint(equalTo: view.widthAnchor, multiplier: 1.0).isActive = true
            statusbarView.topAnchor
                .constraint(equalTo: view.topAnchor).isActive = true
            statusbarView.centerXAnchor
                .constraint(equalTo: view.centerXAnchor).isActive = true
          
        } else {
            let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
            statusBar?.backgroundColor = UIColor.orange
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.searchTextField.becomeFirstResponder()
        self.recentSearchTableView.isHidden = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        tapSearchButton(self.searchButton)
        return true
    }

    //검색버튼 클릭
    @IBAction func tapSearchButton(_ sender: UIBarButtonItem) {
        
        guard let searchStr = searchTextField.text else { return }
        
        guard self.searchText != searchStr else { return }
        guard searchStr != "" else { return }
        
        self.searchText = searchStr
        
        if self.recentSearchArr.count >= 5 {
            self.recentSearchArr.remove(at: 0)
            self.recentSearchArr.append(searchStr)
        } else {
            self.recentSearchArr.append(searchStr)
        }
        
        self.searchTextField.resignFirstResponder()
        self.recentSearchTableView.reloadData()
    
        print(self.recentSearchArr)
        UserDefaults.standard.set(self.recentSearchArr, forKey: "recentSearch")
        self.recentSearchTableView.isHidden = true
        self.searchProductTableView.isHidden = false
        
        productInfoArr.removeAll()
        self.lastKnowContentOfsset = 0
        apiListCall(searchStr)
    }
    
    
    //셀 삭제버튼 클릭
    @objc func deleteBtnAction(_ sender: UIButton){
        
        let point = sender.convert(CGPoint.zero, to: self.recentSearchTableView)
        guard let indexPath = self.recentSearchTableView.indexPathForRow(at: point) else { return }
        self.recentSearchArr.reverse()
        self.recentSearchArr.remove(at: indexPath.row - 1)
        self.recentSearchArr.reverse()
        UserDefaults.standard.set(self.recentSearchArr, forKey: "recentSearch")
        self.recentSearchTableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    //검색기록 전체삭제 클릭
    @objc func allDeleteBtnAction(_ sender: UIButton){

        self.recentSearchArr.removeAll()
        UserDefaults.standard.removeObject(forKey: "recentSearch")
        self.recentSearchTableView.reloadData()
    }
    
    
    //검색기록 전체삭제 클릭
    @objc func tapSearchTextField(_ sender: UIButton){
        self.recentSearchTableView.isHidden = false
    }
    

    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let newLength = (textField.text?.count)! + string.count - range.length
        return !(newLength > 20)
    }
    
 
    
    //상품 리스트 초기 셋팅
    private func apiListCall(_ searchStr : String) {

        print("----product list api start----- \(searchStr)")

        let urlStr = "https://rprecipe.com/api/content/selectContentList?current_page=1&appVer=11&title=\(searchStr)"
        let encodedString = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        guard let url:URL = URL(string: encodedString) else {return}

//        guard let url:URL = URL(string: "https://rprecipe.com/api/check/getScriptInfo") else { return }
        

              let task = URLSession.shared.dataTask(with: url){ [self] (data, response, error) in

                  if let dataJson = data {
                      do{
                          let json = try JSONSerialization.jsonObject(with: dataJson, options: []) as! Dictionary<String,Any>
                          
                          let productArray = json["data"] as! Array<Dictionary<String,Any>>

//                          print(json)
//                          var productInfoArr : [ProductInfo] = []

                          for productInfo in productArray {

//                          let productInfo = json["data"] as! Dictionary<String,Any>/
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

                              self.productInfoArr.append(pI)
                          }

                          DispatchQueue.main.async {
                            self.searchProductTableView.reloadData()
                          }
                      }
                      catch{}
                  }
              }
        task.resume()

        print("----product list script api End-----")
    }
    
}


extension SearchViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.recentSearchTableView{
            return self.recentSearchArr.count + 1
        } else {
          print(productInfoArr.count)
            return self.productInfoArr.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.recentSearchTableView{
            if indexPath.row == 0 {
                
                guard let cell = self.recentSearchTableView.dequeueReusableCell(withIdentifier: "RecentSearchTableViewCell") as? RecentSearchTableViewCell else {return UITableViewCell()}
                
                cell.recentSearchLabel.text = "최근검색어"
                cell.recentSearchLabel.textColor = .black
                cell.deleteAllBtn.setTitle("검색기록 전체삭제", for: .normal)
                
                cell.deleteAllBtn.addTarget(self, action: #selector(allDeleteBtnAction(_:)), for: .touchUpInside)
                cell.deleteBtn.isHidden = true
                cell.deleteAllBtn.isHidden = false
                
                cell.selectionStyle = .none
                
                return cell
                
            } else{
                guard let cell = self.recentSearchTableView.dequeueReusableCell(withIdentifier: "RecentSearchTableViewCell") as? RecentSearchTableViewCell else {return UITableViewCell()}
                
                cell.recentSearchLabel.text = recentSearchArr.reversed()[indexPath.row - 1]
                
                cell.recentSearchLabel.textColor = .lightGray
                cell.deleteBtn.setTitle("X", for: .normal)
                cell.deleteBtn.addTarget(self, action: #selector(deleteBtnAction(_:)), for: .touchUpInside)
                
                cell.deleteBtn.isHidden = false
                cell.deleteAllBtn.isHidden = true
                
                return cell
                
            }
        } else {
            
            guard let cell = self.searchProductTableView.dequeueReusableCell(withIdentifier: "ProductTableViewCell") as? ProductTableViewCell else { return UITableViewCell()}
            
            cell.productTitleLabel.text = productInfoArr[indexPath.row].title
            cell.productSubTitle.text = productInfoArr[indexPath.row].sub_title
            
            
            if let imagePath = productInfoArr[indexPath.row].img_path as? String {
                let imageUrl = URL(string : imagePath)
                cell.productListImage.kf.setImage(with: imageUrl)
            }
            
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        guard indexPath.row != 0 else {return}
//        print(indexPath.row)
        
        let cell = tableView.cellForRow(at: indexPath) as? RecentSearchTableViewCell
        guard let cellLabel = cell?.recentSearchLabel.text else {return}
        
        self.searchTextField.text = cellLabel
        tapSearchButton(self.searchButton)
        
    }
    
    //스크롤 감지하기
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        scrollView.bounces = scrollView.contentOffset.y <= 0
        
        let contentOfsset = self.lastKnowContentOfsset
        
        if contentOfsset > scrollView.contentOffset.y {
            if (contentOfsset - scrollView.contentOffset.y) < 30 {return}
        } else{
            if (scrollView.contentOffset.y - contentOfsset) < 30 {return}
        }
        self.lastKnowContentOfsset = scrollView.contentOffset.y
        
        if contentOfsset == 0 {
            return
        }
        
        if(contentOfsset <= 0 || contentOfsset > scrollView.contentOffset.y){
            //위로스크롤
            NotificationCenter.default.post(
                name: NSNotification.Name("hiddenNaviBar")
                , object: nil
                , userInfo: [
                    "barHiddenBool" : true
                ])
        } else if (contentOfsset < scrollView.contentOffset.y){
            //아래로스크롤
            NotificationCenter.default.post(
                name: NSNotification.Name("hiddenNaviBar")
                , object: nil
                , userInfo: [
                    "barHiddenBool" : false
                ])
        }
        
    }
    
}
