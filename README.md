# telicent-base-images

## Licensing and Usage Terms

### Source Code License
The **source code** for this project is licensed under the Apache License, Version 2.0. 
You can view the full text of the Apache License [here](http://www.apache.org/licenses/LICENSE-2.0).

### Built Image License
When building container images using this source code, please note that the resulting container image is **not**
licensed under Apache 2.0. Instead, the image is subject to the **Red Hat Universal Base Image (UBI) 9 End User License
Agreement (EULA)**. You can find the UBI EULA
[here](https://www.redhat.com/en/about-red-hat-end-user-license-agreements#UBI).


> [!IMPORTANT]
> ### Licensing Considerations for RHEL Users
>
> If this project is built on a licensed Red Hat Enterprise Linux (RHEL) host, the build process may enable full RHEL
> repositories. This can result in the installation of packages that are covered by the Red Hat Enterprise Linux
> Subscription Agreement. 
>
> #### Why This Matters:
> - **Running on non-RHEL Hosts**: If you install packages from full RHEL repositories during the build on a RHEL host,
>   those packages may not be legally run on non-RHEL systems without a valid RHEL subscription.
> - **Avoid Licensing Violations**: Be cautious when adding packages. Ensure that you only install packages that are
>   allowed under the UBI EULA if you intend to run the container on non-RHEL systems.

For more details on the implications of adding software to a UBI container, please refer to the official Red Hat
documentation: [Add Software to a Running UBI
Container](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html-single/building_running_and_managing_containers/index/#add_software_to_a_running_ubi_container).

## Project overview

Telicent base images is a container creation tool built on top of [CeKit](https://github.com/cekit/cekit). Refer to 
CeKit documentation for further information.

Images built by this tool could be found in [Telicent's DockerHub](https://hub.docker.com/u/telicent)


> [!IMPORTANT]
> 
> Project is still in early development stages, so there are some known issues mainly around the CI/CD components.
>
> Currently due to limitation by CeKit when building multip-platform images we have opted-out to use CeKit only
> for Container file creation, then the images are build using Docker. 
> 
> Refer to https://github.com/cekit/cekit/pull/929 for more information
> 
> In next release of CeKit the intention is to swtich to building the images with CeKit utilising podman 
> as builder orchestrator this would reduce the complexity of the CI/CD Pipelines.
>


### Prerequisites

 - Local development, requires the installation of Python and cekit via pip, additional dependencies might be needed 
depending on the builder engine of choice. See CeKit for supported build engines.

### Releases

Only changes affecting the images directly would trigger GH release when merging into `main`, this behaviour was 
changed in [cdb097f6 - commit][cdb097f6]

[cdb097f6]: https://github.com/telicent-oss/telicent-base-images/commit/cdb097f6f8b36e76394262c4c600561363154be6

**NB** Also in order for a release to be automatically triggered there **MUST** be at least one conventional commit
style commit message in the commits merged into `main`, i.e. `feat`, `fix`, `chore` etc.  See
[`tag_version.sh`](tag_version.sh) script for the exact logic used to determine if there are relevant commits, or if you
want to change it in future.

### General note on images

Images produced by this project run as non-root user by default with UID of 185, which is compatible with OpenShift.
Only the bare minimum software is installed, users might need to enable additional repositories to install needed some
packages to make their software work. Please refer to https://access.redhat.com/articles/4238681 for more information 
on repositories.

To temporarily enable a repo pass the following flag to `microdnf` command  `--enablerepo=ubi-9-appstream-rpms`


When building on top of the images make sure you switch to `USER 0(root)` in your container file, then for apps
switch back to "USER user(185)"

Upon running an image the workdir is set to `/home/user`


### Python Image

Python base image starts up in a virtual environment, there is no need to create one. Only Python and pip are installed.
There are additional packages that are relevant which can be installed from the appstream and baseos repos.
Python is installed via microdnf but this might change in the future.

Sumlinks: python3, python, python<version>, pip, pip3, pip<python_version>

### Java Image

Ships with a Temurin JRE and dumb-init installed on it, available on PATH. 
See [modules/jdk/jdk-base](modules/jdk/jdk-base) for specific modifications to Java,
currently only the secure file is touched.


### Nginx Image

Can be run/configured by non-root users. See [modules/nginx/127/configure.sh](modules/nginx/127/configure.sh)
for specific changes made. Default open port 8080

Nginx is installed under /usr/local/nginx.
Default logging as per defualt conf is /usr/local/nginx/logs...
Default logging needs updated to /var/log/nginx/access.log | error.log in order to be propagated to docker.


### Node image

Ships with LTS Node20, npm not available. Additional packages installed can be found under [nodejs-20-module](modules/nodejs/20/module.yaml)


### Modules

Below is a map of the `module-names` to actual `paths`, bear in mind some of those are nested, 
or some would copy content across other modules. Only modules used by the tool are included in the 
table below, therefore the table is not full.

| **Module**                                    | **Path**                                   |
|-----------------------------------------------|-------------------------------------------|
| `telicent.container.util.cleanup.npm`         | `modules/util/cleanup/npm`                |
| `telicent.container.util.cleanup.pkg-python`  | `modules/util/cleanup/python-pkg`         |
| `telicent.container.user`                     | `modules/user`                            |
| `telicent.container.util.cleanup.gcc`         | `modules/util/cleanup/gcc`                |
| `telicent.container.util.tzdata`              | `modules/util/tzdata`                     |
| `telicent.container.util.readlines`           | `modules/util/readlines`                  |
| `telicent.container.util.python-packages`     | `modules/util/pkg-python`                 |
| `telicent.container.util.python-entrypoint`   | `modules/util/python-entrypoint`          |
| `telicent.container.util.python-entrypoint-virtualenv` | `modules/util/python-entrypoint-virtualenv` |
| `telicent.container.openjdk`                  | `modules/jdk/21`                          |
| `telicent.container.util.pkg-update`          | `modules/util/pkg-update`                 |
| `telicent.container.python311-microdnf`       | `modules/python/311-microdnf`             |
| `telicent.container.python`                   | `modules/python/313`                      |
| `telicent.container.util.cleanup`             | `modules/util/cleanup/microdnf`           |
| `telicent.container.util.pyenv-perms`         | `modules/util/pyenv-perms`                |
| `telicent.container.utils.cleanup.tar-gzip`   | `modules/util/cleanup/tar-gzip`           |
| `telicent.container.openjdk.base`             | `modules/jdk/jdk-base/base`               |
| `telicent.container.python.base`              | `modules/python/python-base`              |
| `telicent.container.nodejs`                   | `modules/nodejs/20`                       |
| `telicent.container.util.pkg-nodejs`          | `modules/util/pkg-nodejs`                 |
| `telicent.container.python312-microdnf`       | `modules/python/312-microdnf`             |
| `telicent.container.dumb-init`                | `modules/dumb-init`                       |
| `telicent.container.tar-gzip`                 | `modules/tar-gzip`                        |
| `telicent.container.nginx`                    | `modules/nginx/127`                       |
