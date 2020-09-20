$bbdInjectorFolderPath=".\BetterDiscordApp-injector"
$bbdInjectorZipPath="$($bbdInjectorFolderPath).zip"
$bbdInjectorFolderInnerName="BetterDiscordApp-injector"
$discordAppData="$($env:LOCALAPPDATA)\Discord"

#Delete old extracted folder if exists and re-extract
If (Test-Path $bbdInjectorFolderPath){
    Remove-Item -Recurse $bbdInjectorFolderPath
}
Expand-Archive -Path $bbdInjectorZipPath

#Get highest semver'ed app folder
#adapted from https://stackoverflow.com/a/25027123/14284467
Get-ChildItem -Path $discordAppData -Filter "app-*" |
    Sort-Object { 
        [Version] $(if ($_.BaseName -match "(\d+_){3}\d+") { 
                        $matches[0] -replace "_", "."
                    } 
                    else { 
                        "0.0.0.0"
                    })  
    } | select -last 1 -ExpandProperty Name -OutVariable latestAppDir
$vanillaAppFolderPath="$($discordAppData)\$($latestAppDir)\resources\app"

#Delete original app folder
If (Test-Path $vanillaAppFolderPath){
    Remove-Item -Recurse $vanillaAppFolderPath
}

#Inject
Copy-Item -Path "$($bbdInjectorFolderPath)\$($bbdInjectorFolderInnerName)" -Destination $vanillaAppFolderPath -Recurse

#Start Discord
Invoke-Expression "$($discordAppData)\Update.exe --processStart Discord.exe"
