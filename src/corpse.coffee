ig.module("game.entities.corpse").requires("game.entities.base").defines ->
    window.EntityCorpse = EntityBase.extend(
        size:
            x: 16
            y: 20

        offset:
            x: 14
            y: 4

        maxVel:
            x: 100
            y: 200

        animSheet: new ig.AnimationSheet("media/ns-player.png", 46, 24)

        init: (x, y, settings) ->
            @parent x, y, settings
            sx = 4
            @addAnim "corpse", 0.7, [ 3*sx+0, 3*sx+1 ], true
        
        update: ->
            # flipping logic
            @currentAnim.flip.x = @flip
            @parent()            
    )
