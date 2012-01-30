ig.module("game.entities.ant").requires("game.entities.base").defines ->
    window.EntityAnt = EntityBase.extend(
        animSheet: new ig.AnimationSheet("media/ns-mravenec.png", 12, 5)
        size:
            x: 12
            y: 5

        maxVel:
            x: 100
            y: 100

        friction:
            x: 150
            y: 0

        type: ig.Entity.TYPE.B
        checkAgainst: ig.Entity.TYPE.A
        collides: ig.Entity.COLLIDES.PASSIVE
        health: 10
        speed: 20
        flip: false

        init: (x, y, settings) ->
            @parent x, y, settings
            @addAnim "run", 0.2, [ 0, 1 ]
            @addAnim "death", 1, [ 2, 3 ]

        update: ->
                    # near an edge? return!
            if not ig.game.collisionMap.getTile(@pos.x + (if @flip then +1 else @size.x - 1), @pos.y + @size.y + 1)
                @flip = not @flip
            xdir = (if @flip then -1 else 1)
            @vel.x = @speed * xdir
            @currentAnim.flip.x = not @flip
            @parent()

        handleMovementTrace: (res) ->
            @parent res
            @flip = not @flip if res.collision.x

        check: (other) ->
            @currentAnim = @anims.death
            @speed = 0
    )
