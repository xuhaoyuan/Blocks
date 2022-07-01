import UIKit
import AVFoundation
class SchonSelectButton: UIButton {
    var audioPlayer : AVAudioPlayer!
    override init(frame: CGRect) {
        
        
        super.init(frame:frame)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: AudioIdentifiers.button, ofType: "wav")!))
        } catch {
            fatalError("failed")
        }
        audioPlayer.prepareToPlay()
        //fatalError("init(coder:) has not been implemented")
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        selectionFeedbackGenerator.selectionChanged()


        audioPlayer.play()

        self.transform = self.transform.scaledBy(x: 1.1, y: 1.1)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.transform = self.transform.scaledBy(x: 0.9, y: 0.9)
        }

    }
}
