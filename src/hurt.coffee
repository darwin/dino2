ig.module("game.entities.hurt").requires("game.entities.base").defines ->
    window.EntityHurt = EntityBase.extend(
        _wmDrawBox: true
        _wmBoxColor: "rgba(255, 0, 0, 0.7)"

        size:
            x: 8
            y: 8

        damage: 10
        
        triggeredBy: (entity, trigger) ->
            entity.receiveDamage @damage, this
    )
