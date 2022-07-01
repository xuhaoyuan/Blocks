import SpriteKit
import GameplayKit
import AVFoundation

struct BlockSpriteInfo {
    let node: SKSpriteNode
    let imageName: String
}

class GameScene: SKScene {

    var gameViewControllerDelegate: GameViewControllerDelegate?
    
    private var holdingOnTo : BlockSpriteInfo?
    private var holdingOnToIndex:Int?

    private var cgpoint10x10 = [[WoodTile]]()
    private var cgpointX = [[WoodTile]]()
    private var woodPatternBoxes = [WoodPatternBox]()

    private var touchesNotBlocked:Bool = true
    
    private var singleTouch = true
    
    private var background = SKSpriteNode(imageNamed: "wood_backround")
    
    private var gameHasEnded = false
    
    private var coinSoundEffect:AVAudioPlayer?

    override func didMove(to view: SKView) {
        isPlaying = true
        self.size = view.frame.size

        setUpBackround()
        
        let realRest: CGFloat = (self.size.height - 160 - self.size.width)
        widthOfWoodPatternBox = Int(min(realRest,  self.size.width / 3))
        
        let rest: CGFloat = ((self.size.height  - 160) / 2) - (self.size.width / 2) + CGFloat(widthOfWoodPatternBox) / 2

        distanceOfLowerArea = Int(rest)
        setUpArrays()

        for index in 1...3 {
            let position = CGPoint(x: (frame.size.width / 3) * CGFloat(index ) - (frame.size.width / 6),
                                   y: CGFloat(Double.nan))
            let woodPatternBoxToAppend = WoodPatternBox(position: position)
            woodPatternBoxToAppend.size = CGSize(width: CGFloat(widthOfWoodPatternBox) - 20,
                                                 height: CGFloat(widthOfWoodPatternBox) - 20 )
            woodPatternBoxes.append(woodPatternBoxToAppend)
            addChild(woodPatternBoxes[index - 1])
        }
        
    }
    deinit {
        isPlaying = false
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        //print("touches Began")
        if gameHasEnded {
            selectionFeedbackGenerator.selectionChanged()
            gameViewControllerDelegate?.lostGame()
        }
        guard touchesNotBlocked else {
            return
        }
        if singleTouch == false {
            return
        }

        singleTouch = false
        selectionFeedbackGenerator.selectionChanged()
        var counter = -1
        for woodPatternBox in woodPatternBoxes {
            counter += 1
            if woodPatternBox.testActivate(with: touch.location(in: self)) {
                if let woodPatterBox = woodPatternBoxes[counter].activate() {
                    holdingOnTo = woodPatterBox
                    woodPatterBox.node.position = CGPoint(
                        x: woodPatternBoxes[counter].position.x - woodPatterBox.node.frame.width/2,
                        y: woodPatternBoxes[counter].position.y + CGFloat(touchDistance)
                    )
                    holdingOnToIndex = counter
                    addChild(holdingOnTo!.node)
                    return
                }
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        guard touchesNotBlocked else {
            return
        }
        guard let node = holdingOnTo?.node else { return }
        node.position = CGPoint(
            x: touch.location(in: self).x - node.size.width/2,
            y: touch.location(in: self).y + CGFloat(touchDistance)
        )
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        guard touchesNotBlocked else { return }
        guard let holdingOnToIndex = holdingOnToIndex else { return }

        singleTouch = true
        
        if let node = holdingOnTo?.node {
            let patternBox = woodPatternBoxes[holdingOnToIndex]
            let positionInArray = givePosition(x: Int(touch.location(in: self).x) - Int(node.frame.width)/2,
                                               y: Int(touch.location(in: self).y) + touchDistance)
            
            let isSuccess = checkPositionReal(patternBox.block!.combination, x: positionInArray.0, y: positionInArray.1, imageName: holdingOnTo?.imageName)
            
            if !isSuccess {
                node.anchorPoint = CGPoint(x: 0, y: 0)

                self.touchesNotBlocked = false
                let boxPosition: CGPoint = patternBox.position
                let ySquared: CGFloat = (node.position.y-boxPosition.y)*(node.position.y-boxPosition.y)
                let xSquared: CGFloat = (node.position.x-boxPosition.x)*(node.position.x-boxPosition.x)
                let realDuration = sqrt(Double(xSquared + ySquared))
                var impactIntesity = CGFloat()
                if realDuration < 100 {
                    impactIntesity = 0
                } else {
                    impactIntesity = 0.4
                }
                if #available(iOS 13.0, *) {
                    impactFeedbackGenerator.impactOccurred(intensity: impactIntesity)
                } else {
                    impactFeedbackGenerator.impactOccurred()
                }
                let duration = sqrt(Double(xSquared + ySquared)) / 5000
                let scale: CGFloat = patternBox.children[0].children[0].frame.width / node.children[0].frame.width

                let groupAction = SKAction.group([
                    SKAction.move(to: CGPoint(x: boxPosition.x, y: boxPosition.y), duration: duration),
                    SKAction.scale(to: scale, duration: duration)
                ])
                holdingOnTo?.node.run(groupAction) {
                    
                    node.removeAllActions()
                    self.woodPatternBoxes[holdingOnToIndex].end(isSuccess: isSuccess)
                    node.removeFromParent()
                    self.holdingOnTo = nil
                    //self.checkForCombinations()
                    self.touchesNotBlocked = true
                }
            } else {
                playSound(called: AudioIdentifiers.placeDown)
                impactFeedbackGenerator.impactOccurred()
                node.removeFromParent()
                holdingOnTo = nil
                woodPatternBoxes[holdingOnToIndex].end(isSuccess: isSuccess)
                checkForCombinations()
            }
        }
        var combinations = [[(Int,Int)]]()
        
        for woodPatternBox in woodPatternBoxes {
            if let patternBox = woodPatternBox.block?.combination  {
                combinations.append(patternBox)
            }
        }
        if combinations.isEmpty {
            for woodPatternBox in woodPatternBoxes {
                woodPatternBox.changeCombination()
            }
            checkIfGameEnds()
            return
        }
    }

    override func didFinishUpdate() {
        //print(areTouchesActive,"areTouchesActive")
    }

}

extension GameScene {
    
