FROM 		docker:latest
MAINTAINER	Rio Harapan Ps. <harapan@arc.itb.ac.id>

WORKDIR 	/home

RUN 		apk add --update --no-cache curl make ca-certificates openssl python \
			&& curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
			&& chmod +x ./kubectl \
    		&& mv ./kubectl /usr/local/bin/kubectl \
    		&& wget https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz \
    		&& tar zxvf google-cloud-sdk.tar.gz && ./google-cloud-sdk/install.sh --usage-reporting=false --path-update=true \
    		&& PATH="google-cloud-sdk/bin:${PATH}" \
    		&& gcloud --quiet components update \
    		&& gcloud components install beta \