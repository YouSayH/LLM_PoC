# Show-Tree.ps1


param(
    [string]$Path = '.',
    [string[]]$Exclude = @(
        'venv',
        'venv*',
        '.venv',
        '.git',
        'node_modules',
        '__pycache__',
        '.vscode',
        '_deps',
        '*.dir',
        'x64',
        '.cache',
        'voicevox_core_source',
        '.history'
    ),
    [int]$MaxDepth = -1,
    [switch]$DirectoriesOnly
)


function Get-Visible-Children {
    param($ParentPath)


    try {
        $items = Get-ChildItem -Path $ParentPath -Force -ErrorAction Stop


        $visible = $items | Where-Object {
            $include = $true
            foreach ($ex in $Exclude) {
                if ($_.Name -like $ex) { $include = $false; break }
            }
            if ($DirectoriesOnly) { $include = $include -and $_.PSIsContainer }
            $include
        } | Sort-Object @{Expression = { $_.PSIsContainer }; Descending = $true}, Name


        return ,$visible
    }
    catch {
        Write-Warning "Cannot access '$ParentPath': $($_.Exception.Message)"
        return @()
    }
}


function Print-Tree {
    param(
        [string]$TargetPath,
        [string]$Indent,
        [int]$Depth
    )


    $children = Get-Visible-Children -ParentPath $TargetPath
    for ($i = 0; $i -lt $children.Count; $i++) {
        $child = $children[$i]
        $isLast = ($i -eq ($children.Count - 1))
        $prefix = if ($isLast) { '└── ' } else { '├── ' }


        Write-Host "$Indent$prefix$($child.Name)"


        if ($child.PSIsContainer) {
            if (($MaxDepth -ne -1) -and ($Depth -ge $MaxDepth)) {
                continue
            }


            # ← 互換性のために明示的に if/else で nextIndent を作る
            if ($isLast) {
                $nextIndent = $Indent + '    '
            } else {
                $nextIndent = $Indent + '│   '
            }


            Print-Tree -TargetPath $child.FullName -Indent $nextIndent -Depth ($Depth + 1)
        }
    }
}


# 実行
$resolved = Resolve-Path -Path $Path
Write-Host $resolved.Path
Print-Tree -TargetPath $resolved.Path -Indent "" -Depth 1




























# sp_tree_json


# 概要:
#   指定したフォルダ構造を JSON 化して出力し、指定した拡張子のファイルについては
#   先頭 N 行を "preview" として一緒に含めます。生成AI に渡す用途に最適化しています。


# 互換性:
#   PowerShell 5.1 以上で動作するように記述しています（PowerShell 7 でも動作します）。


# 使い方例:
#   # 現在フォルダを JSON で出力（標準出力）
#   .\sp_tree_json_preview.ps1


#   # プロジェクトを除外パターン付きで JSON に書き出す
#   .\sp_tree_json_preview.ps1 -Path .\myproject -Exclude @('*.vvm','node_modules','*.dll') -OutFile project_tree.json


#   # .py と .md の先頭 5 行を取得し、最大プレビューサイズ 2MB に制限
#   .\sp_tree_json_preview.ps1 -PreviewExtensions @('.py','.md') -PreviewLines 5 -MaxPreviewSizeMB 2 -OutFile tree.json


# パラメータ:
#   -Path                : 対象ディレクトリ (既定 '.')
#   -Exclude             : 除外パターン配列 (ワイルドカード可)
#   -MaxDepth            : 深さ制限 (-1 = 無制限)
#   -DirectoriesOnly     : ディレクトリのみ出力
#   -PreviewExtensions   : 先頭行を取得するファイル拡張子リスト
#   -PreviewLines        : 取得する先頭行数
#   -MaxPreviewSizeMB    : プレビューを作る最大ファイルサイズ（MB）
#   -OutFile             : ファイルに書き出す場合の出力先パス（未指定で標準出力）
#   -RelativePaths       : JSON 内のパスをルートからの相対パスにする


# 出力 JSON の各ノードの主なキー:
#   name          : ファイル/フォルダ名
#   type          : "directory" または "file"
#   relativePath  : ルートからの相対パス（-RelativePaths の場合）
#   size          : バイト（ファイルのみ）
#   modified      : 最終更新日時 (ISO 8601)
#   children      : 子ノードの配列（ディレクトリのみ）
#   preview       : 先頭 N 行 (文字列) または null


# 注意:
#   - バイナリや読み取り権限がないファイルは preview が null になります。
#   - 非常に大きなディレクトリを JSON にする場合、出力サイズが巨大になるので -Exclude で絞ることを推奨します。
# #>


# param(
#     [string]$Path = '.',
#     [string[]]$Exclude = @(
#         'venv', 'venv*', '.venv', '.git', 'node_modules', '__pycache__', '.vscode'
#     ),
#     [int]$MaxDepth = -1,
#     [switch]$DirectoriesOnly,
#     [string[]]$PreviewExtensions = @('.md', '.py', '.txt', '.json', '.yaml', '.yml'),
#     [int]$PreviewLines = 10,
#     [int]$MaxPreviewSizeMB = 1,
#     [string]$OutFile = '',
#     [switch]$RelativePaths
# )


