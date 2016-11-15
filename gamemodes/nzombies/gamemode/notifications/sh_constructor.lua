-- Main Tables
nzNotifications = nzNotifications or AddNZModule("Notifications")
nzNotifications.Data = {}

-- Variables
if CLIENT then
	nzNotifications.Data.SoundQueue = {}
	nzNotifications.Data.NextSound = CurTime()
end
