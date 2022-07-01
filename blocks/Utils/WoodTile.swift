import AVFoundation
import SpriteKit

class WoodTile: SKSpriteNode {
    
    var audioPlayer: AVAudioPlayer?
    var ultraPicked = false
    var isAnimation = false
    var imageName: String = ""
    var isPicked = false {
        willSet(to) {
            if  to == true && isAnimation {
                ultraPicked = true
            }
        }
        didSet {
            if isPicked {
                self.texture = SKTexture(imageNamed: imageName)
            } else if ultraPicked {
                self.texture = SKTexture(imageNamed: imageName)
                isPicked = true
                ultraPicked = false
            } /*else {
               texture = SKTexture(imageNamed: "empty_wooden_square")
               }*/

            
        }
    }
    var pointDelegate:GivePoint?
    init(position:CGPoint) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: AudioIdentifiers.coin, ofType: "wav")!))
            audioPlayer?.prepareToPlay()
        } catch {

        }
        super.init(texture: SKTexture(imageNamed: "empty_wooden_square"),
                   color: UIColor.clear,
                   size: CGSize(width:sizeOfWidth, height: sizeOfWidth))
        
        
        self.anchorPoint = CGPoint(x: 0, y: 0)
        self.position = position
        
    }
    convenience init(x:CGFloat,y:CGFloat) {
        self.init(position:CGPoint(x: x, y: y))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func restart() {
        ultraPicked = false
        isAnimation = false
        isPicked = false
        self.texture = SKTexture(imageNamed: "empty_wooden_square")
        
    }
    func animate() {
        
        audioPlayer?.play()
        selectionFeedbackGenerator.selectionChanged()
        self.texture = SKTexture(imageNamed: "empty_wooden_square")
        let location = CGPoint(x: self.parent!.frame.midX/2,y:self.parent!.frame.maxY - 120)
        
        
        let duration = 0.3
        
        let moveToAnimation = SKAction.move(to: location, duration: duration)
        //let fadeAnimation = SKAction.fadeOut(withDuration: duration)
        let fadeAnimation = SKAction.fadeAlpha(to: 0.4, duration: duration)
        let scaleAnimation = SKAction.scale(by: 0.4, duration: duration)
        let spinAnimation = SKAction.rotate(byAngle: 3, duration: duration)
        let groupAnimation = SKAction.group([moveToAnimation,fadeAnimation,scaleAnimation,spinAnimation])
        
        
        let sprite = SKSpriteNode(texture: SKTexture(imageNamed: imageName), color: UIColor.clear, size: self.size)
        sprite.run(groupAnimation) {
            sprite.removeFromParent()
            self.pointDelegate?.giveSinglePoint()
            
            
        }
        self.parent?.addChild(sprite)
        
        sprite.position = CGPoint(x: self.position.x + self.size.width/2, y: self.position.y + self.size.width/2)
        sprite.zPosition = ZPositions.woodTilesToDrag
        self.isPicked = false
        print("animationEnded")
    }
}
