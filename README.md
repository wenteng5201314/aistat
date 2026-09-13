# aistat

`aistat` 是適用於 macOS Apple Silicon 的唯讀終端機 AI 儀表板。它在同一畫面顯示 Ollama 模型、系統記憶體、Docker 容器記憶體、GPU 使用率與 Memory Pressure。

## 功能

- 顯示 `ollama ps` 的模型、GPU／CPU 配置、Context 與 Until。
- 顯示總記憶體、已使用、App、Wired、Compressed 與 Swap。
- Docker 執行中時顯示每個容器的記憶體用量。
- 使用 `powermetrics` 顯示 GPU active residency；沒有 sudo 權限時不會卡住。
- 以綠、黃、紅提示記憶體壓力；管線輸出時會自動停用色彩。

## 安裝

```bash
chmod +x aistat install.sh tests/run.sh
./install.sh
```

安裝器優先使用可寫入的 `/usr/local/bin`，否則使用 `$HOME/.local/bin`。它不會自行呼叫 sudo或修改 shell 設定。也可自行指定位置：

```bash
./install.sh --prefix "$HOME/.local/bin"
```

若目標已有同名檔案，安裝器預設拒絕覆蓋。確認來源後可執行：

```bash
./install.sh --prefix "$HOME/.local/bin" --force
```

若 `$HOME/.local/bin` 不在 PATH，可自行加入 `~/.zshrc`：

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## 使用

```bash
aistat
aistat --gpu
aistat --no-color
NO_COLOR=1 aistat
```

一般執行不會跳出密碼提示。`aistat --gpu` 才會明確要求 sudo，讓 `powermetrics` 取樣約數秒；若目前已有 sudo 快取權限，一般執行也可直接取得 GPU 數值。

## 狀態顏色

狀態依「可用記憶體比例」提示：20% 以上為綠色正常、10% 至 19% 為黃色注意、低於 10% 為紅色嚴重。這是 aistat 的簡化提示門檻，不等同活動監視器的記憶體壓力圖演算法。

## 資料來源與限制

- 總量與 Swap 來自 `sysctl`；頁面分類來自 `vm_stat`。
- 已使用量以總量扣除 free、inactive、speculative、purgeable 頁面估算。
- App 以 active 與 speculative 頁面加總，作為不重複計入 compressed、也不把大部分 inactive 快取算入的保守估算。這不會與活動監視器的私有計算公式完全相同。
- Memory Pressure 優先使用 `memory_pressure` 的可用百分比；取不到時以 `vm_stat` 後備估算。
- GPU 顯示的是 `powermetrics` 的 GPU active residency，不是 GPU 記憶體用量。
- Ollama 與 Docker 都是選用項目；未安裝或服務未啟動不會讓整個工具失敗。
- Apple 可能在新版 macOS 調整系統指令格式。解析失敗時，aistat 會顯示無法取得，不會把未知值顯示成零。
- 僅支援 macOS Apple Silicon；未針對 Intel Mac、Linux 或 Windows 設計。

## 測試

```bash
bash tests/run.sh
bash -n aistat install.sh tests/run.sh
```

測試使用固定的系統輸出替身，不會呼叫真實 sudo、停止模型或操作容器。

## 移除

刪除安裝位置的單一檔案即可，例如：

```bash
rm "$HOME/.local/bin/aistat"
```

若安裝在 `/usr/local/bin`，請改用實際安裝路徑。刪除前可先執行 `command -v aistat` 確認目標。
