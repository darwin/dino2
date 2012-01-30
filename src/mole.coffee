ig.module("game.entities.mole").requires("game.entities.base").defines ->
    window.EntityMole = EntityBase.extend(
        animSheet: new ig.AnimationSheet("media/ns-enem-krtek.png ", 30, 30)
        size:
            x: 30
            y: 30

        maxVel:
            x: 100
            y: 100

        friction:
            x: 150
            y: 0
        
        type: ig.Entity.TYPE.B
        checkAgainst: ig.Entity.TYPE.BOTH
        collides: ig.Entity.COLLIDES.NONE
        gravityFactor: 0
        flip: false

        init: (x, y, settings) ->
            @parent x, y, settings
            @addAnim "digout", 0.2, [ 0 ... 8 ], true
            
        ready: ->
            # resolve entity by name if specified
            if @target and typeof @target == "string"
                console.log "resolved mole target ", ig.game.getEntityByName(@target)
                @target = ig.game.getEntityByName(@target)
                    
        update: -> 
            @vel.x = 0
            
            @currentAnim.flip.x = @flip
            
            # finish dying
            if @currentAnim is @anims.digout and @anims.digout.loopCount
                @kill()
            
            @parent()
        
        check: (other) ->
            if other instanceof EntityEgg
                if @anims.digout.frame>3
                    egg = other
                    egg.crash()
    )
