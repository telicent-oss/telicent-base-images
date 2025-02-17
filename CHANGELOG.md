# Changelog

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
