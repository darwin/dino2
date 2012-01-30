ig.module("game.entities.bird").requires("game.entities.base").defines ->
    window.EntityBird = EntityBase.extend(
        animSheet: new ig.AnimationSheet("media/ns-enem-ptak.png ", 46, 24)
        size:
            x: 46
            y: 24

        maxVel:
            x: 100
            y: 100

        friction:
            x: 150
            y: 0
        
        type: ig.Entity.TYPE.B
        checkAgainst: ig.Entity.TYPE.BOTH
        collides: ig.Entity.COLLIDES.PASSIVE
        health: 10
        speed: 140
        gravityFactor: 0
        
        flip: false

        init: (x, y, settings) ->
            @parent x, y, settings
            @addAnim "fly", 0.2, [ 0, 1 ]
            @addAnim "flywithegg", 0.2, [ 0, 1 ]
            @addAnim "idle", 0.5, [ 2, 3 ]
            @addAnim "death", 1, [ 1 ]
            
            @counter = 0
            
            @afterAttack = false
            
        ready: ->
            @phaseLen = 50 + ig.game.rand(5)*5
            # resolve entity by name if specified
            if @target and typeof @target == "string"
                console.log "resolved bird target ", ig.game.getEntityByName(@target)
                @target = ig.game.getEntityByName(@target)
                    
        freeFlight: ->
            phase = (@counter % (@phaseLen*3)) / @phaseLen
            @vel.y = 0 if phase==1
            @vel.y = 10 if phase==0
            @vel.y = -10 if phase==2
            
        targetedFlight: ->
            if not @afterAttack
                if @target.broken
                    @afterAttack = true 
                
                # approach target
                tc = @target.collisionCenter()
                mc = @collisionCenter()
                
                mc.y += 20
                dx = tc.x - mc.x
                dy = tc.y - mc.y
                frames = Math.abs(dx / @speed)
                @vel.y = dy / frames
                
                if (not @flip and dx<0) or (@flip and dx>0)
                    @afterAttack = true
                    
            else
                # leave target
                @vel.y = -40
            
        update: -> 
            @counter += 1

            xdir = (if @flip then -1 else 1)
            @vel.x = @speed * xdir
            
            if not @target
                @freeFlight()
            else
                @targetedFlight()
            
            @currentAnim.flip.x = @flip

            # remove bird if it is offscreen
            if @pos.y < ig.game.screen.y - 200
                @kill()

            
            @parent()
        
        check: (other) ->
            if other instanceof EntityEgg
                egg = other
                egg.crash()
    )
