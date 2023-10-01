ShopCard = Object:extend()
ShopCard:implement(GameObject)
function ShopCard:init(args)
  self:init_game_object(args)
  self.shape = Rectangle(self.x, self.y, self.w, self.h)
  self.interact_with_mouse = true
  self.icon = Icon{group = main.current.effects, x = self.x, y = self.y - 26, defender_type = 'swordsman', parent = self}
  --[[
  self.class_icons = {}
  for i, class in ipairs(character_classes[self.unit]) do
    local x = self.x
    if #character_classes[self.unit] == 2 then x = self.x - 10
    elseif #character_classes[self.unit] == 3 then x = self.x - 20 end
    table.insert(self.class_icons, Icon{group = main.current.effects, x = x + (i-1)*20, y = self.y + 6, class = class, character = self.unit, units = self.parent.units, parent = self})
  end
  self.cost = character_tiers[self.unit]
  self.spring:pull(0.2, 200, 10)
  ]]
  --self:refresh()
end

function ShopCard:refresh()
  self.owned = table.any(self.parent.units, function(v) return v.character == self.unit end)
  if self.owned then
    self.owned_n = 0
    for _, unit in ipairs(self.parent.units) do
      if unit.character == self.unit then
        self.owned_n = self.owned_n + ((unit.level == 1 and 1) or (unit.level == 2 and 3) or (unit.level == 3 and 9))
        if unit.reserve then
          self.owned_n = self.owned_n + (unit.reserve[2] or 0)*3
          self.owned_n = self.owned_n + (unit.reserve[1] or 0)
        end
      end
    end
  end
end

function ShopCard:update(dt)
  self:update_game_object(dt)
  if (self.selected and input.m1.pressed) or input[tostring(self.i)].pressed then
    if self.parent:buy(self.unit, self.i) then
      ui_switch1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
      _G[random:table{'coins1', 'coins2', 'coins3'}]:play{pitch = random:float(0.95, 1.05), volume = 0.5}
      self:die()
      self.parent.cards[self.i] = nil
      self.parent:refresh_cards()
      self.parent.party_text:set_text({{text = '[wavy_mid, fg]party ' .. tostring(#self.parent.units) .. '/' .. tostring(max_units), font = pixul_font, alignment = 'center'}})
      locked_state = {locked = self.parent.locked, cards = {self.parent.cards[1] and self.parent.cards[1].unit, self.parent.cards[2] and self.parent.cards[2].unit, self.parent.cards[3] and self.parent.cards[3].unit}} 
      system.save_run(self.parent.level, self.parent.loop, gold, self.parent.units, self.parent.passives, self.parent.shop_level, self.parent.shop_xp, run_passive_pool, locked_state)
    else
      error1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
      self.spring:pull(0.2, 200, 10)
      self.character_icon.spring:pull(0.2, 200, 10)
      for _, ci in ipairs(self.class_icons) do ci.spring:pull(0.2, 200, 10) end
    end
  end
end


function ShopCard:select()
  self.selected = true
  self.spring:pull(0.2, 200, 10)
  self.t:every_immediate(1.4, function()
    if self.selected then
      self.t:tween(0.7, self, {sx = 0.97, sy = 0.97, plus_r = -math.pi/32}, math.linear, function()
        self.t:tween(0.7, self, {sx = 1.03, sy = 1.03, plus_r = math.pi/32}, math.linear, nil, 'pulse_1')
      end, 'pulse_2')
    end
  end, nil, nil, 'pulse')
end


function ShopCard:unselect()
  self.selected = false
  self.t:cancel'pulse'
  self.t:cancel'pulse_1'
  self.t:cancel'pulse_2'
  self.t:tween(0.1, self, {sx = 1, sy = 1, plus_r = 0}, math.linear, function() self.sx, self.sy, self.plus_r = 1, 1, 0 end, 'pulse')
end


function ShopCard:draw()
    print('we got here')
    graphics.push(self.x, self.y, 0, self.sx*self.spring.x, self.sy*self.spring.x)
    graphics.rectangle(self.x, self.y, self.w, self.h, 6, 6, bg[-1])
    graphics.rectangle(self.x+90, self.y, self.w, self.h, 6, 6, bg[-1])
    --[[
    if self.selected then
      graphics.rectangle(self.x, self.y, self.w, self.h, 6, 6, bg[-1])
    end
    if self.owned then
      local x, y = self.x + self.w/5, self.y - self.h/2 + 12
      if self.owned_n == 1 then
        graphics.rectangle(x, y, 2, 2, nil, nil, character_colors[self.unit])
      elseif self.owned_n == 2 then
        graphics.rectangle(x, y, 2, 2, nil, nil, character_colors[self.unit])
        graphics.rectangle(x + 4, y, 2, 2, nil, nil, character_colors[self.unit])
      elseif self.owned_n == 3 then
        graphics.rectangle(x, y, 4, 4, nil, nil, character_colors[self.unit])
      elseif self.owned_n == 4 then
        graphics.rectangle(x, y, 4, 4, nil, nil, character_colors[self.unit])
        graphics.rectangle(x + 5, y, 2, 2, nil, nil, character_colors[self.unit])
      elseif self.owned_n == 5 then
        graphics.rectangle(x, y, 4, 4, nil, nil, character_colors[self.unit])
        graphics.rectangle(x + 5, y, 2, 2, nil, nil, character_colors[self.unit])
        graphics.rectangle(x + 9, y, 2, 2, nil, nil, character_colors[self.unit])
      elseif self.owned_n == 6 then
        graphics.rectangle(x, y, 4, 4, nil, nil, character_colors[self.unit])
        graphics.rectangle(x + 6, y, 4, 4, nil, nil, character_colors[self.unit])
      elseif self.owned_n == 7 then
        graphics.rectangle(x, y, 4, 4, nil, nil, character_colors[self.unit])
        graphics.rectangle(x + 6, y, 4, 4, nil, nil, character_colors[self.unit])
        graphics.rectangle(x + 11, y, 2, 2, nil, nil, character_colors[self.unit])
      elseif self.owned_n == 8 then
        graphics.rectangle(x, y, 4, 4, nil, nil, character_colors[self.unit])
        graphics.rectangle(x + 6, y, 4, 4, nil, nil, character_colors[self.unit])
        graphics.rectangle(x + 11, y, 2, 2, nil, nil, character_colors[self.unit])
        graphics.rectangle(x + 15, y, 2, 2, nil, nil, character_colors[self.unit])
      end
    end
    ]]
    graphics.pop()
end


function ShopCard:on_mouse_enter()
  ui_hover1:play{pitch = random:float(1.3, 1.5), volume = 0.5}
  pop2:play{pitch = random:float(0.95, 1.05), volume = 0.5}
  self.selected = true
  self.spring:pull(0.1)
  self.character_icon.spring:pull(0.1, 200, 10)
  for _, class_icon in ipairs(self.class_icons) do
    class_icon.selected = true
    class_icon.spring:pull(0.1, 200, 10)
  end
end


function ShopCard:on_mouse_exit()
  self.selected = false
  for _, class_icon in ipairs(self.class_icons) do class_icon.selected = false end
end


function ShopCard:die(dont_spawn_effect)
  self.dead = true
  self.character_icon:die(dont_spawn_effect)
  for _, class_icon in ipairs(self.class_icons) do class_icon:die(dont_spawn_effect) end
  if self.info_text then
    self.info_text:deactivate()
    self.info_text.dead = true
    self.info_text = nil
  end
end