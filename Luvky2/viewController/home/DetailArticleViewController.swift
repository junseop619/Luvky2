//
//  DetailArticleViewController.swift
//  Luvky2
//
//  Created by 황준섭 on 2023/07/12.
//

import UIKit

class DetailArticleViewController: UIViewController {

    var detailData = [String:String]()
    
    @IBOutlet var articleUserImg: UIImageView!
    
    @IBOutlet var articleUserName: UILabel!
    
    @IBOutlet var articleUserSex: UILabel!
    
    @IBOutlet var articleUserAge: UILabel!
    
    
    @IBOutlet var articleUserLocal: UILabel!
    
    @IBOutlet var articleUserMember: UILabel!
    
    @IBOutlet var articleTitleImg: UIImageView!
    
    @IBOutlet var articleTitle: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        articleUserImg.image = UIImage(named: detailData["userImg"]!)
        articleUserName.text = detailData["name"]
        articleUserSex.text = detailData["sex"]
        articleUserAge.text = detailData["age"]
        articleUserLocal.text = detailData["local"]
        articleUserMember.text = detailData["member"]
        articleTitleImg.image = UIImage(named: detailData["titleImg"]!)
        articleTitle.text = detailData["title"]

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
