# nlsr-sample

[GitHub - hydrokhoos/nlsr-sample](https://github.com/hydrokhoos/nlsr-sample)

![nlsr-sample-topology.png](nlsr-sample%20340934284b8d429d90d50d48d67414e5/nlsr-sample-topology.png)

## 上の図のネットワークを作る

ディレクトリに移動する

```bash
cd nlsr-sample
```

Dockerコンテナを起動する

```bash
docker run -dit --name router1 --privileged -p 172.16.232.73:63631:6363/udp -v $(pwd):/src/ hydrokhoos/ndn-all:arm
docker run -dit --name router2 --privileged -p 172.16.232.73:63632:6363/udp -v $(pwd):/src/ hydrokhoos/ndn-all:arm
docker run -dit --name router3 --privileged -p 172.16.232.73:63633:6363/udp -v $(pwd):/src/ hydrokhoos/ndn-all:arm
docker run -dit --name router4 --privileged -p 172.16.232.73:63634:6363/udp -v $(pwd):/src/ hydrokhoos/ndn-all:arm
docker run -dit --name producer --privileged -p 172.16.232.73:63635:6363/udp -v $(pwd):/src/ hydrokhoos/ndn-all:arm
docker run -dit --name consumer --privileged -p 172.16.232.73:63636:6363/udp -v $(pwd):/src/ hydrokhoos/ndn-all:arm
```

各コンテナでNFDを起動する

```bash
docker exec -it router1 bash
nfd-start
exit
...
```

各コンテナで隣接ノードへのFaceを作成する

```bash
docker exec -it router1 bash
nfdc face create udp4://172.16.232.73:63632
nfdc face create udp4://172.16.232.73:63633
nfdc face create udp4://172.16.232.73:63635
exit
...
```

各コンテナでNLSRを起動する (別窓かデタッチ)

```bash
docker exec -it router1 bash
nlsr -f /src/nlsr-router1.conf
```

NLSRの状態の確認　routing tableができていればOK

```bash
docker exec -it router1 bash
nlsrc status
```

## ProducerからConsumerにコンテンツを配信する

提供するコンテンツ(sample.txt)を作成する

```bash
docker exec -it producer bash
echo "Hello, world!" > sample.txt
```

コンテンツ名(/sample.txt)を広告する

```bash
docker exec -it producer bash
nlsrc advertise sample.txt
```

作成したコンテンツを提供する

```bash
docker exec -it producer bash
ndnputchunks /sample.txt < sample.txt
```

コンテンツを要求する

```bash
docker exec -it consumer bash
ndncatchunks /sample.txt
```
