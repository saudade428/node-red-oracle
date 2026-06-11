FROM nodered/node-red:latest-debian

USER root

# 1. 僅透過 apt-get 安裝不會衝突的基礎工具
RUN apt-get update && apt-get install -y --no-install-recommends \
    unzip \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 2. 🌟 關鍵修正：直接下載並植入舊版 libaio1 的官方 deb 檔
# 透過全域 CDN 下載，避開 apt 套件庫的版本限制
RUN wget http://deb.debian.org/debian/pool/main/liba/libaio/libaio1_0.3.113-4_amd64.deb && \
    dpkg -i libaio1_0.3.113-4_amd64.deb && \
    rm libaio1_0.3.113-4_amd64.deb

# 3. 建立 Oracle 工作目錄
WORKDIR /opt/oracle

# 4. 下載、解壓、設定權限 (維持你原本成功的指令)
RUN wget --tries=3 https://download.oracle.com/otn_software/linux/instantclient/1927000/instantclient-basic-linux.x64-19.27.0.0.0dbru.zip && \
    wget --tries=3 https://download.oracle.com/otn_software/linux/instantclient/1927000/instantclient-sqlplus-linux.x64-19.27.0.0.0dbru.zip && \
    unzip -oq instantclient-basic-linux.x64-19.27.0.0.0dbru.zip && \
    unzip -oq instantclient-sqlplus-linux.x64-19.27.0.0.0dbru.zip && \
    mv instantclient_19_27 instantclient && \
    chmod -R 755 instantclient && \
    rm -f instantclient-*.zip

# 5. 註冊 Oracle 函式庫路徑到系統中
RUN echo /opt/oracle/instantclient > /etc/ld.so.conf.d/oracle-instantclient.conf && \
    ldconfig

# 6. 建立網路設定檔目錄
RUN mkdir -p /opt/oracle/instantclient/network/admin

# 7. 設定環境變數
ENV PATH=/opt/oracle/instantclient:$PATH
ENV TNS_ADMIN=/opt/oracle/instantclient/network/admin

# 8. 切回 Node-RED 預設工作目錄
WORKDIR /usr/src/node-red
USER node-red
