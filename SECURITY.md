# 安全政策

## 支援範圍

目前安全修正以最新 `main` 分支為主，尚未承諾維護舊版分支。

## 回報安全問題

請勿在公開 GitHub Issue 揭露尚未修正的弱點、密碼、Token、API Key、私鑰、完整系統輸出或可識別個人與組織的資訊。

請優先使用 GitHub 倉庫的 **Security → Report a vulnerability** 私密回報功能。若該功能未開啟，請只建立不含漏洞細節的 Issue，請維護者提供私密聯絡方式。

建議提供受影響版本、最小重現步驟、可能影響、已去識別化的錯誤訊息，以及建議修正方式（若有）。

## 安全設計界線

`aistat` 預設只讀且不主動要求 sudo。只有使用者明確執行 `aistat --gpu` 時才透過 sudo 呼叫 `powermetrics`。專案不應蒐集憑證、保存系統取樣結果或自動修改 Ollama、Docker 與 macOS 設定。
