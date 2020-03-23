//
//  AiComponent.swift
//  MonsterWars
//
//  Created by Main Account on 11/3/15.
//  Copyright © 2015 Razeware LLC. All rights reserved.
//

import Foundation
import GameplayKit

enum MonsterType {
  case quirk
  case zap
  case munch

  static let allValues = [quirk, zap, munch]

}

class AiComponent: GKComponent {

  var nextMonster = MonsterType.quirk
  let entityManager: EntityManager
  
  init(entityManager: EntityManager) {
    self.entityManager = entityManager
    super.init()
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }

  override func update(deltaTime seconds: TimeInterval) {
  
    // Get required components
    guard let teamComponent = entity?.component(ofType: TeamComponent.self),
              let castleComponent = entity?.component(ofType: CastleComponent.self) else {
      return
    }
    
    if nextMonster == .quirk && castleComponent.coins >= costQuirk {
      entityManager.spawnQuirk(teamComponent.team)
      nextMonster = MonsterType.allValues[Int(arc4random()) % MonsterType.allValues.count]
    }
    if nextMonster == .zap && castleComponent.coins >= costZap {
      entityManager.spawnZap(teamComponent.team)
      nextMonster = MonsterType.allValues[Int(arc4random()) % MonsterType.allValues.count]
    }
    if nextMonster == .munch && castleComponent.coins >= costMunch {
      entityManager.spawnMunch(teamComponent.team)
      nextMonster = MonsterType.allValues[Int(arc4random()) % MonsterType.allValues.count]
    }
  
  }

}
