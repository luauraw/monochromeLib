# MonochromeLib 使用説明書

MonochromeLibは、Roblox向けの白黒モノクロームテーマのUIライブラリです。Window、Button、Toggle、Slider、Dropdown、TextInput、Notification、Modal、KeybindPicker、ColorPickerなど、多数のコンポーネントを提供します。

---

## 目次

1. [セットアップ](#セットアップ)
2. [基本設定](#基本設定)
3. [Window（ウィンドウ）](#windowウィンドウ)
4. [Tab（タブ）とSection（セクション）](#tabタブとsectionセクション)
5. [Button（ボタン）](#buttonボタン)
6. [Toggle（トグル/スイッチ）](#toggleトグルスイッチ)
7. [Slider（スライダー）](#sliderスライダー)
8. [Dropdown（ドロップダウン）](#dropdownドロップダウン)
9. [TextInput（テキスト入力）](#textinputテキスト入力)
10. [Notification（通知/トースト）](#notification通知トースト)
11. [Modal（モーダル/ダイアログ）](#modalモーダルダイアログ)
12. [KeybindPicker（キーバインドピッカー）](#keybindpickerキーバインドピッカー)
13. [ColorPicker（カラーピッカー）](#colorpickerカラーピッカー)
14. [Label / Paragraph（ラベル/段落）](#label--paragraphラベル段落)
15. [Separator（セパレーター）](#separatorセパレーター)
16. [ProgressBar（プログレスバー）](#progressbarプログレスバー)
17. [Table（テーブル/リスト）](#tableテーブルリスト)
18. [Tooltip（ツールチップ）](#tooltipツールチップ)
19. [ユーティリティ関数](#ユーティリティ関数)
20. [イベントシステム](#イベントシステム)
21. [完全な使用例](#完全な使用例)

---

## セットアップ

```lua
local MonochromeLib = require(path.to.MonochromeLib)
```

ライブラリをrequireすると、自動的に`PlayerGui`以下に`ScreenGui`（名前: "MonochromeLib"）が作成されます。すべてのUI要素はこのScreenGuiに配置されます。

---

## 基本設定

### テーマのカスタマイズ

```lua
MonochromeLib.Theme({
    Background  = Color3.fromRGB(0, 0, 0),   -- 背景色
    Surface     = Color3.fromRGB(20, 20, 20), -- サーフェス色
    Accent      = Color3.fromRGB(200, 200, 200), -- アクセント色
    TextPrimary = Color3.fromRGB(255, 255, 255), -- メインテキスト色
    -- 他にも多数のキーがあります
})
```

### コンフィグの変更

```lua
MonochromeLib.Config({
    Scale        = 1,                        -- 全体スケール
    Font         = Enum.Font.GothamMedium,   -- フォント
    CornerWindow = 10,                       -- ウィンドウの角丸半径
    TweenFast    = TweenInfo.new(0.15),      -- アニメーション設定
})
```

---

## Window（ウィンドウ）

メインのウィンドウを作成します。

```lua
local mainWindow = MonochromeLib.Window({
    Title    = "設定メニュー",
    Size     = UDim2.new(0, 520, 0, 400),
    Position = UDim2.new(0.5, -260, 0.5, -200),
    MinSize  = Vector2.new(300, 200),
})
```

### Windowのメソッド

| メソッド | 説明 |
|---------|------|
| `:SetTitle(str)` | ウィンドウタイトルを変更 |
| `:SetSize(UDim2)` | サイズを変更 |
| `:SetPosition(UDim2)` | 位置を変更 |
| `:SetVisible(bool)` | 表示/非表示 |
| `:Focus()` | ZIndexを最前面に |
| `:Toggle()` | 表示状態を反転 |
| `:AddTab(name)` | 新しいタブを追加（後述） |
| `:Destroy()` | ウィンドウを破棄 |

### イベント

```lua
mainWindow:On("Close", function()
    print("ウィンドウが閉じられました")
end)
```

---

## Tab（タブ）とSection（セクション）

### タブの追加

```lua
local generalTab = mainWindow:AddTab("一般")
local settingsTab = mainWindow:AddTab("設定")
```

### タブのメソッド

| メソッド | 説明 |
|---------|------|
| `:Select()` | このタブをアクティブにする |
| `:AddSection(title)` | セクションコンテナを追加 |

### セクションの追加

セクションは、コントロールをグループ化するためのコンテナです。

```lua
local displaySection = generalTab:AddSection("表示設定")
-- displaySection は Frame です。この中にコントロールを配置します。
```

---

## Button（ボタン）

```lua
local myButton = MonochromeLib.Button(parentFrame, {
    Text    = "実行",
    Icon    = "rbxassetid://1234567890",  -- オプション
    Variant = "Primary",  -- "Primary", "Ghost", "Danger", "Default"
    Size    = UDim2.new(1, 0, 0, 36),
})
```

### ボタンのメソッド

| メソッド | 説明 |
|---------|------|
| `:SetText(str)` | テキスト変更 |
| `:SetIcon(assetId)` | アイコン変更 |
| `:SetEnabled(bool)` | 有効/無効 |
| `:OnClick(callback)` | クリックイベント |

### 使用例

```lua
myButton:OnClick(function()
    print("ボタンが押されました")
    MonochromeLib.Notification():Show("成功", "処理が完了しました", "Success")
end)
```

---

## Toggle（トグル/スイッチ）

```lua
local darkModeToggle = MonochromeLib.Toggle(parentFrame, {
    Label   = "ダークモード",
    Default = true,
})
```

### メソッド

| メソッド | 説明 |
|---------|------|
| `:SetValue(bool)` | 値を設定 |
| `:GetValue()` | 現在の値を取得 |
| `:OnChange(callback)` | 値変更時のイベント |

```lua
darkModeToggle:OnChange(function(isOn)
    print("ダークモード:", isOn)
end)
```

---

## Slider（スライダー）

```lua
local volumeSlider = MonochromeLib.Slider(parentFrame, {
    Label   = "音量",
    Min     = 0,
    Max     = 100,
    Step    = 5,
    Default = 50,
})
```

### メソッド

| メソッド | 説明 |
|---------|------|
| `:SetValue(num)` | 値を設定 |
| `:GetValue()` | 現在の値を取得 |
| `:SetRange(min, max)` | 範囲を変更 |
| `:SetStep(step)` | ステップ値を変更 |
| `:OnChange(callback)` | 値変更イベント |

---

## Dropdown（ドロップダウン）

```lua
local languageDropdown = MonochromeLib.Dropdown(parentFrame, {
    Label       = "言語",
    Options     = {"日本語", "英語", "中国語", "韓国語"},
    Placeholder = "選択してください",
    MultiSelect = false,  -- 複数選択モード
})
```

### メソッド

| メソッド | 説明 |
|---------|------|
| `:SetOptions({string})` | オプションを再設定 |
| `:GetSelected()` | 選択された値（文字列 or テーブル） |
| `:SetPlaceholder(str)` | プレースホルダー変更 |
| `:OnChange(callback)` | 選択変更イベント |

```lua
languageDropdown:OnChange(function(selected)
    if type(selected) == "string" then
        print("選択:", selected)
    else
        print("選択:", table.concat(selected, ", "))
    end
end)
```

---

## TextInput（テキスト入力）

```lua
local nameInput = MonochromeLib.TextInput(parentFrame, {
    Label       = "ユーザー名",
    Placeholder = "名前を入力",
    MaxLength   = 20,
    Password    = false,
    Prefix      = "@",   -- 左側に表示
    Suffix      = "",    -- 右側に表示
})
```

### メソッド

| メソッド | 説明 |
|---------|------|
| `:GetValue()` | 入力値を取得 |
| `:SetValue(str)` | 値を設定 |
| `:OnChange(callback)` | 入力変更イベント |
| `:OnSubmit(callback)` | Enter押下イベント |
| `:SetError(msg)` | エラーメッセージを表示 |
| `:ClearError()` | エラーをクリア |

---

## Notification（通知/トースト）

```lua
local notif = MonochromeLib.Notification()

-- 通知を表示
notif:Show("タイトル", "メッセージ本文", "Info", 4)  -- タイプ: Info, Success, Warning, Error

-- IDを指定して手動で閉じる
local id = notif:Show("読み込み中", "処理中です...", "Info", 10)
task.wait(3)
notif:Dismiss(id)
```

---

## Modal（モーダル/ダイアログ）

```lua
local confirmModal = MonochromeLib.Modal({
    Title   = "確認",
    Body    = "本当に実行しますか？",
    Confirm = "実行",
    Cancel  = "キャンセル",
})

-- イベント設定
confirmModal:OnConfirm(function()
    print("確認されました")
end)

confirmModal:OnCancel(function()
    print("キャンセルされました")
end)

-- 表示
confirmModal:Open()

-- カスタムコンテンツを埋め込む場合
local customFrame = Instance.new("Frame")
-- ... カスタムUIを構築
confirmModal:SetContent(customFrame)
```

### メソッド

| メソッド | 説明 |
|---------|------|
| `:Open()` | モーダルを表示 |
| `:Close()` | 閉じる |
| `:SetContent(instance)` | カスタムコンテンツを設定 |
| `:OnConfirm(callback)` | 確認ボタンイベント |
| `:OnCancel(callback)` | キャンセルボタンイベント |

---

## KeybindPicker（キーバインドピッカー）

```lua
local keybindPicker = MonochromeLib.KeybindPicker(parentFrame, {
    Label   = "ショートカットキー",
    Default = Enum.KeyCode.F,
})
```

### メソッド

| メソッド | 説明 |
|---------|------|
| `:GetKeybind()` | 現在のキーを取得 |
| `:OnChange(callback)` | キー変更イベント |

```lua
keybindPicker:OnChange(function(keyCode)
    print("新しいキーバインド:", keyCode.Name)
end)
```

---

## ColorPicker（カラーピッカー）

モノクロームライブラリなので、グレースケール専用のピッカーです。

```lua
local colorPicker = MonochromeLib.ColorPicker(parentFrame, {
    Label   = "グレー濃度",
    Default = Color3.fromRGB(128, 128, 128),
})
```

### メソッド

| メソッド | 説明 |
|---------|------|
| `:GetValue()` | Color3を取得 |
| `:SetValue(Color3)` | 値を設定 |
| `:OnChange(callback)` | 変更イベント |

---

## Label / Paragraph（ラベル/段落）

### ラベル（単一行）

```lua
local titleLabel = MonochromeLib.Label(parentFrame, {
    Text     = "設定メニュー",
    Size     = 18,
    Color    = Color3.fromRGB(255,255,255),
    Muted    = false,
    Truncate = true,  -- はみ出し時にツールチップ表示
})

titleLabel:SetText("新しいタイトル")
```

### パラグラフ（複数行、自動改行）

```lua
local description = MonochromeLib.Paragraph(parentFrame, {
    Text  = "これは長い説明文です。自動的に折り返し表示されます。",
    Size  = 13,
    Color = Color3.fromRGB(150,150,150),
})

description:SetText("新しい説明文")
```

---

## Separator（セパレーター）

```lua
-- 単純な線
MonochromeLib.Separator(parentFrame, {})

-- ラベル付き
MonochromeLib.Separator(parentFrame, { Label = "その他の設定" })
```

---

## ProgressBar（プログレスバー）

```lua
local progress = MonochromeLib.ProgressBar(parentFrame, {
    Label         = "読み込み中...",
    Indeterminate = false,  -- 不定モード（くるくる）
})

-- 値の設定（0～1）
progress:SetValue(0.75)

-- 不定モード切り替え
progress:SetIndeterminate(true)
```

---

## Table（テーブル/リスト）

```lua
local userTable = MonochromeLib.Table(parentFrame, {
    Columns = {
        {Name = "名前", Key = "name"},
        {Name = "レベル", Key = "level"},
        {Name = "ステータス", Key = "status"},
    },
    Size = UDim2.new(1, 0, 0, 200),
})

-- データ設定
userTable:SetData({
    {name = "プレイヤー1", level = 42, status = "オンライン"},
    {name = "プレイヤー2", level = 17, status = "オフライン"},
    {name = "プレイヤー3", level = 99, status = "ゲーム中"},
})

-- 行クリックイベント
userTable:OnRowClick(function(rowData, rowIndex)
    print(rowData.name, "がクリックされました")
end)

-- カラムを動的に変更
userTable:SetColumns({{Name = "ID", Key = "id"}, {Name = "名前", Key = "name"}})
```

---

## Tooltip（ツールチップ）

任意のGuiObjectにツールチップを追加します。

```lua
local tooltipSystem = MonochromeLib.Tooltip()

-- ボタンにツールチップをアタッチ
tooltipSystem:Attach(myButton:GetInstance(), "このボタンは設定を保存します")

-- どのGuiObjectにもアタッチ可能
tooltipSystem:Attach(someTextBox, "ここにユーザー名を入力")
```

---

## ユーティリティ関数

### アニメーション

```lua
MonochromeLib.Tween(frame, {Position = UDim2.new(0, 100, 0, 0)}, 0.3, Enum.EasingStyle.Quad)
```

### リップルエフェクト

```lua
MonochromeLib.Ripple(parentFrame, x, y)  -- クリック位置に波紋
```

### デバウンス

```lua
local debouncedFunc = MonochromeLib.Debounce(function(arg)
    print("実行:", arg)
end, 0.5)

debouncedFunc("A")
debouncedFunc("B")  -- 最後の呼び出しから0.5秒後にBのみ実行
```

### ZIndex取得

```lua
local newZ = MonochromeLib.ZIndex()  -- 新しいZIndex値を取得
```

### ライブラリ全体の破棄

```lua
MonochromeLib.Destroy()  -- ScreenGuiごと全て破棄
```

---

## イベントシステム

すべてのコンポーネントはイベントシステムを持ちます。

```lua
-- イベントリスナー登録
component:On("EventName", function(...)
    -- 処理
end)

-- 内部的なファイア（通常はライブラリが使用）
-- component:Fire("EventName", ...)
```

利用可能なイベント:

| コンポーネント | イベント名 | 引数 |
|--------------|-----------|------|
| Window | `Close` | - |
| Button | `Click` | - |
| Toggle | `Change` | `(value: boolean)` |
| Slider | `Change` | `(value: number)` |
| Dropdown | `Change` | `(value: string \| {string})` |
| TextInput | `Change`, `Submit` | `(text: string)` |
| Modal | `Confirm`, `Cancel` | - |
| KeybindPicker | `Change` | `(keyCode: Enum.KeyCode)` |
| ColorPicker | `Change` | `(color: Color3)` |
| Table | `RowClick` | `(rowData: table, rowIndex: number)` |

---

## 完全な使用例

```lua
local MonochromeLib = require(script.Parent.MonochromeLib)

-- テーマ調整
MonochromeLib.Theme({
    Background = Color3.fromRGB(8, 8, 12),
    Accent = Color3.fromRGB(220, 220, 240),
})

-- メインウィンドウ作成
local win = MonochromeLib.Window({
    Title = "設定ダッシュボード",
    Size = UDim2.new(0, 600, 0, 450),
})

-- タブ追加
local general = win:AddTab("一般")
local audio = win:AddTab("オーディオ")
local about = win:AddTab("情報")

-- 一般タブのセクション
local appearance = general:AddSection("外観")

local darkMode = MonochromeLib.Toggle(appearance, {
    Label = "ダークモード",
    Default = true,
})

local brightnessSlider = MonochromeLib.Slider(appearance, {
    Label = "明るさ",
    Min = 0, Max = 100, Default = 80,
})

-- オーディオタブ
local audioSection = audio:AddSection("音量設定")

local masterVol = MonochromeLib.Slider(audioSection, {
    Label = "マスター音量",
    Min = 0, Max = 100, Default = 70,
})

local muteToggle = MonochromeLib.Toggle(audioSection, {
    Label = "ミュート",
    Default = false,
})

-- 情報タブ
local infoSection = about:AddSection("バージョン情報")
local versionLabel = MonochromeLib.Label(infoSection, {
    Text = "MonochromeLib v1.0.0",
    Size = 14,
    Muted = true,
})

-- フッターボタン
local footerSection = about:AddSection("")
local closeBtn = MonochromeLib.Button(footerSection, {
    Text = "閉じる",
    Variant = "Ghost",
})

closeBtn:OnClick(function()
    win:Destroy()
end)

-- 通知システムのテスト
local notif = MonochromeLib.Notification()
darkMode:OnChange(function(isOn)
    notif:Show("テーマ変更", isOn and "ダークモード有効" or "ライトモード有効", "Info", 2)
end)
```

---

## 注意事項

- すべてのコンポーネントは親Frameを必要とします。通常は`tab:AddSection()`が返すFrameを使用します。
- ライブラリは自動的にScreenGuiを作成します。手動で作成する必要はありません。
- パフォーマンスのため、不要になったウィンドウやコンポーネントは`:Destroy()`してください。
- モバイル（タッチ）にも対応しています。
- カラーピッカーはモノクロームライブラリのためグレースケール専用です。

---

以上がMonochromeLibの基本的な使い方です。各コンポーネントはチェーンメソッドで設定を行えるため、直感的にUIを構築できます。
