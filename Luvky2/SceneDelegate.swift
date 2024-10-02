//
//  SceneDelegate.swift
//  Luvky2
//
//  Created by 황준섭 on 2023/07/11.
//

import UIKit

import KakaoSDKAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    //test code
    var isLogged: Bool = false


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        //test code
        let storyBoard = UIStoryboard(name: "Main", bundle: nil) //Main.storyboard 가져오기
        
        if isLogged == false {
            //로그인 안된 상태
            guard let loginVC = storyBoard.instantiateViewController(withIdentifier: "kakaoLoginView") as? LoginViewController else {return}
            window?.rootViewController = loginVC
        } else {
            //로그인 된 상태
            guard let mainVC = storyBoard.instantiateViewController(withIdentifier: "FirstMain") as? FirstTabBarViewController else {return}
            window?.rootViewController = mainVC
        }
    }
    
    //test func
    func changeRootViewController (_ vc: UIViewController, animated: Bool) {
        guard let window = self.window else { return }
        window.rootViewController = vc // 전환
    }
    //-------
    
    //앱에서 카카오톡을 실행시키기 위해 앱 실행 허용 목록(Allowlist)에 카카오톡을 등록하고, 서비스 앱으로 돌아올 때 쓰일 커스텀 URL 스킴을 설정
    //카카오톡에서 서비스 앱으로 돌아왔을 때 카카오 로그인 처리를 정상적으로 완료하기 위해 AppDelegate.swift 파일에 handleOpenUrl()을 추가
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                _ = AuthController.handleOpenUrl(url: url)
                
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

