# yiluzhuanqian.com
# 

wget http://www.yiluzhuanqian.com/soft/docker_images/ylzq_v19.3.1.tar
docker load  --input ylzq_v19.3.1.tar
docker run --name=ylzq15.1.1 -d -e uid=87785 ylzq:v19.3.1
docker ps
