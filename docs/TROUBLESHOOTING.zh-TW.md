# aistat 疑難排解指南

## 安裝後顯示 `command not found: aistat`

若 `$HOME/.local/bin/aistat` 存在，先在目前終端加入 PATH：

```bash
export PATH="$HOME/.local/bin:$PATH"
aistat
```

確認可用後再永久加入 zsh：

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

## 沒有載入中的模型

這通常不是錯誤。分別檢查：

```bash
ollama list  # 已安裝模型
ollama ps    # 目前載入模型
```

若顯示無法連線，請先啟動 Ollama；`aistat` 不會自行啟動服務。

## GPU 需要 sudo 權限

執行 `aistat --gpu`。若仍無法取得，可直接檢查：

```bash
sudo powermetrics --samplers gpu_power -n 1
```

若原始指令有 GPU 資料但 `aistat` 無法解析，回報時只附上已移除個資的相關片段。

## Docker 未安裝或引擎未執行

```bash
docker --version
docker info
```

只安裝 CLI、但沒有啟動 Docker Desktop 或其他引擎時，`docker info` 仍會失敗。

## Docker 數值與活動監視器不同

`aistat` 顯示各容器用量；活動監視器通常顯示整個 Docker 虛擬機，還包含 Linux VM、檔案快取與服務本身，因此較高是正常現象。

## 記憶體數值與活動監視器不同

`aistat` 依公開的 `vm_stat` 與 `sysctl` 推算；活動監視器的分類公式未完整公開，取樣時間也不同。判斷是否缺記憶體時，優先看 Memory Pressure，再觀察 Swap 是否持續上升及操作是否延遲。

macOS 不會在 RAM 空出後立即清空 Swap。只要 Memory Pressure 正常且操作順暢，通常不用重開機。

## 沒有顏色

管線輸出、`--no-color` 或 `NO_COLOR` 都會停用色彩：

```bash
unset NO_COLOR
```

## 回報問題前

```bash
sw_vers
uname -m
aistat --help
bash --version | head -n 1
```

請勿在公開 Issue 張貼密碼、Token、API Key、私鑰、完整使用者路徑或公司內部資訊。安全問題請依[安全政策](../SECURITY.md)回報。
