# Changelog

## Changes from v0.5.16 to v0.5.17

### Chores
- prepare release v0.5.16  ([d3e0035](https://github.com/telicent-oss/telicent-base-images/commit/d3e0035c58e1d217d394911e3e7efde63ed5b33d))

## Changes from v0.5.15 to v0.5.16

### Chores
- update base for descriptors  ([0a4da1c](https://github.com/telicent-oss/telicent-base-images/commit/0a4da1c832f8be07b8218dddcffa244774072d92))
### Others
- [Minor] Some CVEs need patching after base image move to Red Hat 9.7 (from 9.6) ([4262b48](https://github.com/telicent-oss/telicent-base-images/commit/4262b48f2d86f1c7f1040f9126309159eb2b60a6))

## Changes from v0.5.14 to v0.5.15

### Chores
- prepare release v0.5.14  ([164794e](https://github.com/telicent-oss/telicent-base-images/commit/164794e4e7e0fd28feba80458e128de6f81d6e2f))
### Others
- [Minor] Adding OS variants to existing CVEs ([2ce6891](https://github.com/telicent-oss/telicent-base-images/commit/2ce6891eb50b8d9e2f2629e6ea78cdecc0bf3dd9))

## Changes from v0.5.13 to v0.5.14

### Chores
- update base for descriptors  ([db918b0](https://github.com/telicent-oss/telicent-base-images/commit/db918b0a1d6e89e9683a1b4dfeb51877103e1c74))
### Others
- [Minor] Addressing CVE-2025-12863. Plus updating Grype script. ([db814aa](https://github.com/telicent-oss/telicent-base-images/commit/db814aa1d1cea3b0a5fdff306a6a865770a2c57d))
- [Minor] Extending CVE-2025-59375 to cover Mac OS. ([694b757](https://github.com/telicent-oss/telicent-base-images/commit/694b7579199fd43900d6e8ba4117c1b9ac621b7c))
- [Minor] CVE-2005-2541 & CVE-2024-10524 ([84d8426](https://github.com/telicent-oss/telicent-base-images/commit/84d8426d6c1f9b86a038ea52e8c9eb3790ceb5c0))
- [Minor] CVE-2025-53057 ([5993815](https://github.com/telicent-oss/telicent-base-images/commit/5993815c552e03fdad01dcfb19bd297f5647fd86))
- [CORE-1017] Adding Vex statement for CVE-2025-53066 and grype script for testing ([728262d](https://github.com/telicent-oss/telicent-base-images/commit/728262d6e50ce6fd05a16c4e000d1879792c4c1e))
- [CORE-1017] Adding Vex statement for CVE-2025-53066 and grype script for testing ([b7b2ff0](https://github.com/telicent-oss/telicent-base-images/commit/b7b2ff09fc64639d0da112e9e6c1013386b9ef63))

## Changes from v0.5.12 to v0.5.13

### Chores
- prepare release v0.5.12  ([4a2ffc5](https://github.com/telicent-oss/telicent-base-images/commit/4a2ffc5ab8723b990fb661f7a826a99fdf6701e2))

## Changes from v0.5.11 to v0.5.12

### Chores
- update base for descriptors  ([f246396](https://github.com/telicent-oss/telicent-base-images/commit/f24639601e05b84f5b12667fab8a3b6b3e5435da))
### Others
- [Minor] Properly propagate values and general script tidy up. ([5629aeb](https://github.com/telicent-oss/telicent-base-images/commit/5629aeb00b487c853794eb44cec37bfc3aa3cf9f))
- [Minor] Properly propagate values and general script tidy up. ([209c68f](https://github.com/telicent-oss/telicent-base-images/commit/209c68fd61832bd8657f750ea341d07d4e339736))

## Changes from v0.5.10 to v0.5.11

### Chores
- update base for descriptors  ([651359b](https://github.com/telicent-oss/telicent-base-images/commit/651359b52ff947ada2fdbf5f675a235bb839e52c))
### Fixes
- Added CVE-2025-59375 (#230)  ([3b08fce](https://github.com/telicent-oss/telicent-base-images/commit/3b08fcea617deaf031a80974e76751e9d8e04eb0))
### Others
- [CORE-938] Tweak output - ACTIVE is better than OK ([9d7686b](https://github.com/telicent-oss/telicent-base-images/commit/9d7686ba57fdfec0327d794e8d36fa3e3b7bdde9))
- [CORE-938] Adding suppression for CVE-2025-8941. By default, find the UBI-9 instance we are using and check that. ([6d2b600](https://github.com/telicent-oss/telicent-base-images/commit/6d2b600a4ba55f266cdb10410ed6a19c46215d98))
- [CORE-938] Adding suppression for CVE-2025-8941. Simplifying script to be easier to use and understand. ([85fec2c](https://github.com/telicent-oss/telicent-base-images/commit/85fec2ca8a20256e730b63862807a5c7641a9566))
- [CORE-938] Adding suppression for CVE-2025-8941. Removing accidental commit. ([8e20ef9](https://github.com/telicent-oss/telicent-base-images/commit/8e20ef9d38ffea9f56bb5cf914d3fb729c23ce50))
- Update .vex/CVE-2025-8941.openvex.json ([4fd439b](https://github.com/telicent-oss/telicent-base-images/commit/4fd439b59bd002821c7d78249c507108b347a54a))
- [CORE-939] Adding suppression for CVE-2025-8941 ([f6a3c40](https://github.com/telicent-oss/telicent-base-images/commit/f6a3c407205a054dd8d25acfe364cc72f97496cb))
- [CORE-938] Removing stale CVEs that are no longer applicable and added script to find them. ([2cf7259](https://github.com/telicent-oss/telicent-base-images/commit/2cf72592208f49ea5bdc54fb25d53d6f03b3019b))
- [CORE-938] Removing CVE-2025-4638 suppression as no longer necessary. ([f620e54](https://github.com/telicent-oss/telicent-base-images/commit/f620e54976067f598be2ea6e0891196de8b9ef15))

## Changes from v0.5.9 to v0.5.10

### Chores
- update base for descriptors  ([7a36d12](https://github.com/telicent-oss/telicent-base-images/commit/7a36d12434504eeedd5069f1cc379c74691ae429))
### Fixes
- Adding CVE-2025-5914 - (CORE-927). Covering other versions.  ([f33b6ee](https://github.com/telicent-oss/telicent-base-images/commit/f33b6eef211107a81b5bfaec9192a75b6c76c656))
- Adding CVE-2025-5914 - (CORE-927)  ([2350cc3](https://github.com/telicent-oss/telicent-base-images/commit/2350cc34fd23f2fc39c6b4adecaa62393a8254dd))

## Changes from v0.5.8 to v0.5.9

### Chores
- update base for descriptors  ([5d49ec5](https://github.com/telicent-oss/telicent-base-images/commit/5d49ec54a40285bbca6cfa02ecc9398c779600a2))

## Changes from v0.5.7 to v0.5.8

### Chores
- update base for descriptors  ([3467643](https://github.com/telicent-oss/telicent-base-images/commit/3467643e9630d8815febd576ae053eb0af43b548))
### Fixes
- Adding CVE-2025-7425 - extra variant.  ([22e9f0f](https://github.com/telicent-oss/telicent-base-images/commit/22e9f0f0aca0a0590d7ec7c9d76b207ef01c32f0))
- Adding CVE-2025-7425  ([6e120b5](https://github.com/telicent-oss/telicent-base-images/commit/6e120b53746d55e33746bed7946c4c966c889397))

## Changes from v0.5.6 to v0.5.7

### Chores
- update base for descriptors  ([88ff991](https://github.com/telicent-oss/telicent-base-images/commit/88ff9919c3a4dec9e879c68061159bfc0040c108))
### Fixes
- Adding CVE-2025-50106  ([6a096a2](https://github.com/telicent-oss/telicent-base-images/commit/6a096a2b1c45cffd73be179b4b4f2679bd6b7bab))
### Others
- Update CVE-2025-6965.openvex.json ([70ea8d1](https://github.com/telicent-oss/telicent-base-images/commit/70ea8d1bd3695cc8689841a85f1247c19f6eb39d))

## Changes from v0.5.5 to v0.5.6

### Chores
- Bump Java image version (CORE-889)  ([994d449](https://github.com/telicent-oss/telicent-base-images/commit/994d449daf2a056e9018a0586d979261c5f2efc9))
### Fixes
- Add VEX statements for CVE-2025-30749 & CVE-2025-50059  ([8727e63](https://github.com/telicent-oss/telicent-base-images/commit/8727e633e50041072dbdd0e7a2ffe4bba34daa24))
### Others
- Added impact statement ([522e941](https://github.com/telicent-oss/telicent-base-images/commit/522e941f33dcb9aed44db690ead8f4abc1f87856))
- Corrected author ([1e4d502](https://github.com/telicent-oss/telicent-base-images/commit/1e4d502cd96ddc244676eb4e1a47686a365b790e))

## Changes from v0.5.4 to v0.5.5

### Fixes
- updating Red Hat UBI-9 image  ([c7b9e8d](https://github.com/telicent-oss/telicent-base-images/commit/c7b9e8dd7dc98c4fcf44848da9a0518bbee67c7e))
- vex declarations for recent CVEs  ([da5b37e](https://github.com/telicent-oss/telicent-base-images/commit/da5b37e76afb09ab19b6fa0dbb82dc1c24169a13))
### Others
- remove space in file name ([9728298](https://github.com/telicent-oss/telicent-base-images/commit/97282984552db2ab6857cb56d8b86bcc83830284))

## Changes from v0.5.3 to v0.5.4

### Chores
- update base for descriptors  ([473b41a](https://github.com/telicent-oss/telicent-base-images/commit/473b41a5feb8193cd7e2d86e833a24cb14ad1809))

## Changes from v0.5.2 to v0.5.3

### Chores
- update base for descriptors  ([4abe878](https://github.com/telicent-oss/telicent-base-images/commit/4abe8787fd50561e0a9f5f2205efcd5f22502745))

## Changes from v0.5.1 to v0.5.2

### Chores
- update base for descriptors  ([c203e6f](https://github.com/telicent-oss/telicent-base-images/commit/c203e6fef059bf30e1edc10a4f84d0499440b4e1))
### Fixes
- Removing defunct v3.11 of Python as all relevant apps should be migrated to v3.12.  ([e0725c6](https://github.com/telicent-oss/telicent-base-images/commit/e0725c66fcf2cee2ed195d76b0d1ac9d2a37d1f7))
- vex declarations for recent Python CVEs  ([4b085e5](https://github.com/telicent-oss/telicent-base-images/commit/4b085e5223c31e49ae8daccb6a276b5a13d5f249))
- [CORE-858] disabling checks for apps we don't actively deploy to reduce the noise from alerts.  ([906da3f](https://github.com/telicent-oss/telicent-base-images/commit/906da3f72819388b40a5ad150d834b3e04a6d55c))
- [CORE-857] correcting recent CVEs raised against libxml2 and adding tooling to aid with suppression. PR Feedback  ([9ec927e](https://github.com/telicent-oss/telicent-base-images/commit/9ec927e7d5bd124a82f0e3f0cd81467aa9d60d1c))
- [CORE-857] correcting recent CVEs raised against libxml2 and adding tooling to aid with suppression.  ([d445fd2](https://github.com/telicent-oss/telicent-base-images/commit/d445fd25924db0543d0a9d5fa3edc3bc52ae59d1))

## Changes from v0.5.0 to v0.5.1

### Chores
- update base for descriptors  ([e075d07](https://github.com/telicent-oss/telicent-base-images/commit/e075d07bc15c037fe0d53e624d497629ca6ec20b))
### Fixes
- adding vex statement for CVE-2025-5702 (telicent-nodejs20 specific add)  ([032c52b](https://github.com/telicent-oss/telicent-base-images/commit/032c52b2bfa4efbc90f6f2b4c410aed685456be9))
- adding vex statement for CVE-2025-5702 (telicent-nginx1.27 specific add). Migrating to Telicent Grype scan.  ([2b834e1](https://github.com/telicent-oss/telicent-base-images/commit/2b834e13f2cf642899fb802ab20b4805fad2d8a5))

## Changes from v0.4.0 to v0.5.0

### Features
- dev scripts  ([49e659b](https://github.com/telicent-oss/telicent-base-images/commit/49e659b89ec48d284fa459008bc5ca8f43e487af))
### Chores
- update base for descriptors  ([94ee3a2](https://github.com/telicent-oss/telicent-base-images/commit/94ee3a229fcd1ae3352af682b3ed656861f0fb31))
- prepare release v0.4.0  ([dc39570](https://github.com/telicent-oss/telicent-base-images/commit/dc39570622344beb2971490b365ad696d6c2af3b))
### Fixes
- adding vex statement for CVE-2025-5702  ([c1980db](https://github.com/telicent-oss/telicent-base-images/commit/c1980db81848a51039a694bff87746f002400fd9))

## Changes from v0.3.13 to v0.4.0

### Features
- helper  ([499f9e2](https://github.com/telicent-oss/telicent-base-images/commit/499f9e2098d1804a156cebb0f67e68e9945884a8))
### Chores
- prepare release v0.4.0  ([9909107](https://github.com/telicent-oss/telicent-base-images/commit/990910754973a2b7b45a9a12831bbb3f38743e86))
### Fixes
- CVE-2025-4638 CVE-2025-4802  ([04b3eb6](https://github.com/telicent-oss/telicent-base-images/commit/04b3eb67c01b0ff455a5f234a3afbe2524aab050))
- adding vex statement for CVE-2025-4802 (adding x86_64 support)  ([f77a931](https://github.com/telicent-oss/telicent-base-images/commit/f77a9317ae6fe05b51437800f4b0f590c4945909))
- adding vex statement for CVE-2025-4802  ([5e9c78e](https://github.com/telicent-oss/telicent-base-images/commit/5e9c78e3a6ccd8a17fbf04707bb5cd5a7256c5b0))
- fixing vex statement for CVE-2025-4638  ([2334df1](https://github.com/telicent-oss/telicent-base-images/commit/2334df16693f90faf03faef13b5fac086e27c81b))
- adding vex statement for CVE-2025-4638  ([f2545cf](https://github.com/telicent-oss/telicent-base-images/commit/f2545cfea71e05959fd59d448ba2aa8d492ea816))
### Others
- fix(2025-06-04T14:20:20.357Z): rebuild for new node - https://nodejs.org/en/blog/vulnerability/may-2025-security-releases - https://access.redhat.com/errata/RHSA-2025:8468  ([cef2f34](https://github.com/telicent-oss/telicent-base-images/commit/cef2f3404ebe6722a6fce25f97aa5bbafcb0e961))
- bump grype action to 6.2.0 to resolve db cache issues (#183)  ([2d3aae9](https://github.com/telicent-oss/telicent-base-images/commit/2d3aae94605c146d845452a39a52eb9729da30db))

## Changes from v0.3.13 to v0.4.0

### Features
- helper  ([499f9e2](https://github.com/telicent-oss/telicent-base-images/commit/499f9e2098d1804a156cebb0f67e68e9945884a8))
### Fixes
- CVE-2025-4638 CVE-2025-4802  ([04b3eb6](https://github.com/telicent-oss/telicent-base-images/commit/04b3eb67c01b0ff455a5f234a3afbe2524aab050))
- adding vex statement for CVE-2025-4802 (adding x86_64 support)  ([f77a931](https://github.com/telicent-oss/telicent-base-images/commit/f77a9317ae6fe05b51437800f4b0f590c4945909))
- adding vex statement for CVE-2025-4802  ([5e9c78e](https://github.com/telicent-oss/telicent-base-images/commit/5e9c78e3a6ccd8a17fbf04707bb5cd5a7256c5b0))
- fixing vex statement for CVE-2025-4638  ([2334df1](https://github.com/telicent-oss/telicent-base-images/commit/2334df16693f90faf03faef13b5fac086e27c81b))
- adding vex statement for CVE-2025-4638  ([f2545cf](https://github.com/telicent-oss/telicent-base-images/commit/f2545cfea71e05959fd59d448ba2aa8d492ea816))
### Others
- fix(2025-06-04T14:20:20.357Z): rebuild for new node - https://nodejs.org/en/blog/vulnerability/may-2025-security-releases - https://access.redhat.com/errata/RHSA-2025:8468  ([cef2f34](https://github.com/telicent-oss/telicent-base-images/commit/cef2f3404ebe6722a6fce25f97aa5bbafcb0e961))
- bump grype action to 6.2.0 to resolve db cache issues (#183)  ([2d3aae9](https://github.com/telicent-oss/telicent-base-images/commit/2d3aae94605c146d845452a39a52eb9729da30db))

## Changes from v0.3.12 to v0.3.13

### Chores
- update base for descriptors  ([61bcd51](https://github.com/telicent-oss/telicent-base-images/commit/61bcd51e8016e75125a3e50286c9bab79e919ff1))
### Fixes
- Don't propagate TRIVY_VEX env  ([940466b](https://github.com/telicent-oss/telicent-base-images/commit/940466b972d940bf5174555c4740926e2a8ac2d4))

## Changes from v0.3.11 to v0.3.12

### Chores
- Fix build_resolver.sh image change detection  ([c804c6c](https://github.com/telicent-oss/telicent-base-images/commit/c804c6c4e307dd85c16b48aa41b3952924ac22aa))
- update base for descriptors  ([c06b407](https://github.com/telicent-oss/telicent-base-images/commit/c06b40745ace46ef62a0a62bb3d7dcebcb14b640))
- update base for descriptors  ([ab789ff](https://github.com/telicent-oss/telicent-base-images/commit/ab789ffbf1e596165d0a00c2bd7d8dedab3e8d0e))
### Fixes
- Keep tar/gzip in Java base images, in-line with Python images. (CORE-802)  ([de4273e](https://github.com/telicent-oss/telicent-base-images/commit/de4273ecc39345db61095d5c5e4e835e34e152cb))
- correcting some typos in the README  ([7d996ed](https://github.com/telicent-oss/telicent-base-images/commit/7d996edeb5bb7645075e8996babc6601ad038cf9))
### Others
- Update reusable-image-builder.yaml ([2ae2a47](https://github.com/telicent-oss/telicent-base-images/commit/2ae2a47a7b1aad30aaef77131d06f59104133ec0))

## Changes from v0.3.10 to v0.3.11

### Chores
- update base for descriptors  ([0cc9b3b](https://github.com/telicent-oss/telicent-base-images/commit/0cc9b3b575bee1528fbcb59a934f7eebcbd362c1))
- Fix notification images  ([5f34ba1](https://github.com/telicent-oss/telicent-base-images/commit/5f34ba18b160ca03ce0842bbc98bbacd41957a51))
### Others
- Revert "chore: Fix notification images" ([2d6d09a](https://github.com/telicent-oss/telicent-base-images/commit/2d6d09ae2094f7ac8dae2237339c103866893497))
- Set USES_JAVA flag on Periodic CVE scans ([ab6771c](https://github.com/telicent-oss/telicent-base-images/commit/ab6771c5e935a9b69eb50b228a2ecc33c2f17a37))

## Changes from v0.3.9 to v0.3.10

### Fixes
- Revert removal of krb5-libs (CORE-774)  ([56e1be7](https://github.com/telicent-oss/telicent-base-images/commit/56e1be7c14f2492829996b44d66270b7c273dc74))
### Others
- Ignore CVE-2022-37967 (CORE-774) ([137233b](https://github.com/telicent-oss/telicent-base-images/commit/137233b71cb78543077eae683b1d64e494e96c4d))

## Changes from v0.3.8 to v0.3.9

### Chores
- Update README re: conventional commits  ([a2ca838](https://github.com/telicent-oss/telicent-base-images/commit/a2ca8382af0f8c13dde51e5a15c5bc1afffd172f))
### Fixes
- Apply krb5-libs removal to all images (CORE-774)  ([5788d58](https://github.com/telicent-oss/telicent-base-images/commit/5788d580ea9636b9602390b3698369684d7cda41))
- Skip release prep steps if no changes to release (CORE-774)  ([bc5dbfb](https://github.com/telicent-oss/telicent-base-images/commit/bc5dbfb3c39dc24769ce4c5fa0f637454ada7754))
### Others
- Remove krb5-libs to resolve CVE-2022-37967 (CORE-744) ([d7b8958](https://github.com/telicent-oss/telicent-base-images/commit/d7b8958240891eb291003480f0fc6308e83a9901))

## Changes from v0.3.7 to v0.3.8

### Chores
- update base for descriptors  ([77903b4](https://github.com/telicent-oss/telicent-base-images/commit/77903b4bf16e124236c9d11416dc3ef8d83f31d0))
### Fixes
- disabling (for time being) images that are not in active development or use, thus unlikely to be fixed.  ([54533b8](https://github.com/telicent-oss/telicent-base-images/commit/54533b87dd1ed6dbd515c964f0491efc30349b09))
- Updating script so as not to write log messages to the file we are updating.  ([c1ef1ab](https://github.com/telicent-oss/telicent-base-images/commit/c1ef1abda515c147b8d44a2bce3d054ee91d7536))
### Others
- adding check of existing published Java Images.  Plus some task & job name tidy-up.  ([d549656](https://github.com/telicent-oss/telicent-base-images/commit/d549656eb61d9d327723503916aa8e0eba7253b4))

## Changes from v0.3.6 to v0.3.7

### Fixes
- pull red hat images from docker hub rather than from red hat registry. Update workflow to use alternate source & script for image  ([34bb89a](https://github.com/telicent-oss/telicent-base-images/commit/34bb89ad985aa950ddc965cd9333ef22dc1553df))
- pull red hat images from docker hub rather than from red hat registry.  ([2f7d970](https://github.com/telicent-oss/telicent-base-images/commit/2f7d970cc4e2552dd87856c22e943fd9d7fcd99f))

## Changes from v0.3.5 to v0.3.6

### Fixes
- updating Red Hat UBI-9 image.  ([e2d85fc](https://github.com/telicent-oss/telicent-base-images/commit/e2d85fc5a27e1c41ed2c435781aa4fc9cb572fe8))

## Changes from v0.3.4 to v0.3.5

### Fixes
- cleanup gcc more aggressively (#144)  ([4a605a8](https://github.com/telicent-oss/telicent-base-images/commit/4a605a8e85803f0689111d214827526affe58349))

## Changes from v0.3.3 to v0.3.4

### Fixes
- reduce software footprint after compilation (#142)  ([013a644](https://github.com/telicent-oss/telicent-base-images/commit/013a644446efac88ca4abe56a5e852df8327ac46))

## Changes from v0.3.2 to v0.3.3

### Fixes
- support old version of pid location alongside newer one (#140)  ([e1e7ece](https://github.com/telicent-oss/telicent-base-images/commit/e1e7ecea4df2047ddd3a38f85f9a8d95685fc318))

## Changes from v0.3.1 to v0.3.2

### Fixes
- remove redundant gcc cleanup module from nginx package install (#138)  ([2749deb](https://github.com/telicent-oss/telicent-base-images/commit/2749deb16bac7675836f2a4b8ad27c43769eccbc))

## Changes from v0.3.0 to v0.3.1

### Fixes
- remove redundant symlink creation (#136)  ([cf4bf9c](https://github.com/telicent-oss/telicent-base-images/commit/cf4bf9c89559cde63e3a22d758f4fc3e6fa46698))

## Changes from v0.2.15 to v0.3.0

### Features
- attempt nginx 1.24 from redhat package source (#134)  ([9a4701c](https://github.com/telicent-oss/telicent-base-images/commit/9a4701cecde2409ce6e5898b6a260e51e0789c2a))

## Changes from v0.2.14 to v0.2.15

### Fixes
- correct nodever in nodejs module (#133)  ([58d4a43](https://github.com/telicent-oss/telicent-base-images/commit/58d4a43f131c021a29f8eb49d8b1d9e17c5f51d0))
- trigger install of latest nodejs 20 to resolve CVE-2025-22150 and CVE-2025-23085  ([a5cb515](https://github.com/telicent-oss/telicent-base-images/commit/a5cb5153c7241e6db5a3716ecd43f38bffd8403d))

## Changes from v0.2.13 to v0.2.14

### Fixes
- teams notification sends success message on failure  ([12adc65](https://github.com/telicent-oss/telicent-base-images/commit/12adc6531f2ecf4d8e31b2eb19c06e0e31380226))
- address cves from setuptools  ([9e4318b](https://github.com/telicent-oss/telicent-base-images/commit/9e4318bd359239c034a5d511ce13c0b0e7f23676))

## Changes from v0.2.12 to v0.2.13

### Chores
- update base for descriptors (#128)  ([98d60c0](https://github.com/telicent-oss/telicent-base-images/commit/98d60c009f22f217b5fa3a73bc4b9ad2b09dc290))

## Changes from v0.2.11 to v0.2.12

### Fixes
- upgrade setuptools in older python  ([0322827](https://github.com/telicent-oss/telicent-base-images/commit/0322827f537985e16071f23e4dca0e6a77d17e44))

## Changes from v0.2.10 to v0.2.11

### Chores
- update base for descriptors (#125)  ([f81f654](https://github.com/telicent-oss/telicent-base-images/commit/f81f654e0abea4a75eaea52d29c10491ce560e52))
- change commit message from bots  ([fdf7f33](https://github.com/telicent-oss/telicent-base-images/commit/fdf7f3321d6e857d0af9a7efcb54c5228a20a86d))
- update descriptors (#123)  ([766d332](https://github.com/telicent-oss/telicent-base-images/commit/766d33234f56ea25cb3dc2424a71b3cca283bb00))
### Others
- Revert "chore: update descriptors (#123)" (#124) ([52122d2](https://github.com/telicent-oss/telicent-base-images/commit/52122d21a17998567e327776c070a731b44178e0))

## Changes from v0.2.9 to v0.2.10

### Chores
- manual version bump  ([1336f50](https://github.com/telicent-oss/telicent-base-images/commit/1336f50d651c0bf4e3b6fbc30a9bdbe3db35e2d4))
- allow builds to pass when cve has no fixes  ([75a3c0b](https://github.com/telicent-oss/telicent-base-images/commit/75a3c0b2980d10cc5118c474ec9d8e59c08d9766))
- allow builds to pass when cve has no fixes  ([fe1a7f3](https://github.com/telicent-oss/telicent-base-images/commit/fe1a7f3c028002deaaabe83e948861e21339e086))
### Fixes
- make sure teams notification is sent  ([3d56070](https://github.com/telicent-oss/telicent-base-images/commit/3d56070d9799a083d5c17afb24459670a6135d77))

## Changes from v0.2.8 to v0.2.9

### Fixes
- fixes around cve-2022-49043  ([0f0fdbc](https://github.com/telicent-oss/telicent-base-images/commit/0f0fdbc06b94a30b3d5fcb421bf97459c19e363e))

## Changes from v0.2.7 to v0.2.8

### Chores
- update descriptors (#118)  ([3646c85](https://github.com/telicent-oss/telicent-base-images/commit/3646c854541d2d0febc26a7515db5b8ebe63db72))
### Fixes
- release workflow not triggering when new base is detected  ([6649e5c](https://github.com/telicent-oss/telicent-base-images/commit/6649e5c7489c1c95d0e6b4b67ecc9d5c7a3b12fc))

## Changes from v0.2.6 to v0.2.7

### Chores
- provide sample usage examples  ([5e9546b](https://github.com/telicent-oss/telicent-base-images/commit/5e9546b0da5e5ef224813d621cdeda03137bca0d))
### Fixes
- do not trigger release if changes do not affect images directly  ([d97f7bc](https://github.com/telicent-oss/telicent-base-images/commit/d97f7bcef678c819b7ff7eec3e707241a0d0caff))

## Changes from v0.2.5 to v0.2.6

### Fixes
- teams reporting  ([8943c43](https://github.com/telicent-oss/telicent-base-images/commit/8943c43b6fc2c6b44d280ee0ce12c54e0b55f1cc))

## Changes from v0.2.4 to v0.2.5

### Fixes
- invalid yaml fixed formatting  ([dae0922](https://github.com/telicent-oss/telicent-base-images/commit/dae09228e2b74def3c95fbb7816b057b375562de))

## Changes from v0.2.3 to v0.2.4

### Chores
- typo in workflow  ([338c8e0](https://github.com/telicent-oss/telicent-base-images/commit/338c8e0fabc5d33fa6512c16217adb81bef3726c))
- update descriptors (#114)  ([14effe5](https://github.com/telicent-oss/telicent-base-images/commit/14effe5c1b3149eebfefb702f657571545667643))
- rename files (#111)  ([fce7fc7](https://github.com/telicent-oss/telicent-base-images/commit/fce7fc7324b8ab993aee2e10f6211601ef4d5bc2))
### Fixes
- prep python images for k8s fixed issues around perms (#113)  ([3225ff5](https://github.com/telicent-oss/telicent-base-images/commit/3225ff5e4b36d2839511314fd2aa859ca7735456))

## Changes from v0.2.3 to v0.2.3

### Chores
- introduce reporting to image builds  ([9187934](https://github.com/telicent-oss/telicent-base-images/commit/918793449abc8ae6da9a2274ad1a301ce1741ef7))
- typo in filename  ([27dbf3d](https://github.com/telicent-oss/telicent-base-images/commit/27dbf3df7aa9ee92375ac554fb0e35dc2b6cac14))
- better workflow reporting in teams  ([b22663e](https://github.com/telicent-oss/telicent-base-images/commit/b22663ecdeef903a0f40e7506184c92c5aa7c7f5))
- add background to the notification  ([4072073](https://github.com/telicent-oss/telicent-base-images/commit/40720733e6992dd8a3a59bd44e324c9b68ef695b))
### Fixes
- resolve issues around json payload in teams notification  ([983dd1d](https://github.com/telicent-oss/telicent-base-images/commit/983dd1dd970b7f6416ebcb6792eb3a0477118930))
- issues around parsing in tag version  ([8fceb4e](https://github.com/telicent-oss/telicent-base-images/commit/8fceb4ef65d7c671e45384cb8ecc7ad8f294a7c2))

## Changes from v0.2.3 to v0.2.3

### Chores
- add background to the notification  ([4072073](https://github.com/telicent-oss/telicent-base-images/commit/40720733e6992dd8a3a59bd44e324c9b68ef695b))
### Fixes
- issues around parsing in tag version  ([8fceb4e](https://github.com/telicent-oss/telicent-base-images/commit/8fceb4ef65d7c671e45384cb8ecc7ad8f294a7c2))

## Changes from v0.2.2 to v0.2.3

### Chores
- update descriptors (#107)  ([e0ef7df](https://github.com/telicent-oss/telicent-base-images/commit/e0ef7df3366249318179d1cf76437fc2650c420f))
### Fixes
- use different name for base images updater  ([84f5934](https://github.com/telicent-oss/telicent-base-images/commit/84f59341325796b8f82392acd1b09c220391ff8e))

## Changes from v0.2.1 to v0.2.2

### Fixes
- do not fail workflow wehn to images to build  ([acb5fac](https://github.com/telicent-oss/telicent-base-images/commit/acb5facaef8b316a0056f0df4d7de54404f97275))

## Changes from v0.2.0 to v0.2.1

### Chores
- add periodic scans for published images  ([35a5fd4](https://github.com/telicent-oss/telicent-base-images/commit/35a5fd4dceea7f7d5290538d070486f16a13c682))
### Fixes
- artifacts naming  ([72bb3de](https://github.com/telicent-oss/telicent-base-images/commit/72bb3dece1eccf8fc3a6831f5bc4b55cee5ea3a3))
- artifacts naming  ([dbc97b1](https://github.com/telicent-oss/telicent-base-images/commit/dbc97b1662a522847444a99288da4f3d0a19b4b0))
- artifacts naming  ([5492ba4](https://github.com/telicent-oss/telicent-base-images/commit/5492ba4d658618b0037dbf48eb60b882005fec57))
- inherit secrets  ([0dc7349](https://github.com/telicent-oss/telicent-base-images/commit/0dc73496679ba5f0d41f91b39dcd035b74fa2d8d))
- periodic scans wrong arg  ([97a12ad](https://github.com/telicent-oss/telicent-base-images/commit/97a12ad999f051db84d87f9acb340ba3c4d73ce2))
- periodic scans need two matrix jobs  ([1df7870](https://github.com/telicent-oss/telicent-base-images/commit/1df78703516627c5a6618a0aff49464a3ed8498c))

## Changes from v0.1.0 to v0.2.0

### Features
- auto updater workflow stable images  ([3c30eeb](https://github.com/telicent-oss/telicent-base-images/commit/3c30eeb8489dd81e597b985522a68e9594152a98))
- cicd automated releases  ([e1092a4](https://github.com/telicent-oss/telicent-base-images/commit/e1092a48c11af5b7884c330d0fb45dedf3c8abe5))
- trigger build from release  ([06aaaf0](https://github.com/telicent-oss/telicent-base-images/commit/06aaaf07fdc0f1d36cf705ff367bde7f1ffe523d))
- trigger build from release  ([62051b4](https://github.com/telicent-oss/telicent-base-images/commit/62051b459834777e548693c46b11471a420f8baa))
### Chores
- lowercase commit title  ([5fc2a21](https://github.com/telicent-oss/telicent-base-images/commit/5fc2a21dcd227d999692dab7dc2e373db6c0541e))
- update descriptors (#104)  ([4ce08af](https://github.com/telicent-oss/telicent-base-images/commit/4ce08af5457eb53614caf4f4e6342ae21c429d33))
- rename bot  ([cfd10ff](https://github.com/telicent-oss/telicent-base-images/commit/cfd10ffa2ba0f27c09dd098b1d80057782a8f3ba))
- update descriptors (#102)  ([47884d9](https://github.com/telicent-oss/telicent-base-images/commit/47884d9b8088d0bcec1ab6cf35889b7d8cce789a))
- refactor  ([c84896d](https://github.com/telicent-oss/telicent-base-images/commit/c84896deb5aba5d5234478d1320720d0e02c8171))
- yq should be availabe on gh runners  ([dc5437e](https://github.com/telicent-oss/telicent-base-images/commit/dc5437ebe28b96779f45268abe037815f42da0c9))
- cleanup  ([c83a754](https://github.com/telicent-oss/telicent-base-images/commit/c83a7542a12479062a4f45e4f271b21fddc80f03))
- remove dependabot as it is not suitable for this project  ([bd4b7a4](https://github.com/telicent-oss/telicent-base-images/commit/bd4b7a42fba3f3b82498b3b2f726293f5a4b186e))
### Fixes
- issues with build resolver  ([3b92ebc](https://github.com/telicent-oss/telicent-base-images/commit/3b92ebc4a5ac44918d64e31ec0eec434af15dc31))
- cves  ([5e471df](https://github.com/telicent-oss/telicent-base-images/commit/5e471df0e4bcdce40323ea33104b841619ccbe9c))
- cves  ([7d8a647](https://github.com/telicent-oss/telicent-base-images/commit/7d8a6476158f3fd34fc25d3eebfcfdec1419b4bc))
- cves  ([14c01e2](https://github.com/telicent-oss/telicent-base-images/commit/14c01e2732a6f18134d8d3d1ef6541d6dde24e22))
- bild resolver logic fixes  ([9550072](https://github.com/telicent-oss/telicent-base-images/commit/95500722af80e8b79c000efb9aa478788b49b925))
- detect changes narrow comparison range  ([738678e](https://github.com/telicent-oss/telicent-base-images/commit/738678e3e7ebbb3c92f6b7d558dd52b23b059809))
- detect changes narrow comparison range  ([c5e0323](https://github.com/telicent-oss/telicent-base-images/commit/c5e03230e3dcba5609100e4aff3cd89f8f8597c1))
- detect changes do not pick second last tag for comparison  ([510ef0d](https://github.com/telicent-oss/telicent-base-images/commit/510ef0d4d8055d82d924e7ae3267e1b17ff63959))
- update path in image builder change check logic  ([ff56686](https://github.com/telicent-oss/telicent-base-images/commit/ff5668667a371dd621ea0e543ebcf27b2301691c))
- update path in image builder  ([d1cf7ce](https://github.com/telicent-oss/telicent-base-images/commit/d1cf7ce1dad73e58668166f9c2203fd76df8c6e3))
- update path in image builder script  ([4d14964](https://github.com/telicent-oss/telicent-base-images/commit/4d1496438151e8c44afc04b871cbcfffb66804e3))
- update path in image builder script  ([4ee7742](https://github.com/telicent-oss/telicent-base-images/commit/4ee7742adf7adfe79f174c7f7897d41411750c14))
- update path in image builder script  ([292ecac](https://github.com/telicent-oss/telicent-base-images/commit/292ecac1d62b7e420bfd4795af55c309188d558c))
- update path in image builder script  ([6475130](https://github.com/telicent-oss/telicent-base-images/commit/6475130872da7e50b7f20c9612804a9df53d88b3))
- update path in image builder script  ([110ad74](https://github.com/telicent-oss/telicent-base-images/commit/110ad74b41da247f626bf988414151a01d797b5f))
- artifact fetch logic  ([e103286](https://github.com/telicent-oss/telicent-base-images/commit/e1032862c8902fafa863dfa081c0c062844be5fd))
- graphql  ([ea8fcc8](https://github.com/telicent-oss/telicent-base-images/commit/ea8fcc859c32388bee78801c41fc0b708d007129))
- graphql  ([219d280](https://github.com/telicent-oss/telicent-base-images/commit/219d28051b6e65969b721db1840eac467eda8973))
- handle pr logic improvements v2  ([2f1af95](https://github.com/telicent-oss/telicent-base-images/commit/2f1af95eaa0bc9066254721302bb2311780a95cb))
- handle pr logic improvements  ([2825855](https://github.com/telicent-oss/telicent-base-images/commit/2825855f9de467be47d8c9821722444c9d77f18d))
- misc fixes around builds bot user details  ([7e2aa76](https://github.com/telicent-oss/telicent-base-images/commit/7e2aa76f6a90873692e76926599a0a476255a1ff))
- misc fixes around builds bot user details  ([4336dde](https://github.com/telicent-oss/telicent-base-images/commit/4336ddefc74c25e9091f86426bf5fc15df519d44))
- misc fixes around builds bot user details  ([a96f715](https://github.com/telicent-oss/telicent-base-images/commit/a96f7151c654b6fa9168669800928f650f939ef8))
- misc fixes around builds bot user details  ([c536e13](https://github.com/telicent-oss/telicent-base-images/commit/c536e1318ea7c3475faa76ec3568819139995f05))
- misc fixes around builds bot user details  ([b76e597](https://github.com/telicent-oss/telicent-base-images/commit/b76e597b5e5ef6259bdbe7dc18bc52cdf2911f57))
- misc fixes around builds bot user details  ([9c77996](https://github.com/telicent-oss/telicent-base-images/commit/9c77996da2d5776393d2b290d74935c78c7ede12))
- misc fixes around builds bot user details  ([11e7f4b](https://github.com/telicent-oss/telicent-base-images/commit/11e7f4b42bfe245379ae68d7a39b82adf68c026a))
- misc fixes around builds subsequent workflows  ([ccea9c8](https://github.com/telicent-oss/telicent-base-images/commit/ccea9c85b92de8faf72e32e03caef4900fd633f1))
- misc fixes around builds subsequent workflows  ([22439ff](https://github.com/telicent-oss/telicent-base-images/commit/22439fffb2fca80fc56184957979f6aa6a8c8ca1))
- misc fixes around builds  ([6be5700](https://github.com/telicent-oss/telicent-base-images/commit/6be5700294402473f48fe06cabc19e907f5a10a4))
- misc fixes around builds  ([3bda786](https://github.com/telicent-oss/telicent-base-images/commit/3bda786cbf385f70ee268191ad1dd54c39964a1b))
- build image trigger  ([ee3a3fd](https://github.com/telicent-oss/telicent-base-images/commit/ee3a3fd482d5661308f0ae0d7b1ab057f2ae7465))
### Others
- Revert "chore: update descriptors (#102)" (#103) ([6134906](https://github.com/telicent-oss/telicent-base-images/commit/6134906e9fa6a7076724a8bf1af22dfe2348274b))
- whitespace chage on tzdata module ([686f03a](https://github.com/telicent-oss/telicent-base-images/commit/686f03aaa5a01ef45f51eaf611a1d6424ac94261))

### Features
- Initial development of telicent base images (#1)  ([f602ae5](https://github.com/telicent-oss/telicent-base-images/commit/f602ae557cdc3008f1b7f3e89a4dec4c9057331e))
