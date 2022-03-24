//
//  ViewController.swift
//  collectionViewTe
//
//  Created by 이호엽 on 2022/03/14.
//

import UIKit
import GoogleMobileAds

class ViewController: UIViewController {

    
    @IBOutlet weak var tabCollectionView: UICollectionView!
    @IBOutlet weak var pageCollectionView: UICollectionView!
    @IBOutlet weak var highlightView: UIView!
    
    
//    var tabArray : [String] = []
    var tabInfoArr : [TabInfo] = []
//    var productInfoArr : [ProductInfo] = []
    
    var productInfoDic : Dictionary<String , [ProductInfo]> = [:]
    
    var constraints :  [NSLayoutConstraint] = []
    var currentIdx: CGFloat = 0.0
    
    var productArray : [String] = []
    
    var pageCell = PageCollectionViewCell()
    
    var intdd : Int = 0
    
    //google ad
    public lazy var bannerView: GADBannerView = {
        let banner = GADBannerView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        return banner
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        apiScriptInfo()
        
        self.tabCollectionView.delegate = self
        self.tabCollectionView.dataSource = self
        
        self.pageCollectionView.delegate = self
        self.pageCollectionView.dataSource = self
        self.pageCollectionView.isPagingEnabled = true
        
//        self.navigationController?.hidesBarsOnSwipe = true
        
        self.setupBannerViewToBottom()
        pageCellSetting()
        
        NotificationCenter.default.addObserver(
            self
            , selector: #selector(moveProductWebView(_:))
            , name: NSNotification.Name("MoveWebView")
            , object: nil
        )
        
        NotificationCenter.default.addObserver(
            self
            , selector: #selector(hiddenNaviBar(_:))
            , name: NSNotification.Name("hiddenNaviBar")
            , object: nil)

    }
    
    
    
    //테이블뷰 스크롤시 네비게이션바 히든 여부
    var barHidden : Bool = false
    @objc private func hiddenNaviBar(_ notification : Notification){

        guard let bool : Bool = notification.userInfo?["barHiddenBool"] as? Bool else {return}

        if barHidden != bool{
           if bool {
               self.navigationController?.setNavigationBarHidden(false, animated: true)
    
           }else {
               self.navigationController?.setNavigationBarHidden(true, animated: true)
            
           }
            self.pageCell.prepareForReuse()
            barHidden = bool
        }
    }

    //리스트 클릭시 웹뷰 컨트롤러로 이동
    @objc private func moveProductWebView(_ notification : Notification){
        
        guard let link_url : String = notification.userInfo?["link_url"] as? String else {return}
        guard let webControllerView = self.storyboard?.instantiateViewController(identifier: "ProductDetailViewController") as? ProductDetailViewController else { return }
        
        webControllerView.link_url = link_url
        
        self.navigationController?.pushViewController(webControllerView, animated: true)
    }
    
    // 페이지 셀 셋팅
    private func pageCellSetting(){
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        flowLayout.scrollDirection = .horizontal
//        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
//        flowLayout.minimumInteritemSpacing = 0
        
        flowLayout.estimatedItemSize = CGSize(width:  self.pageCollectionView.frame.width, height:  self.pageCollectionView.frame.height + 50)
        
//        flowLayout.itemSize = CGSize(width:  self.pageCollectionView.frame.width, height:  self.pageCollectionView.frame.height + 50)
        
        self.pageCollectionView.collectionViewLayout = flowLayout
        

    }
    
 
    @IBAction func pushTest(_ sender: UIBarButtonItem) {
        
        let push = UNMutableNotificationContent()
        push.title = "test Title"
        push.subtitle = "test subTitle"
        push.body = "test body"
        push.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let request = UNNotificationRequest(identifier: "test", content: push, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
    }
    
}




extension ViewController : UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == tabCollectionView {

