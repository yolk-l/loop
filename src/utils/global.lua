local global = {}

global.id = 0

function global.gen_id()
    global.id = global.id + 1
    return global.id
end

return global

