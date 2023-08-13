# AT Commands

## Mode Pref

```plain
AT+QNWPREFCFG="mode_pref" # 查询当前配置。默认 AUTO
AT+QNWPREFCFG: "mode_pref",AUTO
OK
AT+QNWPREFCFG="mode_pref",LTE # 设置 RAT 为仅 LTE
OK
AT+QNWPREFCFG="mode_pref",NR5G # 设置 RAT 为仅 NR5G 模式
OK
AT+QNWPREFCFG="mode_pref",LTE:NR5G # 设置先搜 LTE 网络再搜 NR5G
OK
AT+QNWPREFCFG="mode_pref",NR5G:LTE # 设置先搜 NR5G 网络再搜 LTE
OK
```

## NR5G Bands

```plain
AT+QNWPREFCFG="nr5g_band" # 查询当前为 UE 配置的 5G NR 频段
+QNWPREFCFG: "nr5g_band",1:79 # 格式：1:2:…:N。支持的频段：n1、n28、n41、n77、n78、n79
OK
AT+QNWPREFCFG="nr5g_band",1:79 # 设置 5G NR 频段。默认 AT+QNWPREFCFG="nr5g_band",1:28:41:77:78:79
OK
```

## LTE Bands

```plain
AT+QNWPREFCFG="lte_band" # 查询当前为 UE 配置的 LTE/4G 频段。默认 1:2:3:5:7:8:20:28:34:38:39:40:41
+QNWPREFCFG: "lte_band",1:2:3 # 范围：B1~B80；格式：1:2:…:N。
OK
AT+QNWPREFCFG="lte_band",1:2:3 # 设置 LTE/4G 频段列表。
OK
```

## Signal Strength

```plain
AT+CSQ # 信号强度
AT+QNWINFO # 信号状态
AT+QENG="servingcell" # 查询主小区信息
```
