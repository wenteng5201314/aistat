# aistat 技術參考

## 架構與介面

`aistat` 是 Bash 3.2 相容的單檔唯讀工具。每個資料來源獨立處理錯誤，選用工具失敗不會阻止其他區塊輸出。

```text
aistat [--gpu] [--no-color] [--help]
```

未知參數以狀態碼 2 退出；非 Darwin 或非 `arm64` 平台以狀態碼 1 退出。

## 資料來源與公式

### Ollama

執行 `ollama ps`，依標題列的欄位起始位置切割，避免模型大小的空白或 Until 的多個單字破壞解析。

### 記憶體

- 總量：`sysctl -n hw.memsize`
- 頁面分類：`vm_stat`
- Swap：`sysctl vm.swapusage`

```text
Used = Total - page_size × (free + inactive + speculative + purgeable)
App = page_size × (active + speculative)
Wired = page_size × wired
Compressed = page_size × pages occupied by compressor
```

Used 下限為 0。App 刻意不重複計入 compressed，也不把大部分 inactive 快取納入。這不是活動監視器的官方公式。

### Docker

先以 `docker info` 檢查引擎，再執行：

```bash
docker stats --no-stream --format '{{.Name}}\t{{.MemUsage}}\t{{.MemPerc}}'
```

### GPU

一般模式先用 `sudo -n true` 檢查既有權限；不會要求密碼。`--gpu` 才執行互動式：

```bash
sudo powermetrics --samplers gpu_power -n 1
```

程式解析 `GPU HW active residency`；這是時間取樣比例，不是 GPU 記憶體用量。

### Memory Pressure

優先解析 `memory_pressure` 的 system-wide free percentage；缺值時估算：

```text
available = page_size × (free + inactive + speculative + purgeable) ÷ total × 100
```

20% 以上為正常，10%–19% 為注意，低於 10% 為嚴重。這是專案自訂門檻。

## 色彩與安全

非互動輸出、`NO_COLOR` 或 `--no-color` 會停用 ANSI 色碼。`AISTAT_FORCE_COLOR=1` 僅供測試。

工具不修改設定、不停止模型或容器、不保存取樣結果；一般模式不觸發互動式 sudo。測試使用臨時 PATH 與固定 fixture，不執行真實 sudo。

## 相容性限制

目前只承諾支援 macOS Apple Silicon 與 Bash 3.2。Apple、Ollama 或 Docker 改變 CLI 輸出格式時，對應欄位可能暫時無法取得。
