//
//  HomeTableViewCell.swift
//  Luvky2
//
//  Created by 황준섭 on 2023/07/12.
//

import UIKit
import Amplify

import KakaoSDKAuth
import KakaoSDKCommon
import KakaoSDKUser

class HomeTableViewCell: UITableViewCell {
    
    @IBOutlet var articleUserImg: UIImageView!
    @IBOutlet var articleUserName: UILabel!
    @IBOutlet var articleUserSex: UILabel!
    @IBOutlet var articleUserAge: UILabel!
    @IBOutlet var articleUserLocal: UILabel!
    @IBOutlet var articleTitleImg: UIImageView!
    @IBOutlet var articleUserMember: UILabel!
    @IBOutlet var articleTitle: UILabel!
    
    @IBOutlet var articleDate: UILabel!
    
    
    private let upperView = UIView()
    private let lowerView = UIView()

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
