function GM:ShowHelp( ply )
    if IsValid( ply ) then
        ply:ConCommand("nz_settings")
    end
end
