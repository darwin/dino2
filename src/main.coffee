viewport =
    w: 480
    h: 240
    
ig.module("game.main").requires("impact.game", 
"impact.font"

"game.entities.base"
"game.entities.enemy"
"game.entities.mobius"
"game.entities.trigger"
"game.entities.hurt"
"game.entities.kill"
"game.entities.teller"
"game.entities.delay"
"game.entities.outro"

"game.entities.player"
"game.entities.corpse"
"game.entities.egg"
"game.entities.snake"
"game.entities.kroko"
"game.entities.ant"
"game.entities.bird"
"game.entities.mole"
"game.entities.flock"

"game.levels.story"
).defines ->
    window.game = ig.Game.extend(
        font: new ig.Font("media/04b03.font.png")
        font2: new ig.Font("media/font-black.png")
        bubbleImage: new ig.Image("media/ns-bubble.png")
        gravity: 300
        currentLevel: null
        infoControls: "LEFT+RIGHT ARROWS for run, UP for jump, DOWN for laying down eggs"
        infoRestart1: "No remaining live eggs - you've failed!"
        infoRestart2: "Press SPACE and try to save dinos again"
        
        defineInputs: ->
            ig.input.bind ig.KEY.LEFT_ARROW, "left"
            ig.input.bind ig.KEY.RIGHT_ARROW, "right"
            ig.input.bind ig.KEY.UP_ARROW, "jump"
            ig.input.bind ig.KEY.X, "jump"
            ig.input.bind ig.KEY.DOWN_ARROW, "layegg"
            ig.input.bind ig.KEY.SPACE, "layegg"
            ig.input.bind ig.KEY.R, "cheat"
            ig.input.bind ig.KEY.Y, "finish"
            
        defineAnimatedBackgrounds: ->
            lavaTopTile = 5 * 16 + 0
            lavaBottomTile = 5 * 16 + 8
            waterTopTile = 6 * 16 + 0
            waterBottomTile = 6 * 16 + 8
            fireSmall = 0 * 16 + 14
            fireMedium1 = 1 * 16 + 14
            fireMedium2 = 2 * 16 + 14

            as = new ig.AnimationSheet("media/tiles.png", 8, 8)
            @backgroundAnims = 
                "media/tiles.png":
                    14: new ig.Animation(as, 0.3, [fireSmall...fireSmall + 2])
                    30: new ig.Animation(as, 0.3, [fireMedium1...fireMedium1 + 2])
                    46: new ig.Animation(as, 0.3, [fireMedium2...fireMedium2 + 2])
                    80: new ig.Animation(as, 0.2, [lavaTopTile...lavaTopTile + 8])
                    88: new ig.Animation(as, 0.2, [lavaBottomTile...lavaBottomTile + 8])
                    96: new ig.Animation(as, 0.2, [waterTopTile...waterTopTile + 8])
                    104: new ig.Animation(as, 0.2, [waterBottomTile...waterBottomTile + 8])
        
        createTimers: ->
            @bubbleTimer = new ig.Timer()
            
        applyMobiusIfPresent: ->
            mobius = ig.game.getEntityByName("mobius")
            unless mobius
                console.log "define mobius!" 
                return
            
            mobius.wrapMap()
            
            
        launchLevel: ->
            getParam = (variable) ->
                query = window.location.search.substring(1)
                vars = query.split("&")
                i = 0

                while i < vars.length
                    pair = vars[i].split("=")
                    return pair[1] if pair[0] is variable
                    i++
                    
            @doCheats = getParam("c")
            
            unless @currentLevel
                levelName = getParam("l") or "story"
                # capitalize first letter
                levelName = levelName.replace(/^(\w)(\w*)$/, (m, a, b) ->
                    a.toUpperCase() + b
                )
                @currentLevel = "Level" + levelName
                
            console.log "loading level: #{@currentLevel}" 
            @loadLevel ig.global[@currentLevel]
            @applyMobiusIfPresent()
            
        rand: (max=0) ->
            if max
                @randSeed % (max+1)
            else
                @randSeed
        
        init: ->
            @activatedEgg = null
            @randSeed = 0
            
            @createTimers()
            @defineInputs()
            @defineAnimatedBackgrounds()
            @launchLevel()

            start = ig.game.getEntityByName("start")
            if start
                @screen.x = start.pos.x - ig.system.width / 2
                @screen.y = start.pos.y - ig.system.height / 2
            
                # initial scrolldown for first time
                if not window.replay
                    @screen.y -= 1000
            
        activateNextEgg: ->
            eggs = @getEntitiesByType(EntityEgg)
            
            bestEgg = null
            furthestX = -1
            for egg in eggs when egg.isSafe()
                if egg.pos.x > furthestX
                    furthestX = egg.pos.x
                    bestEgg = egg
            @activatedEgg = bestEgg
            
        scrollCameraTo: (target) ->
            speed =
                x: 10
                y: 10
            
            tx = target.pos.x - ig.system.width / 2
            ty = target.pos.y - ig.system.height / 2 - 10 # why 10px?
            
            dx = Math.round(@screen.x - tx)
            dy = Math.round(@screen.y - ty)
            
            if Math.abs(dx)<40 and Math.abs(dy)<40 # don't make it too precise to prevent camera jumps
                return true
                
            if dx > 0 then dirx = 1 else dirx = -1
            if dy > 0 then diry = 1 else diry = -1
            
            mx = dirx * speed.x
            my = diry * speed.y
            
            mx = dx if Math.abs(dx) < Math.abs(mx)
            my = dy if Math.abs(dy) < Math.abs(my)
            
            @screen.x -= mx
            @screen.y -= my
                
            return false
            
        cheat: ->
            # find immediate nest to the left and place an egg there
            nests = @getEntitiesByType(EntityNest)
            
            x = ig.game.screen.x + ig.system.width / 2
            
            best = null
            bestx = -1
            for nest in nests
                if nest.pos.x < x
                    if nest.pos.x > bestx
                        best = nest
                        bestx = nest.pos.x
                        
            if best
                cc = best.collisionCenter()
                ig.game.spawnEntity "EntityEgg", cc.x, cc.y - 15
                ig.game.sortEntitiesDeferred()
                
        finish: ->
            console.log "finish"
            best = @getEntityByName("finish")
            cc = best.collisionCenter()
            ig.game.spawnEntity "EntityEgg", cc.x, cc.y - 15
            ig.game.sortEntitiesDeferred()
                
        isGameOver: ->
            player = @getEntitiesByType(EntityPlayer)[0]
            return false if player
            eggs = @getEntitiesByType(EntityEgg)
            for egg in eggs
                return false if egg.isSafe()
            return true

        update: ->

            @randSeed+=1

            # logika kamery
            player = @getEntitiesByType(EntityPlayer)[0]
            if player
                if player.pos.x<9100
                    @screen.x = player.pos.x - ig.system.width / 2
                    @screen.y = player.pos.y - ig.system.height / 2
            else
                # restart hry
                if @isGameOver()
                    if @doCheats
                        if ig.input.pressed("cheat")
                            @cheat()
                        if ig.input.pressed("finish")
                            @finish()
                    if ig.input.pressed("layegg") or ig.input.pressed("jump")
                        window.replay = true
                        @init()
                        return

                if not @activatedEgg
                    @activateNextEgg()
                else
                    if @scrollCameraTo @activatedEgg
                        @activatedEgg.born()
                        @activatedEgg = null
                    
            @parent()

        drawBubble: (player) ->
            return unless player
            return unless @bubble
            player = ig.game.getEntityByName(@bubble.who) if @bubble.who
            
            if @bubbleTimer.delta() >= @bubble.duration
                player.talks = false
                return
                
            player.talks = true
            flipX = false
            flipX = player.currentAnim.flip.x if player.currentAnim
            x = player.pos.x
            if flipX > 0
                x += 6
            else
                x += 48
            y = player.pos.y - 32
            x += -ig.game.screen.x - 180
            y += -ig.game.screen.y - 4

            origAlpha = ig.system.context.globalAlpha
            ig.system.context.globalAlpha = @bubbleTimer.delta().map(@bubble.duration - 0.5, @bubble.duration, 1, 0)

            @bubbleImage.drawTile x, y, (if @bubble.type then 1 else 0), 320, 32, flipX, false
            x += 180
            y += 8
            ig.game.font2.draw @bubble.text, x, y, ig.Font.ALIGN.CENTER
            ig.system.context.globalAlpha = origAlpha

        drawHUD: (player) ->
            if player
                pct = player.time / player.lifetime 
            else
                pct = 0
            display = Math.floor(pct * 100)
            status = "Run! remaining time: #{display}%"
            @font.draw status, 2, 2
            
        drawTimeBar: (player) ->
            size = 46
            pct = player.time / player.lifetime 
            len = pct*size
            color = Math.floor(pct * 128)
            ig.system.context.fillStyle = "rgba(255, #{color}, #{color}, 0.9)"
            ig.system.context.fillRect(
                ig.system.getDrawPos(player.pos.x - ig.game.screen.x - 20),
                ig.system.getDrawPos(player.pos.y - ig.game.screen.y - 10), 
                len * ig.system.scale, 
                2 * ig.system.scale
            )

        draw: ->
            @parent()
            
            # nakresli info hlasku
            player = @getEntitiesByType(EntityPlayer)[0]
            if player
                @drawTimeBar player if player.hasTime()
                @drawBubble player
                @font.draw @infoControls, 2, 230 unless player.runAway
                @drawHUD player unless player.runAway
            
            if @isGameOver()
                @font.draw @infoRestart1, viewport.w/2 + 10, 80, ig.Font.ALIGN.CENTER
                if (Math.floor(@rand() / 20) % 3) > 0
                    @font.draw @infoRestart2, viewport.w/2 + 10, 100, ig.Font.ALIGN.CENTER

        tell: (text, duration, who, target, type) ->
            @bubble = { text, duration, who, target, type } 
            @bubbleTimer.reset()
    )