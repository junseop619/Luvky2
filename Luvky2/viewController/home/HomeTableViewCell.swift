//
//  HomeTableViewCell.swift
//  Luvky2
//
//  Created by 황준섭 on 2023/07/12.
//

import UIKit

class HomeTableViewCell: UITableViewCell {
    
    @IBOutlet var articleUserImg: UIImageView!
    @IBOutlet var articleUserName: UILabel!
    @IBOutlet var articleUserSex: UILabel!
    @IBOutlet var articleUserAge: UILabel!
    @IBOutlet var articleUserLocal: UILabel!
    @IBOutlet var articleTitleImg: UIImageView!
    @IBOutlet var articleUserMember: UILabel!
    
    
    @IBOutlet var articleTitle: UILabel!
    
    private let upperView = UIView()
    private let lowerView = UIView()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
