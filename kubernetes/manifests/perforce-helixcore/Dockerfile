FROM ubuntu:18.04
RUN apt update && apt upgrade -y && apt install -y wget curl gnupg2 && \
    wget -qO - https://package.perforce.com/perforce.pubkey | apt-key add - 
RUN echo "deb http://package.perforce.com/apt/ubuntu bionic release" > /etc/apt/sources.list.d/perforce.list 
RUN apt update -y
RUN apt-get install -y helix-p4d 
RUN /opt/perforce/sbin/configure-helix-p4d.sh \
    -n \
    -p 8080 \
    -r /opt/perforce \
    -u root \
    -P SecretPassword \
    --case=1 \
    master

ENV P4PORT="8080" P4USER="root"

ENTRYPOINT [ "su -l perforce -c 'p4dctl start master'" ]

# RUN rm -rf /var/lib/apt/lists/*

# /opt/perforce/sbin/configure-helix-p4d.sh -n -p 8081 -r /opt/perforce -u root -P SecretPassword --case=1 testing