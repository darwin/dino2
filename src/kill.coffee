ig.module("game.entities.kill").requires("game.entities.base").defines ->
    window.EntityKill = EntityBase.extend(
        _wmScalable: true
        _wmDrawBox: true
        _wmBoxColor: "rgba(196, 0, 0, 0.7)"

        size:
            x: 8
            y: 8

        type: ig.Entity.TYPE.B
        checkAgainst: ig.Entity.TYPE.BOTH
        collides: ig.Entity.COLLIDES.PASSIVE
        
        check: (other) ->
            other.receiveDamage 10, this
    )
