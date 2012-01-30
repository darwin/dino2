ig.module("game.entities.trigger").requires("game.entities.base").defines ->
    window.EntityTrigger = EntityBase.extend(
        _wmScalable: true
        _wmDrawBox: true
        _wmBoxColor: "rgba(196, 255, 0, 0.7)"
        size:
            x: 16
            y: 16

        target: null
        wait: -1
        waitTimer: null
        canFire: true
        type: ig.Entity.TYPE.NONE
        checkAgainst: ig.Entity.TYPE.A
        collides: ig.Entity.COLLIDES.NEVER
        
        init: (x, y, settings) ->
            # if settings.checks
            #     @checkAgainst = ig.Entity.TYPE[settings.checks.toUpperCase()] or ig.Entity.TYPE.A
            #     delete settings.check
            @parent x, y, settings
            @waitTimer = new ig.Timer()

        check: (other) ->
            if @canFire and @waitTimer.delta() >= 0
                console.log "trigger"
                if typeof (@target) is "object"
                    for t of @target
                        ent = ig.game.getEntityByName(@target[t])
                        if ent and typeof (ent.triggeredBy) is "function"
                            ent.triggeredBy other, this
                if @wait is -1
                    @canFire = false
                else
                    @waitTimer.set @wait

        update: ->
    )
