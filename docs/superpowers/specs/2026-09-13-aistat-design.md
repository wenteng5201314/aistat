# aistat 終端機 AI 儀表板設計

## 目標

建立適用於 macOS Apple Silicon 的唯讀 Bash 工具 `aistat`，在單次執行中彙整 Ollama、系統記憶體、Docker、GPU 與記憶體壓力。缺少非必要指令或權限時，仍輸出其餘資訊並清楚標示無法取得的項目。

## 交付內容

- `aistat`：可直接執行的 Bash 主程式。
- `install.sh`：將主程式安裝為 PATH 中的 `aistat` 指令。
- `tests/run.sh` 與測試資料：驗證輸出解析、狀態顏色與降級行為。
- `README.md`：安裝、使用方式、資料來源、權限與限制。

## 架構

主程式維持單檔，依資料來源切成小函式。系統指令由可覆寫的環境變數或 PATH 解析，以便測試用固定輸出取代真實系統狀態。各區塊獨立收集資料；任何單一區塊失敗都不應中止整份儀表板。

### Ollama

若可使用 `ollama`，執行 `ollama ps`，保留模型名稱、處理器欄位中的 GPU 百分比、Context 與 Until。由於模型名稱和 Until 可能含空白或版本差異，解析器依標題欄位置切欄，不假設固定欄數。未安裝、服務未啟動或沒有模型時分別顯示可理解的狀態。

### macOS 記憶體

- 總量：優先使用 `sysctl -n hw.memsize`。
- App、Wired、Compressed：從 `vm_stat` 頁面數乘上頁面大小估算。
- 已使用：總量減去 Free、Inactive、Speculative、Purgeable；README 明確標示這是儀表板估算值，不等同活動監視器的私有計算公式。
- Swap：從 `sysctl vm.swapusage` 取得 used 值。

所有容量統一轉為人類可讀的 GiB 或 MiB。

### Docker

只有在 `docker info` 成功時執行 `docker stats --no-stream`。顯示容器名稱與記憶體用量／限制；Docker 未安裝或引擎未執行時顯示簡短狀態，不報錯退出。

### GPU

GPU 指標為選用功能。預設不觸發互動式 sudo：若目前已有權限，使用 `sudo -n powermetrics --samplers gpu_power -n 1`；否則顯示需要權限，並提供 `--gpu` 模式讓使用者明確選擇執行一次互動式 sudo。解析 GPU active residency；若該 macOS 版本輸出格式不同，保留原始不可取得提示。

### Memory Pressure 與顏色

優先解析 `memory_pressure` 的 system-wide memory free percentage，並以 `vm_stat` 使用比例作為缺值時的後備估算。狀態門檻固定為：

- 綠：可用比例大於或等於 20%。
- 黃：可用比例 10% 到 19%。
- 紅：可用比例低於 10%。

這些是工具的提示門檻，不宣稱等同活動監視器圖表。只有標準輸出連接終端且未設定 `NO_COLOR` 時輸出 ANSI 顏色。

## 命令介面

```text
aistat [--gpu] [--no-color] [--help]
```

- 無參數：快速、非互動地顯示所有可取得資料。
- `--gpu`：允許透過 sudo 執行一次 `powermetrics`。
- `--no-color`：停用 ANSI 顏色。
- `--help`：顯示說明。

不支援的參數會回傳非零狀態並顯示用法。

## 安裝策略

`install.sh` 預設選擇第一個可寫入的位置：`/usr/local/bin`，其次為 `$HOME/.local/bin`。可用 `--prefix DIR` 指定安裝目錄。安裝不自行呼叫 sudo、不修改 shell 設定檔，也不覆蓋與本專案無關的檔案；若目標已有 `aistat`，顯示來源並要求使用者明確加上 `--force` 才覆蓋。

## 測試與驗收

測試以暫存 PATH 放入假的 `ollama`、`vm_stat`、`sysctl`、`memory_pressure`、`docker`、`powermetrics` 與 `sudo`，驗證：

1. Ollama 欄位可從典型輸出正確呈現。
2. 記憶體容量計算與單位轉換正確。
3. Docker 執行中與未執行時都能正常輸出。
4. 無 sudo 權限時 GPU 區塊優雅降級。
5. 綠、黃、紅門檻及 `NO_COLOR` 行為正確。
6. 安裝到指定暫存目錄後可執行 `aistat --help`。
7. 使用 `bash -n` 驗證所有 Shell 檔案語法。

最後在目前這台 Mac 實際執行一次不需 sudo 的儀表板；GPU 權限模式不會自動觸發密碼提示。

## 安全與限制

工具只讀取本機系統狀態，不寫入系統設定、不停止模型或容器，也不蒐集或保存敏感資料。macOS 指令輸出可能隨版本改變，因此解析失敗時必須顯示未知，不得以零值冒充實際狀態。
