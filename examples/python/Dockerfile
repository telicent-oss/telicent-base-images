FROM localhost:6500/telicent-python3.14:latest

USER root

COPY sbom.json /opt/telicent/sbom/
RUN microdnf --setopt=tsflags=nodocs --setopt=install_weak_deps=0 --enablerepo=ubi-9-appstream-rpms install openblas-devel gfortran which -y

ENV BLAS=openblas

USER user
RUN mkdir ./app
COPY . $HOME/app/
WORKDIR app
RUN python3 -m pip install --upgrade pip --root-user-action=ignore && \
    python3 -m pip install pip-tools && \
    python3 -m piptools compile --extra adapter -o requirements.txt pyproject.toml && \
    python3 -m pip install -r requirements.txt --no-cache-dir

CMD ["python3", "-m", "adapter.bulk_producer"]
