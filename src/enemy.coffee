ig.module("game.entities.enemy").requires("game.entities.base").defines ->
    window.EntityEnemy = EntityBase.extend(
        

        init: (x, y, settings) ->
            @parent(x,y,settings)
            @timerHurt = 0       
            
            
        update: -> 
            @timerHurt += 1
            
            
            @parent()

        
        dealDamage: (other) ->
            
            if other instanceof EntityPlayer
                @currentAnim = @anims.kolize
                if other.pos.x > @pos.x
                    @currentAnim.flip.x = 0
                else
                    @currentAnim.flip.x = 1
                    
                
                
                @currentAnim.update()
                @timer = @delkaStani
                @speed = 0
                if(@timerHurt > 50)
                    other.hurt()
                    @timerHurt = 0
              
        check: (other) ->
            if other instanceof EntityEgg
                egg = other
                stav = egg.crash()   
                    
            if other instanceof EntityPlayer
                @dealDamage other
                
    
    )