    func checkIfGameEnds() {
        //print("checkIfGameEnds")
        var combinations = [[(Int,Int)]]()
        
        for woodPatternBox in woodPatternBoxes {
            if let patternBox = woodPatternBox.block?.combination  {
                combinations.append(patternBox)
            }
        }
        if combinations.isEmpty {
            for woodPatternBox in woodPatternBoxes {
                woodPatternBox.changeCombination()
            }
            checkIfGameEnds()
            return
        }
        for combination in combinations {
            if checkIfPossibleToFit(combination) {
                return
            }
        }
        gameHasEnded = true
        touchesNotBlocked = false
        gameViewControllerDelegate?.fadeButton()
        self.run(SKAction.fadeAlpha(to: CGFloat(alphaValue), duration: 1))
    }
    
    func setUpBackround() {
        background.size = self.size
        background.zPosition = -1

        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        addChild(background)
    }
    
    func setUpArrays() {
        for y in 0...9 {
            cgpoint10x10.append([WoodTile]())
            for x in 0...9 {
                let woodTile = WoodTile(position: CGPoint(
                    x: CGFloat(x) * CGFloat(self.frame.maxX / 10),
                    y: CGFloat(y) * CGFloat(self.frame.maxX / 10) + CGFloat(distanceOfLowerArea))
                )
                woodTile.pointDelegate = self


                cgpoint10x10[cgpoint10x10.count - 1].append(woodTile)
                self.addChild(woodTile)
            }
        }
        for Yrow in 0...9 {
            cgpointX.append([WoodTile]())
            for Xrow in 0...9 {
                cgpointX[cgpointX.count - 1].append(cgpoint10x10[Xrow][Yrow])
            }
        }
    }

    func givePoint() {
        points += 1
        gameViewControllerDelegate?.giveScore(score: points)
    }
    
    func giveScore(howMany score: Int) {
        points += score
        gameViewControllerDelegate?.giveScore(score: points)
    }
    
    func givePosition(x: Int, y: Int) -> (Int, Int) {
        if y < distanceOfLowerArea {
            return (-30,-30)
        }
        let realX = x
        let realY = y - distanceOfLowerArea
        let sizeOfTiles = Int(sizeOfWidth)

        let xValueRemainder = realX%sizeOfTiles
        let yValueRemainder = realY%sizeOfTiles

        return ((realX - xValueRemainder) / sizeOfTiles,(realY - yValueRemainder) / sizeOfTiles)

    }
    
