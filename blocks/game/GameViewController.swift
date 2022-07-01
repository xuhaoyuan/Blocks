import UIKit
import SpriteKit
import AVFoundation


class GameViewController: UIViewController {

    private let main_musik_url = URL(fileURLWithPath: Bundle.main.path(forResource: AudioIdentifiers.main_musik, ofType: "wav")!)

    private var controllAlphaOfPauseViewController: ShowPauseViewController?

    private var gameSceneDelegate:GameSceneDelegate?
    private var globalAudioPlayer:AVAudioPlayer?
    private var gameWasEnded = false
    private var doubleHit: CGFloat = 0

    @IBOutlet weak var highscoreLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    //    @IBOutlet var buttons: [UIButton]!
    

    private var pauseIsActive = false

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        globalAudioPlayer = try? AVAudioPlayer(contentsOf: main_musik_url)
        globalAudioPlayer?.numberOfLoops = 2048
        globalAudioPlayer?.volume = 0.75
        globalAudioPlayer?.play()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }

        highscoreLabel.text = "最高分: " + String(userDefaults.integer(forKey: "highscore"))
        scoreLabel.text = "分数: "  + String(0)

        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            let scene =  GameScene()
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
            scene.gameViewControllerDelegate = self
            gameSceneDelegate = scene
            // Present the scene
            view.presentScene(scene)
            
            
            view.ignoresSiblingOrder = true
            
            //view.showsFPS = true
            //view.showsNodeCount = true
            //view.bringSubviewToFront(h)
        }
    }

    @IBAction func pauseGame(_ sender: Any) {
        if gameWasEnded {
            return
        }
        if pauseIsActive {
            pauseIsActive = false
            controllAlphaOfPauseViewController?.cancel()
            gameSceneDelegate?.makeActive()
            pauseButton.setImage(UIImage(named: "wood_pause_button"), for: .normal)
        } else {
            pauseButton.setImage(UIImage(named: "wood_back_button"), for: .normal)
            pauseIsActive = true
            controllAlphaOfPauseViewController?.show(isPause: true)
            gameSceneDelegate?.makeInactive()
        }

    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let pauseGameViewController = segue.destination as? PauseGameViewController {
            pauseGameViewController.pauseControlls = self
            self.controllAlphaOfPauseViewController = pauseGameViewController
        } else if segue.destination is StartingViewController {
            isPlaying = false
        }
        
    }
}

extension GameViewController:GameViewControllerDelegate {
    func fadeButton() {
        print("button faded")
        gameWasEnded = true
        UIView.animate(withDuration: 1) {
            self.pauseButton.alpha = CGFloat(alphaValue)
        }
    }

    func lostGame() {
        //aktuelleGameScene = nil
        print("lostGame")
        gameWasEnded = true
        controllAlphaOfPauseViewController?.show(isPause: false)
        //gameSceneDelegate?.makeInactive()
    }


    func giveScore(score:Int) {
        scoreLabel.text = "分数: "  + String(score)
        GameViewController.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.identityScoreLabel), object: nil)
        UIView.animateKeyframes(withDuration: 0.15, delay: 0, options: [.calculationModeLinear]) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) { [self] in
                self.scoreLabel.transform = CGAffineTransform(scaleX: 1.1 + self.doubleHit,
                                                              y: 1.1 + self.doubleHit)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.4) {
                self.scoreLabel.transform = CGAffineTransform(scaleX: 0.9 + self.doubleHit, y: 0.9 + self.doubleHit)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.9, relativeDuration: 0.1) {
                self.scoreLabel.transform = CGAffineTransform.identity
            }
        } completion: { [weak self] _ in
            guard let self = self else { return }
            self.doubleHit += 0.05
            self.perform(#selector(self.identityScoreLabel), with: nil, afterDelay: 1)
        }

        if score > userDefaults.integer(forKey: KeysForUserDefaults.highscore) {
            userDefaults.set(score, forKey: KeysForUserDefaults.highscore)
            highscoreLabel.text = "最高分: "  + String(score)
        }
    }

    @objc private func identityScoreLabel() {
        self.scoreLabel.transform = CGAffineTransform.identity
        self.doubleHit = 0
    }
}
//MARK: - protocol vom PauseViewController
extension GameViewController:PauseControls {
    func restartGame() {
        saveAScore(EigeneCell(date: Date(), score: points))
        newGame()
        //addToTabelle(EigeneCell(date: Date(), score: points))
        self.pauseButton.alpha = 1
        gameWasEnded = false
        gameSceneDelegate?.makeActive()
        gameSceneDelegate?.restartScene()
        pauseIsActive = false
        pauseButton.setImage(UIImage(named: "wood_pause_button"), for: .normal)
        //newGame()
        print("restartGame")
    }
    
    func endGame() {
        saveAScore(EigeneCell(date: Date(), score: points))
        newGame()
        isPlaying = false
        //addToTabelle(EigeneCell(date: Date(), score: points))
        gameWasEnded = false
        points = 0
        //newGame()
        self.dismiss(animated: true, completion: nil)
        self.globalAudioPlayer?.pause()
        self.globalAudioPlayer = nil
        isPlaying = false
        print("endGame")
    }
    
    func continueGame() {
        gameSceneDelegate?.makeActive()
        print("continueGame")
        pauseIsActive = false
        pauseButton.setImage(UIImage(named: "wood_pause_button"), for: .normal)
        //scoreLabel.text = "Score: 0"
    }
}
