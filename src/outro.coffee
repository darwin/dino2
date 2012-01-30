ig.module("game.entities.outro").requires("game.entities.base").defines ->
    window.EntityOutro = EntityBase.extend(
        _wmScalable: true
        _wmDrawBox: true
        _wmBoxColor: "rgba(0, 128, 255, 0.7)"
        
        size:
            x: 32
            y: 64

        type: ig.Entity.TYPE.NONE
        checkAgainst: ig.Entity.TYPE.A
        collides: ig.Entity.COLLIDES.NEVER
        
        init: (x, y, settings) ->
            @parent x, y, settings

        check: (other) ->
            return if @fired
            @fired = true
            player = ig.game.getEntitiesByType(EntityPlayer)[0]
            if player
                player.runAway = true
                setTimeout(->
                    if window.displayOutro
                        window.displayOutro()
                , 4000)
    )
