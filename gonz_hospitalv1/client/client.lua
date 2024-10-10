ESX = exports["es_extended"]:getSharedObject()


local GonzHospital = {}


Citizen.CreateThread(function()
    local lmodel = GetHashKey('s_m_m_doctor_01')
    RequestModel(lmodel)

    while not HasModelLoaded(lmodel) do
        Wait(10)
    end

    for _, hospital in ipairs(Config.Hospitals) do
        local npcCoords = hospital.NPC.coords
        local npcHeading = hospital.NPC.heading

        local lPed = CreatePed(4, lmodel, npcCoords, npcHeading, false, false)
        SetEntityInvincible(lPed, true)
        FreezeEntityPosition(lPed, true)
        SetBlockingOfNonTemporaryEvents(lPed, true)
        SetAmbientVoiceName(lPed, "s_m_y_dealer_01")
        TaskStartScenarioInPlace(lPed, "WORLD_HUMAN_CLIPBOARD", 0, true)
    end

    SetModelAsNoLongerNeeded(lmodel)
end)


for _, hospital in ipairs(Config.Hospitals) do
    exports.ox_target:addSphereZone({
        coords = hospital.NPC.coords,
        radius = 1,
        options = {
            {
                name = 'npctarget',
                distance = 4.0,
                icon = 'fa-solid fa-user-doctor',
                label = 'Bliv tilset af doktoren',
                onSelect = function()
                    GonzHospital.StartGettingChecked(hospital)
                end
            }
        }
    })
end

GonzHospital.StartGettingChecked = function(hospital)
    lib.progressBar({
        duration = 7000,
        label = 'Skriver dig ind på ventelisten...',
        useWhileDead = false,
        canCancel = false,
        disable = {
            car = true,
            move = true,
        },
        anim = {
            dict = 'amb@world_human_clipboard@male@base',
            clip = 'base'
        },
        prop = {
            model = `p_amb_clipboard_01`,
            pos = vec3(0.03, 0.03, 0.02),
            rot = vec3(0.5, 0.0, -1.0)
        },
    })
    GonzHospital.TeleInBed(hospital)
end


GonzHospital.TeleInBed = function(hospital)
    local playerPed = PlayerPedId()
    local bed = hospital.Beds[math.random(1, #hospital.Beds)]

    isHealing = true
    DoScreenFadeOut(500)
    Citizen.Wait(3500)
    SetEntityCoords(playerPed, bed.coords.x, bed.coords.y, bed.coords.z + 0.3)
    SetEntityHeading(playerPed, bed.heading + 180.0)
    ExecuteCommand('e passout3')
    DoScreenFadeIn(1000)

    lib.progressBar({
        duration = 30000,
        label = 'Du bliver tilset af lægen...',
        useWhileDead = false,
        canCancel = false,
        disable = {
            car = true,
            move = true,
        },
    })

    ClearPedTasksImmediately(playerPed)
    SetEntityHealth(playerPed, 150)
    TriggerEvent('esx_ambulancejob:revive')
end
