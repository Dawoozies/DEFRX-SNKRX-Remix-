--make your new arena here
ArenaDefence = Object:extend()
ArenaDefence:implement(State)
ArenaDefence:implement(GameObject)
function ArenaDefence:init(name)
    self:init_state(name)
    self:init_game_object()
end
function ArenaDefence:on_enter(from, level, loop, units, passives, shop_level, shop_xp, lock)
    self.hfx:add('condition1', 1)
    self.hfx:add('condition2', 1)
    self.level = level or 1
    self.loop = loop or 0
    self.units = units or {}
    self.passives = passives
    self.shop_level = shop_level or 1
    self.shop_xp = shop_xp or 0
    self.lock = lock
  
    self.starting_units = table.copy(units)
    
    self.floor = Group()
    self.main = Group():set_as_physics_world(32, 0, 0, {'player', 'crystal' , 'defender', 'enemy', 'projectile', 'enemy_projectile', 'force_field', 'ghost'})
    self.post_main = Group()
    self.effects = Group()
    self.ui = Group()

    self.main:disable_collision_between('player', 'player')
    self.main:disable_collision_between('player', 'projectile')
    self.main:disable_collision_between('player', 'enemy_projectile')
    self.main:disable_collision_between('projectile', 'projectile')
    self.main:disable_collision_between('projectile', 'enemy_projectile')
    self.main:disable_collision_between('projectile', 'enemy')
    self.main:disable_collision_between('enemy_projectile', 'enemy')
    self.main:disable_collision_between('enemy_projectile', 'enemy_projectile')
    self.main:disable_collision_between('player', 'force_field')
    self.main:disable_collision_between('projectile', 'force_field')
    self.main:disable_collision_between('ghost', 'player')
    self.main:disable_collision_between('ghost', 'projectile')
    self.main:disable_collision_between('ghost', 'enemy')
    self.main:disable_collision_between('ghost', 'enemy_projectile')
    self.main:disable_collision_between('ghost', 'ghost')
    self.main:disable_collision_between('ghost', 'force_field')
    self.main:disable_collision_between('defender', 'player')
    self.main:disable_collision_between('defender', 'projectile')
    self.main:disable_collision_between('defender', 'enemy_projectile')
    self.main:disable_collision_between('crystal', 'projectile')
    self.main:disable_collision_between('crystal', 'enemy_projectile')

    self.main:enable_trigger_between('projectile', 'enemy')
    self.main:enable_trigger_between('enemy_projectile', 'player')
    self.main:enable_trigger_between('player', 'enemy_projectile')
    self.main:enable_trigger_between('enemy_projectile', 'enemy')
    self.main:enable_trigger_between('player', 'ghost')
    self.main:enable_trigger_between('ghost', 'player')
    self.main:enable_trigger_between('enemy_projectile', 'defender')
    self.main:enable_trigger_between('enemy_projectile', 'crystal')

    self.gold_picked_up = 0
    self.damage_dealt = 0
    self.damage_taken = 0
    self.main_slow_amount = 1
    self.enemies = {Seeker, EnemyCritter}
    self.color = self.color or fg[0]

    -- Spawn solids and player
    self.x1, self.y1 = gw/2 - 0.8*gw/2, gh/2 - 0.8*gh/2
    self.x2, self.y2 = gw/2 + 0.8*gw/2, gh/2 + 0.8*gh/2
    self.w, self.h = self.x2 - self.x1, self.y2 - self.y1
    self.spawn_points = {
      {x = self.x1 + 32, y = self.y1 + 32, r = math.pi/4},
      {x = self.x1 + 32, y = self.y2 - 32, r = -math.pi/4},
      {x = self.x2 - 32, y = self.y1 + 32, r = 3*math.pi/4},
      {x = self.x2 - 32, y = self.y2 - 32, r = -3*math.pi/4},
      {x = gw/2, y = gh/2, r = random:float(0, 2*math.pi)}
    }
    self.spawn_offsets = {{x = -12, y = -12}, {x = 12, y = -12}, {x = 12, y = 12}, {x = -12, y = 12}, {x = 0, y = 0}}

    --left and right walls
    Wall{group = self.main, vertices = math.to_rectangle_vertices(-40, -40, 0, gh+40), color = bg[-1]}
    Wall{group = self.main, vertices = math.to_rectangle_vertices(gw, -40, gw+40, gh+40), color = bg[-1]}
    --top and bottom walls
    Wall{group = self.main, vertices = math.to_rectangle_vertices(-40,-40,gw+40,0), color = bg[-1]}
    Wall{group = self.main, vertices = math.to_rectangle_vertices(-40,gh,gw+40,gh+40), color = bg[-1]}

    --WallCover{group = self.main, vertices = math.to_rectangle_vertices(-20, gh/2-40,0, gh/2+40), color = red[0]}
    WallCover{group = self.main, vertices = math.to_rectangle_vertices(-20, 0, 0, gh), color = red[0]}
    --self.crystal = WallCover{group = self.main, vertices = math.to_rectangle_vertices(gw-40,gh/2-10,gw-20, gh/2+10), color = green[0]}
    --Wall{group = self.main, vertices = math.to_rectangle_vertices(-40, -40, self.x1, gh + 40), color = bg[-1]}
    --Wall{group = self.main, vertices = math.to_rectangle_vertices(self.x2, -40, gw + 40, gh + 40), color = bg[-1]}
    --Wall{group = self.main, vertices = math.to_rectangle_vertices(self.x1, -40, self.x2, self.y1), color = bg[-1]}
    --Wall{group = self.main, vertices = math.to_rectangle_vertices(self.x1, self.y2, self.x2, gh + 40), color = bg[-1]}
    --WallCover{group = self.post_main, vertices = math.to_rectangle_vertices(-40, -40, self.x1, gh + 40), color = bg[-1]}
    --WallCover{group = self.post_main, vertices = math.to_rectangle_vertices(self.x2, -40, gw + 40, gh + 40), color = bg[-1]}
    --WallCover{group = self.post_main, vertices = math.to_rectangle_vertices(self.x1, -40, self.x2, self.y1), color = bg[-1]}
    --WallCover{group = self.post_main, vertices = math.to_rectangle_vertices(self.x1, self.y2, self.x2, gh + 40), color = bg[-1]}

    self.gold_text = Text({{text = '[wavy_mid]gold: [yellow]' .. main.current.gold_picked_up, font = pixul_font, alignment = 'center'}}, global_text_tags)

    self.units = {
        {character = 'archer', level = 1},
    }

    for i, unit in ipairs(self.units) do
        if i == 1 then
          self.player = Player{group = self.main, x = gw/2, y = gh/2 + 16, leader = true, character = unit.character, level = unit.level, passives = self.passives, ii = i}
        else
          self.player:add_follower(Player{group = self.main, character = unit.character, level = unit.level, passives = self.passives, ii = i})
        end
    end

    local units = self.player:get_all_units()
    for _, unit in ipairs(units) do
      local chp = CharacterHP{group = self.effects, x = self.x1 + 8 + (unit.ii-1)*22, y = self.y2 + 14, parent = unit}
      unit.character_hp = chp
    end

    self.crystal = Crystal{group = self.main, x = gw/2+40, y = gh/2}
    --local crystalhp = CharacterHP{group = self.effects, x = self.x1, y = self.y2, parent = self.crystal}
    --self.crystal.character_hp = crystalhp
    --defenders can level up individually
    --defenders gain xp for themselves and their class
    --a low level defender generates much much less xp for their class if a higher level
    --expose the attack speed as a slider below each defender
    self.defenders = {
        {character = 'archer', defenderlevel = 1, defenderxp = 0}
    }
    self.placed_defenders = {}
