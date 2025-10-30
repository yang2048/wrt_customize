#禁用dropbear SSH服务的自动启动
uci del dropbear.main.enable
#移除指定的监听接口限制
uci del dropbear.main.Interface
#删除root用户通过密码认证登录
uci del dropbear.main.RootPasswordAuth
uci commit dropbear
