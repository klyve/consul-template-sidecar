FROM debian:jessie


RUN apt-get update \
  && apt-get install -y wget \
  && apt-get install -y curl \
  && apt-get install jq \
  && rm -rf /var/lib/apt/lists/*

#RUN apt-get install curl

# Download consul and kubectl
RUN wget --output-document /consul-template.tgz https://releases.hashicorp.com/consul-template/0.20.0/consul-template_0.20.0_linux_amd64.tgz
RUN wget https://storage.googleapis.com/kubernetes-release/release/v1.15.0/bin/linux/amd64/kubectl
RUN tar xvzf /consul-template.tgz
RUN rm -v /consul-template.tgz

RUN chmod +x ./kubectl
RUN chmod +x ./consul-template
RUN mv ./kubectl /usr/local/bin/kubectl
RUN mv ./consul-template /usr/local/bin/consul-template

COPY ./app.sh /app.sh
RUN chmod +x app.sh

CMD ["/app.sh"]
