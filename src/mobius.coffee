ig.module("game.entities.mobius").requires("game.entities.base").defines ->
  window.EntityMobius = EntityBase.extend(
    _wmDrawBox: true
    _wmScalable: true
    _wmBoxColor: "rgba(0, 28, 230, 0.3)"

    size:
      x: 8
      y: 160
    
    wrapSize: 300

    update: ->
        
    wrapMap: ->
        # mobius oznacuje misto, kde se ma mapa zawrapovat
        # zkopiruje posledni background mapu (main) a kolizni mapu
        # sirka wrapu je @wrapSize
        maps = [ig.game.backgroundMaps[ig.game.backgroundMaps.length-1], ig.game.collisionMap]
        for map in maps
            for y in [0...map.height]
                row = map.data[y]
                bx = (@pos.x + @size.x) / map.tilesize
                for x in [0...@wrapSize]
                    row[bx+x] = row[x]
  )
