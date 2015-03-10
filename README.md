# openstack部署
OpenStack FlatDHCP模式部署自动化脚本
# 两种部署模式
- 内部网络模式：VM的网络为内部网络，网关指向宿主机上的br100网桥，由OpenStack作NAT映射访问外网；
- 物理网络模式：VM的网络为物理网络，网关指向物理网关，不需要OpenStack作NAT映射；
