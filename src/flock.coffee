ig.module("game.entities.flock").requires("game.entities.base").defines ->
    window.EntityFlock = EntityBase.extend(
        animSheet: new ig.AnimationSheet("media/ns-birds.png", 10, 7)
        size:
            x: 10
            y: 10
        
        
        type: ig.Entity.TYPE.B
        checkAgainst: ig.Entity.TYPE.BOTH
        collides: ig.Entity.COLLIDES.PASSIVE   
        flip: false
        speed: 15
        
        init: (x, y, settings) ->
            @parent x, y, settings
            @addAnim "run", 0.3, [ 0, 1 ]
            
            
            
            
            @xdir =  1
            
            
        update: -> 
            
            @gravityFactor = 0
            
            
            
            @flip = (if @xdir == 1 then 0 else 1)
            
            @vel.x = @speed * @xdir
            
            
            @currentAnim.flip.x = @flip
            
            
            @parent()

        
        handleMovementTrace: (res) ->
            @parent res
            @flip = not @flip if res.collision.x

    )
