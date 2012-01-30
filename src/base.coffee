ig.module("game.entities.base").requires("impact.entity").defines ->
    window.EntityBase = ig.Entity.extend(
        collisionCenter: ->
            {
                x: @pos.x + @offset.x + @size.x/2
                y: @pos.y + @offset.y + @size.y/2
            }
            
        visibleOnCamera: ->
            (ig.game.screen.x <= @pos.x <= ig.game.screen.x + ig.system.width) and
            (ig.game.screen.y <= @pos.y <= ig.game.screen.y + ig.system.height)
            
    )
