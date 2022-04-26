$dir = Get-Location
$scDir = Join-Path -Path $dir -ChildPath 'sound'
$nodeDir = Join-Path -Path $dir -ChildPath 'Leap-OSC'
$nodeModulesDir = Join-Path -Path $nodeDir -ChildPath 'node_modules'

if (-Not (Test-Path -Path $nodeModulesDir)) {
    Write-Host 'Installing node modules before first run...'
    Set-Location $nodeDir
    npm install --save
    Set-Location $dir
}

# Launch node relay
Start-Process -FilePath "node" -WorkingDirectory $nodeDir -ArgumentList "index.js"

# Launch SuperCollider
#Start-Process -FilePath "sclang" -WorkingDirectory $scDir -ArgumentList "init.scd"
Start-Process -FilePath (Join-Path -Path $scDir -ChildPath "init.scd")

Write-Host "Done :-)"