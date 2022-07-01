import UIKit

class SelectSegmentedControl: UISegmentedControl {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        selectionFeedbackGenerator.selectionChanged()
        super.touchesBegan(touches, with: event)
    }
}
