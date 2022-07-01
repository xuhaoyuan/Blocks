import UIKit
import SpriteKit
import AVFoundation

var secondAudioPlayer:AVAudioPlayer?

var points = 0

var touchDistance = 0
var selectionOn = true

var distanceOfLowerArea = 0

var widthOfWoodPatternBox = 0

var sizeOfWidth: CGFloat {
    return UIScreen.main.bounds.width / 10
}

var userDefaults = UserDefaults.standard

var selectionFeedbackGenerator = SFG()

var impactFeedbackGenerator = IFG(style: .heavy)

var notificationFeedbackGenerator = NFG()

var isANewScore = true

func isKeyPresentInUserDefaults(key: String) -> Bool {
    return userDefaults.object(forKey: key) != nil
}

func buildASmallSprite(_ block: BlockInfo?) -> SKSpriteNode {
    guard let block = block else { return SKSpriteNode() }
    let texture = SKTexture(imageNamed:  block.imageNamed)
    let nodeToReturn = SKSpriteNode(texture: nil)
    nodeToReturn.anchorPoint = CGPoint(x: 0, y: 0)
    var heighestWidth:CGFloat = 0
    var heighestHeight:CGFloat = 0
    for coordinate in block.combination {
        let widthOfSquare = CGFloat(widthOfWoodPatternBox) / 7.5
        let spriteNode = SKSpriteNode(texture: texture, color: UIColor.clear, size: CGSize(width: widthOfSquare, height: widthOfSquare))
        spriteNode.position = CGPoint(x: CGFloat(coordinate.0) * widthOfSquare, y: CGFloat(coordinate.1) * widthOfSquare)
        if CGFloat(coordinate.0) * widthOfSquare > heighestWidth {
            heighestWidth = CGFloat(coordinate.0) * widthOfSquare
        }
        if CGFloat(coordinate.1) * widthOfSquare > CGFloat(heighestHeight) {
            heighestHeight = CGFloat(coordinate.1) * widthOfSquare
            
        }

        nodeToReturn.addChild(spriteNode)
    }
    nodeToReturn.size = CGSize(width:heighestWidth , height: heighestHeight)
    return nodeToReturn
    
}

func buildASprite(_ block: BlockInfo?) -> BlockSpriteInfo {
    guard let block = block else { fatalError() }
    
    let texture = SKTexture(imageNamed: block.imageNamed)
    let nodeToReturn = SKSpriteNode(texture: nil)
    //    nodeToReturn.anchorPoint = CGPoint(x: 0, y: 0)
    var size: CGSize = .zero
    for coordinate in block.combination {
        let spriteNode = SKSpriteNode(texture: texture, color: UIColor.clear, size: CGSize(width: sizeOfWidth, height: sizeOfWidth))
        spriteNode.position = CGPoint(x: CGFloat(coordinate.0) * sizeOfWidth,
                                      y: CGFloat(coordinate.1) * sizeOfWidth)
        nodeToReturn.addChild(spriteNode)
        size.width = max(size.width, spriteNode.frame.maxX)
        size.height = max(size.height, spriteNode.frame.height)
        print(spriteNode.frame)
    }
    nodeToReturn.size = size
    return BlockSpriteInfo(node: nodeToReturn, imageName: block.imageNamed)
    
}

func resetDefaults() {
    
    
    let dictionary = userDefaults.dictionaryRepresentation()
    dictionary.keys.forEach { key in
        userDefaults.removeObject(forKey: key)
    }
}

func getTabelle() -> [EigeneCell]? {
    let data = userDefaults.object(forKey: KeysForUserDefaults.tabellenAccess)
    let decoder = JSONDecoder()
    if let arrayOfCellData = try? decoder.decode([EigeneCell].self, from: data as! Data) {
        return arrayOfCellData
    }
    return nil
    
}

func _addToTabelle(_ cellData:EigeneCell) {
    
    var arrayToAddOn = getTabelle()!
    // print("arrayGot",arrayToAddOn)
    arrayToAddOn.append(cellData)
    //print("arrayafterAppending",arrayToAddOn)
    
    let encoder = JSONEncoder()
    if let encoded = try? encoder.encode(arrayToAddOn) {
        userDefaults.set(encoded, forKey: KeysForUserDefaults.tabellenAccess)
        print("encoding succeeded")
    } else {
        print("encoding failed")
    }
    
}

func saveAScore(_ cellData:EigeneCell) {
    if isANewScore {
        _addToTabelle(cellData)
    }
    isANewScore = false
}

func newGame() {
    isANewScore = true
}

var isPlaying = false

func playSound(called string:String) {
    let pathToSound = Bundle.main.path(forResource: string, ofType: "wav")
    let url = URL(fileURLWithPath: pathToSound!)
    
    do{
        secondAudioPlayer = try AVAudioPlayer(contentsOf: url)
        secondAudioPlayer?.play()
        
    } catch {
        print("hat nicht den Sound gespielt")
    }
}
