ig.module("game.entities.kroko").requires("game.entities.enemy").defines ->
    window.EntityKroko = EntityEnemy.extend(
        animSheet: new ig.AnimationSheet("media/ns-enem-kroko.png ", 46, 24)
        size:
            x: 46
            y: 11
        
        offset:
            x: 0
            y: 13


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
        speed: 20
        flip: false
        

        init: (x, y, settings) ->
            @parent x, y, settings
            @addAnim "run", 0.2, [ 0, 1 ]
            @addAnim "idle", 0.5, [ 2, 3 ]
            @addAnim "kolize", 0.4, [ 4, 5 ]
            @timer = 0
            
            @delkaChuze = 120
            @delkaStani = @delkaChuze + 40
            @wait=0
            @sezrani = false
        update: -> 
            @timer += 1
                
                # near an edge? return!
            if not ig.game.collisionMap.getTile(@pos.x + (if @flip then +1 else @size.x - 1), @pos.y + @size.y + 1)
                @flip = not @flip
                
            if (@timer <= @delkaChuze)
                @speed = 20  
                @currentAnim = @anims.run
            else
                @speed = 0
                @currentAnim = @anims.idle
                
            if (@timer >= @delkaStani)
                    @timer = 0
                
            xdir = (if @flip then -1 else 1)
            @vel.x = @speed * xdir
            
            @currentAnim.flip.x = @flip
            if (@sezrani == true)
                @wait+=1
            @parent()

        
        
        handleMovementTrace: (res) ->
            @parent res
            @flip = not @flip if res.collision.x


        check: (other) ->
            if other instanceof EntityEgg
                egg = other
                egg.crash() 
                if (egg.broken == true)
                    @currentAnim = @anims.kolize
                    @currentAnim.update()
                    @sezrani = true
                        
                if(@wait > 20)
                    egg.kill()
                    @wait = 0
                    @sezrani = false
                    
            if other instanceof EntityPlayer
                @dealDamage other
        
    )
