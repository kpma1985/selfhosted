FROM ubuntu:22.04

ENV CODE_SERVER_VERSION=4.9.1

# update package directory
RUN apt-get update

# add mambaforge
RUN apt-get install -y curl && \
    curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-$(uname)-$(uname -m).sh" && \
    bash "Mambaforge-$(uname)-$(uname -m).sh" -b -p /opt/mambaforge && \
    rm "Mambaforge-$(uname)-$(uname -m).sh" && \
    ln -s /opt/mambaforge/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/mambaforge/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

# make RUN commands use the new environment
SHELL ["/bin/bash", "--login", "-c"]

# install jupyter to base repository
RUN mamba install -y -c conda-forge nodejs jupyterlab jupyter-server-proxy jupyter-vscode-proxy

# install code-server
RUN curl -fL https://github.com/coder/code-server/releases/download/v${CODE_SERVER_VERSION}/code-server-${CODE_SERVER_VERSION}-linux-amd64.tar.gz \
    | tar -C /lib -xz && \
    ln -s /lib/code-server-${CODE_SERVER_VERSION}-linux-amd64/bin/code-server /bin/code-server

# install rstudio server
RUN apt-get install -y wget gdebi-core && \
    wget https://download2.rstudio.org/server/jammy/amd64/rstudio-server-2022.12.0-353-amd64.deb && \
    gdebi -n rstudio-server-2022.12.0-353-amd64.deb && \
    rm rstudio-server-2022.12.0-353-amd64.deb

# the different applications in this container run on different ports
# jupyterlab
EXPOSE 8888
# code-server
EXPOSE 8080
# rstudio-server
EXPOSE 8787

# launch jupyterlab through entrypoint.sh so conda environment can be used
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]