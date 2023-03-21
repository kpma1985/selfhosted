FROM ubuntu:22.04

# update package directory
RUN apt-get update

# add python and pip
#RUN apt-get install -y python3 python3-pip && \
#    pip install jupyter

# add mambaforge
RUN apt-get install -y curl && \
    curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-$(uname)-$(uname -m).sh" && \
    bash "Mambaforge-$(uname)-$(uname -m).sh" -b -p /opt/mambaforge && \
    rm "Mambaforge-$(uname)-$(uname -m).sh" && \
    ln -s /opt/mambaforge/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/mambaforge/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

# add opam + ocaml w/ jupyter kernel
RUN add-apt-repository ppa:avsm/ppa && \
	apt-get update && \
	apt-get install ocaml opam -y
RUN opam init --disable-sandboxing -y
RUN apt-get install -y zlib1g-dev libffi-dev libgmp-dev libzmq5-dev pkg-config
RUN opam install -y jupyter && \
    echo '#use "topfind";;' >> ~/.ocamlinit && \
    echo 'Topfind.log:=ignore;;' >> ~/.ocamlinit && \
    eval $(opam env) && \
    ocaml-jupyter-opam-genspec && \
    jupyter kernelspec install --name "ocaml-jupyter-$(opam var switch)" "$(opam var share)/jupyter"