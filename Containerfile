FROM ghcr.io/rulentwave/gentoo-prefix-builder@sha256:300924deec4550e310836cf4ffd29a22d06f6b7a9eb0c6885328414defe70d6f as stage3

FROM registry.fedoraproject.org/fedora@sha256:71dbd9e6ab4b9266593a0f8d9cb095ed7f4f4993dd569bc0c88a0ce2aa59f9d5

ARG PREFIX=/usr/lib/gentoo-prefix

COPY --from=stage3 ${PREFIX} ${PREFIX}
WORKDIR /opt/app
COPY entrypoint.sh .
COPY extension-release.gentoo-prefix .
COPY run.sh .
COPY overrides /overrides
RUN mkdir /out

RUN dnf install -y rsync erofs-utils cryptsetup openssl

RUN /bin/bash -c "source ${PREFIX}/etc/profile && chmod +x /opt/app/run.sh && /opt/app/run.sh sysext"

ENTRYPOINT ["/opt/app/entrypoint.sh"]
CMD ["/opt/app/run.sh"]
