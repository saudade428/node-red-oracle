FROM nodered/node-red:latest-debian

USER root

# 1. 安裝系統依賴 (unzip, libaio1, wget) 並清理 apt 快取以縮小映像檔體積
RUN apt-get update && apt-get install -y --no-install-recommends \
    unzip \
    libaio1 \
    wget \
    && rm -rf /var/lib/apt/lists/*

# 2. 建立 Oracle 專用目錄 (避開 /data 覆蓋陷阱)
WORKDIR /opt/oracle

# 3. 下載、解壓縮並設定 Oracle Instant Client 19.27 (Basic & SQLPlus)
RUN wget https://download.oracle.com/otn_software/linux/instantclient/1927000/instantclient-basic-linux.x64-19.27.0.0.0dbru.zip && \
    wget https://download.oracle.com/otn_software/linux/instantclient/1927000/instantclient-sqlplus-linux.x64-19.27.0.0.0dbru.zip && \
    unzip instantclient-basic-linux.x64-19.27.0.0.0dbru.zip && \
    unzip instantclient-sqlplus-linux.x64-19.27.0.0.0dbru.zip && \
    mv instantclient_19_27 instantclient && \
    chmod -R 755 instantclient && \
    rm instantclient-*.zip

# 4. 建立 network/admin 資料夾結構以容納 tnsnames.ora
RUN mkdir -p /opt/oracle/instantclient/network/admin

# 5. 設定全域環境變數
# 讓 Node-RED 找得到動態函式庫與 sqlplus 指令
ENV LD_LIBRARY_PATH=/opt/oracle/instantclient:$LD_LIBRARY_PATH
ENV PATH=/opt/oracle/instantclient:$PATH
# 明確指定 tnsnames.ora 的讀取路徑
ENV TNS_ADMIN=/opt/oracle/instantclient/network/admin

# 6. 切回 Node-RED 預設工作目錄與無特權使用者 (安全性最佳實踐)
WORKDIR /usr/src/node-red
USER node-red
