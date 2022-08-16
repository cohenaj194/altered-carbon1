FROM alpine:3.7
COPY --from=golang:1.14-alpine /usr/local/go/ /usr/local/go/

ENV PATH="/usr/local/go/bin:${PATH}"

RUN apk -v --update add \
      util-linux \
      jq \
      curl \
      python \
      py-pip \
      groff \
      less \
      mailcap \
      tzdata \
      ruby \
      ruby-bundler \
      make \
      gcc \
      ruby-dev \
      libc-dev \
      libffi-dev \
      bash \
      ansible \
      sshpass \
      openssh-client \
      terraform \
      git \
      musl-dev \
      go \
      && \
      pip install --upgrade awscli==1.14.5 s3cmd==2.0.1 python-magic anybadge yq && \
      apk -v --purge del && \
      rm /var/cache/apk/*

# add glab to generate gitlab tickets
RUN echo "@edge http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories
RUN apk add --no-cache glab@edge

# add kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.15.1/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin/kubectl

# add aws-iam-authenticator
RUN curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.16.8/2020-04-16/bin/linux/amd64/aws-iam-authenticator
RUN chmod +x ./aws-iam-authenticator
RUN cp ./aws-iam-authenticator usr/bin/aws-iam-authenticator
RUN mkdir -p $HOME/bin && cp ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator && export PATH=$PATH:$HOME/bin
RUN echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc

# upgrade terraform to 0.12.31
RUN wget https://releases.hashicorp.com/terraform/0.12.31/terraform_0.12.31_linux_amd64.zip
RUN unzip terraform_0.12.31_linux_amd64.zip && rm terraform_0.12.31_linux_amd64.zip
RUN mv terraform /usr/bin/terraform

# get govc for vsphere lists
RUN curl -L -o - https://github.com/vmware/govmomi/releases/download/v0.25.0/govc_$(uname -s)_$(uname -m).tar.gz | tar -C /usr/local/bin -xvzf - govc

# install the godog cumcumber.io tool
# alias godog="/root/go/bin/godog"
RUN mkdir godogs && cd godogs && go mod init godogs && go get github.com/cucumber/godog/cmd/godog

# install github-cli tool gh for github pipelines
RUN wget https://github.com/cli/cli/releases/download/v2.6.0/gh_2.6.0_linux_386.tar.gz -O ghcli.tar.gz
RUN tar --strip-components=1 -xf ghcli.tar.gz