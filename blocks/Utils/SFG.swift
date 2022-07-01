import UIKit

class SFG: UISelectionFeedbackGenerator {
    override func selectionChanged() {
        guard selectionOn else {
            return
        }
        super.selectionChanged()
        self.prepare()
        print("selection Changed")
    }
    func singleSelection() {
        guard selectionOn else {
            return
        }
        super.selectionChanged()
        print("single selection changed")
        
    }
}

