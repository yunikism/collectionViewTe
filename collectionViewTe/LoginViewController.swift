//
//  LoginViewController.swift
//  collectionViewTe
//
//  Created by 이호엽 on 2022/04/04.
//

import UIKit
import KakaoSDKUser
import KakaoSDKAuth
import KakaoSDKCommon
import Alamofire


class LoginViewController: UIViewController {

    @IBOutlet weak var loginBackGroundImageView: UIImageView!
    @IBOutlet weak var kakaoLoginImageView: UIImageView!
    
    @IBOutlet weak var loginLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .primary

        self.kakaoLoginImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapKakaoLoginImageView(_:))))
        self.kakaoLoginImageView.isUserInteractionEnabled = true
        
//        self.navigationController?.title = "로그인"
        self.title = "로그인"
        
    }
    
    @objc func tapKakaoLoginImageView(_ sender:AnyObject){
       
        if (UserApi.isKakaoTalkLoginAvailable()) {
            kakaoAppLogin()
        }else {
            kakaoWebLogin()
        }
        
    }
    
    //카카오 앱 로그인
    func kakaoAppLogin(){
        UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
            if let error = error {
                print(error)
            }
            else {
                print("loginWithKakaoTalk() success.")
                self.kakaoLoginInfoSave()
                //do something
                _ = oauthToken
            }
        }
    }
   
    //카카오 웹 로그인
    func kakaoWebLogin(){
        UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                if let error = error {
                    print(error)
                }
                else {
                    print("loginWithKakaoAccount() success.")
                    self.kakaoLoginInfoSave()
                    //do something
                    _ = oauthToken
                }
            }
    }
    
    //카카오 로그인 정보
    func kakaoLoginInfoSave(){
        
        UserApi.shared.me() {(user, error) in
            if let error = error {
                print(error)
            }
            else {
                guard let user = user,
                      let nickName = user.kakaoAccount?.profile?.nickname,
                      let profileImagePath = user.kakaoAccount?.profile?.profileImageUrl,
                      let thumbnailImagePath = user.kakaoAccount?.profile?.thumbnailImageUrl,
                      let id = user.id,
                      let uuid = UIDevice.current.identifierForVendor?.uuidString
                else { return }

                let deviceType = UIDevice.modelName

                let params = [
                    "loginDiv" : "1"
                    ,"id" : id
                    ,"nickName" : nickName
                    ,"profileImagePath" : profileImagePath
                    ,"thumbnailImagePath" : thumbnailImagePath
                    ,"uuid" : uuid
                    ,"deviceInfo" :deviceType
                ] as Dictionary
//                print("params : \(params)")

                guard let url : URL = URL(string: "https://rprecipe.com/api/common/loginCheck") else { return }
                AF.request(
                    url
                    , method: .post
                    , parameters: params)
                .responseData(completionHandler: {reponse in
                    switch reponse.result{
                    case let .success(data):
                        do{
//                            let json = try JSONSerialization.jsonObject(with: data, options: []) as! Dictionary<String,Any>
//                            print(data)
                            let json = try JSONSerialization.jsonObject(with: data, options: []) as! Dictionary<String,Any>
                            print("json : \(json)")

                            guard let apiInfo = json["data"] as? Dictionary<String,Any> else { return }
                            print("apiInfo : \(apiInfo)")

                            let member_no = String(apiInfo["member_no"] as! Int)
//                            guard let member_no1 = apiInfo["member_no"] as? String else{ }
                            
                            let app_nm = apiInfo["app_nm"] as! String
                            let prf_pt_url = apiInfo["prf_pt_url"] as! String
                            let thni_pt_url = apiInfo["thni_pt_url"] as! String
                            let uuid = apiInfo["uuid"] as! String
                            let device_info = apiInfo["device_info"] as! String
                            let login_div = apiInfo["login_div"] as? String ?? ""
                            let api_key = apiInfo["api_key"] as! String
                            let id = apiInfo["id"] as! String

                            let memberInfo =  MemberInfo(member_no: member_no
                                       ,app_nm: app_nm
                                       ,prf_pt_url: prf_pt_url
                                       ,thni_pt_url: thni_pt_url
                                       ,uuid: uuid
                                       ,device_info: device_info
                                       ,login_div: String(login_div)
                                       ,api_key: api_key
                                       ,id: id)
                            print("memberInfo : \(memberInfo)" )
                            
                            UserDefaults.standard.set(member_no, forKey: "member_no")
                            
                            NotificationCenter.default.post(
                                name: NSNotification.Name("kakaoLoginSuccessToast")
                                , object: nil
                                , userInfo: nil)
                            
                            self.navigationController?.popViewController(animated: true)
                            
                            

                        } catch {
                            print("http body error")
                        }


                    case let .failure(error):
                        print(error)
                    }
                })

                //do something
                _ = user
            }
        }
    }
    
}
