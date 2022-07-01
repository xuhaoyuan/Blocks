import UIKit

class NFG: UINotificationFeedbackGenerator {
    override func notificationOccurred(_ notificationType: UINotificationFeedbackGenerator.FeedbackType) {
        guard selectionOn else {
            return
        }
        super.notificationOccurred(notificationType)
        self.prepare()
        print(notificationType,"occured")
    }

    func singleNotification(_ notificationType: UINotificationFeedbackGenerator.FeedbackType) {
        guard selectionOn else {
            return
        }
        super.notificationOccurred(notificationType)
        print("single",notificationType,"occured")
    }
}
