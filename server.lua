local RSGCore        = exports['rsg-core']:GetCoreObject()
local smoking        = {}
local lastSmoke      = {}
local SMOKE_COOLDOWN = 60 * 1000

local cigStages      = {
    "cigaret10",
    "cigaret9",
    "cigaret8",
    "cigaret7",
    "cigaret6",
    "cigaret5",
    "cigaret4",
    "cigaret3",
    "cigaret2",
    "cigaret"
}


local chewStages = {
    "chewingtobacco5",
    "chewingtobacco4",
    "chewingtobacco3",
    "chewingtobacco2",
    "chewingtobacco"
}



local function notify(src, title, msg, ntype)
    TriggerClientEvent('ox_lib:notify', src, {
        title       = title,
        description = msg,
        type        = ntype
    })
end

local function canSmoke(source)
    if smoking[source] then
        TriggerClientEvent('ox_lib:notify', source,
            { title = "Hata", description = "Zaten bir şey içiyorsun!", type = "error" })
        return false
    end
    local now  = GetGameTimer()
    local last = lastSmoke[source] or 0
    if now - last < SMOKE_COOLDOWN then
        local rem = math.ceil((SMOKE_COOLDOWN - (now - last)) / 1000)
        TriggerClientEvent('ox_lib:notify', source,
            { title = "Bekle", description = rem .. " saniye sonra tekrar içebilirsin", type = "error" })
        return false
    end
    return true
end

local function startSmoking(source)
    smoking[source]   = true
    lastSmoke[source] = GetGameTimer()
end

-- Helper: önce çakmak bak, yoksa kibrit sil
local function consumeMatch(source, context)
    local hasLighter = exports['rsg-inventory']:GetItemCount(source, 'lighter') > 0
    if hasLighter then return true end
    return exports['rsg-inventory']:RemoveItem(source, Config.ItemNeed, 1, nil, context)
end

-- PIPE SMOKER
RSGCore.Functions.CreateUseableItem("pipe_smoker", function(source, item)
    if not canSmoke(source) then return end
    if not consumeMatch(source, 'pipe_smoker') then return notify(source, 'Hata', Config.Text.Pipe, 'error') end
    local ok2 = exports['rsg-inventory']:RemoveItem(source, Config.ItemNeed2, 1, nil, 'pipe_smoker')
    if not ok2 then return notify(source, 'Hata', Config.Text.Pipe, 'error') end
    TriggerClientEvent('prop:pipe_smoker', source)
    startSmoking(source)
    local rem = exports['rsg-inventory']:GetItemCount(source, Config.ItemNeed2)
    if rem > 0 then
        notify(source, 'Başarılı', rem .. " doz pipo tütünü kaldı", 'success')
    else
        notify(source, 'Başarılı', "Son dozu pipoda kullandın", 'success')
    end
end)

-- CIGAR (Puro)
RSGCore.Functions.CreateUseableItem("cigar", function(source, item)
    if not canSmoke(source) then return end
    if not consumeMatch(source, 'cigar') then return notify(source, 'Hata', Config.Text.Cigar, 'error') end

    -- puroyu sil
    if not exports['rsg-inventory']:RemoveItem(source, 'cigar', 1, nil, 'cigar') then
        return notify(source, 'Hata', Config.Text.Cigar, 'error')
    end

    TriggerClientEvent('prop:cigar', source)
    startSmoking(source)
    notify(source, 'Başarılı', 'Puro içildi', 'success')
end)

-- SINGLE-USE CIGARETTE
RSGCore.Functions.CreateUseableItem("cigarette", function(source, item)
    if not canSmoke(source) then return end
    if not consumeMatch(source, 'cigarette') then return notify(source, 'Hata', Config.Text.Allumettes, 'error') end
    if not exports['rsg-inventory']:RemoveItem(source, 'cigarette', 1, nil, 'cigarette') then
        return notify(source, 'Hata', Config.Text.Allumettes, 'error')
    end
    TriggerClientEvent('prop:cigaret', source)
    startSmoking(source)
end)


for i, itemName in ipairs(cigStages) do
    RSGCore.Functions.CreateUseableItem(itemName, function(source, item)
        if not canSmoke(source) then return end
        if not consumeMatch(source, itemName) then return notify(source, 'Hata', Config.Text.Allumettes, 'error') end

        if not exports['rsg-inventory']:RemoveItem(source, itemName, 1, nil, itemName) then
            return notify(source, 'Hata', Config.Text.Allumettes, 'error')
        end

        -- bir sonraki aşamayı ekle
        local nextItem = cigStages[i + 1]
        if nextItem then exports['rsg-inventory']:AddItem(source, nextItem, 1) end

        TriggerClientEvent('prop:cigaret', source)
        startSmoking(source)
        local remaining = #cigStages - i
        if remaining > 0 then
            notify(source, 'Başarılı', remaining .. " tane sigara kaldı", 'success')
        else
            notify(source, 'Başarılı', "Son sigaranı içtin", 'success')
        end
    end)
end


for i, itemName in ipairs(chewStages) do
    RSGCore.Functions.CreateUseableItem(itemName, function(source, item)
        if not canSmoke(source) then return end

        if not exports['rsg-inventory']:RemoveItem(source, itemName, 1, nil, itemName) then
            return notify(source, 'Hata', 'Envanterinizde çiğnenecek tütün yok.', 'error')
        end

        local nextItem = chewStages[i + 1]
        if nextItem then exports['rsg-inventory']:AddItem(source, nextItem, 1) end

        TriggerClientEvent('prop:chewingtobacco', source)
        startSmoking(source)
        local remaining = #chewStages - i
        if remaining > 0 then
            notify(source, 'Başarılı', remaining .. " doz çiğneme tütünü kaldı", 'success')
        else
            notify(source, 'Başarılı', "Son dozu çiğnedin", 'success')
        end
    end)
end


RegisterNetEvent('smoke:stop')
AddEventHandler('smoke:stop', function()
    smoking[source] = false
end)
