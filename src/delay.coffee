ig.module("game.entities.delay").requires("game.entities.base").defines ->
    window.EntityDelay = EntityBase.extend(
        _wmDrawBox: true
        _wmBoxColor: "rgba(255, 100, 0, 0.7)"

        size:
            x: 8
            y: 8

        delay: 1
        
        init: (x, y, settings) ->
            @parent x, y, settings
            @delayTimer = new ig.Timer()

        triggeredBy: (entity, trigger) ->
            @fire = true
            @delayTimer.set @delay
            @triggerEntity = entity

        update: ->
            if @fire and @delayTimer.delta() > 0
                @fire = false
                for t of @target
                    ent = ig.game.getEntityByName(@target[t])
                    if ent and typeof (ent.triggeredBy) is "function"
                        ent.triggeredBy @triggerEntity, this
    )
