if not lib then
    return
end

local Items = require 'modules.items.shared' --[[@as table<string, OxClientItem>]]

local function sendDisplayMetadata(data)
    SendNUIMessage({
        action = 'displayMetadata',
        data = data
    })
end

--- use array of single key value pairs to dictate order
---@param metadata string | table<string, string> | table<string, string>[]
---@param value? string
local function displayMetadata(metadata, value)
    local data = {}

    if type(metadata) == 'string' then
        if not value then
            return
        end

        data = {{
            metadata = metadata,
            value = value
        }}
    elseif table.type(metadata) == 'array' then
        for i = 1, #metadata do
            for k, v in pairs(metadata[i]) do
                data[i] = {
                    metadata = k,
                    value = v
                }
            end
        end
    else
        for k, v in pairs(metadata) do
            data[#data + 1] = {
                metadata = k,
                value = v
            }
        end
    end

    if client.uiLoaded then
        return sendDisplayMetadata(data)
    end

    CreateThread(function()
        repeat
            Wait(100)
        until client.uiLoaded

        sendDisplayMetadata(data)
    end)
end

exports('displayMetadata', displayMetadata)

---@param _ table?
---@param name string?
---@return table?
local function getItem(_, name)
    if not name then
        return Items
    end

    if type(name) ~= 'string' then
        return
    end

    name = name:lower()

    if name:sub(0, 7) == 'weapon_' then
        name = name:upper()
    end

    return Items[name]
end

setmetatable(Items --[[@as table]] , {
    __call = getItem
})

---@cast Items +fun(itemName: string): OxClientItem
---@cast Items +fun(): table<string, OxClientItem>

local function Item(name, cb)
    local item = Items[name]
    if item then

        if not item.client.export and not item.client.event then
            item.effect = cb
        end
    end
end

local ox_inventory = exports[shared.resource]
-----------------------------------------------------------------------------------------------
-- Clientside item use functions
-----------------------------------------------------------------------------------------------
Item('creditcard', function(data, slot)
    ox_inventory:useItem(data, function(data)
        if slot then
            local propList = {"prop_atm_01", "prop_atm_02", "prop_atm_03", "prop_fleeca_atm"}
            TriggerEvent('ws_bank:useBank', slot.metadata.id)
        end
    end)
end)
-----------------------------------------------------------------------------------------------

exports('Items', function(item)
    return getItem(nil, item)
end)
exports('ItemList', function(item)
    return getItem(nil, item)
end)

return Items
