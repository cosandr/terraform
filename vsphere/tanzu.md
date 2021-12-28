# VMWare Tanzu

### HAProxy

Management network (VLAN 100) "DSwitch MGMT"
Workload network (VLAN 30) "DSwitch KUBE"

Host Name = haproxy.hlab.no
DNS = 10.0.100.1,1.1.1.1,1.0.0.1
Load balancer IP: 10.0.100.252/24
Management gateway: 10.0.100.253
Workload IP = 10.0.30.252/24
Workload Gateway = 10.0.30.253
Load Balancer IP Ranges = 10.0.30.0/25
Virtual IP Range = 10.0.30.208/28

### Workload Managenment

Load Balancer: HAProxy
Data Plane API: 10.0.100.252:5556
Virtual Server IP Ranges: 10.0.30.208-10.0.30.222
TLS from VM: Settings > VM Options > Advanced > Edit Configuration > guestinfo.dataplaneapi.cacert
Decode with `base64 -d`

ntp server: 0.pool.ntp.org,1.pool.ntp.org

workload port group: DSwtich KUBE
workload gw: 10.0.30.253
workload netmask: 255.255.255.0

workload l3
range: 10.0.30.100-10.0.30.200
gw: 10.0.30.253
dns: 10.0.30.1,1.1.1.1
ntp server: 0.pool.ntp.org,1.pool.ntp.org
