ig.module("game.entiti\es.egg").requires("game.entities.base").defines ->
    window.EntityEgg = EntityBase.extend(
        animSheet: new ig.AnimationSheet("media/ns-vajco.png", 18, 22)
        dangerDelay: 50
        size:
            x: 11
            y: 12

        offset:
            x: 4
            y: 9

        maxVel:
            x: 100
            y: 200

        type: ig.Entity.TYPE.B

        init: (x, y, settings) ->
            @parent x, y, settings
            sx = 13
            @addAnim "grow", 0.2, [ 1*sx+0, 0*sx+0 ], true
            @addAnim "normal", 1, [ 0*sx+0 ]
            @addAnim "shine", 0.1, [ 0*sx+1 ... 0*sx+5 ], true
            @addAnim "born", 0.1, [ 1*sx+0 ... 1*sx+13 ], true
            @addAnim "break", 0.1, [ 2*sx+0 ... 2*sx+2 ], true
            @safe = false
            @counter = 0
            
        born: ->
            @player = ig.game.spawnEntity "EntityPlayer", @pos.x, @pos.y-4
            @player.birth()
            
            @currentAnim = @anims.born
            @currentAnim.rewind()
            @broken = true
            
        crash: ->
            return if @broken # already broken?
            @currentAnim = @anims.break
            @currentAnim.rewind()
            @broken = true
            
        callBird: ->
            fromDir = if ig.game.rand(1)==0 then -1 else 1
            
            spawn = 
                x: @pos.x + fromDir * 300
                y: @pos.y - (180 + ig.game.rand(4)*4)
                
            ig.game.spawnEntity "EntityBird", spawn.x, spawn.y, { target: this, flip: fromDir>0 }
            
        callMole: (info) -> 
            fromDir = if ig.game.rand(1)==0 then -1 else 1
            
            fromDir = 1 if info.l
            fromDir = -1 if info.r

            spawn = 
                x: @collisionCenter().x - 20 + fromDir * 15
                y: @pos.y - 18
                
            ig.game.spawnEntity "EntityMole", spawn.x, spawn.y, { target: this, flip: fromDir>0 }
            
        underOpenSky: ->
            # true if the egg lies under open sky
            c = @collisionCenter()
            cm = ig.game.collisionMap
            c.y -= 5
            t = cm.trace(c.x, c.y, 8*20, -8*20, 1, 1)
            return false if t.collision.x or t.collision.y
            t = cm.trace(c.x, c.y, -8*20, -8*20, 1, 1)
            return false if t.collision.x or t.collision.y
            t = cm.trace(c.x, c.y, 0, -6*20, 1, 1)
            return false if t.collision.x or t.collision.y
            return true

        onSoftGround: ->
            # true if the egg lies on soft ground
            c = @collisionCenter()
            cm = ig.game.collisionMap
            
            c.y -= 5
                
            t1 = cm.trace(c.x, c.y, 40, 0, 1, 1)
            t2 = cm.trace(c.x, c.y, -40, 0, 1, 1)
            t1x = cm.trace(c.x+15, c.y, 40, 5, 1, 1)
            t2x = cm.trace(c.x+15, c.y, -40, 5, 1, 1)
            
            occupiedLeft = t2.collision.x or not t2x.collision.y
            occupiedRight = t1.collision.x or not t1x.collision.y
            
            if occupiedRight and occupiedLeft
                false
            else
                { l: occupiedLeft, r: occupiedRight }
            
        evalDanger: ->
            # eval current situation and call predators if the egg is in danger
            if @underOpenSky()
                @callBird()
                return
               
            info = @onSoftGround() 
            if info
                @callMole(info)
                return

        update: ->
            if @currentAnim is @anims.normal
                @counter += 1
                

            # finish initial grow
            if @currentAnim is @anims.grow and @anims.grow.loopCount
                @currentAnim = @anims.normal
                @currentAnim.rewind()

            # jump form egg
            if @currentAnim is @anims.born and @anims.born.frame>=12 and not @jumpDone
                @player.eggJump()
                @jumpDone = true
                
            # start shine, TODO: randomization
            if @currentAnim is @anims.normal and @counter%150==0
                @currentAnim = @anims.shine
                @currentAnim.rewind()

            # finish shine -> normal
            if @currentAnim is @anims.shine and @anims.shine.loopCount
                @currentAnim = @anims.normal
                @currentAnim.rewind()
                
            # call predators if the egg is in danger
            if @currentAnim is @anims.normal and @counter==@dangerDelay
                @evalDanger() unless @isSafe()
            
            @parent()

        markAsSafe: ->
            @safe = true
        
        isSafe: ->
            @safe and not @broken
    )
