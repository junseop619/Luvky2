//
//  ProfileViewController.swift
//  Luvky2
//
//  Created by 황준섭 on 2023/08/01.
//

import UIKit
import Amplify

class ProfileViewController: UIViewController {
    
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var profileUserNickName: UILabel!
    @IBOutlet var profileUserSex: UILabel!
    @IBOutlet var profileUserAge: UILabel!
    @IBOutlet var profileUserText: UILabel!
    
    @IBOutlet weak var profileMoreBtn: UIBarButtonItem!
    
    var receiveUser: String?
    var detailData = [String:String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            detailData = await readUser() ?? ["":""]
            profileUserNickName.text = "tempo"
            profileUserSex.text = "tempo"
            profileUserAge.text = "tempo"
            profileUserText.text = "tempo"
            
            let fileName = await detailData["userImgName"]
            let image = await downloadImage(fileName: fileName ?? "")
            await self.profileImage.image = image
        }
    }
  
    
    private func readUser() async -> [String:String]? {
        do{
            let users = try await Amplify.DataStore.query(User.self, where: User.keys.id.eq(receiveUser))
            var tempo_detailData = [String:String]()
            for user in users {
                tempo_detailData = ["userNickName":user.UserNickName,"userImgName":user.UserImageName,"userImgUrl":user.UserImageUrl,"sex":user.UserSex,"age":user.UserAge]
                return tempo_detailData
            }
        } catch {
            print("Could not query DataStore: \(error)")
        }
        return nil
    }
    
    func downloadImage(fileName: String) async -> UIImage {
        let url: URL
        do {
            url = try await Amplify.Storage.getURL(key: fileName)
        } catch {
            print("Failed to get URL for image: \(error)")
            return UIImage(named: "Luvky_Icon.png")!
        }
        let downloadTask = Amplify.Storage.downloadFile(
            key: fileName,
            local: url,
            options: nil
        )
        Task {
            for await progress in await downloadTask.progress {
                print("Progress: \(progress)")
            }
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let image = UIImage(data: data) ?? UIImage(named: fileName)!
            return image
        } catch {
            print(url)
            print("Download Error: \(error)")
            return UIImage(named: "Luvky_Icon.png")!
        }
    }
}
