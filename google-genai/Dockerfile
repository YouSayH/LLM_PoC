# ベースイメージの指定
# python:3.11-slim は軽量なLinux環境にPython 3.11がインストールされたイメージです。
# "slim" を使うことでイメージサイズを小さく保てます。
FROM python:3.11-slim

# 作業ディレクトリの設定
# コンテナ内の /app というディレクトリを作成し、そこを起点にコマンドを実行します。
WORKDIR /app

# 依存関係ファイルのコピー
# ホスト（あなたのPC）の requirements.txt をコンテナ内の現在のディレクトリ（/app）にコピーします。
# COPY <ホストのパス> <コンテナのパス>
COPY requirements.txt .

# 依存パッケージのインストール
# --no-cache-dir オプションでキャッシュを作らないようにし、イメージサイズを小さくします。
RUN pip install --no-cache-dir -r requirements.txt

# アプリケーションコードのコピー
# 現在のディレクトリの全てのファイルをコンテナの /app にコピーします。
# 注: compose.yaml でボリュームマウントを使う場合、開発中はここは必須ではありませんが、
# 本番環境へのデプロイを見越して記述しておくのが一般的です。
COPY . .

# ポートの公開（ドキュメント用）
# コンテナがポート 8000 を使用することを明示します。
# 実際にポートを開けるのは実行時（docker run -p や docker compose）の設定です。
EXPOSE 8000

# コンテナ起動時に実行されるデフォルトコマンド
# uvicorn: ASGIサーバー（FastAPIを動かすためのサーバー）
# server:app : server.py ファイル内の app オブジェクトを指定
# --host 0.0.0.0 : 外部（ホストPCなど）からのアクセスを許可するために必須
# --port 8000 : 8000番ポートで待ち受け
# --reload : コードを変更したら自動で再起動する（開発用オプション）
CMD ["uvicorn", "server:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]