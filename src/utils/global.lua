local global = {}

global.id = 0
global.monsterId = 0

function global.gen_id()
    global.id = global.id + 1
    return global.id
end

function global.gen_monster_id()
    global.monsterId = global.monsterId + 1
    return global.monsterId
end

return global

