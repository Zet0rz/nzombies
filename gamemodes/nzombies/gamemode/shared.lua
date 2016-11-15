GM.Name = "nZombies"
GM.Author = "Alig96, Zet0r, Lolle"
GM.Email = "N/A"
GM.Website = "N/A"

-- Constants --

--Round Constants

ROUND_WAITING = 0
ROUND_INIT = 1
ROUND_PREP = 2
ROUND_PROG = 3
ROUND_CREATE = 4
ROUND_GO = 5

--Team Constants

TEAM_SPECS = 1
TEAM_PLAYERS = 2
TEAM_ZOMBIES = 3

--Setup Teams
team.SetUp( TEAM_SPECS, "Spectators", Color( 255, 255, 255 ) )
team.SetUp( TEAM_PLAYERS, "Players", Color( 255, 0, 0 ) )
team.SetUp( TEAM_ZOMBIES, "Zombies", Color( 0, 255, 0 ) )
