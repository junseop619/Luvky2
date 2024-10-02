//
//  LoginViewController.swift
//  Luvky2
//
//  Created by 황준섭 on 2023/07/12.
//

import UIKit
import Amplify
import Combine
import KakaoSDKAuth
import KakaoSDKCommon
import KakaoSDKUser
import AuthenticationServices

import Alamofire

class LoginViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //token 존재 여부 확인
        if (AuthApi.hasToken()) {
            UserApi.shared.accessTokenInfo { (_, error) in
                if let error = error { //false
                    if let sdkError = error as? SdkError, sdkError.isInvalidTokenError() == true  {
                        //sdk error
                                            }
                    else {
                        //기타 에러
                        //loginBTN으로 처리
                        print("token error")
                        print(error)
                    }
                }
                else {
                    //토큰 유효성 체크 성공(필요 시 토큰 갱신됨)
                    //token을 가지고 있고 error가 없다면
                    //그냥 이동
                    print("loginWithKakaoTalk() success.")
                    self.loginDBCheck()
                }
            }
        }
        else {
            //not token
            //kakaoLogin(btn)으로 처리
        }
    }
    
    

    
    //kakao email db check
    private func loginDBCheck() {
        UserApi.shared.me { [self] user, error in
            if let error = error {
                print("db error check-----------------------------")
                print(error)
            } else {
                let email = user?.kakaoAccount?.email
                Task{
                    let users = try await Amplify.DataStore.query(User.self, where: User.keys.id.eq(email))
                    for user in users{
                        if(user.id == email){
                            guard let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "FirstMain") as? FirstTabBarViewController else { return }
                                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainVC, animated: false)
                        } else {
                            guard let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "FirstJoin") as? JoinViewController else { return }
                                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainVC, animated: false)
                        }
                    }
                }
            }
        }
    }
    
    
    
    
    @IBAction func kakaoLogin(_ sender: Any) {
        print("press this button")
        
        //카카오톡 실행 가능 여부 확인
        if (UserApi.isKakaoTalkLoginAvailable()) {
            
            //카톡 설치되어있으면 -> 카톡으로 로그인
            UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                if let error = error {
                    print("button error method")
                    print(error)
                }
                else {
                    print("loginWithKakaoTalk() success.")
                    _ = oauthToken
                    self.loginDBCheck()
                }
            }
        } else {
            //using mac test code
        
            
            guard let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "FirstMain") as? FirstTabBarViewController else { return }
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainVC, animated: false)
            
            //---------------------------------------------------------------------------
            
            
            let alert = UIAlertController(title: "죄송합니다", message: "카카오톡이 설치 되어있어야만 이용가능합니다.", preferredStyle: UIAlertController.Style.alert)
            let yAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(yAction)
            present(alert, animated: true, completion: nil)
            
        }
    }
    
    @IBAction func appleLogin(_ sender: Any) {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self as? ASAuthorizationControllerPresentationContextProviding
        controller.performRequests()
    }
    
    func getAppleRefreshToken(code: String, completionHandler: @escaping (AppleTokenResponse) -> Void) {
        let url = "https://appleid.apple.com/auth/token"
        let header: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded"]
        let parameters: Parameters = [
            "client_id": "com.tistory.pinlib.Luvky2",
            "client_secret": "clientSecret",
            "code": code,
            "grant_type": "authorization_code"
        ]

        AF.request(url,
                   method: .post,
                   parameters: parameters,
                   headers: header)
        .validate(statusCode: 200..<300)
        .responseData { response in
            switch response.result {
            case .success:
                guard let data = response.data else { return }
                /*
                let responseData = JSON(data)
                print(responseData) */
                
                do {
                    guard let responseData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                        print("Error: Couldn't convert JSON data to Dictionary")
                        return
                    }
                    print(responseData)
                } catch {
                    print("Error decoding JSON: \(error)")
                }

                guard let output = try? JSONDecoder().decode(AppleTokenResponse.self, from: data) else {
                    print("Error: JSON Data Parsing failed")
                    return
                }

                completionHandler(output)
            case .failure:
                print("애플 토큰 발급 실패 - \(response.error.debugDescription)")
            }
        }
    }
    
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            // authorization code
            if let authorizationCode = credential.authorizationCode {
                let code = String(decoding: authorizationCode, as: UTF8.self)
                print("Code - \(code)")
                
                // 애플 refresh token 발급 api 통신
                self.getAppleRefreshToken(code: code) { data in
                    // 응답받은 데이터를 유저디폴트에 저장함
                    UserDefaults.standard.set(data.refreshToken, forKey: "AppleRefreshToken")
                }
            }
            
        }
    }
}





