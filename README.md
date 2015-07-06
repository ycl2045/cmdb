##README
1. IDCOS 环境目录/home/ap/idcos
2. 采集客户端脚本路径/home/ap/idcos/ocsinventory-agent
3. COPY lib 到 /home/ap/idcos/ocsinventory-agent
4. COPY cmd/ocsinventory-agent 到 /home/ap/idcos/bin
5. echo “PATH=$PATH:/home/ap/idcos/bin” >> .bash_profile   ---redhat
6. echo “export PATH” >>  .bash_profile
7. 运行 ocsinventory-agent --local=/tmp  ----生成json到本地/tmp下
8. ocsinventory-agent --server=http://localhost:8080   ---把json数据推送到mongo上；
