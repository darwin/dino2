ig.module("game.entities.teller").requires("game.entities.base").defines ->
    window.EntityTeller = EntityBase.extend(
        _wmScalable: true
        _wmDrawBox: true
        _wmBoxColor: "rgba(0, 255, 255, 0.7)"
        
        size:
            x: 32
            y: 64

        target: null
        wait: -1
        waitTimer: null
        canFire: true
        duration: 5
        type: ig.Entity.TYPE.NONE
        checkAgainst: ig.Entity.TYPE.A
        collides: ig.Entity.COLLIDES.NEVER
        
        init: (x, y, settings) ->
            # if settings.checks
            #     @checkAgainst = ig.Entity.TYPE[settings.checks.toUpperCase()] or ig.Entity.TYPE.A
            #     delete settings.check
            @parent x, y, settings
            @waitTimer = new ig.Timer()

        action: ->
            ig.game.tell @text, @duration, @who, @target, @bubble

        check: (other) ->
            if @canFire and @waitTimer.delta() >= 0
                @action()
                if @wait is -1
                    @canFire = false
                else
                    @waitTimer.set @wait
    )
