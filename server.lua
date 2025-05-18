
local cigStages = {
    "cigaret10", -- 10 sigara aşaması
    "cigaret9",
    "cigaret8",
    "cigaret7",
    "cigaret6",
    "cigaret5",
    "cigaret4",
    "cigaret3",
    "cigaret2",
    "cigaret"    -- 1 sigara aşaması
}

-- server.lua
local RSGCore = exports['rsg-core']:GetCoreObject()

-- Basit notify
local function notify(src, title, msg, ntype)
    TriggerClientEvent('ox_lib:notify', src, {
        title       = title,
        description = msg,
        type        = ntype
    })
end

local function consumeMatch(source, context)
    local hasLighter = exports['rsg-inventory']:GetItemCount(source, 'lighter') > 0
    if hasLighter then
        return true
    end
    return exports['rsg-inventory']:RemoveItem(source, Config.ItemNeed, 1, nil, context)
end

-- PIPE SMOKER
RSGCore.Functions.CreateUseableItem("pipe_smoker", function(source, item)
    if not consumeMatch(source, 'pipe_smoker') then
        return notify(source, 'Hata', Config.Text.Pipe, 'error')
    end
    local ok2 = exports['rsg-inventory']:RemoveItem(source, Config.ItemNeed2, 1, nil, 'pipe_smoker')
    if not ok2 then
        return notify(source, 'Hata', Config.Text.Pipe, 'error')
    end
    TriggerClientEvent('prop:pipe_smoker', source)
end)

-- CIGAR (Puro)
RSGCore.Functions.CreateUseableItem("cigar", function(source, item)
    -- 1) Elde çakmak yoksa kibrit harca
    if not consumeMatch(source, 'cigar') then
        return notify(source, 'Hata', Config.Text.Cigar, 'error')
    end

    -- 2) Kullanımdan önce kaç doz tütün var bak
    local before = exports['rsg-inventory']:GetItemCount(source, Config.ItemNeed2)
    if before <= 0 then
        return notify(source, 'Hata', 'Puronun tütünü envanterde yok.', 'error')
    end

    -- 3) Bir doz tütünü eksilt
    exports['rsg-inventory']:RemoveItem(source, Config.ItemNeed2, 1, nil, 'cigar')

    -- 4) Animasyonu tetikle
    TriggerClientEvent('prop:cigar', source)

    -- 5) Kalan dozu bildir
    local after = exports['rsg-inventory']:GetItemCount(source, Config.ItemNeed2)
    if after > 0 then
        notify(source, 'Başarılı', after .. " doz tütün kaldı", 'success')
    else
        notify(source, 'Başarılı', "Son doz tütünü kullandın", 'success')
    end
end)

-- SINGLE-USE CIGARETTE
RSGCore.Functions.CreateUseableItem("cigarette", function(source, item)
    if not consumeMatch(source, 'cigarette') then
        return notify(source, 'Hata', Config.Text.Allumettes, 'error')
    end
    local ok2 = exports['rsg-inventory']:RemoveItem(source, 'cigarette', 1, nil, 'cigarette')
    if not ok2 then
        return notify(source, 'Hata', Config.Text.Allumettes, 'error')
    end
    TriggerClientEvent('prop:cigaret', source)
end)



for i, itemName in ipairs(cigStages) do
    RSGCore.Functions.CreateUseableItem(itemName, function(source, item)
        -- İlk önce çakmak varsa kibrit silme, yoksa kibrit sil
        if not consumeMatch(source, itemName) then
            return notify(source, 'Hata', Config.Text.Allumettes, 'error')
        end

        -- Mevcut aşama sigarayı envanterden çıkar
        local ok = exports['rsg-inventory']:RemoveItem(source, itemName, 1, nil, itemName)
        if not ok then
            return notify(source, 'Hata', Config.Text.Allumettes, 'error')
        end

        -- Bir sonraki (daha az kalan) aşamayı ekle
        local nextItem = cigStages[i + 1]
        if nextItem then
            exports['rsg-inventory']:AddItem(source, nextItem, 1)
        end

        -- Animasyonu tetikle
        TriggerClientEvent('prop:cigaret', source)

        -- Kalan sayıyı bildir
        local remaining = #cigStages - i
        if remaining > 0 then
            notify(source, 'Başarılı', remaining .. " tane sigara kaldı", 'success')
        else
            notify(source, 'Başarılı', "Son sigaranı içtin", 'success')
        end
    end)
end

-- CHEWING TOBACCO (5 → 1 → Bitti)
local chewStages = {
    "chewingtobacco5",  -- 5 doz
    "chewingtobacco4",  -- 4 doz
    "chewingtobacco3",  -- 3 doz
    "chewingtobacco2",  -- 2 doz
    "chewingtobacco"    -- 1 doz
}

for i, itemName in ipairs(chewStages) do
    RSGCore.Functions.CreateUseableItem(itemName, function(source, item)
        -- Mevcut dozu sil
        local ok = exports['rsg-inventory']:RemoveItem(source, itemName, 1, nil, itemName)
        if not ok then
            return notify(source, 'Hata', 'Envanterinizde çiğnenecek tütün yok.', 'error')
        end

        -- Bir alt doz aşamasını ekle (i == #chewStages ise atlanır)
        local nextItem = chewStages[i + 1]
        if nextItem then
            exports['rsg-inventory']:AddItem(source, nextItem, 1)
        end

        -- Animasyonu tetikle
        TriggerClientEvent('prop:chewingtobacco', source)

        -- Kalan doz sayısını bildir
        local remaining = #chewStages - i
        if remaining > 0 then
            notify(source, 'Başarılı', remaining .. " doz çiğneme tütünü kaldı", 'success')
        else
            notify(source, 'Başarılı', "Son dozu çiğnedin", 'success')
        end
    end)
end
