import UIKit
import XHYCategories

class PauseGameViewController: UIViewController {

    @IBOutlet weak var pauseLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!

    var pauseIsActive = false
    var pauseControlls:PauseControls?

    override func viewWillAppear(_ animated: Bool) {
        view.alpha = 0
        view.isUserInteractionEnabled = false
    }
    //MARK: - viewDidLoad()
    override func viewDidLoad() {
        view.cornerRadius = 20
        view.border(color: UIColor(hex: "202B39")!, width: 5)
        view.backgroundColor = UIColor(hex: "202B39")?.withAlphaComponent(0.8)
        
    }
    //MARK: - button @IBActions
    @IBAction func continueButton_tapped(sender: UIButton) {
        print("continueGame_button")
        
        cancel()
        pauseControlls?.continueGame()
    }

    @IBAction func restartButton_tapped(sender: UIButton) {
        print("restartGame_button")
        
        cancel()
        pauseControlls?.restartGame()
    }

    @IBAction func homeButton_tapped(sender: UIButton) {
        print("endGame_button")
        pauseControlls?.endGame()
    }
}
//MARK: - protocol from GameViewController
extension PauseGameViewController:ShowPauseViewController {
    func cancel() {
        view.alpha = 0
        view.isUserInteractionEnabled = false
    }

    func show(isPause: Bool) {
        if isPause {
            view.alpha = 1
        } else {
            UIView.animate(withDuration: 2) {
                self.view.alpha = 1
            }
        }
        continueButton.isHidden = !isPause
        continueButton.isEnabled = isPause

        view.border(color: UIColor.black, width: 5)
        view.backgroundColor = UIColor(hex: "202B39")!

        view.isUserInteractionEnabled = true

        if isPause {
            pauseLabel.text = "暂停"
        } else {
            pauseLabel.text = "失败"
        }
    }
}
