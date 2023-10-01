Icon = Object:extend()
Icon:implement(GameObject)
function Icon:init(args)
    self:init_game_object(args)
    self.shape = Rectangle(self.x,self.y,40,20)
    self.interact_with_mouse = true
    self.t:every(0.5, function() self.flash = not self.flash end)
    self.spring:pull(0.2, 200, 10)
end
function Icon:update(dt)
    self:update_game_object(dt)
  end
function Icon:draw()
    graphics.push(self.x, self.y, 0, self.sx*self.spring.x, self.sy*self.spring.x)

    graphics.line(self.x - 5, self.y + 21, self.x - 5, self.y + 24, (n >= 1) and fg[-5] or fg[-10], 3)
    graphics.line(self.x - 5, self.y + 28, self.x - 5, self.y + 31, (n >= 2) and fg[-5] or fg[-10], 3)
    graphics.line(self.x + 0, self.y + 21, self.x + 0, self.y + 24, (n >= 3) and fg[-5] or fg[-10], 3)
    graphics.line(self.x + 0, self.y + 28, self.x + 0, self.y + 31, (n >= 4) and fg[-5] or fg[-10], 3)
    graphics.line(self.x + 5, self.y + 21, self.x + 5, self.y + 24, (n >= 5) and fg[-5] or fg[-10], 3)
    graphics.line(self.x + 5, self.y + 28, self.x + 5, self.y + 31, (n >= 6) and fg[-5] or fg[-10], 3)

    local i, j, k, n = class_set_numbers[self.class](self.units)
    local next_n
    if self.parent:is(ShopCard) then
      next_n = n+1
      if k then
        if next_n > k then next_n = nil end
      else
        if next_n > j then next_n = nil end
      end
      if table.any(self.units, function(v) return v.character == self.character end) then next_n = nil end
    end

    graphics.rectangle(self.x, self.y, 16, 24, 4, 4, self.highlighted and fg[0] or ((n >= i) and class_colors[self.class] or bg[3]))
    _G[self.class]:draw(self.x, self.y, 0, 0.3, 0.3, 0, 0, self.highlighted and fg[-5] or ((n >= i) and _G[class_color_strings[self.class]][-5] or bg[10]))
    graphics.rectangle(self.x, self.y + 26, 16, 16, 3, 3, self.highlighted and fg[0] or bg[3])
    if i == 1 then
      if self.highlighted then
        graphics.rectangle(self.x, self.y + 26, 3, 9, nil, nil, (n >= 1) and fg[-5] or fg[-10])
      else
        graphics.rectangle(self.x, self.y + 26, 3, 9, nil, nil, (n >= 1) and class_colors[self.class] or bg[10])
      end
      if next_n then
        if next_n == 1 then
          graphics.rectangle(self.x, self.y + 26, 3, 9, nil, nil, self.flash and class_colors[self.class] or bg[10])
        end
      end

    elseif i == 2 and not k then
      if self.highlighted then
        graphics.line(self.x - 3, self.y + 20, self.x - 3, self.y + 25, (n >= 1) and fg[-5] or fg[-10], 3)
        graphics.line(self.x - 3, self.y + 27, self.x - 3, self.y + 32, (n >= 2) and fg[-5] or fg[-10], 3)
        graphics.line(self.x + 4, self.y + 20, self.x + 4, self.y + 25, (n >= 3) and fg[-5] or fg[-10], 3)
        graphics.line(self.x + 4, self.y + 27, self.x + 4, self.y + 32, (n >= 4) and fg[-5] or fg[-10], 3)
      else
        graphics.line(self.x - 3, self.y + 20, self.x - 3, self.y + 25, (n >= 1) and class_colors[self.class] or bg[10], 3)
        graphics.line(self.x - 3, self.y + 27, self.x - 3, self.y + 32, (n >= 2) and class_colors[self.class] or bg[10], 3)
        graphics.line(self.x + 4, self.y + 20, self.x + 4, self.y + 25, (n >= 3) and class_colors[self.class] or bg[10], 3)
        graphics.line(self.x + 4, self.y + 27, self.x + 4, self.y + 32, (n >= 4) and class_colors[self.class] or bg[10], 3)
      end
      if next_n then
        if next_n == 1 then
          graphics.line(self.x - 3, self.y + 20, self.x - 3, self.y + 25, self.flash and class_colors[self.class] or bg[10], 3)
        elseif next_n == 2 then
          graphics.line(self.x - 3, self.y + 27, self.x - 3, self.y + 32, self.flash and class_colors[self.class] or bg[10], 3)
        elseif next_n == 3 then
          graphics.line(self.x + 4, self.y + 20, self.x + 4, self.y + 25, self.flash and class_colors[self.class] or bg[10], 3)
        elseif next_n == 4 then
          graphics.line(self.x + 4, self.y + 27, self.x + 4, self.y + 32, self.flash and class_colors[self.class] or bg[10], 3)
        end
      end
    elseif i == 2 and k == 6 then
      if self.highlighted then
        graphics.line(self.x - 5, self.y + 21, self.x - 5, self.y + 24, (n >= 1) and fg[-5] or fg[-10], 3)
        graphics.line(self.x - 5, self.y + 28, self.x - 5, self.y + 31, (n >= 2) and fg[-5] or fg[-10], 3)
        graphics.line(self.x + 0, self.y + 21, self.x + 0, self.y + 24, (n >= 3) and fg[-5] or fg[-10], 3)
        graphics.line(self.x + 0, self.y + 28, self.x + 0, self.y + 31, (n >= 4) and fg[-5] or fg[-10], 3)
        graphics.line(self.x + 5, self.y + 21, self.x + 5, self.y + 24, (n >= 5) and fg[-5] or fg[-10], 3)
        graphics.line(self.x + 5, self.y + 28, self.x + 5, self.y + 31, (n >= 6) and fg[-5] or fg[-10], 3)
      else
        graphics.line(self.x - 5, self.y + 21, self.x - 5, self.y + 24, (n >= 1) and class_colors[self.class] or bg[10], 3)
        graphics.line(self.x - 5, self.y + 28, self.x - 5, self.y + 31, (n >= 2) and class_colors[self.class] or bg[10], 3)
        graphics.line(self.x + 0, self.y + 21, self.x + 0, self.y + 24, (n >= 3) and class_colors[self.class] or bg[10], 3)
        graphics.line(self.x + 0, self.y + 28, self.x + 0, self.y + 31, (n >= 4) and class_colors[self.class] or bg[10], 3)
        graphics.line(self.x + 5, self.y + 21, self.x + 5, self.y + 24, (n >= 5) and class_colors[self.class] or bg[10], 3)
        graphics.line(self.x + 5, self.y + 28, self.x + 5, self.y + 31, (n >= 6) and class_colors[self.class] or bg[10], 3)
      end
      if next_n then
        if next_n == 1 then
          graphics.line(self.x - 5, self.y + 21, self.x - 5, self.y + 24, self.flash and class_colors[self.class] or bg[10], 3)
        elseif next_n == 2 then
          graphics.line(self.x - 5, self.y + 28, self.x - 5, self.y + 31, self.flash and class_colors[self.class] or bg[10], 3)
        elseif next_n == 3 then
          graphics.line(self.x + 0, self.y + 21, self.x + 0, self.y + 24, self.flash and class_colors[self.class] or bg[10], 3)
        elseif next_n == 4 then
          graphics.line(self.x + 0, self.y + 28, self.x + 0, self.y + 31, self.flash and class_colors[self.class] or bg[10], 3)
        elseif next_n == 5 then
          graphics.line(self.x + 5, self.y + 21, self.x + 5, self.y + 24, self.flash and class_colors[self.class] or bg[10], 3)
        elseif next_n == 6 then
          graphics.line(self.x + 5, self.y + 28, self.x + 5, self.y + 31, self.flash and class_colors[self.class] or bg[10], 3)
        end
      end

    elseif i == 3 then
      if self.highlighted then
        graphics.line(self.x - 3, self.y + 19, self.x - 3, self.y + 22, (n >= 1) and fg[-5] or fg[-10], 3)
        graphics.line(self.x - 3, self.y + 24, self.x - 3, self.y + 27, (n >= 2) and fg[-5] or fg[-10], 3)
        graphics.line(self.x - 3, self.y + 29, self.x - 3, self.y + 32, (n >= 3) and fg[-5] or fg[-10], 3)
        graphics.line(self.x + 4, self.y + 19, self.x + 4, self.y + 22, (n >= 4) and fg[-5] or fg[-10], 3)
        graphics.line(self.x + 4, self.y + 24, self.x + 4, self.y + 27, (n >= 5) and fg[-5] or fg[-10], 3)
        graphics.line(self.x + 4, self.y + 29, self.x + 4, self.y + 32, (n >= 6) and fg[-5] or fg[-10], 3)
      else
        graphics.line(self.x - 3, self.y + 19, self.x - 3, self.y + 22, (n >= 1) and class_colors[self.class] or bg[10], 3)
        graphics.line(self.x - 3, self.y + 24, self.x - 3, self.y + 27, (n >= 2) and class_colors[self.class] or bg[10], 3)
        graphics.line(self.x - 3, self.y + 29, self.x - 3, self.y + 32, (n >= 3) and class_colors[self.class] or bg[10], 3)
        graphics.line(self.x + 4, self.y + 19, self.x + 4, self.y + 22, (n >= 4) and class_colors[self.class] or bg[10], 3)
        graphics.line(self.x + 4, self.y + 24, self.x + 4, self.y + 27, (n >= 5) and class_colors[self.class] or bg[10], 3)
        graphics.line(self.x + 4, self.y + 29, self.x + 4, self.y + 32, (n >= 6) and class_colors[self.class] or bg[10], 3)
      end
      if next_n then
        if next_n == 1 then
          graphics.line(self.x - 3, self.y + 19, self.x - 3, self.y + 22, self.flash and class_colors[self.class] or bg[10], 3)
        elseif next_n == 2 then
          graphics.line(self.x - 3, self.y + 24, self.x - 3, self.y + 27, self.flash and class_colors[self.class] or bg[10], 3)
        elseif next_n == 3 then
          graphics.line(self.x - 3, self.y + 29, self.x - 3, self.y + 32, self.flash and class_colors[self.class] or bg[10], 3)
        elseif next_n == 4 then
          graphics.line(self.x + 4, self.y + 19, self.x + 4, self.y + 22, self.flash and class_colors[self.class] or bg[10], 3)
        elseif next_n == 5 then
          graphics.line(self.x + 4, self.y + 24, self.x + 4, self.y + 27, self.flash and class_colors[self.class] or bg[10], 3)
        elseif next_n == 6 then
          graphics.line(self.x + 4, self.y + 29, self.x + 4, self.y + 32, self.flash and class_colors[self.class] or bg[10], 3)
        end
      end
    end
  graphics.pop()
end