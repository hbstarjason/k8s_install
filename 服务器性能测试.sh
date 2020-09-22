# superbench测试VPS服务器配置信息、IO性能、到国内节点的网速
wget https://raw.githubusercontent.com/oooldking/script/master/superbench.sh chmod +x superbench.sh &&  bash superbench.sh

# superspeed测试VPS服务器到国内节点的网速
wget https://raw.githubusercontent.com/oooldking/script/master/superspeed.sh chmod +x superspeed.sh && bash superspeed.sh 

# serverreview-benchmark测试VPS服务器配置信息、CPU/内存/硬盘性能、全球节点测速
yum install curl -y
curl -LsO https://raw.githubusercontent.com/sayem314/serverreview-benchmark/master/bench.sh chmod +x bench.sh && bash bench.sh -a share

# Best Trace可视化路由跟踪工具
wget http://down.xxorg.com/Tool/besttrace/besttrace chmod +x besttrace
./besttrace -q 1 目标IP

