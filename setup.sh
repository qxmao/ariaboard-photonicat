#!/bin/bash
sed -i 's/SerialDevice=\/dev\/ttyS0/SerialDevice=\/dev\/ttyS4/g' /etc/pcat-manager.conf
/etc/init.d/pcat-manager restart
echo "#!/bin/bash" >/root/at.sh
echo "minicom -b 115200 -D /dev/ttyUSB2" >/root/at.sh
chmod +x /root/at.sh
echo "#!/bin/bash" >/root/zz-setup.sh
echo "curl https://public.zhangzhe-tech.cn/pcat/setup-script/firmware.sh | bash" >/root/zz-setup.sh
chmod +x /root/zz-setup.sh
echo '查询网络信息;AT+QNWINFO
查询载波聚合参数;AT+QCAINFO
查询信号强度和信道误码率;AT+CSQ
查询服务小区信息;AT+QENG="servingcell"
查询邻区信息;AT+QENG="neighbourcell"
启用命令回显;ATE1
禁用命令回显;ATE0
模块温度;AT+QTEMP
重启Modem;AT+CFUN=1,1
mode_pref check;AT+QNWPREFCFG="mode_pref"
mode_pref AUTO;AT+QNWPREFCFG="mode_pref",AUTO
mode_pref LTE;AT+QNWPREFCFG="mode_pref",LTE
mode_pref NR5G;AT+QNWPREFCFG="mode_pref",NR5G
mode_pref NR5GSA;AT+QNWPREFCFG="mode_pref",NR5G-SA
mode_pref NR5G_LTE;AT+QNWPREFCFG="mode_pref",NR5G:LTE
mode_pref LTE_NR5G;AT+QNWPREFCFG="mode_pref",LTE:NR5G
mode_pref NR5GSA_LTE;AT+QNWPREFCFG="mode_pref",NR5G-SA:LTE
mode_pref LTE_NR5GSA;AT+QNWPREFCFG="mode_pref",LTE:NR5G-SA
Get Info "ATI";ATI' >/etc/atcommands.user
echo 'ip6tables -t nat -A POSTROUTING -o eth0 -m comment --comment "v6NATwan6" -j MASQUERADE' >>/etc/firewall.user
echo 'ip6tables -t nat -A POSTROUTING -o usb0 -m comment --comment "v6NATwwan6" -j MASQUERADE' >>/etc/firewall.user

uci set firewall.guestforwardingwan=forwarding
uci set firewall.guestforwardingwan.src='guest'
uci set firewall.guestforwardingwan.dest='wan'
uci set firewall.guestzone=zone
uci set firewall.guestzone.name='guest'
uci set firewall.guestzone.input='ACCEPT'
uci set firewall.guestzone.output='ACCEPT'
uci set firewall.guestzone.forward='ACCEPT'
uci set firewall.guesttolanrule=rule
uci set firewall.guesttolanrule.name='Reject Guest To LAN'
uci add_list firewall.guesttolanrule.proto='all'
uci set firewall.guesttolanrule.src='guest'
uci set firewall.guesttolanrule.dest='lan'
uci set firewall.guesttolanrule.target='REJECT'
uci set network.brguest=device
uci set network.brguest.type='bridge'
uci set network.brguest.name='br-guest'
uci set network.guest=interface
uci set network.guest.proto='static'
uci set network.guest.ipaddr='100.99.255.1'
uci set network.guest.netmask='255.255.255.0'
uci add_list firewall.guestzone.network='guest'
uci set network.guest.device='br-guest'
uci set network.wwan=interface
uci set network.wwan.proto='ncm'
uci set network.wwan.device='/dev/ttyUSB3'
uci set network.wwan.pdptype='IPV4V6'
uci set network.wwan.apn='3gnet'
uci set network.wwan.ipv6='auto'
uci add_list firewall.@zone[1].network='wwan'
uci set network.rndis=interface
uci set network.rndis.proto='dhcp'
uci set network.rndis.device='usb1'
uci add_list firewall.@zone[1].network='rndis'
uci set network.ovpn_zzhome=interface
uci set network.ovpn_zzhome.proto='none'
uci set network.ovpn_zzhome.device='tun99'
uci add_list firewall.@zone[0].network='ovpn_zzhome'
uci set firewall.allowwanzz=rule
uci set firewall.allowwanzz.name='Allow WAN ZZ'
uci set firewall.allowwanzz.direction='in'
uci set firewall.allowwanzz.device='eth0'
uci add_list firewall.allowwanzz.proto='all'
uci set firewall.allowwanzz.src='wan'
uci add_list firewall.allowwanzz.src_ip='10.99.0.0/24'
uci add_list firewall.allowwanzz.src_ip='10.99.10.0/24'
uci set firewall.allowwanzz.family='ipv4'
uci set firewall.allowwanzz.target='ACCEPT'
uci set network.lan.ip6assign='64'
uci add_list network.lan.ip6class='local'
uci set network.globals.ula_prefix='fd10:99:255::/48'
uci commit network
uci commit firewall
uci set dhcp.lan.ra='server'
uci set dhcp.lan.dhcpv6='server'
uci del dhcp.lan.ndp
uci set dhcp.lan.ra_default='2'
uci set dhcp.lan.limit='100'
uci set dhcp.guest=dhcp
uci set dhcp.guest.interface='guest'
uci set dhcp.guest.start='100'
uci set dhcp.guest.limit='100'
uci set dhcp.guest.leasetime='12h'
uci commit dhcp
/etc/init.d/firewall restart
/etc/init.d/network restart

