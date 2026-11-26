# Experimental image descriptors

Descriptors here are excluded from automated release builds, version increments,
and the scheduled UBI 9 base updater. They can be built locally from the repository
root using the normal helper:

```bash
./.dev/build-image.sh ./future-descriptors/telicent-base-java-ubi10.yaml
./.dev/build-image.sh ./future-descriptors/telicent-base-python314-ubi10.yaml
```

These produce `telicent-java21-ubi10:0.1.0` and
`telicent-python3.14-ubi10:0.1.0`. Both use a pinned UBI 10 Minimal base and
install timezone data explicitly. Java reuses the Temurin 21 modules; Python
uses a dedicated RPM-based Python 3.14 module and the shared virtual environment
configuration. The virtual environment comes first on PATH; the system Python
is left unchanged. Python 3.14 is an AppStream package, rather than the system
default interpreter.

After building, smoke-test the runtime and default user:

```bash
docker run --rm telicent-java21-ubi10:0.1.0 java -version
docker run --rm telicent-java21-ubi10:0.1.0 id
docker run --rm telicent-python3.14-ubi10:0.1.0 /home/user/app-venv/bin/python --version
docker run --rm telicent-python3.14-ubi10:0.1.0 id
```

Full container builds and runtime checks are required before promotion to
`image-descriptors`. Validate both amd64 and arm64; amd64 hosts need
x86-64-v3 support. The base updater must support UBI 10 before promotion.
