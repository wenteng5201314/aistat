# aistat

`aistat` 是專為 macOS Apple Silicon 設計的唯讀終端機 AI 系統儀表板。它把 Ollama、系統記憶體、Docker、GPU 與 Memory Pressure 集中在同一畫面，方便快速判斷本機 AI 模型是否占用大量統一記憶體。

## 主要功能

- 顯示 `ollama ps` 的模型、處理器配置、Context 與 Until。
- 顯示總記憶體、已使用、App、Wired、Compressed 與 Swap。
- Docker 執行中時顯示各容器的記憶體用量與限制。
- 使用 `powermetrics` 顯示 GPU active residency；沒有 sudo 權限時會安全降級。
- 以綠、黃、紅提示 Memory Pressure。
- 支援 `NO_COLOR`；缺少選用工具或權限時，其他區塊仍可正常顯示。

## 系統需求

- Apple Silicon Mac（M1 或更新晶片）與 macOS
- Bash 3.2 或更新版本
- 選用：Ollama、Docker、`powermetrics` 的 sudo 權限

## 快速開始

```bash
git clone https://github.com/wenteng5201314/aistat.git
cd aistat
chmod +x aistat install.sh tests/run.sh
./install.sh
aistat
```

安裝器優先使用可寫入的 `/usr/local/bin`；否則安裝到 `$HOME/.local/bin`。它不會自行呼叫 sudo，也不會修改 shell 設定。

若終端機找不到 `aistat`，請參閱[疑難排解指南](docs/TROUBLESHOOTING.zh-TW.md#安裝後顯示-command-not-found-aistat)。

## 常用指令

```bash
aistat                 # 一般檢查；不主動要求 sudo
aistat --gpu           # 允許 sudo 取得一次 GPU 使用率
aistat --no-color      # 停用 ANSI 色彩
NO_COLOR=1 aistat      # 以環境變數停用色彩
aistat --help          # 顯示內建說明
```

完整安裝、更新、輸出判讀與移除方式，請參閱[使用操作手冊](docs/USER_GUIDE.zh-TW.md)。

## 輸出解讀重點

- **Ollama**：確認目前是否有模型載入，以及模型使用 CPU/GPU 的比例。
- **記憶體**：App 與已使用數值依 `vm_stat` 推算，不保證與活動監視器完全相同。
- **Docker**：顯示容器用量，不等於活動監視器中的整個 Docker 虛擬機用量。
- **GPU**：顯示取樣期間的 GPU active residency，不代表 GPU 記憶體容量。
- **Memory Pressure**：判斷系統是否缺記憶體時，應優先查看這一項，而不是只看 Swap。

深入的資料來源與計算方式請參閱[技術參考](docs/TECHNICAL_REFERENCE.zh-TW.md)。

## 文件

- [使用操作手冊](docs/USER_GUIDE.zh-TW.md)
- [疑難排解指南](docs/TROUBLESHOOTING.zh-TW.md)
- [技術參考](docs/TECHNICAL_REFERENCE.zh-TW.md)
- [參與貢獻](CONTRIBUTING.md)
- [安全政策](SECURITY.md)
- [版本紀錄](CHANGELOG.md)
- [MIT License](LICENSE)

## 測試

```bash
bash tests/run.sh
bash -n aistat install.sh tests/run.sh
```

測試使用固定的系統輸出替身，不會呼叫真實 sudo、停止模型或操作容器。

## 授權

本專案採用 [MIT License](LICENSE)。你可以使用、複製、修改、合併、發布及散布本軟體，但必須保留原授權與著作權聲明。