# function Get-Visible-Children {
#     param(
#         [string]$ParentPath
#     )


#     try {
#         $items = Get-ChildItem -Path $ParentPath -Force -ErrorAction Stop
#     }
#     catch {
#         Write-Warning "Cannot access '$ParentPath': $($_.Exception.Message)"
#         return @()
#     }


#     $visible = @()
#     foreach ($it in $items) {
#         $include = $true
#         foreach ($ex in $Exclude) {
#             if ($it.Name -like $ex) {
#                 $include = $false
#                 break
#             }
#         }
#         if ($DirectoriesOnly -and -not $it.PSIsContainer) {
#             $include = $false
#         }
#         if ($include) { $visible += $it }
#     }


#     # ディレクトリを先に、その後名前順
#     $visible = $visible | Sort-Object @{Expression = { $_.PSIsContainer }; Descending = $true}, Name
#     return ,$visible
# }


# function Get-PreviewText {
#     param(
#         [string]$FilePath
#     )


#     try {
#         $fi = Get-Item -LiteralPath $FilePath -ErrorAction Stop
#     }
#     catch {
#         return $null
#     }


#     if (-not $fi -or $fi.Length -eq $null) { return $null }


#     $maxBytes = $MaxPreviewSizeMB * 1MB
#     if ($fi.Length -gt $maxBytes) { return $null }


#     try {
#         # まず UTF8 で読んでみる
#         $lines = Get-Content -LiteralPath $FilePath -Encoding UTF8 -TotalCount $PreviewLines -ErrorAction Stop
#         return ($lines -join "`n")
#     }
#     catch {
#         try {
#             # 失敗したら既定のエンコーディングで再試行
#             $lines = Get-Content -LiteralPath $FilePath -TotalCount $PreviewLines -ErrorAction Stop
#             return ($lines -join "`n")
#         }
#         catch {
#             return $null
#         }
#     }
# }


# function Build-Node {
#     param(
#         [string]$FullPath,
#         [int]$Depth
#     )


#     try {
#         $item = Get-Item -LiteralPath $FullPath -Force -ErrorAction Stop
#     }
#     catch {
#         return $null
#     }


#     $node = [ordered]@{}
#     $node.name = $item.Name
#     if ($RelativePaths) {
#         $root = (Resolve-Path -Path $Path).Path
#         if ($FullPath -like "$root*" ) {
#             $rel = $FullPath.Substring($root.Length)
#             if ($rel.StartsWith('\') -or $rel.StartsWith('/')) { $rel = $rel.Substring(1) }
#             $node.relativePath = $rel
#         }
#         else {
#             $node.relativePath = $FullPath
#         }
#     }
#     else {
#         $node.relativePath = $FullPath
#     }


#     if ($item.PSIsContainer) {
#         $node.type = 'directory'
#         $node.size = $null
#         $node.modified = $item.LastWriteTime.ToString('o')
#         $node.preview = $null


#         # 深度チェック
#         if (($MaxDepth -ne -1) -and ($Depth -ge $MaxDepth)) {
#             $node.children = @()
#             return $node
#         }


#         $children = Get-Visible-Children -ParentPath $FullPath
#         $childNodes = @()
#         foreach ($ch in $children) {
#             $childNode = Build-Node -FullPath $ch.FullName -Depth ($Depth + 1)
#             if ($childNode -ne $null) { $childNodes += $childNode }
#         }
#         $node.children = $childNodes
#     }
#     else {
#         $node.type = 'file'
#         $node.size = $item.Length
#         $node.modified = $item.LastWriteTime.ToString('o')


#         $ext = [IO.Path]::GetExtension($item.Name)
#         if ($ext -ne $null) { $ext = $ext.ToLower() }


#         $node.preview = $null
#         if ($PreviewExtensions -contains $ext) {
#             $pv = Get-PreviewText -FilePath $FullPath
#             if ($pv -ne $null) { $node.preview = $pv }
#         }


#         $node.children = @()
#     }


#     return $node
# }


# # 実行ブロック
# $resolvedRoot = Resolve-Path -Path $Path
# $rootPath = $resolvedRoot.Path


# $rootNode = Build-Node -FullPath $rootPath -Depth 0


# # JSON に変換
# $json = $null
# try {
#     $json = $rootNode | ConvertTo-Json -Depth 100 -Compress
# }
# catch {
#     # 万一深さで失敗したらもう少し小さい深さで試す
#     $json = $rootNode | ConvertTo-Json -Depth 50 -Compress
# }


# if ($OutFile -ne '') {
#     $json | Out-File -FilePath $OutFile -Encoding UTF8
#     Write-Output "Wrote JSON to: $OutFile"
# }
# else {
#     Write-Output $json
# }

