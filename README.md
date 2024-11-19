# telicent-base-images

## Licensing and Usage Terms

### Source Code License
The **source code** for this project is licensed under the Apache License, Version 2.0. 
You can view the full text of the Apache License [here](http://www.apache.org/licenses/LICENSE-2.0).

### Built Image License
When building container images using this source code, please note that the resulting container image is **not** licensed under Apache 2.0.
Instead, the image is subject to the **Red Hat Universal Base Image (UBI) 9 End User License Agreement (EULA)**. 
You can find the UBI EULA [here](https://www.redhat.com/en/about-red-hat-end-user-license-agreements#UBI).


> [!IMPORTANT]
> ### Licensing Considerations for RHEL Users
>
> If this project is built on a licensed Red Hat Enterprise Linux (RHEL) host, the build process may enable full RHEL repositories. 
> This can result in the installation of packages that are covered by the Red Hat Enterprise Linux Subscription Agreement. 
>
> #### Why This Matters:
> - **Running on non-RHEL Hosts**: If you install packages from full RHEL repositories during the build on a RHEL host, those packages may not be legally run on non-RHEL systems without a valid RHEL subscription.
> - **Avoid Licensing Violations**: Be cautious when adding packages. Ensure that you only install packages that are allowed under the UBI EULA if you intend to run the container on non-RHEL systems.

For more details on the implications of adding software to a UBI container, please refer to the official Red Hat documentation: 
[Add Software to a Running UBI Container](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html-single/building_running_and_managing_containers/index/#add_software_to_a_running_ubi_container).
#


podman inspect telicent-base:latest | jq '.[0].Size, .[0].RootFS.Layers'
cekit -v --descriptor base/telicent-base.yaml  build --overrides-file overrides.yaml podman --platform linux/amd64,linux/arm64

arm64 breaks builds cause packages dont support em


The GNU toolchain
GNU make
pthreads - glibc-devel
zlib-dev (optional, for gzip compression support) - microdnf install zlib-devel
libssl-dev (optional, for SSL and SASL SCRAM support) - microdnf remove openssl-devel
libsasl2-dev (optional, for SASL GSSAPI support) - microdnf install cyrus-sasl-devel
libzstd-dev (optional, for ZStd compression support) - mby centos repo ?
```
[root@c4f6890aef6a /]# rpm -qa libzstd
libzstd-1.5.1-2.el9.x86_64
[root@c4f6890aef6a /]# curl -fsSL https://rpmfind.net/linux/centos-stream/10-stream/AppStream/x86_64/os/Packages/libzstd-devel-1.5.1-2.el9.x86_64.rpm -o libzstd-devel-1.5.1-2.el9.x86_64.rpm
curl: (22) The requested URL returned error: 404
[root@c4f6890aef6a /]# curl -fsSL https://dl.rockylinux.org/pub/rocky/9/devel/x86_64/os/Packages/l/libzstd-devel-1.5.1-2.el9.x86_64.rpm -o libzstd-devel-1.5.1-2.el9.x86_64.rpm
[root@c4f6890aef6a /]# rpm -ivh ./libzstd-devel-1.5.1-2.el9.x86_64.rpm 
warning: ./libzstd-devel-1.5.1-2.el9.x86_64.rpm: Header V4 RSA/SHA256 Signature, key ID 350d275d: NOKEY
Verifying...                          ################################# [100%]
Preparing...                          ################################# [100%]
Updating / installing...
   1:libzstd-devel-1.5.1-2.el9        ################################# [100%]
[root@c4f6890aef6a /]# ls /usr/include/zstd.h
/usr/include/zstd.h
[root@c4f6890aef6a /]# 

```
libcurl-dev (optional, for SASL OAUTHBEARER OIDC support) - libcurl-devel
