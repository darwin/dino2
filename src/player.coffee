ig.module("game.entities.player").requires("impact.entity").defines ->
    window.EntityPlayer = EntityBase.extend(
        animSheet: new ig.AnimationSheet("media/ns-player.png", 46, 24)
        size:
            x: 16
            y: 20

        offset:
            x: 20  # redefined dynamically in update
            y: 4

        maxVel:
            x: 200
            y: 400

        friction:
            x: 600
            y: 200

        type: ig.Entity.TYPE.A
        checkAgainst: ig.Entity.TYPE.NONE
        collides: ig.Entity.COLLIDES.PASSIVE
        accelGround: 800
        accelAir: 400
        jump: 250
        gravityFactor: 1.5
        health: 100
        lifetime: 12
        
        init: (x, y, settings) ->
            @parent x, y, settings
            @specialMode = false
            sx = 4
            @addAnim "idle", 1, [ 1*sx+0 .. 1*sx+1 ]
            @addAnim "run", 0.07, [ 0*sx+0 .. 0*sx+1 ]
            @addAnim "jump", 1, [ 0*sx+0 ]
            @addAnim "fall", 0.4, [ 0*sx+1 ]
            @addAnim "die", 0.2, [ 2*sx+0 .. 2*sx+1 ], true
            @addAnim "layegg", 0.5, [ 2*sx+0 .. 2*sx+1], true
            @addAnim "birth", 0.2, [ 0*sx+2 .. 0*sx+3 ], true
            @addAnim "none", 1, [ 100 ]
            @addAnim "hurt", 0.1, [ 4*sx+0, 4*sx+1 ], true
            @time = @lifetime
            @reduced = 0
            @timer = new ig.Timer(@lifetime);

        reduceTime: (amount=0) ->
            return unless @time

            @reduced += amount
            delta = @timer.delta()
            @time = @lifetime - (@lifetime + delta) - @reduced
            
            if @time <= 0
                @time = 0
                @currentAnim = @anims.die
                @currentAnim.rewind()
                @specialMode = true
                
        hasTime: ->
            true
        
        receiveDamage: (x) ->
            @reduceTime 1000000000
                
        hurt: (amount=0.2) ->
            return unless @time
            @currentAnim = @anims.hurt
            @currentAnim.rewind()
            @specialMode = true
            @reduceTime amount
        
        birth: ->
            @currentAnim = @anims.none
            @currentAnim.rewind()
            @specialMode = true

        eggJump: ->
            @currentAnim = @anims.birth
            @currentAnim.rewind()
            @vel.y = -@jump/2
            @vel.x = @jump/2
            @specialMode = true
            
        draw: ->
            # simulate aging
            sheet = 4 * 5
            phase = Math.floor((0.99 - @time / @lifetime) * 3)
            shift = phase * sheet
            tile = @currentAnim.tile
            @currentAnim.tile += shift
            @parent()
            @currentAnim.tile -= shift
            
        update: ->
            # outro
            if @runAway
                @accel.x = @accelGround
                @currentAnim = @anims.run
                @flip = false
            else    
                # time is running out
                @reduceTime() if @hasTime()

                if @specialMode
                    @accel.x = 0
            
                if not @specialMode
                    # basic movement left <-> right
                    accel = (if @standing then @accelGround else @accelAir)
                    if ig.input.state("left")
                        @accel.x = -accel
                        @flip = true
                    else if ig.input.state("right")
                        @accel.x = accel
                        @flip = false
                    else
                        @accel.x = 0
                
                    # jump, fall, run, idle
                    @vel.y = -@jump if @standing and ig.input.pressed("jump")
                    if @vel.y < 0
                        @currentAnim = @anims.jump
                    else if @vel.y > 0
                        @currentAnim = @anims.fall
                    else unless @vel.x is 0
                        @currentAnim = @anims.run
                    else
                        @currentAnim = @anims.idle
                
                    # start laying down a new egg
                    if ig.input.pressed("layegg")
                        @currentAnim = @anims.layegg
                        @currentAnim.rewind()
                        @specialMode = true

                # finish laying down an egg
                if @currentAnim is @anims.layegg and @anims.layegg.loopCount
                    ig.game.spawnEntity "EntityEgg", @pos.x, @pos.y+2
                    ig.game.sortEntitiesDeferred()
                    @currentAnim = @anims.run
                    @specialMode = false

                # finish dying
                if @currentAnim is @anims.die and @anims.die.loopCount
                    ig.game.spawnEntity "EntityCorpse", @pos.x, @pos.y, { flip: @flip }
                    @kill()

                # finish birth
                if @currentAnim is @anims.birth and @anims.birth.loopCount
                    @currentAnim = @anims.run
                    @specialMode = false

                # finish hurt
                if @currentAnim is @anims.hurt and @anims.hurt.loopCount
                    @currentAnim = @anims.run
                    @specialMode = false
            
            # flipping logic
            @currentAnim.flip.x = @flip
            if @flip then @offset.x = 11 else @offset.x = 20
            
            @parent()
    )
