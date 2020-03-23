//
//  EntityManager.swift
//  MonsterWars
//
//  Created by Main Account on 11/3/15.
//  Copyright © 2015 Razeware LLC. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class EntityManager {

  var entities = Set<GKEntity>()
  var toRemove = Set<GKEntity>()
  let scene: SKScene
  
  lazy var componentSystems: [GKComponentSystem] = {
    let moveSystem = GKComponentSystem(componentClass: MoveComponent.self)
    let meleeSystem = GKComponentSystem(componentClass: MeleeComponent.self)
    let firingSystem = GKComponentSystem(componentClass: FiringComponent.self)
    let castleSystem = GKComponentSystem(componentClass: CastleComponent.self)
    let aiSystem = GKComponentSystem(componentClass: AiComponent.self)
    return [moveSystem, meleeSystem, firingSystem, castleSystem, aiSystem]
  }()
  
  init(scene: SKScene) {
    self.scene = scene
  }
  
  func add(_ entity: GKEntity) {
    entities.insert(entity)
    
    for componentSystem in componentSystems {
      componentSystem.addComponent(foundIn: entity)
    }
  
    if let spriteNode = entity.component(ofType: SpriteComponent.self)?.node {
      scene.addChild(spriteNode)
    }
  
  }
  
  func remove(_ entity: GKEntity) {
  
    if let spriteNode = entity.component(ofType: SpriteComponent.self)?.node {
      spriteNode.removeFromParent()
    }
    
    toRemove.insert(entity)
    entities.remove(entity)
  }
  
  func entitiesForTeam(_ team: Team) -> [GKEntity] {
    
    return entities.compactMap{ entity in
      if let teamComponent = entity.component(ofType: TeamComponent.self) {
        if teamComponent.team == team {
          return entity
        }
      }
      return nil
    }
    
  }
  
  func moveComponentsForTeam(_ team: Team) -> [MoveComponent] {
    let entities = entitiesForTeam(team)
    var moveComponents = [MoveComponent]()
    for entity in entities {
      if let moveComponent = entity.component(ofType: MoveComponent.self) {
        moveComponents.append(moveComponent)
      }
    }
    return moveComponents
  }
  
  func castleForTeam(_ team: Team) -> GKEntity? {
    for entity in entities {
      if let teamComponent = entity.component(ofType: TeamComponent.self),
             let _ = entity.component(ofType: CastleComponent.self) {
        if teamComponent.team == team {
          return entity
        }
      }
    }
    return nil
  }
  
  func update(_ deltaTime: CFTimeInterval) {
    for componentSystem in componentSystems {
      componentSystem.update(deltaTime: deltaTime)
    }
    
    for curRemove in toRemove {
      for componentSystem in componentSystems {
        componentSystem.removeComponent(foundIn: curRemove)
      }
    }
    toRemove.removeAll()
  }
  
  func spawnQuirk(_ team: Team) {
    guard let teamEntity = castleForTeam(team),
          let teamCastleComponent = teamEntity.component(ofType: CastleComponent.self),
          let teamSpriteComponent = teamEntity.component(ofType: SpriteComponent.self) else {
      return
    }
    
    if teamCastleComponent.coins < costQuirk {
      return
    }
    
    teamCastleComponent.coins -= costQuirk
    scene.run(SoundManager.sharedInstance.soundSpawn)
    
    let monster = Quirk(team: team, entityManager: self)
    if let spriteComponent = monster.component(ofType: SpriteComponent.self) {
      spriteComponent.node.position = CGPoint(x: teamSpriteComponent.node.position.x, y: CGFloat.random(min: scene.size.height * 0.25, max: scene.size.height * 0.75))
      spriteComponent.node.zPosition = 2
    }
    add(monster)
  }

  func spawnZap(_ team: Team) {
    guard let teamEntity = castleForTeam(team),
          let teamCastleComponent = teamEntity.component(ofType: CastleComponent.self),
          let teamSpriteComponent = teamEntity.component(ofType: SpriteComponent.self) else {
      return
    }
    
    if teamCastleComponent.coins < costZap {
      return
    }
    
    teamCastleComponent.coins -= costZap
    scene.run(SoundManager.sharedInstance.soundSpawn)
    
    let monster = Zap(team: team, entityManager: self)
    if let spriteComponent = monster.component(ofType: SpriteComponent.self) {
      spriteComponent.node.position = CGPoint(x: teamSpriteComponent.node.position.x, y: CGFloat.random(min: scene.size.height * 0.25, max: scene.size.height * 0.75))
      spriteComponent.node.zPosition = 2
    }
    add(monster)
  }

  func spawnMunch(_ team: Team) {
    guard let teamEntity = castleForTeam(team),
          let teamCastleComponent = teamEntity.component(ofType: CastleComponent.self),
          let teamSpriteComponent = teamEntity.component(ofType: SpriteComponent.self) else {
      return
    }
    
    if teamCastleComponent.coins < costMunch {
      return
    }
    
    teamCastleComponent.coins -= costMunch
    scene.run(SoundManager.sharedInstance.soundSpawn)
    
    let monster = Munch(team: team, entityManager: self)
    if let spriteComponent = monster.component(ofType: SpriteComponent.self) {
      spriteComponent.node.position = CGPoint(x: teamSpriteComponent.node.position.x, y: CGFloat.random(min: scene.size.height * 0.25, max: scene.size.height * 0.75))
      spriteComponent.node.zPosition = 2
    }
    add(monster)
  }

}
