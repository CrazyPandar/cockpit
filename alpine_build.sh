
#/bin/sh
ALPINE_VERSION=3.9
CONTAINER_NAME=cockpit-build

docker run -d --restart always --network host -v "$(pwd):/data/cockpit" --name ${CONTAINER_NAME} alpine:${ALPINE_VERSION} sleep 12345678901234567890

docker exec -it ${CONTAINER_NAME} sh -c "echo https://mirrors.ustc.edu.cn/alpine/v${ALPINE_VERSION}/main > /etc/apk/repositories"
docker exec -it ${CONTAINER_NAME} sh -c "echo https://mirrors.ustc.edu.cn/alpine/v${ALPINE_VERSION}/community >> /etc/apk/repositories"
#docker exec -it ${CONTAINER_NAME} sh -c 'echo https://mirrors.ustc.edu.cn/alpine/edge/main >> /etc/apk/repositories'
#docker exec -it ${CONTAINER_NAME} sh -c 'echo https://mirrors.ustc.edu.cn/alpine/edge/community >> /etc/apk/repositories'

docker exec -it ${CONTAINER_NAME} apk add alpine-sdk autoconf automake intltool fts-dev json-glib-dev polkit-dev krb5-dev linux-pam-dev libexecinfo-dev npm python bsd-compat-headers
docker exec -it ${CONTAINER_NAME} apk add udisks2 networkmanager

docker exec -it ${CONTAINER_NAME} addgroup -g $(id -g) builder
docker exec -it ${CONTAINER_NAME} adduser -D -u $(id -u) -G builder builder

echo
echo == Generate configure and makefile ==
echo ./autogen.sh
echo autoreconf
echo

echo
echo == Generate Makefile ==
echo ./configure --disable-doc --disable-pcp --disable-ssh --disable-systemd --prefix=/usr --sbindir=/usr/bin --sysconfdir=/etc --localstatedir=/var
echo

echo
echo == debug ==
echo XDG_DATA_DIRS=/data/cockpit ./cockpit-ws --local-session=./cockpit-bridge
echo 

docker exec -it ${CONTAINER_NAME} su -l builder -c 'cd /data/cockpit && sh'
exit
