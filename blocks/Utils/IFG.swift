import UIKit

class IFG: UIImpactFeedbackGenerator {
    override func impactOccurred() {
        guard selectionOn else {
            return
        }
        super.impactOccurred()
        self.prepare()
        print("impact occured")
        
    }
    func singleImpact() {
        guard selectionOn else {
            return
        }
        super.impactOccurred()
        self.prepare()
        print("single impact occured")
    }

}
