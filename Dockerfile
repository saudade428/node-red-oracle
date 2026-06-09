FROM nodered/node-red:latest-debian

USER root

# 1. 補上 ca-certificates，確保 wget 能正確驗證 HTTPS 連線
RUN apt-get update && apt-get install -y --no-install-recommends \
    unzip \
    libaio1 \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 2. 建立 Oracle 工作目錄
WORKDIR /opt/oracle

# 3. 下載、解壓、設定權限
RUN wget --tries=3 https://download.oracle.com/otn_software/linux/instantclient/1927000/instantclient-basic-linux.x64-19.27.0.0.0dbru.zip && \
    wget --tries=3 https://download.oracle.com/otn_software/linux/instantclient/1927000/instantclient-sqlplus-linux.x64-19.27.0.0.0dbru.zip && \
    unzip -oq instantclient-basic-linux.x64-19.27.0.0.0dbru.zip && \
    unzip -oq instantclient-sqlplus-linux.x64-19.27.0.0.0dbru.zip && \
    mv instantclient_19_27 instantclient && \
    chmod -R 755 instantclient && \
    rm -f instantclient-*.zip

# ==========================================
# 🌟 關鍵新增：將 Oracle 函式庫路徑註冊到系統中
RUN echo /opt/oracle/instantclient > /etc/ld.so.conf.d/oracle-instantclient.conf && \
    ldconfig
# ==========================================

# 4. 建立網路設定檔目錄
RUN mkdir -p /opt/oracle/instantclient/network/admin

# 5. 設定環境變數
# 保留 PATH 讓你可以直接打 sqlplus，捨棄容易失效的 LD_LIBRARY_PATH
ENV PATH=/opt/oracle/instantclient:$PATH
ENV TNS_ADMIN=/opt/oracle/instantclient/network/admin

# 6. 切回 Node-RED 預設工作目錄
WORKDIR /usr/src/node-red
USER node-red
