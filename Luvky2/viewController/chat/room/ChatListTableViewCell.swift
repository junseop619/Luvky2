import UIKit

class ChatListTableViewCell: UITableViewCell {
    
    @IBOutlet var chatProfileImage: UIImageView!
    @IBOutlet var chatProfileName: UILabel!
    @IBOutlet var chatProfileText: UILabel!
    @IBOutlet var chatProfileTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
