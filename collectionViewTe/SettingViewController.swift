//
//  SettingViewController.swift
//  collectionViewTe
//
//  Created by 이호엽 on 2022/04/04.
//

import UIKit
import Alamofire
import KakaoSDKUser
import KakaoSDKAuth
import KakaoSDKCommon
import MapKit


class SettingViewController: UIViewController {

    @IBOutlet weak var settingTableView: UITableView!
    var member_no : String = ""
    var loginSuccess = false
//    let memberInfo : MemberInfo()
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        self.navigationController?.navigationBar.topItem?.title=""
        self.settingTableView.delegate = self
        self.settingTableView.dataSource = self
        
        
        NotificationCenter.default.addObserver(
            self
            , selector: #selector(kakaoLoginSuccessToast(_:))
            , name: NSNotification.Name("kakaoLoginSuccessToast")
            , object: nil)
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        print("Setting~!~! viewWillAppear")
        if let member_no = UserDefaults.standard.string(forKey: "member_no"){
            self.member_no = member_no
        }else {
            self.member_no = ""
        }
        self.settingTableView.reloadData()
        if self.loginSuccess{
            showToast(message: "로그인 되었습니다", font: .systemFont(ofSize: 14.0))
        }
        self.loginSuccess = false
    }
    
    
    @objc private func kakaoLoginSuccessToast(_ notification : Notification){
        self.loginSuccess = true
//        showToast(message: "로그인 되었습니다", font: .systemFont(ofSize: 14.0))
    }
    
    func kakaoLogout() {
        let alert = UIAlertController(title: "알림", message: "로그아웃 하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) {[weak self] action in
        UserApi.shared.logout {(error) in
            if let error = error {
//                UserDefaults.standard.removeObject(forKey: "member_no")
//                self?.member_no = ""
//                self?.settingTableView.reloadData()
//                self?.showToast(message: "로그아웃 되었습니다", font: .systemFont(ofSize: 12.0))
                print(error)
            }
            else {
                UserDefaults.standard.removeObject(forKey: "member_no")
                self?.member_no = ""
//                print("logout() success.")
                self?.settingTableView.reloadData()
                self?.showToast(message: "로그아웃 되었습니다", font: .systemFont(ofSize: 14.0))
            }
        }
        })
        alert.addAction(UIAlertAction(title: "취소", style: .default) { action in
            return
        })
        present(alert, animated: true, completion: nil)
        
    }
    
    func kakaoTokenExistence(){
        if (AuthApi.hasToken()) {
            UserApi.shared.accessTokenInfo { (_, error) in
                if let error = error {
                    if let sdkError = error as? SdkError, sdkError.isInvalidTokenError() == true  {
                        //로그인 필요
                        print("로그인 필요")
                    }
                    else {
                        //기타 에러
                        print("에러 몰루")
                    }
                }
                else {
                    print("로그인 했음@#@#@#@#@#@#@#@#@")
                    //토큰 유효성 체크 성공(필요 시 토큰 갱신됨)
                }
            }
        }
        else {
            print("로그인 필요~~~~~~~")
            //로그인 필요
        }
    }

    //카카오 로그인 정보
    func kakaoLoginInfo(){
        
        UserApi.shared.me() {(user, error) in
            if let error = error {
                print(error)
            }
            else {
                
                guard let user = user,
                      let nickname = user.kakaoAccount?.profile?.nickname,
                      let profileImageUrl = user.kakaoAccount?.profile?.profileImageUrl,
                      let thumbnailImageUrl = user.kakaoAccount?.profile?.thumbnailImageUrl,
                      let id = user.id,
                      let uuid = UIDevice.current.identifierForVendor?.uuidString
//                      let deviceType = UIDevice.modelName
                else { return }
                
                let deviceType = UIDevice.modelName

                
                print("-----------------------------------")
                print(deviceType)
                print("-----------------------------------")
                
                print("me() success.")
                print ("\(id)")
                print ("\(nickname)")
                print ("\(profileImageUrl)")
                print ("\(thumbnailImageUrl)")
                print(uuid)
                print(deviceType)
//                print ("\(user?.kakaoAccount?.email)")
                
                //do something
                _ = user
            }
        }
    }
    

    
    

    func deviceModelName() -> String? {
        var modelName = ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"]
        if modelName!.count > 0 {
            return modelName
        }
        let device = UIDevice.current
        let selName = "_\("deviceInfo")ForKey:"
        let selector = NSSelectorFromString(selName)

        if device.responds(to: selector) {
            modelName = String(describing: device.perform(selector, with: "marketing-name"))
        }
        return modelName
    }
    
    
    
    
}

extension SettingViewController : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell =  self.settingTableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath)

        
//        let member_no = memberInfo.member_no
        
        if indexPath.row == 0 {
            print("self.member_no : \(self.member_no)")
            if self.member_no == ""{
                cell.textLabel?.text = "로그인!@!@"
            }else {
                cell.textLabel?.text = "로그아웃!@!@"
            }
        }
//        else if indexPath.row == 1 {
//            cell.textLabel?.text = "로그인 check!"
//        }else if indexPath.row == 2 {
//            cell.textLabel?.text = "로그아웃!"
//        }else if indexPath.row == 3 {
//            cell.textLabel?.text = "로그인 정보"
//        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
            if self.member_no == ""{
                guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else { return }
                self.navigationController?.pushViewController(vc, animated: false)
                
            }else{
                kakaoLogout()
            }
            
        }
//        else if indexPath.row == 1  {
//            kakaoTokenExistence()
//        }else if indexPath.row == 2 {
//            kakaoLogout()
//        }else if indexPath.row == 3 {
////            kakaoLoginInfo()
//            NotificationCenter.default.post(
//                name: NSNotification.Name("kakaoLoginCheck")
//                , object: nil
//                , userInfo: nil)
//        }
    }

}

extension UIViewController {

func showToast(message : String, font: UIFont) {

    let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
    toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    toastLabel.textColor = UIColor.white
    toastLabel.font = font
    toastLabel.textAlignment = .center;
    toastLabel.text = message
    toastLabel.alpha = 1.0
    toastLabel.layer.cornerRadius = 10;
    toastLabel.clipsToBounds  =  true
    self.view.addSubview(toastLabel)
    UIView.animate(withDuration: 2.0, delay: 0.1, options: .curveEaseOut, animations: {
         toastLabel.alpha = 0.0
    }, completion: {(isCompleted) in
        toastLabel.removeFromSuperview()
    })
} }
