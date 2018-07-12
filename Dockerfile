FROM 		docker:latest
MAINTAINER	Rio Harapan Ps. <harapan@arc.itb.ac.id>

WORKDIR 	/home

RUN 		apk add --update --no-cache curl make ca-certificates openssl python btrfs-progs e2fsprogs e2fsprogs-extra iptables xfsprogs xz pigz; \
			if zfs="$(apk info --no-cache --quiet zfs)" && [ -n "$zfs" ]; then \
				apk add --no-cache zfs; \
			fi \
			&& curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
			&& chmod +x ./kubectl \
    		&& mv ./kubectl /usr/local/bin/kubectl \
    		&& wget https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz \
    		&& tar zxvf google-cloud-sdk.tar.gz && ./google-cloud-sdk/install.sh --usage-reporting=false --path-update=true \
    		&& PATH="google-cloud-sdk/bin:${PATH}" \
    		&& gcloud --quiet components update \
    		&& gcloud components install beta

ENV 		PATH /home/google-cloud-sdk/bin:$PATH
RUN			echo $PATH
# set up subuid/subgid so that "--userns-remap=default" works out-of-the-box
RUN set -x \
	&& addgroup -S dockremap \
	&& adduser -S -G dockremap dockremap \
	&& echo 'dockremap:165536:65536' >> /etc/subuid \
	&& echo 'dockremap:165536:65536' >> /etc/subgid

# https://github.com/docker/docker/tree/master/hack/dind
ENV DIND_COMMIT 52379fa76dee07ca038624d639d9e14f4fb719ff

RUN set -ex; \
	apk add --no-cache --virtual .fetch-deps libressl; \
	wget -O /usr/local/bin/dind "https://raw.githubusercontent.com/docker/docker/${DIND_COMMIT}/hack/dind"; \
	chmod +x /usr/local/bin/dind; \
	apk del .fetch-deps

COPY dockerd-entrypoint.sh /usr/local/bin/

VOLUME /var/lib/docker
EXPOSE 2375

ENTRYPOINT ["dockerd-entrypoint.sh"]
CMD []

# reference from:
# https://github.com/docker-library/docker/tree/441b13e5f1de3cf3a9afc27f99adf0e247bfba35/18.03/dind