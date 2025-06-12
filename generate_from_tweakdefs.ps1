# Convert our bespoke tweakdef to a player-friendly version
# and then minify it and get its URL-safe base64 encoding

#-- Config ---------------------------------------------------------------------

$base_dir = 'D:\vscode\proj\beyond-all-reason\small_teams'

$tweakdef = 'tweakdefs.lua'
$encoding = 'tweakdefs_encoding.txt'
$minified = 'tweakdefs_minified.lua'
$min_code = 'tweakdefs_minified_encoding.txt'
$template = 'template.md'
$git_gist = 'gist.md'

$substitutions = @{
    '(?sm)\A--[\s\S]+?(?=^local)'                                          = "---small_teams_tweak`n"
    'local units = \{\}\r?\n'                                              = ''
    '(?sm)\r?\nlocal function (deep|diff|dumb_equal)[\s\S\r\n]+?^end\r?\n' = ''
    '(?sm)^\tif unitDef and not units[\s\S\r\n]+?\tend\r?\n'               = ''
    '(?sm)[- \r\n]+Convert to tweakunits.+\r?\n\z'                         = ''
}

$inserts = @{
    tweakdefs  = '<!-- tweakdefs_readable -->'
    tweakunits = '<!-- tweakunits_readable -->'
    encoding   = '<!-- tweakdefs_encoding -->'
}

#-- Code -----------------------------------------------------------------------

$tweakdef_content = Get-Content -Path $base_dir\$tweakdef -Raw | Out-String

# Run in BAR to get tweakunits from infolog (todo: write it to file directly).
$encoding_content = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes([string] $tweakdef_content))
$encoding_content = $encoding_content.TrimEnd('=') -replace '\+', '-' -replace '/', '_'

Set-Content -Path $base_dir\$encoding -Value $encoding_content -NoNewline -Force -EA 0

# User-facing tweakdefs have unnecessary utility code removed.
$substitutions.GetEnumerator() | ForEach-Object {
    $tweakdef_content = $tweakdef_content -replace $_.Key, $_.Value
}

$friendly_content = $tweakdef_content

# The tweakdefs code is minified before encoding to be as small as possible.
if (-not (Get-Command luamin -EA 0)) {
    npm install -g luamin
}
$tweakdef_content = luamin -c $tweakdef_content

$minified_content = $tweakdef_content
Set-Content -Path $base_dir\$minified -Value $minified_content -NoNewline -Force -EA 0

$tweakdef_content = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes([string] $tweakdef_content))
$tweakdef_content = $tweakdef_content.TrimEnd('=') -replace '\+', '-' -replace '/', '_'

$min_code_content = $tweakdef_content

Set-Content -Path $base_dir\$min_code -Value $min_code_content -NoNewline -Force -EA 0

# The gist contains portions of all the previous in a markdown document.
$markdown = Get-Content -Path $base_dir\$template -Raw | Out-String

$markdown = [regex]::Replace($markdown, $inserts.tweakdefs, ('```lua', $friendly_content, '```' -join "`n"))
$markdown = [regex]::Replace($markdown, $inserts.encoding, ('>', $min_code_content -join ' '))

Set-Content -Path $base_dir\$git_gist -Value $markdown -NoNewline -Force -EA 0
