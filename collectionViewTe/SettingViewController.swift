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
    
//    let memberInfo : MemberInfo()
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        self.navigationController?.navigationBar.topItem?.title=""
        self.settingTableView.delegate = self
        self.settingTableView.dataSource = self
 
    }
    
    
    func kakaoLogout() {
        UserApi.shared.logout {(error) in
            if let error = error {
                print(error)
            }
            else {
                print("logout() success.")
            }
        }
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
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell =  self.settingTableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath)

        
//        let member_no = memberInfo.member_no
        
        if indexPath.row == 0 {
//            if member_no == nil{
                cell.textLabel?.text = "로그아웃"
//            }else {
                cell.textLabel?.text = "로그인"
//            }
            
        }else if indexPath.row == 1 {
            cell.textLabel?.text = "로그인 check!"
        }else if indexPath.row == 2 {
            cell.textLabel?.text = "로그아웃!"
        }else if indexPath.row == 3 {
            cell.textLabel?.text = "로그인 정보"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else { return }
            
            self.navigationController?.pushViewController(vc, animated: false)
            
            
        }else if indexPath.row == 1  {
            kakaoTokenExistence()
        }else if indexPath.row == 2 {
            kakaoLogout()
        }else if indexPath.row == 3 {
//            kakaoLoginInfo()
            NotificationCenter.default.post(
                name: NSNotification.Name("kakaoLoginCheck")
                , object: nil
                , userInfo: nil)
        }
    }

}

