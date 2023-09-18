Defender = Object:extend()
Defender:implement(GameObject)
Defender:implement(Physics)
Defender:implement(Unit)
function Defender:init(args)
    self:init_game_object(args)
    self:init_unit()
    
    --self.color = blue[0]
    self.defender_type = args['defender_type'] or 'archer'
    --original size is 9,9
    self:set_as_rectangle(9,9,'dynamic','defender')
    --self:set_as_triangle(9,9, 'dynamic', 'defender')
    self.color = blue[0]
    self:set_damping(100)
    self.visual_shape = 'rectangle'
    --self.visual_shape = 'triangle'
    self.damage_dealt = 0

    self.defender_id = args.defender_id
    print('args.defender_id:'..args.defender_id)
    self.xp = args.xp
    self.defender_level = args.defender_level
    if self.defender_level == 1 then
      self.xp_till_next_level = 20
    else
      self.xp_till_next_level = 20 + 20*args.defender_level
    end

    self.classes = character_classes['swordsman']
    self:calculate_stats(true)

    if self.defender_type == 'archer' then
        self.attack_sensor = Circle(self.x, self.y, 160)
        self.t:cooldown(2, function() local enemies = self:get_objects_in_shape(self.attack_sensor, main.current.enemies); return enemies and #enemies > 0 end, function()
        local closest_enemy = self:get_closest_object_in_shape(self.attack_sensor, main.current.enemies)
        if closest_enemy then
            self:shoot(self:angle_to_object(closest_enemy), {pierce = 0, ricochet = 0})
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
    --graphics.print('xp='..self.xp, pixul_font, self.x, self.y)
    --graphics.line(self.x - 0.5*self.shape.w, self.y - self.shape.h, self.x + 0.5*self.shape.w, self.y - self.shape.h, bg[-3], 2)
    --local n = math.remap(self.hp, 0, self.max_hp, 0, 1)
    --graphics.line(self.x - 0.5*self.shape.w, self.y - self.shape.h, self.x - 0.5*self.shape.w + n*self.shape.w, self.y - self.shape.h,
    --self.hfx.hit.f and fg[0] or ((self:is(Player) and green[0]) or (table.any(main.current.enemies, function(v) return self:is(v) end) and red[0])), 2)
    if self.visual_shape == 'rectangle' then
      graphics.rectangle(self.x, self.y, self.shape.w, self.shape.h, 3, 3, (self.hfx.hit.f or self.hfx.shoot.f) and fg[0] or self.color)
    end
    if self.visual_shape == 'triangle' then
      graphics.triangle(self.x, self.y, self.shape.w, self.shape.h, (self.hfx.hit.f or self.hfx.shoot.f) and fg[0] or self.color)
    end

    graphics.line(self.x-self.shape.w/2, self.y+self.shape.h, self.x+self.shape.w/2, self.y+self.shape.h, bg[-3], 2)
    graphics.line(self.x-self.shape.w/2, self.y+self.shape.h, self.x-self.shape.w/2+2*(self.shape.w/2)*(self.xp/self.xp_till_next_level), self.y+self.shape.h, green[8], 2)
    --graphics.print_centered('XP', pixul_font, self.x, self.y+self.shape.h, 0, 0.5, 0.5, 0, 0)


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

    if self.defender_type == 'archer' then
        archer1:play{pitch = random:float(0.95, 1.05), volume = 0.35}
    end

    HitCircle{group = main.current.effects, 
    x=self.x+0.8*self.shape.w*math.cos(r), 
    y=self.y+0.8*self.shape.w*math.sin(r),
    rs = 6}
    local defender_info = {group = main.current.main,
    x=self.x+1.6*self.shape.w*math.cos(r),
    y=self.y+1.6*self.shape.w*math.sin(r),
    v=250,
    r=r,
    color=self.color,
    dmg=self.dmg*dmg_m,
    crit=crit,
    character=self.character,
    parent=self,
    level=self.level,
    defender_id=self.defender_id
    }
    Projectile(table.merge(defender_info, mods or {}))
  end
function Defender:increase_xp(amount)
  self.xp = self.xp + amount
end
--[[
XPBar = Object:extend()
XPBar:implement(GameObject)
XPBar:implement(Parent)
function XPBar:init(args)
  self:init_game_object(args)
  self.hidden = true
end

function XPBar:update(dt)
  self:update_game_object(dt)
  self:follow_parent_exclusively()
end

function XPBar:draw()
  if self.hidden then return end
  local p = self.parent
  graphics.push(p.x, p.y, 0, p.hfx.hit.x, p.hfx.hit.x)
    graphics.line(p.x - 0.5*p.shape.w, p.y - p.shape.h, p.x + 0.5*p.shape.w, p.y - p.shape.h, bg[-3], 2)
    local n = math.remap(p.hp, 0, p.max_hp, 0, 1)
    graphics.line(p.x - 0.5*p.shape.w, p.y - p.shape.h, p.x - 0.5*p.shape.w + n*p.shape.w, p.y - p.shape.h,
    p.hfx.hit.f and fg[0] or ((p:is(Player) and green[0]) or (table.any(main.current.enemies, function(v) return p:is(v) end) and red[0])), 2)
  graphics.pop()
end
]]