            return self.tabInfoArr.count

        }else {

            return self.tabInfoArr.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == tabCollectionView {
            guard  let cell = self.tabCollectionView.dequeueReusableCell(withReuseIdentifier: "TabCollectionViewCell", for: indexPath) as? TabCollectionViewCell else {
                return UICollectionViewCell()
            }

            if tabInfoArr[indexPath.row].code_name.count < 4{
                cell.tabTitleLabel.text = "   " + tabInfoArr[indexPath.row].code_name + "   "
            }else {
                cell.tabTitleLabel.text = " " + tabInfoArr[indexPath.row].code_name + " "
            }
            
            return cell
            
        }else {
            guard let cell = self.pageCollectionView.dequeueReusableCell(withReuseIdentifier: "PageCollectionViewCell", for: indexPath) as? PageCollectionViewCell else {
                return UICollectionViewCell()
            }

            print("indexPath : \(indexPath) /////// \(intdd)")
            cell.indexCell = indexPath
            cell.tabInfoArr = self.tabInfoArr
            cell.productInfoDic = self.productInfoDic
            cell.contentDiv = self.tabInfoArr[indexPath.row].code_id
            cell.layer.addBorder([.bottom,.left,.right,.top], color: .lightGray, width: 0.5)
            intdd = intdd + 1
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    //collectionView select
        
        if collectionView == tabCollectionView {
            
//            self.pageCollectionView.scrollToItem(at: indexPath, at: .top, animated: true)
            let rect = self.pageCollectionView.layoutAttributesForItem(at: indexPath)?.frame
            self.pageCollectionView.scrollRectToVisible(rect!, animated: true)
            
            self.tabCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        

        if Int(scrollView.contentOffset.x / pageCollectionView.frame.width) == 9 {
            print("앙 도착띠")
        }
        
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    // collectionView scoll
        
    
        if scrollView == pageCollectionView{
            
            let index = Int(targetContentOffset.pointee.x / pageCollectionView.frame.width)
            let indexPath = IndexPath(item: index, section: 0)
            
            print("roll~ index : \(indexPath)")
            
            if indexPath.row == 9{
                
            } else {
               
            }
            
            self.tabCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .bottom)
            self.tabCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            
            
        }else {

        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let cvRect = collectionView.frame

        return CGSize(width: view.frame.width  , height: cvRect.height)

    }
    
}


extension ViewController {
    
    
    //상단 탭바 불러오기
    private func apiScriptInfo(){
        print("----script api start-----")
        guard let url:URL = URL(string: "https://rprecipe.com/api/check/getScriptInfo") else { return }
        
        let task = URLSession.shared.dataTask(with: url){ [self] (data, response, error) in

            if let dataJson = data {
                do{
                    let json = try JSONSerialization.jsonObject(with: dataJson, options: []) as! Dictionary<String,Any>
                    
                    let scriptInfo = json["data"] as! Dictionary<String,Any>
                    
                    let catelistString = scriptInfo["catelist"] as! String
                        
                    let cateList = try JSONSerialization.jsonObject(with: Data(catelistString.utf8), options: []) as! Array<Dictionary<String,Any>>
                    
                    self.tabInfoArr.append(TabInfo(code_name: "홈", code_id: "000"))
                    for(_, v) in cateList.enumerated() {
                        
                            guard let code_name = v["code_name"] as? String else {return}
                            guard let code_id = v["code_id"] as? String else {return}
                            
                            let scInfo = TabInfo(code_name: code_name, code_id: code_id)
                            self.tabInfoArr.append(scInfo)
                        
                    }
                    DispatchQueue.main.async {
                        self.tabCollectionView.reloadData()//main
//                        self.pageCollectionView.reloadData()
                        let firstIndex = IndexPath(item: 0, section: 0)
                        self.tabCollectionView.selectItem(at: firstIndex, animated: false, scrollPosition: .right)
                        apiListCall()
                    }
                }
                catch{}
            }
        }
        task.resume()
        print("----script api End-----")
    }
    
    
    //상품 리스트 초기 셋팅
    private func apiListCall() {
        
        print("----product list api start-----")
        
        for tabInfo in tabInfoArr {
            
            let contentDivCd = tabInfo.code_id
            let url : URL
            
            if contentDivCd == "000" {
                url = URL(string: "https://rprecipe.com/api/content/selectContentList?current_page=1&appVer=11")!
            }else{
                url = URL(string: "https://rprecipe.com/api/content/selectContentList?current_page=1&appVer=11&contentDivCd=\(contentDivCd)")!
            }
            
              let task = URLSession.shared.dataTask(with: url){ [self] (data, response, error) in
      
                  if let dataJson = data {
                      do{
                          let json = try JSONSerialization.jsonObject(with: dataJson, options: []) as! Dictionary<String,Any>
            
                          let productArray = json["data"] as! Array<Dictionary<String,Any>>
            
//                          print(json)
                          var productInfoArr : [ProductInfo] = []
            
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
                  
                              productInfoArr.append(pI)
                          }
                  
                          productInfoDic.updateValue(productInfoArr, forKey: contentDivCd)
                        
//                        print("contentDivCd : \(contentDivCd) \(tabInfo.code_name) ......\(productInfoDic[contentDivCd]?[0].title)")
                          DispatchQueue.main.async {
                            self.pageCollectionView.reloadData()
                          }
                      }
                      catch{}
                  }
              }
        task.resume()
        }
        
        print("----product list script api End-----")
    }
    
}



extension CALayer {
    
    //셀 테두리 지정
    func addBorder(_ arr_edge: [UIRectEdge], color: UIColor, width: CGFloat) {
        for edge in arr_edge {
            let border = CALayer()
            switch edge {
            case UIRectEdge.top:
                border.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: width)
                break
            case UIRectEdge.bottom:
                border.frame = CGRect.init(x: 0, y: frame.height - width, width: frame.width, height: width)
                break
            case UIRectEdge.left:
                border.frame = CGRect.init(x: 0, y: 0, width: width, height: frame.height)
                break
            case UIRectEdge.right:
                border.frame = CGRect.init(x: frame.width - width, y: 0, width: width, height: frame.height)
                break
            default:
                break
            }
            border.backgroundColor = color.cgColor;
            self.addSublayer(border)
        }
    }
}





//구글 광고
extension ViewController : GADBannerViewDelegate {
    
    func setupBannerViewToBottom(height: CGFloat = 50) {
           let adSize = GADAdSizeFromCGSize(CGSize(width: view.frame.width, height: height))
           bannerView = GADBannerView(adSize: adSize)

           bannerView.translatesAutoresizingMaskIntoConstraints = false
           view.addSubview(bannerView)
           NSLayoutConstraint.activate([
               bannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
               bannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
               bannerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
               bannerView.heightAnchor.constraint(equalToConstant: height)
           ])

//           bannerView.adUnitID = "ca-app-pub-6056528810711682/3296571971"
           bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716" //test
           bannerView.rootViewController = self
           bannerView.load(GADRequest())
           bannerView.delegate = self
       }
    
    public func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.alpha = 0
        UIView.animate(withDuration: 1) {
            bannerView.alpha = 1
        }
    }
    
}
