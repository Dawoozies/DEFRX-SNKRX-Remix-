Button = Object:extend()
Button:implement(GameObject)
function Button:init(args)
  self:init_game_object(args)
  self.shape = Rectangle(self.x, self.y, args.w or (pixul_font:get_text_width(self.button_text) + 8), pixul_font.h + 4)
  self.interact_with_mouse = true
  self.text = Text({{text = '[' .. self.fg_color .. ']' .. self.button_text, font = pixul_font, alignment = 'center'}}, global_text_tags)
end


function Button:update(dt)
  self:update_game_object(dt)
  if main.current.in_credits and not self.credits_button then return end

  if self.hold_button then
    if self.selected and input.m1.pressed then
      self.press_time = love.timer.getTime()
      self.spring:pull(0.2, 200, 10)
    end
    if self.press_time then
      if input.m1.down and love.timer.getTime() - self.press_time > self.hold_button then
        self:action()
        self.press_time = nil
        self.spring:pull(0.1, 200, 10)
      end
    end
    if input.m1.released then
      self.press_time = nil
      self.spring:pull(0.1, 200, 10)
    end
  else
    if self.selected and input.m1.pressed then
      if self.action then
        self:action()
      end
    end
    if self.selected and input.m2.pressed then
      if self.action_2 then
        self:action_2()
      end
    end
  end
end


function Button:draw()
  graphics.push(self.x, self.y, 0, self.spring.x, self.spring.y)
    if self.hold_button and self.press_time then
      graphics.set_line_width(5)
      graphics.set_color(fg[-5])
      graphics.arc('open', self.x, self.y, 0.6*self.shape.w, 0, math.remap(love.timer.getTime() - self.press_time, 0, self.hold_button, 0, 1)*2*math.pi)
      graphics.set_line_width(1)
    end
    graphics.rectangle(self.x, self.y, self.shape.w, self.shape.h, 4, 4, self.selected and fg[0] or _G[self.bg_color][0])
    self.text:draw(self.x, self.y + 1, 0, 1, 1)
  graphics.pop()
end


function Button:on_mouse_enter()
  if main.current.in_credits and not self.credits_button then return end
  ui_hover1:play{pitch = random:float(1.3, 1.5), volume = 0.5}
  pop2:play{pitch = random:float(0.95, 1.05), volume = 0.5}
  self.selected = true
  self.text:set_text{{text = '[fgm5]' .. self.button_text, font = pixul_font, alignment = 'center'}}
  self.spring:pull(0.2, 200, 10)
  if self.mouse_enter then self:mouse_enter() end
end


function Button:on_mouse_exit()
  if main.current.in_credits and not self.credits_button then return end
  self.text:set_text{{text = '[' .. self.fg_color .. ']' .. self.button_text, font = pixul_font, alignment = 'center'}}
  self.selected = false
  if self.mouse_exit then self:mouse_exit() end
end


function Button:set_text(text)
  self.button_text = text
  self.text:set_text{{text = '[' .. self.fg_color .. ']' .. self.button_text, font = pixul_font, alignment = 'center'}}
  self.spring:pull(0.2, 200, 10)
end
