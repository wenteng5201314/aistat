# aistat 使用操作手冊

`aistat` 只讀取系統狀態，不會停止模型、關閉容器或修改 macOS 設定。

## 1. 安裝

確認 Mac 使用 Apple Silicon（結果應為 `arm64`）：

```bash
uname -m
```

從 GitHub 安裝：

```bash
git clone https://github.com/wenteng5201314/aistat.git
cd aistat
chmod +x aistat install.sh tests/run.sh
./install.sh
```

安裝器優先使用可寫入的 `/usr/local/bin`，否則使用 `$HOME/.local/bin`；不呼叫 sudo，也不修改 `~/.zshrc`。指定位置或覆蓋舊版：

```bash
./install.sh --prefix "$HOME/.local/bin"
./install.sh --force
```

## 2. 基本操作

```bash
aistat                 # 一般模式，不主動要求 sudo
aistat --gpu           # 以 sudo 取得一次 GPU 使用率
aistat --no-color      # 停用色彩
NO_COLOR=1 aistat      # 適合輸出至檔案
aistat --help          # 顯示說明
```

終端機輸入 sudo 密碼時不會顯示星號或文字，輸入完成後按 Return 即可。把結果存成純文字：

```bash
NO_COLOR=1 aistat > aistat-report.txt
```

## 3. 輸出判讀

### Ollama

- **模型**：目前載入的模型名稱。
- **GPU**：`ollama ps` 回報的處理器配置。
- **Context**：上下文上限；越大時 KV cache 通常也越大。
- **Until**：模型預計保留到何時；`Stopping...` 表示正在卸載。

「沒有載入中的模型」不代表 Ollama 未安裝，只表示目前沒有模型留在記憶體。

### 記憶體

- **總量**：統一記憶體總量。
- **已使用**、**App**：依 `vm_stat` 推算。
- **Wired**：不能立即移到 Swap 的系統記憶體。
- **Compressed**：macOS 壓縮後留在記憶體中的資料。
- **Swap**：目前存放於 SSD 交換空間的資料。

活動監視器的分類公式未完整公開，因此估算值不會完全一致。

### Docker

顯示容器的記憶體用量／限制與比例，不包含整個 Docker Desktop 虛擬機的額外成本。

### GPU

顯示取樣期間的 GPU active residency。WindowServer、瀏覽器與動畫也會使用 GPU，因此 Ollama 未載入時仍可能不是 0%。

### Memory Pressure

| 狀態 | 可用比例 | 建議 |
| --- | ---: | --- |
| 正常（綠） | 20% 以上 | 通常不需處理 |
| 注意（黃） | 10%–19% | 觀察大型模型、Docker 與 Swap |
| 嚴重（紅） | 低於 10% | 卸載模型或關閉暫時不用的大型工作負載 |

這是 `aistat` 的提示門檻，不等同活動監視器的演算法。

## 4. 常見流程

載入模型前後分別執行 `aistat`；需要即時 GPU 取樣時使用 `aistat --gpu`。工作完成後可自行卸載模型：

```bash
ollama stop MODEL_NAME
aistat
```

請以 `ollama ps` 顯示的名稱取代 `MODEL_NAME`。`aistat` 本身不會停止模型。

## 5. 更新

在 clone 的專案資料夾中執行：

```bash
git pull --ff-only
./install.sh --force
```

## 6. 移除

```bash
command -v aistat
rm "$HOME/.local/bin/aistat"
```

若 `command -v` 顯示不同位置，請改用實際路徑。刪除前務必先確認目標。

## 7. 延伸閱讀

- [疑難排解](TROUBLESHOOTING.zh-TW.md)
- [技術參考](TECHNICAL_REFERENCE.zh-TW.md)