uci del dropbear.@dropbear[-1].Interface
uci commit dropbear
/etc/init.d/dropbear restart

uci set mwan3.globals.local_source='none'
uci set mwan3.wan6_m1_w3=member
uci set mwan3.wan6_m1_w3.interface='wan6'
uci set mwan3.wan6_m1_w3.metric='1'
uci set mwan3.wan6_m1_w3.weight='3'
uci set mwan3.wwan_m10_w3=member
uci set mwan3.wwan_m10_w3.interface='wwan_4'
uci set mwan3.wwan_m10_w3.metric='10'
uci set mwan3.wwan_m10_w3.weight='3'
uci set mwan3.wwan6_m10_w3=member
uci set mwan3.wwan6_m10_w3.interface='wwan_6'
uci set mwan3.wwan6_m10_w3.metric='10'
uci set mwan3.wwan6_m10_w3.weight='3'
uci set mwan3.rndis_m5_w3=member
uci set mwan3.rndis_m5_w3.interface='rndis'
uci set mwan3.rndis_m5_w3.metric='5'
uci set mwan3.rndis_m5_w3.weight='3'
uci set mwan3.wan=interface
uci set mwan3.wan.enabled='1'
uci set mwan3.wan.initial_state='online'
uci set mwan3.wan.family='ipv4'
uci add_list mwan3.wan.track_ip='223.5.5.5'
uci add_list mwan3.wan.track_ip='1.1.1.1'
uci add_list mwan3.wan.track_ip='1.2.4.8'
uci set mwan3.wan.track_method='ping'
uci set mwan3.wan.reliability='1'
uci set mwan3.wan.count='1'
uci set mwan3.wan.size='56'
uci set mwan3.wan.check_quality='0'
uci set mwan3.wan.timeout='4'
uci set mwan3.wan.interval='5'
uci set mwan3.wan.failure_interval='5'
uci set mwan3.wan.recovery_interval='5'
uci set mwan3.wan.down='6'
uci set mwan3.wan.up='3'
uci set mwan3.wan.flush_conntrack='always'
uci set mwan3.wan6=interface
uci set mwan3.wan6.enabled='1'
uci set mwan3.wan6.initial_state='online'
uci set mwan3.wan6.family='ipv6'
uci add_list mwan3.wan6.track_ip='2400:3200::1'
uci add_list mwan3.wan6.track_ip='2606:4700::1111'
uci add_list mwan3.wan6.track_ip='2001:dc7:1000::1'
uci add_list mwan3.wan6.track_ip='2408:8899::8'
uci set mwan3.wan6.track_method='ping'
uci set mwan3.wan6.reliability='1'
uci set mwan3.wan6.count='1'
uci set mwan3.wan6.size='56'
uci set mwan3.wan6.check_quality='0'
uci set mwan3.wan6.timeout='4'
uci set mwan3.wan6.interval='5'
uci set mwan3.wan6.failure_interval='5'
uci set mwan3.wan6.recovery_interval='5'
uci set mwan3.wan6.down='6'
uci set mwan3.wan6.up='3'
uci set mwan3.wan6.flush_conntrack='always'
uci set mwan3.rndis=interface
uci set mwan3.rndis.enabled='1'
uci set mwan3.rndis.initial_state='online'
uci set mwan3.rndis.family='ipv4'
uci add_list mwan3.rndis.track_ip='223.5.5.5'
uci add_list mwan3.rndis.track_ip='1.1.1.1'
uci add_list mwan3.rndis.track_ip='1.2.4.8'
uci set mwan3.rndis.track_method='ping'
uci set mwan3.rndis.reliability='1'
uci set mwan3.rndis.count='1'
uci set mwan3.rndis.size='56'
uci set mwan3.rndis.check_quality='0'
uci set mwan3.rndis.timeout='4'
uci set mwan3.rndis.interval='5'
uci set mwan3.rndis.failure_interval='5'
uci set mwan3.rndis.recovery_interval='5'
uci set mwan3.rndis.down='6'
uci set mwan3.rndis.up='3'
uci set mwan3.rndis.flush_conntrack='always'
uci set mwan3.wwan_4=interface
uci set mwan3.wwan_4.enabled='1'
uci set mwan3.wwan_4.initial_state='online'
uci set mwan3.wwan_4.family='ipv4'
uci add_list mwan3.wwan_4.track_ip='223.5.5.5'
uci add_list mwan3.wwan_4.track_ip='1.1.1.1'
uci add_list mwan3.wwan_4.track_ip='1.2.4.8'
uci set mwan3.wwan_4.track_method='ping'
uci set mwan3.wwan_4.reliability='1'
uci set mwan3.wwan_4.count='1'
uci set mwan3.wwan_4.size='56'
uci set mwan3.wwan_4.check_quality='0'
uci set mwan3.wwan_4.timeout='4'
uci set mwan3.wwan_4.interval='5'
uci set mwan3.wwan_4.failure_interval='5'
uci set mwan3.wwan_4.recovery_interval='5'
uci set mwan3.wwan_4.down='6'
uci set mwan3.wwan_4.up='3'
uci set mwan3.wwan_4.flush_conntrack='never'
uci set mwan3.wwan_6=interface
uci set mwan3.wwan_6.enabled='1'
uci set mwan3.wwan_6.initial_state='online'
uci set mwan3.wwan_6.family='ipv6'
uci add_list mwan3.wwan_6.track_ip='2400:3200::1'
uci add_list mwan3.wwan_6.track_ip='2606:4700::1111'
uci add_list mwan3.wwan_6.track_ip='2001:dc7:1000::1'
uci add_list mwan3.wwan_6.track_ip='2408:8899::8'
uci set mwan3.wwan_6.track_method='ping'
uci set mwan3.wwan_6.reliability='1'
uci set mwan3.wwan_6.count='1'
uci set mwan3.wwan_6.size='56'
uci set mwan3.wwan_6.check_quality='0'
uci set mwan3.wwan_6.timeout='4'
uci set mwan3.wwan_6.interval='5'
uci set mwan3.wwan_6.failure_interval='5'
uci set mwan3.wwan_6.recovery_interval='5'
uci set mwan3.wwan_6.down='6'
uci set mwan3.wwan_6.up='3'
uci set mwan3.wwan_6.flush_conntrack='always'
uci del mwan3.balanced.use_member
uci add_list mwan3.balanced.use_member='wan_m1_w3'
uci add_list mwan3.balanced.use_member='wan6_m1_w3'
uci add_list mwan3.balanced.use_member='rndis_m5_w3'
uci add_list mwan3.balanced.use_member='wwan_m10_w3'
uci add_list mwan3.balanced.use_member='wwan6_m10_w3'
uci commit mwan3
/etc/init.d/mwan3 restart