    func deletePositions(_ points:[(Int,Int)] ) {
        for point in points {
            cgpoint10x10[point.1][point.0].animate()
        }
    }
    
    func checkPositionReal(_ checkableCoordinates: [(Int,Int)],x:Int,y:Int, imageName: String?) -> Bool {
        if x > 9 || x < 0 || y < 0 || y > 9 {
            //print("return 1")
            return false
        }
        for checkableCoordinate in checkableCoordinates {
            if checkableCoordinate.0 + x > 9 || checkableCoordinate.1 + y > 9 {
                //print("return 2")
                return false
            }
            if cgpoint10x10[checkableCoordinate.1 + y][checkableCoordinate.0 + x].isPicked {
                //print("return 3")
                return false
            }

        }
        var pointsToAdd = 0
        for checkableCoordinate in checkableCoordinates {
            pointsToAdd += 1
            cgpoint10x10[checkableCoordinate.1 + y][checkableCoordinate.0 + x].imageName = imageName ?? ""
            cgpoint10x10[checkableCoordinate.1 + y][checkableCoordinate.0 + x].isPicked = true
        }
        giveScore(howMany: pointsToAdd)
        return true
        
    }
    
    func checkForCombinations() {
        var allTiles = [WoodTile]()

    firstFor:for row in cgpoint10x10 {

        for column in row {
            if !column.isPicked {
                continue firstFor
            }
        }
        for column in row {
            allTiles.append(column)
        }
    }
        
    firstFor:for row in cgpointX {
        for column in row {
            if !column.isPicked {
                continue firstFor
            }
        }
        for column in row {
            allTiles.append(column)
        }
    }
        if allTiles.isEmpty {
            checkIfGameEnds()
            return
        }
        var checkedTiles = [WoodTile]()
    allTilesForIn:for tile in allTiles {
    checkedTilesForIn:for checkedTile in checkedTiles {
        if checkedTile == tile {
            continue allTilesForIn
        }
    }
        checkedTiles.append(tile)
    }
        for checkedTile in checkedTiles {
            checkedTile.isPicked = false
            checkedTile.isAnimation = true
        }
        func animateTiles() {
            if checkedTiles.isEmpty {
                checkIfGameEnds()
                for checkedTile in checkedTiles {
                    
                    checkedTile.isAnimation = false
                }
                return
            }
            //allTiles.first?
            checkedTiles.removeFirst().animate()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) { // 0.075
                animateTiles()
            }
        }
        animateTiles()
    }
    
    func checkIfPossibleToFit(_ checkableCoordinates: [(Int, Int)]) -> Bool {
        
        for Yindex in 0...9 {
        XForIn:for Xindex in 0...9 {
            for checkableCoordinate in checkableCoordinates {
                if checkableCoordinate.0 < 0 || checkableCoordinate.1 < 0 || checkableCoordinate.0 > 9 || checkableCoordinate.1 > 9 {
                    return false
                }
                if checkableCoordinate.0 + Xindex > 9 || checkableCoordinate.1 + Yindex > 9 {
                    continue XForIn
                }
                if cgpoint10x10[checkableCoordinate.1 + Yindex][checkableCoordinate.0 + Xindex].isPicked {
                    continue XForIn
                }
            }
            return true


        }
        }
        return false
    }
}

extension GameScene:GameSceneDelegate {
    
    func makeInactive() {
        //print("makeInactive")
        self.alpha = 0.4
        self.touchesNotBlocked = false
        
    }
    
    func makeActive() {
        //print("makeActive")
        self.touchesNotBlocked = true
        self.alpha = 1
        //aktuelleGameScene = self.self
    }
    func restartScene() {
        for yrow in cgpoint10x10 {
            for xcolumn in yrow {
                xcolumn.restart()
            }
        }
        for woodPatternbox in woodPatternBoxes {
            woodPatternbox.changeCombination()
        }
        
        gameHasEnded = false
        points = 0
        gameViewControllerDelegate?.giveScore(score: 0)
    }
}

extension GameScene: GivePoint {
    func giveSinglePoint() {
        givePoint()
    }
}
