FROM debian:buster as base

ENV NETATALK_VERSION 3.1.12
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get install \
        --assume-yes \
        apt-utils

FROM base as build

ENV BUILD_DEPS  \
                build-essential \
                dpkg-dev \
                dh-make \
                fakeroot \
                libevent-dev \
                libssl-dev \
                libgcrypt-dev \
                libkrb5-dev \
                libpam0g-dev \
                libwrap0-dev \
                libdb-dev \
                libtdb-dev \
                libmariadb-dev-compat \
                libavahi-client-dev \
                libacl1-dev \
                libldap2-dev \
                libcrack2-dev \
                systemtap-sdt-dev \
                libdbus-1-dev \
                libdbus-glib-1-dev \
                libglib2.0-dev \
                libtracker-sparql-2.0-dev \
                libtracker-miner-2.0-dev \
                libltdl-dev \
                file

ENV DEBIAN_FRONTEND=noninteractive

RUN     apt-get install \
            --no-install-recommends \
            --fix-missing \
            --assume-yes \
            $BUILD_DEPS \
            tracker \
            avahi-daemon \
            curl

RUN     curl -sSL  http://ufpr.dl.sourceforge.net/project/netatalk/netatalk/${NETATALK_VERSION}/netatalk-${NETATALK_VERSION}.tar.gz -O \
            && tar fxvz netatalk-${NETATALK_VERSION}.tar.gz \
            && cd netatalk-${NETATALK_VERSION}

WORKDIR netatalk-${NETATALK_VERSION}

RUN DEBFULLNAME="Instant User" DEBEMAIL="user@debian.org" dh_make -s -c gpl3 --yes --createorig
ADD rules.add .
RUN cat rules.add >> debian/rules
RUN debian/rules binary

FROM base

RUN mkdir /media/share

COPY --from=build /netatalk_*.deb /
RUN dpkg --force-depends -i "/netatalk_${NETATALK_VERSION}-1_$(dpkg --print-architecture).deb" && apt-get install -f -y

COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY afp.conf /etc/afp.conf
ENV DEBIAN_FRONTEND=newt

CMD ["/docker-entrypoint.sh"]