uci set sms_tool.general.storage='ME'
uci set sms_tool.general.readport='/dev/ttyUSB2'
uci set sms_tool.general.sendport='/dev/ttyUSB2'
uci set sms_tool.general.pnumber='86'
uci set sms_tool.general.mergesms='1'
uci set sms_tool.general.algorithm='Advanced'
uci set sms_tool.general.direction='Start'
uci set sms_tool.general.prefix='0'
uci set sms_tool.general.information='0'
uci set sms_tool.general.atport='/dev/ttyUSB2'
uci set sms_tool.general.checktime='30'
uci set atinout.general.atcport='/dev/ttyUSB2'
uci commit sms_tool
uci commit atinout

uci set wrtbwmon.general.path='/mnt/mmcblk0p3/data/usage.db'
uci commit wrtbwmon
/etc/init.d/wrtbwmon restart

uci set dockerd.globals.data_root='/mnt/mmcblk0p3/docker/'
uci commit dockerd
/etc/init.d/dockerd restart

uci set wireless.default_radio0.ssid='zzzz'
uci set wireless.default_radio0.encryption='psk2'
uci set wireless.default_radio0.key='xxxxxxxxxx'
uci set wireless.radio0.channel='auto'
uci set wireless.radio0.disabled='0'
uci set wireless.radio0.mu_beamformer='0'
uci set wireless.radio0.country='CN'
uci set wireless.radio0.cell_density='0'
uci set wireless.radio0.beacon_int='50'
uci set wireless.radio0.htmode='HE40'
uci set wireless.radio0.channel='36'

uci set wireless.default_radio1.ssid='zzzzz'
uci set wireless.default_radio1.encryption='psk2'
uci set wireless.default_radio1.key='xxxxxxxxxx'
uci set wireless.default_radio1.network='guest'
uci set wireless.radio1.channel='auto'
uci set wireless.radio1.disabled='0'
uci set wireless.radio1.country='CN'

uci commit wireless
uci del network.@device[0].ports
uci add_list network.brguest.ports='eth1'
uci commit network
/etc/init.d/network restart

uci set wireless.radio1.disabled='1'
uci commit wireless