end
function ArenaDefence:update(dt)
    self:update_game_object(dt*slow_amount)
    self.main:update(dt*slow_amount)
    self.effects:update(dt*slow_amount)
    self.ui:update(dt*slow_amount)

    if self.gold_text then self.gold_text:update(dt) end

    if input.k.pressed then
        --self:spawn_enemy(4)
        local p = table.random(self.spawn_points)
        self:spawn_n_enemies(p, 1, 8, true)
    end
    
    if input.place_defender.pressed then
        local defender_id = #self.placed_defenders+1
        self.placed_defenders[defender_id] = Defender{
          group = self.main,
          x=camera.mouse.x,
          y=camera.mouse.y,
          --defender_type = 'archer',
          defender_type = 'swordsman',
          defender_id = defender_id,
          xp = 0,
          defender_level = 1
        }
    end

end
function ArenaDefence:draw()
    self.main:draw()
    self.effects:draw()
    self.ui:draw()

    if self.gold_text then self.gold_text:draw(64, 20) end
    --show window dimensions here
    --width, height = love.graphics.getDimensions()
    --love.graphics.print('width:'..width..'height:'..height)
end
function ArenaDefence:spawn_enemy(n)
    n = n or 1
    local p = table.random(self.spawn_points)
    for i = 1, n do
      self.t:after((i-1)*0.1, function()
        local o = table.random(self.spawn_offsets)
        SpawnEffect{group = self.effects, x = p.x + o.x, y = p.y + o.y, action = function(x, y) Seeker{group = self.main, x = x, y = y, character = 'seeker'} end}
        end)
    end
end
function ArenaDefence:spawn_n_enemies(p, j, n, pass)
    if self.died then return end
    if self.arena_clear_text then return end
    if self.quitting then return end
    if self.won then return end
    if self.choosing_passives then return end
    if n and n <= 0 then return end
  
    j = j or 1
    n = n or 4
    self.last_spawn_enemy_time = love.timer.getTime()
    local check_circle = Circle(0, 0, 2)
    self.t:every(0.1, function()
      local o = self.spawn_offsets[(self.t:get_every_iteration('spawn_enemies_' .. j) % 5) + 1]
      SpawnEffect{group = self.effects, x = p.x + o.x, y = p.y + o.y, action = function(x, y)
        spawn1:play{pitch = random:float(0.8, 1.2), volume = 0.15}
        if not pass then
          check_circle:move_to(x, y)
          local objects = self.main:get_objects_in_shape(check_circle, {Seeker, EnemyCritter, Critter, Player, Sentry, Automaton, Bomb, Volcano, Saboteur, Pet, Turret})
          if #objects > 0 then self.enemy_spawns_prevented = self.enemy_spawns_prevented + 1; return end
        end
  
        if random:bool(table.reduce(level_to_elite_spawn_weights[self.level], function(memo, v) return memo + v end)) then
          local elite_type = level_to_elite_spawn_types[self.level][random:weighted_pick(unpack(level_to_elite_spawn_weights[self.level]))]
          Seeker{group = self.main, x = x, y = y, character = 'seeker', level = self.level,
            speed_booster = elite_type == 'speed_booster', exploder = elite_type == 'exploder', shooter = elite_type == 'shooter', headbutter = elite_type == 'headbutter', tank = elite_type == 'tank', spawner = elite_type == 'spawner'}
        else
          Seeker{group = self.main, x = x, y = y, character = 'seeker', level = self.level}
        end
      end}
    end, n, nil, 'spawn_enemies_' .. j)
  end
function ArenaDefence:increase_xp_of_defender(defender_id, xp_amount)
  table.foreach(self.placed_defenders,
    function(v,k,xp_amount)
      if k == defender_id then
        v:increase_xp(1)
      end
    end
  )
end