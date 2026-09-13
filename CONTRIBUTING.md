# 參與貢獻

感謝你協助改善 `aistat`。請讓每次變更維持小範圍、可理解，並保留 Bash 3.2 與 macOS Apple Silicon 相容性。

## 開發流程

1. Fork 專案並建立功能分支。
2. 修改前閱讀 README、操作手冊與技術參考。
3. 行為變更先新增會正確失敗的測試，再修改主程式。
4. 執行完整測試與語法檢查。
5. 提交 Pull Request，說明原因、驗證結果與限制。

## 本機驗證

```bash
bash tests/run.sh
bash -n aistat install.sh tests/run.sh
NO_COLOR=1 ./aistat
```

最後一項只讀取本機狀態且不主動要求 sudo。需要驗證 GPU 時可自行執行 `./aistat --gpu`。

## 測試與程式風格

- 使用 `tests/fixtures/` 的固定輸出測試解析器。
- 測試不得依賴本機 Ollama、Docker 或真實 sudo。
- 使用 macOS Bash 3.2 支援的語法及系統內建工具。
- 每個資料來源應獨立降級，不讓單一選用工具造成整體失敗。
- 不加入停止模型、清理記憶體或修改系統設定等破壞性行為，除非先完成安全設計。

Pull Request 請包含問題情境、變更內容、測試實際結果、未驗證平台，以及不含個資的輸出範例（若輸出格式有變）。安全問題請遵循 `SECURITY.md`。
