#!/bin/bash
apt-get update \
    && apt-get install -y apt-transport-https ca-certificates \
    && sed -i 's/http:/https:/g' /etc/apt/sources.list \
    && apt-get update \
    && apt-get -y upgrade \
    && apt-get -y dist-upgrade \
    && apt-get --purge autoremove -y

apt-get --no-install-recommends -y install \
    vim \
    inotify-tools \
    curl \
    wget \
    mount \
    psmisc \
    dpkg \
    apt \
    lsb-release \
    sudo \
    gnupg \
    apt-transport-https \
    ca-certificates \
    dirmngr \
    mdadm \
    iproute2 \
    ethtool \
    procps \
    cron \
    lvm2 \
    systemd \
    systemd-timesyncd \
    sysstat \
    net-tools 

curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
        | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null \
    && echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] https://nginx.org/packages/debian $(lsb_release -cs) nginx" \
        | sudo tee /etc/apt/sources.list.d/nginx.list \
    && echo 'Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n' \
        | sudo tee /etc/apt/preferences.d/99nginx \
    && cat /etc/apt/preferences.d/99nginx

curl -sL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor \
        | tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg >/dev/null \
    && echo "deb https://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/postgresql.list \
    && echo "deb https://apt.artifacts.ui.com $(lsb_release -cs) main release" > /etc/apt/sources.list.d/ubiquiti.list \
    && apt-get update 
    

cp -a files/version /usr/lib/version
cp -a files/lib/. /lib/


apt-get --no-install-recommends -y install /opt/debs/ubnt-archive-keyring_*_arm64.deb \
    && apt-get --no-install-recommends -y install postgresql-14 postgresql-9.6 \
    && apt-get update \
    && apt-get -y --no-install-recommends --allow-downgrades --allow-remove-essential --allow-change-held-packages \
        -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' \
        install /opt/debs/*.deb /opt/unifi-drive-deb/*.deb 

sed -i 's/return Ys(),Je()?/return Ys(),!0?/g' /usr/share/unifi-core/app/service.js \
    && mv /sbin/mdadm /sbin/mdadm.orig \
    && mv /sbin/ubnt-tools /sbin/ubnt-tools.orig \
    && systemctl enable storage_disk dbpermissions fix_hosts \
    && pg_dropcluster --stop 9.6 main \
    && sed -i 's/rm -f/rm -rf/' /sbin/pg-cluster-upgrade \
    && sed -i 's/OLD_DB_CONFDIR=.*/OLD_DB_CONFDIR=\/etc\/postgresql\/9.6\/main/' /sbin/pg-cluster-upgrade \
    && touch /usr/bin/uled-ctrl \
    && chmod +x /usr/bin/uled-ctrl \
    && chown root:root /etc/sudoers.d/* \
    && echo -e '\n\nexport PGHOST=127.0.0.1\n' >> /usr/lib/ulp-go/scripts/envs.sh \
    && cp -a files/etc/. /etc/ \
    && cp -a files/sbin/. /sbin/ \
    && cp -a files/usr/. /usr/ 