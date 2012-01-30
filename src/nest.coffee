ig.module("game.entities.nest").requires("game.entities.base").defines ->
    window.EntityNest = EntityBase.extend(
        size:
            x: 30
            y: 5

        offset:
            x: 0
            y: 0

        maxVel:
            x: 100
            y: 200

        type: ig.Entity.TYPE.B
        checkAgainst: ig.Entity.TYPE.B
        collides: ig.Entity.COLLIDES.PASSIVE
        
        animSheet: new ig.AnimationSheet("media/ns-hnizdo.png", 30, 5)
        zIndex: 10

        init: (x, y, settings) ->
            @parent x, y, settings
            sx = 1
            @addAnim "main", 1, [ 0*sx+0 ], true
        
        update: ->
            @parent()
            
        check: (other) ->
            if other instanceof EntityEgg
                egg = other
                egg.markAsSafe()
    )
