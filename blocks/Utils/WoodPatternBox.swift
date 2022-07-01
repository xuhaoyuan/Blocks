import SpriteKit

struct BlockInfo {
    let imageNamed: String
    let combination: [(Int,Int)]
}

class WoodPatternBox: SKSpriteNode {
    var block: BlockInfo?
    var isActive = false
    var wasAsuccess = false

    func changeCombination() {
        if isActive {
            return
        }
        alpha = 1
        wasAsuccess = false
        block = BlockInfo(imageNamed: "wooden_square_toplace\(arc4random()%6)",
                          combination: WoodPatterns.all.randomElement()!)
        removeAllChildren()
        let spriteInside = buildASmallSprite(block!)
        spriteInside.zPosition = ZPositions.woodTilesToDrag
        spriteInside.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        spriteInside.position = CGPoint(x: 0 - spriteInside.frame.maxX, y: 0  - spriteInside.frame.maxY)
        addChild(spriteInside)
    }
    func testActivate(with point:CGPoint) -> Bool {
        return self.contains(point)
        
    }
    func activate() -> BlockSpriteInfo? {
        if wasAsuccess {
            return nil
        }
        if isActive {
            print("activate function called wrong")
            return nil
        }
        let returnSprite = buildASprite(block!)
        returnSprite.node.zPosition = ZPositions.woodTilesToDrag
        isActive = true
        alpha = 0.5
        return returnSprite
    }
    func end(isSuccess:Bool) {
        if !isActive {
            print("succes function called wrong")
            return
        }
        isActive = false
        alpha = 1
        if isSuccess {
            block = nil
            wasAsuccess = true
            removeAllChildren()
            
        } else {
            isActive = false
        }
    }
    
    init(position:CGPoint) {
        super.init(texture: SKTexture(imageNamed: "empty_wooden_square"), color: UIColor.clear, size: CGSize(width:distanceOfLowerArea,height:distanceOfLowerArea))
        print(distanceOfLowerArea,"distanceOfLowerArea")
        self.position = CGPoint(x: position.x, y:  CGFloat(distanceOfLowerArea) / 2 + (UIApplication.shared.keyWindow!.safeAreaInsets.bottom > 0 ? 10 : 0))

        changeCombination()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
