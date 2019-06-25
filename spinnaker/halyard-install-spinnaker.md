```bash
############# 安装halyard

# https://www.spinnaker.io/setup/install/halyard/
$ curl -O https://raw.githubusercontent.com/spinnaker/halyard/master/install/debian/InstallHalyard.sh
$ useradd -m spinnaker

# usermod -aG sudo spinnaker 
# su - spinnaker

$ curl -sL https://packages.microsoft.com/keys/microsoft.asc | \
    gpg --dearmor | \
    sudo tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null

$ sudo bash InstallHalyard.sh
Please supply a non-root user to run Halyard as: spinnaker

$ hal -v 
1.21.0-20190619202809

############# 配置redis存储
# apt install redis-server
$ hal config storage edit --type redis

############# 配置cloudprovider
$ hal config provider docker-registry enable

# 集成harbor
$ hal config provider docker-registry account add harbor \
--address http://15.114.100.72 \
--repositories library/redis --username admin --password

# 集成docker hub
$ hal config provider docker-registry account add my-docker-registry \
--address index.docker.io \
--repositories library/redis \
--username hbstarjason \
--password
Your docker registry password: XXX

############# 集成jenkins
$ hal config ci jenkins enable
$ hal config ci jenkins master add my-jenkins-master \
--address http://15.114.100.64:8080/jenkins --username admin \
--password
The password of the jenkins user to authenticate as.: XXXX

############# 配置邮件提醒(可选)

############## 集成kubernetes
$ kubectl config view
$ kubectl config get-contexts

ns.json
{
  "kind": "Namespace",
  "apiVersion": "v1",
  "metadata": {
    "name": "spinnaker",
    "labels": {
      "name": "spinnaker"
    }
  }
}
$ kubectl create -f ns.json
namespace "spinnaker" created


$ hal config provider kubernetes enable
$ hal config provider kubernetes account add k8s-account \
     --provider-version v2 \
     --context $(kubectl config current-context)
     
##### hal config provider kubernetes account add my-k8s-account --docker-registries my-docker-registry,harbor



$ hal config deploy edit --type=distributed --account-name k8s-account


### sudo hal config deploy edit --type localdebian

$ hal version list
$ hal config version edit --version 1.12.13
$ sudo hal deploy apply


# https://blog.spinnaker.io/exposing-spinnaker-to-end-users-4808bc936698
# 部署完成后，默认只能本机访问，改为从外网能直接访问
$ echo "host: 0.0.0.0" | tee \
~/.hal/default/service-settings/gate.yml \
~/.hal/default/service-settings/deck.yml
$ hal config security ui edit --override-base-url http://x.x.x.x:9000
$ hal config security api edit --override-base-url http://x.x.x.x:8084
$ sudo hal deploy apply


# 日志文件目录为/var/log/spinnaker



$ kubectl exec spin-halyard  -n spinnaker -it -- bash -il


$ hal version bom 1.12.5
+ Get BOM for 1.12.5
  Success
version: 1.12.5
timestamp: '2019-03-08 23:26:14'
services:
  echo:
    version: 2.3.1-20190214121429
    commit: 5db9d437ca7f2fa374dcada17f77bbbb2965bd67
  clouddriver:
    version: 4.3.5-20190307172446
    commit: f87eb66fd55cd4df7497ef22528a11709745075d
  deck:
    version: 2.7.5-20190308182538
    commit: e9b899d63cb6ea15dc2d6c99a810c8b48886c6a5
  fiat:
    version: 1.3.2-20190128153726
    commit: daf21b24330a5f22866601559aa0f7ac99590274
  front50:
    version: 0.15.2-20190222161456
    commit: 3105e86b8c084ad6ad78507e3a5e5a427f290b99
  gate:
    version: 1.5.2-20190301030607
    commit: b238ab993ab25381ce907260879548ed74a4953f
  igor:
    version: 1.1.1-20190213190226
    commit: 63d06a5c5d55f07443dd60a81035b35cf96238e7
  kayenta:
    version: 0.6.1-20190221030610
    commit: 81d906bf8307143f40fe88f8554baa318de25ef1
  orca:
    version: 2.4.0-20190308182538
    commit: 5e911ff1c29bbc443ce48bcaefbc45f27d389edd
  rosco:
    version: 0.9.0-20190123170846
    commit: 42f81a2501de6d40676d47661579a6106b5c3e8a
  defaultArtifact: {}
  monitoring-third-party:
    version: 0.11.2-20190222030609
    commit: 232c84a8a87cecbc17f157dd180643a8b2e6067a
  monitoring-daemon:
    version: 0.11.2-20190222030609
    commit: 232c84a8a87cecbc17f157dd180643a8b2e6067a
dependencies:
  redis:
    version: 2:2.8.4-2
  consul:
    version: 0.7.5
  vault:
    version: 0.7.0
artifactSources:
  debianRepository: https://dl.bintray.com/spinnaker-releases/debians
  dockerRegistry: gcr.io/spinnaker-marketplace
  googleImageProject: marketplace-spinnaker-release
  gitPrefix: https://github.com/spinnaker
```

