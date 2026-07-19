FROM ghcr.io/rulentwave/gentoo-prefix-builder@sha256:300924deec4550e310836cf4ffd29a22d06f6b7a9eb0c6885328414defe70d6f as stage3

FROM registry.fedoraproject.org/fedora@sha256:82177f185c3b61c1abbad38eb767c08a26197d5ad4b51466fa968568d4252179

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
