param(
    [Parameter(Mandatory = $true)]
    [string]$Slug,

    [Parameter(Mandatory = $true)]
    [string]$Name,

    [Parameter(Mandatory = $true)]
    [string]$SourceDir,

    [Parameter(Mandatory = $true)]
    [string]$Base,

    [string]$Idle = "",
    [string]$Walk = "",
    [string]$Run = "",
    [string]$Punch = "",
    [string]$Kick = "",
    [string]$Jump = "",
    [hashtable]$ExtraAnimations = @{},
    [hashtable]$TextureMap = @{},
    [string]$SourceUrl = "",
    [string]$LicenseNote = "Check the original store license before committing.",
    [string]$AnimationName = "Unreal Take"
)

$ErrorActionPreference = "Stop"

function Get-RepoRoot {
    $current = (Get-Location).Path
    while ($current -and -not (Test-Path (Join-Path $current "project.godot"))) {
        $parent = Split-Path -Parent $current
        if ($parent -eq $current) {
            break
        }
        $current = $parent
    }
    if (-not (Test-Path (Join-Path $current "project.godot"))) {
        throw "Run this script from inside the Godot project."
    }
    return $current
}

function Resolve-SourcePath([string]$root, [string]$relativePath) {
    if ([string]::IsNullOrWhiteSpace($relativePath)) {
        return ""
    }
    if ([System.IO.Path]::IsPathRooted($relativePath)) {
        return (Resolve-Path -LiteralPath $relativePath).Path
    }
    return (Resolve-Path -LiteralPath (Join-Path $root $relativePath)).Path
}

function Copy-Or-Convert-Model([string]$inputPath, [string]$outputNoExt) {
    $extension = [System.IO.Path]::GetExtension($inputPath).ToLowerInvariant()
    if ($extension -eq ".glb" -or $extension -eq ".gltf") {
        $destination = "$outputNoExt$extension"
        Copy-Item -LiteralPath $inputPath -Destination $destination -Force
        return $destination
    }
    if ($extension -ne ".fbx") {
        throw "Unsupported model extension: $extension ($inputPath)"
    }

    $converter = Join-Path $script:RepoRoot "tools\fbx2gltf\FBX2glTF-windows-x86_64\FBX2glTF-windows-x86_64.exe"
    if (-not (Test-Path $converter)) {
        throw "Missing FBX2glTF converter at tools\fbx2gltf. Convert this FBX to GLB manually or restore the local converter."
    }

    $converterOutput = & $converter -b --pbr-metallic-roughness -i $inputPath -o $outputNoExt 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "FBX2glTF failed for $inputPath`n$($converterOutput -join "`n")"
    }
    return "$outputNoExt.glb"
}

function To-ResPath([string]$absolutePath) {
    $rootPath = (Resolve-Path -LiteralPath $script:RepoRoot).Path
    if (-not $rootPath.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
        $rootPath += [System.IO.Path]::DirectorySeparatorChar
    }
    $rootUri = [Uri]::new($rootPath)
    $fileUri = [Uri]::new((Resolve-Path -LiteralPath $absolutePath).Path)
    $relative = [Uri]::UnescapeDataString($rootUri.MakeRelativeUri($fileUri).ToString())
    return "res://" + ($relative -replace "\\", "/")
}

$script:RepoRoot = Get-RepoRoot
$sourceRoot = Resolve-Path -LiteralPath $SourceDir

$characterRoot = Join-Path $script:RepoRoot "assets\characters\$Slug"
$animationRoot = Join-Path $characterRoot "animations"
$textureRoot = Join-Path $characterRoot "textures"
$generatedRoot = Join-Path $script:RepoRoot "external_packs\generated"

New-Item -ItemType Directory -Force $characterRoot, $animationRoot, $textureRoot, $generatedRoot | Out-Null

$basePath = Resolve-SourcePath $sourceRoot $Base
$baseOutput = Copy-Or-Convert-Model $basePath (Join-Path $characterRoot $Slug)

$animationInputs = @{
    idle = $Idle
    walk = $Walk
    run = $Run
    punch = $Punch
    kick = $Kick
    jump = $Jump
}
foreach ($slot in $ExtraAnimations.Keys) {
    $animationInputs[[string]$slot] = [string]$ExtraAnimations[$slot]
}
$animationOutputs = @{}
foreach ($slot in $animationInputs.Keys) {
    $input = $animationInputs[$slot]
    if ([string]::IsNullOrWhiteSpace($input)) {
        continue
    }
    $inputPath = Resolve-SourcePath $sourceRoot $input
    $fileName = "$Slug`_$slot"
    $animationOutputs[$slot] = Copy-Or-Convert-Model $inputPath (Join-Path $animationRoot $fileName)
}

$textureOutputs = @{}
foreach ($slot in $TextureMap.Keys) {
    $inputPath = Resolve-SourcePath $sourceRoot ([string]$TextureMap[$slot])
    $extension = [System.IO.Path]::GetExtension($inputPath).ToLowerInvariant()
    if ($extension -notin @(".png", ".jpg", ".jpeg", ".tga", ".webp")) {
        throw "Unsupported texture extension: $extension ($inputPath)"
    }
    $destination = Join-Path $textureRoot ("$Slug`_$slot$extension")
    Copy-Item -LiteralPath $inputPath -Destination $destination -Force
    $textureOutputs[$slot] = $destination
}

$readme = @"
# $Name

Source: $SourceUrl

License: $LicenseNote

Imported with ``scripts/tools/prepare_external_character_pack.ps1``.

All runtime references should use ``res://assets/characters/$Slug/...``.
"@
Set-Content -LiteralPath (Join-Path $characterRoot "README.md") -Value $readme -Encoding UTF8

$snippetPath = Join-Path $generatedRoot "$Slug`_roster_snippet.gd"
$orderedAnimationSlots = @("idle", "walk", "punch", "kick", "jump", "run")
foreach ($slot in ($animationOutputs.Keys | Sort-Object)) {
    if ($slot -notin $orderedAnimationSlots) {
        $orderedAnimationSlots += $slot
    }
}

$animationLines = foreach ($slot in $orderedAnimationSlots) {
    if ($animationOutputs.ContainsKey($slot)) {
        "`t`t`t`t`"$slot`": `"$((To-ResPath $animationOutputs[$slot]))`","
    }
}
$animationNameLines = foreach ($slot in $orderedAnimationSlots) {
    if ($animationOutputs.ContainsKey($slot)) {
        "`t`t`t`"$slot`": `"$AnimationName`","
    }
}
$textureLines = foreach ($slot in $textureOutputs.Keys) {
    "`t`t`t`t`"$slot`": `"$((To-ResPath $textureOutputs[$slot]))`","
}

$snippet = @"
{
	"name": "$Name",
	"style": "External imported fighter",
	"color": Color(0.9, 0.78, 1.0),
	"move_folder": "res://data/moves/prototype",
	"visual": {
		"base": "$((To-ResPath $baseOutput))",
		"animations": {
$($animationLines -join "`n")
		},
		"animation_names": {
$($animationNameLines -join "`n")
		},
		"textures": {
$($textureLines -join "`n")
		},
		"face_right_degrees": 40.0,
		"face_left_degrees": 320.0,
	},
},
"@
Set-Content -LiteralPath $snippetPath -Value $snippet -Encoding UTF8

Write-Host "Imported runtime files to: assets/characters/$Slug"
Write-Host "Roster snippet: external_packs/generated/$Slug`_roster_snippet.gd"
