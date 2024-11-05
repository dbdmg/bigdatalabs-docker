FROM ubuntu:22.04

# Define user and user id default arguments
ARG USER=student
ARG UID=1010
ARG VSCODE_SRV_DIR=/vscode
ENV VSCODE_SRV_DIR=${VSCODE_SRV_DIR}
ENV HOSTNAME=bigdatalabs
ENV SERVICE_URL=https://open-vsx.org/vscode/gallery
ENV ITEM_URL=https://open-vsx.org/vscode/item

ENV DEBIAN_FRONTEND=noninteractive
ENV CODESERVER_VERSION=4.22.0
ENV M2_HOME=/opt/apache-maven-3.9.9
ENV MAVEN_HOME=${M2_HOME}

RUN apt-get update &&\
    apt-get install -y curl git wget gnupg &&\ 
    curl -fsSL https://code-server.dev/install.sh | sh -s -- --version=${CODESERVER_VERSION} &&\
    apt-get clean

# install amazon corretto open JDK manually
# RUN apt-get install java-common
# RUN wget https://corretto.aws/downloads/latest/amazon-corretto-8-x64-linux-jdk.deb
# RUN dpkg --install amazon-corretto-8-x64-linux-jdk.deb

# install amazon corretto open JDK through apt-get
RUN wget -O - https://apt.corretto.aws/corretto.key | gpg --dearmor -o /usr/share/keyrings/corretto-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/corretto-keyring.gpg] https://apt.corretto.aws stable main" | tee /etc/apt/sources.list.d/corretto.list
RUN apt-get update; apt-get install -y java-1.8.0-amazon-corretto-jdk    

# install apache maven
RUN wget https://dlcdn.apache.org/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.tar.gz
RUN tar -xvf apache-maven-3.9.9-bin.tar.gz
RUN mv apache-maven-3.9.9 /opt/
RUN rm apache-maven-3.9.9-bin.tar.gz

ENV PATH=${MAVEN_HOME}/bin:${PATH}


# install python and pyspark
RUN apt-get update && \
    apt-get install -y python3 python3-pip python-is-python3 && \
    pip3 install autopep8 pylint pyspark findspark ipython jupyterlab && \
    apt-get clean

RUN useradd -ms /bin/bash -u ${UID} $USER && \
    usermod -d ${VSCODE_SRV_DIR} $USER && \
    mkdir -p ${VSCODE_SRV_DIR}/extensions && \
    mkdir -p ${VSCODE_SRV_DIR}/data && \
    # mkdir -p ${VSCODE_SRV_DIR}/workspace && \
    cp /root/.bashrc ${VSCODE_SRV_DIR}/.bashrc && \
    cp /root/.profile ${VSCODE_SRV_DIR}/.profile && \
    echo 'alias code=code-server' >> ${VSCODE_SRV_DIR}/.bashrc && \
    echo 'export PS1="\[\e]0;\u@\h: \w\a\]\[\033[0;00m\][\A]\[\033[00;00m\]\[\033[01;34m\]\u\[\033[00m\]:\[\033[01;34m\]\w\[\e[91m\]\[\033[00m\]$ "' >> ${VSCODE_SRV_DIR}/.bashrc

# COPY pylance extension
COPY ./extensions/ms-python.vscode-pylance-2024.4.1.vsix /tmp

# install vscode extensions
RUN code-server --extensions-dir ${VSCODE_SRV_DIR}/extensions \
    --install-extension ms-python.python \
    --install-extension ms-python.pylint \
    --install-extension ms-toolsai.jupyter \
    --install-extension tmp/ms-python.vscode-pylance-2024.4.1.vsix \
    --install-extension vscjava.vscode-java-pack
# clean and remove pylance extension
RUN rm /tmp/ms-python.vscode-pylance-2024.4.1.vsix

RUN chown -R ${USER}:${USER} ${VSCODE_SRV_DIR}

COPY ./start.sh start.sh
RUN chmod 755 start.sh
USER ${USER}
ENTRYPOINT [ "/start.sh" ]