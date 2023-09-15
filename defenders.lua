Defender = Object:extend()
Defender:implement(GameObject)
Defender:implement(Physics)
Defender:implement(Unit)
function Defender:init(args)
    self:init_game_object(args)
    self:init_unit()
    
    --self.color = blue[0]
    self.defendertype = args['defendertype'] or 'archer'
    self:set_as_rectangle(9,9,'dynamic','defender')
    self:set_damping(100)
    self.visual_shape = 'rectangle'
    self.damage_dealt = 0

    self.classes = character_classes['swordsman']
    self:calculate_stats(true)

    if self.defendertype == 'archer' then
        self.attack_sensor = Circle(self.x, self.y, 160)
        self.t:cooldown(2, function() local enemies = self:get_objects_in_shape(self.attack_sensor, main.current.enemies); return enemies and #enemies > 0 end, function()
        local closest_enemy = self:get_closest_object_in_shape(self.attack_sensor, main.current.enemies)
        if closest_enemy then
            self:shoot(self:angle_to_object(closest_enemy), {pierce = 100, ricochet = 0})
        end
    end, nil, nil, 'shoot')
    end
end
function Defender:update(dt)
    self:update_game_object(dt)
    self:calculate_stats()
    if self.hp < self.max_hp then
        self:show_hp()
    end
end
function Defender:draw()
    graphics.push(self.x, self.y, self.r, self.hfx.hit.x*self.hfx.shoot.x, self.hfx.hit.x*self.hfx.shoot.x)
    if self.visual_shape == 'rectangle' then
      graphics.rectangle(self.x, self.y, self.shape.w, self.shape.h, 3, 3, (self.hfx.hit.f or self.hfx.shoot.f) and fg[0] or self.color)
    end
    graphics.pop()
  end
  function Defender:on_collision_enter(other, contact)
    local x, y = contact:getPositions()
    if table.any(main.current.enemies, function(v) return other:is(v) end) then
      other:push(random:float(2, 8)*(self.knockback_m or 1), self:angle_to_object(other))
      other:hit(self.dmg)
      self:hit(other.dmg)
      HitCircle{group = main.current.effects, x = x, y = y, rs = 6, color = fg[0], duration = 0.1}
      for i = 1, 2 do HitParticle{group = main.current.effects, x = x, y = y, color = self.color} end
      for i = 1, 2 do HitParticle{group = main.current.effects, x = x, y = y, color = other.color} end
    end
  end
  function Defender:hit(damage, from_undead)
    if self.dead then return end
    self.hfx:use('hit', 0.25, 200, 10)
  
    local actual_damage = math.max(self:calculate_damage(damage), 0)
    self.hp = self.hp - actual_damage
    _G[random:table{'player_hit1', 'player_hit2'}]:play{pitch = random:float(0.95, 1.05), volume = 0.5}
    camera:shake(0.5, 0.075)
    main.current.damage_taken = main.current.damage_taken + actual_damage
    if self.hp <= 0 then
      self.dead = true
    end
  end
  function Defender:shoot(r, mods)
    mods = mods or {}
    camera:spring_shake(0.025, r)
    self.hfx:use('shoot', 0.25)
  
    local dmg_m = 1
    local crit = false

    if self.defendertype == 'archer' then
        archer1:play{pitch = random:float(0.95, 1.05), volume = 0.35}
    end

    HitCircle{group = main.current.effects, 
    x=self.x+0.8*self.shape.w*math.cos(r), 
    y=self.y+0.8*self.shape.w*math.sin(r),
    rs = 6}
    local t = {group = main.current.main,
    x=self.x+1.6*self.shape.w*math.cos(r),
    y=self.y+1.6*self.shape.w*math.sin(r),
    v=250,
    r=r,
    color=self.color,
    dmg=self.dmg*dmg_m,
    crit=crit,
    character=self.character,
    parent=self,
    level=self.level
    }
    Projectile(table.merge(t, mods or {}))
  end
  