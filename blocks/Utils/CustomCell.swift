import UIKit

class CustomCell: UITableViewCell {
    override func awakeFromNib() {
        self.selectedBackgroundView = UIView()
        self.selectedBackgroundView?.backgroundColor = UIColor(red: 0.7373 - 0.05, green: 0.2863 - 0.05, blue: 0.0667 - 0.05, alpha: 1.0)
        selectionStyle = .default
    }
}
