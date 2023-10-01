ShopScreen = Object:extend()
ShopScreen:implement(State)
ShopScreen:implement(GameObject)
function ShopScreen:init(name)
    self:init_state(name)
    self:init_game_object()
end

function ShopScreen:on_enter(args)
    camera.x, camera.y = gw/2, gh/2
    input:set_mouse_visible(true)
    self.main = Group()
end

function ShopScreen:update(dt)
end

function ShopScreen:draw()
end