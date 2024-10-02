//
//  AppDelegate.swift
//  Luvky2
//
//  Created by 황준섭 on 2023/07/11.
//

import UIKit
import Amplify
import AWSDataStorePlugin

import AWSAPIPlugin

import AWSS3StoragePlugin
import AWSCognitoAuthPlugin
import AWSPinpointPushNotificationsPlugin

import KakaoSDKCommon
import KakaoSDKAuth

import AuthenticationServices



@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        Amplify.Logging.logLevel = .info
        
        let apiPlugin = AWSAPIPlugin(modelRegistration: AmplifyModels())
        
        let dataStorePlugin = AWSDataStorePlugin(modelRegistration: AmplifyModels())
            do {
                let datastoreConfiguration = DataStoreConfiguration.custom(authModeStrategy: .multiAuth)
                let datastorePlugin2 = AWSDataStorePlugin(modelRegistration: AmplifyModels(), configuration: datastoreConfiguration)
                try Amplify.add(plugin: datastorePlugin2)
                
                try Amplify.add(plugin: apiPlugin)
                //try Amplify.add(plugin: dataStorePlugin)
                //s3
                try Amplify.add(plugin: AWSCognitoAuthPlugin())
                
                //push notification-----------
                //try Amplify.add(plugin: AWSPinpointPushNotificationsPlugin())
                
                /*
                try Amplify.add(
                    plugin: AWSPinpointPushNotificationsPlugin(options: [.badge, .alert, .sound])
                )*/
                // ---------------------
                
                try Amplify.add(plugin: AWSS3StoragePlugin())
                try Amplify.configure()
                print("Initialized Amplify");
                print("Amplify configured with Auth and Storage plugins")
            } catch {
                // simplified error handling for the tutorial
                print("Could not initialize Amplify: \(error)")
            }
        // Override point for customization after application launch.
        
        //iOS 앱에서 iOS SDK를 사용하려면 네이티브 앱 키를 사용해 iOS SDK를 초기화하는 과정이 필요하기 때문에 Kakao SDK를 초기화하는 코드를 추가
        KakaoSDK.initSDK(appKey: "129bed1de60021e887774b632c4ef8a1")
        
        //apple login
        
        /*
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let id = ASAuthorizationAppleIDCredential.user
        appleIDProvider.getCredentialState(forUserID: credential) { (credentialState, error) in
            switch credentialState {
            case .authorized:
                // The Apple ID credential is valid.
                print("해당 ID는 연동되어있습니다.")
            case .revoked:
                // The Apple ID credential is either revoked or was not found, so show the sign-in UI.
                print("해당 ID는 연동되어있지않습니다.")
            case .notFound:
                // The Apple ID credential is either was not found, so show the sign-in UI.
                print("해당 ID를 찾을 수 없습니다.")
            default:
                break
            }
        }*/
        
        //apple login end
        return true
    }

    
    
    /*
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if (AuthApi.isKakaoTalkLoginUrl(url)) {
            return AuthController.handleOpenUrl(url: url)
        }

        return false
    }*/
    
    // Note: In order for this to work on the simulator, you must be running
    // on Apple Silicon, with macOS 13+, Xcode 14+, and iOS simulator 16+.
    //
    // If your development environment does not meet all of these requirements,
    // then you must run on a real device to get an APNs token.
    //
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Task {
            do {
                try await Amplify.Notifications.Push.registerDevice(apnsToken: deviceToken)
                print("Registered with Pinpoint.")
            } catch {
                print("Error registering with Pinpoint: \(error)")
            }
        }
    }
   
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

