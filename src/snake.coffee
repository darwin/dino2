ig.module("game.entities.snake").requires("game.entities.enemy").defines ->
    window.EntitySnake = EntityEnemy.extend(
        animSheet: new ig.AnimationSheet("media/ns-enem-had.png", 46, 24)
        size:
            x: 35
            y: 13
        
        offset:
            x: 6
            y: 11

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
        
        flip: false
        speed: 15

        init: (x, y, settings) ->
            @parent x, y, settings
            @addAnim "run", 0.3, [ 0, 1 ]
            @addAnim "idle", 0.5, [ 2, 3 ]
            @addAnim "kolize", 0.4, [ 4, 5 ]
            @timer = 0
            
            
            @delkaChuze = 100
            @delkaStani = @delkaChuze + 45
        update: -> 
            @timer += 1

            # near an edge? return!
            if not ig.game.collisionMap.getTile(@pos.x + (if @flip then +1 else @size.x - 1), @pos.y + @size.y + 1)
                @flip = not @flip
                            
            if (@timer <= @delkaChuze)
                @speed = 15  
                @currentAnim = @anims.run
            else
                @speed = 0
                @currentAnim = @anims.idle
                
            if (@timer > @delkaStani)
                    @timer = 0
                    
            xdir = (if @flip then -1 else 1)
            @vel.x = @speed * xdir
            
            
            @currentAnim.flip.x = @flip
            
            
            @parent()

        
        
        handleMovementTrace: (res) ->
            @parent res
            @flip = not @flip if res.collision.x

        
                
    
    )
