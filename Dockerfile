ARG BASE_TAG=5.0.3-debian
FROM nodered/node-red:${BASE_TAG}

ARG ORACLE_DIR=1927000
ARG ORACLE_VER=19.27.0.0.0dbru
ARG ORACLE_FOLDER=instantclient_19_27
ARG NPM_VERSION=12.2.1

USER root

# 基礎工具與 libaio（trixie 為 libaio1t64，Oracle 需要 libaio.so.1）
RUN apt-get update && apt-get install -y --no-install-recommends \
      unzip wget ca-certificates libaio1t64 \
    && ln -snf libaio.so.1t64 /usr/lib/x86_64-linux-gnu/libaio.so.1 \
    && rm -rf /var/lib/apt/lists/* \
    && npm install -g npm@${NPM_VERSION}

# Oracle Instant Client
WORKDIR /opt/oracle
RUN wget --tries=3 https://download.oracle.com/otn_software/linux/instantclient/${ORACLE_DIR}/instantclient-basic-linux.x64-${ORACLE_VER}.zip \
 && wget --tries=3 https://download.oracle.com/otn_software/linux/instantclient/${ORACLE_DIR}/instantclient-sqlplus-linux.x64-${ORACLE_VER}.zip \
 && unzip -oq 'instantclient-*.zip' \
 && mv ${ORACLE_FOLDER} instantclient \
 && chmod -R 755 instantclient \
 && rm -f instantclient-*.zip \
 && echo /opt/oracle/instantclient > /etc/ld.so.conf.d/oracle-instantclient.conf \
 && ldconfig \
 && mkdir -p /opt/oracle/instantclient/network/admin

ENV PATH=/opt/oracle/instantclient:$PATH
ENV TNS_ADMIN=/opt/oracle/instantclient/network/admin

WORKDIR /usr/src/node-red
USER node-red
