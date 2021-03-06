$luarocksZipName = "luarocks-2.4.4-win32"
$luarocksInstallerDir = (Join-Path "$env:TEMP" "$luarocksZipName")
$luarocksInstallDir = (Join-Path "$env:ChocolateyPackageFolder" "$luarocksZipName")

Install-ChocolateyZipPackage -PackageName 'luarocks' `
 -Url "https://luarocks.github.io/luarocks/releases/$luarocksZipName.zip" `
 -Checksum '763d2fbe301b5f941dd5ea4aea485fb35e75cbbdceca8cc2f18726b75f9895c1' -ChecksumType 'sha256' `
 -UnzipLocation "$luarocksInstallerDir"

# Run the installer script.
# https://github.com/luarocks/luarocks/wiki/Installation-instructions-for-Windows
Push-Location -Path "$(Join-Path "$luarocksInstallerDir" "$luarocksZipName")"
& .\install.bat /NOADMIN /SELFCONTAINED /L /Q /P "$luarocksInstallDir"
Pop-Location

Remove-Item "$luarocksInstallerDir" -Force -Recurse

# Do not create shim for LuaRocks bundled tools.
$files = get-childitem (Join-Path "$luarocksInstallDir" "tools") -include *.exe -recurse
foreach ($file in $files) {
  #generate an ignore file
  New-Item "$file.ignore" -type file -force | Out-Null
}

# Install the bat files.
$files = get-childitem (Join-Path "$luarocksInstallDir" "*.bat")
foreach ($file in $files) {
  Install-BinFile `
    -Name ([System.IO.Path]::GetFileNameWithoutExtension($file)) `
    -Path "$file"
}
