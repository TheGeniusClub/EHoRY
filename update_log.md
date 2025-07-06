# 一键解决隐藏问题脚本

### Introducion 简介
一个致力于帮助您通过 检测软件(如牛头Native test，Momo)的 脚本

此脚本只能帮你通过 某些检测软件的 某些错误提示

如果执行了脚本后检测软件提示了其他错误，请检查你是否有隐藏好环境

如果脚本出现错误，请私信 酷安@yu13140 以报告问题

### Usage 使用方法
1.确认MT管理器已经拥有Root权限  
2.打开MT管理器(最好不是特别老的版本)  
3.点击下载好的脚本，点击设置  
4.勾选*使用 ROOT权限 执行*，上面那两项随便选(哪项可以执行选哪项)  
- 4.1 对于Kitsune Mask(狐狸面具)用户，请使用MT扩展包选项  
5.点击 执行 按钮，按脚本要求操作  
- 特别地：如果执行脚本时出现了错误，请你私信酷安@yu13140以报告脚本错误

### Changelog 日志
> 从v4.2ultra版本开始，脚本支持Github云端更新

#### v2
1.删除了对红魔手机的支持  
2.针对data分区未解密的用户，切换了脚本加密方式

#### v2.1beta
1.Holmes：Miscellaneous Check (a)  
2.Ruru：环境检测中TWRP/XPrivacyLua/Xposed Edge被发现

##### v2.2
1.快捷开关开发者模式

#### v3.0beta
1.优化了脚本执行UI界面：主菜单优化为滚动形式  
2.稍微精简且美化了脚本代码  
3.取消了对索尼手机的支持  
4.Momo：设备正在使用非原厂设备  
5.Native Detector：Detected LSPosed (5)  
6.Hunter：SafetyDetectClient Check [Root/Unlock]  
7.Hunter：Find Risk File(shizuku)

#### v3.1
1.添加了对APatch与APatch Next的识别

#### v3.1orange
1.添加了对已经刷入Zygisk Next模块的KSU的识别

#### v3.1FIX
1.修复了解决"匹配CTS文件❌"问题的代码错误  
2.添加了对KernelSU与KernelSU Next的识别  
3.修正了Futile Hide (10)的错误代码

#### v4.0RC
1.使用ChatGPT对代码进行了部分精简和美化  
2.添加了对APatch Ci和Kitsune Mask(狐狸面具)的识别  
3.加快了脚本响应速度  
4.修复了在不同手机上脚本出错的问题  
5.Holmes：Something Wrong  
6.Native Test：Futile Hide (01)

#### v4.1
1.添加了更新模块的功能  
2.修复了Holmes：Something Wrong的代码错误  
3.Native Test：Conventional Tests (1)       
4.Native Test：Evil Service (2)  
5.Native Test：Found Injection (04)  
6.(实验性)Holmes：Found Injection (9ff)/Evil Modification (7)  

#### v4.1FIX
1.添加了配置隐藏应用列表功能(过Luna)  
2.修复了Momo：设备正在使用非原厂系统的错误代码  
3.删除了对APatch Ci的识别(Ci实在是太多版本了，但能正常用)  
4.优化了Holmes：Miscellaneous Check (a)的代码  
5.Hunter：当前手机 已经被解锁/Boot分区签名失败

#### v4.2
1.添加了一键模块的功能(KernelSU GKI模式除外)  
2.感谢酷安@Aurora星空_Z的支持  
3.一键模块功能移除对APatch系列的支持(peekaboo请自行嵌入)  
4.Holmes：Miscellaneous Check (a)代码已迁移到Something Wrong  
5.修复了识别Root方式失误的问题  
6.增强了脚本兼容性

#### v4.2ultra
1.修复了部分APatch以及KernelSU安装不了模块的问题  
2.优化了部分代码，增强了对低版本Root管理器的兼容性  
3.一键模块功能已支持用户手动选择是否删除所有模块  
4.一键模块功能添加了自动神仙救砖模块  
5.添加对MT扩展包的支持  
6.模块改为使用Gitlab直链下载  
7.RootbeerFresh：SElinux Flag is Enabled  
8.Magisk检测应用：init.rc已被Magisk修改  
9.Momo：tee损坏

#### v4.3
1.自动更新LSPosed配置(仅限刚刷模块的用户)  
2.添加一键安装检测软件10件套的功能  
3.美化了互动界面UI：更改字体颜色  
4.修复了脚本权限不足的问题  

#### v4.4
1.由于Gitlab的原因，现把脚本迁移到Github  
2.以后将在Github云端更新，使用cdn加速  
3.修复了一键模块和Tricky Store模块安装不了的问题  
4.针对APatch10933存在的问题进行修复  
5.增加了对多种Root共存的检测  
6.系统环境使用脚本自带curl(8.12.0-DEV)  

#### v4.5
1.添加了安装当前设备上的指定模块的功能  
2.针对MKSU12074及更高版本存在的问题进行修复  
3.取消对Termux的支持(可能会导致某些问题)  
4.脚本提供的keybox不再有效，请自行寻找  
5.优化了过检测软件功能的UI界面

#### v4.5Prominent
1.感谢酷安@传说中的小菜叶的技术支持  
2.(实验性)支持APatch半自动刷入cherish_peekaboo模块  
3.考虑到兼容问题，我们更改了以下内容  
- 更新了LSPosed的版本
- APatch+Kitsune：把ReZygisk替换为NeoZygisk
- APatch：取消"选择是否安装救砖模块"
- Kitsune Mask：替换为jm7175版LSPosed
- KSU：优化了安装逻辑
- 取消对MKSU的支持(等我研究研究)

4.修复了一些兼容性问题  
5.提供备用线路下载必要文件  
6.增加了对支持A/B分区设备的检测  
7.(实验性)添加了 切换Root方案 功能  
8.(实验性)Native Test：Futile Hide (8)  
9.Native Detector：检测到Boot状态异常

#### v4.6Foresight
1.优化了部分代码  
2.解决了一些小问题  
3.优化了多线路下载服务  
4.(实验)Native Detector：Magic Mount

#### v4.7_Escondido (v1)
1.加强了对执行代码错误的检测  
2.优化了部分代码  
3.更新模块  
4.对ksu系-gki用户添加了安装susfs(除内置susfs)  
5.将neozygisk换成rezygisk(实测结果)  
6.为测试网速的函数添加可视化进度条  
7.取消脚本必须放在/data的限制(必须解压)  
8.重启对mksu的支持(如仍有问题请反馈)  
9.Luna：发现风险应用(com.byyoung.setting)  
10.Holmes：Property Modified (1) 

#### v4.8_Mysterious (v2)
1.修复了APatch无法嵌入peekaboo模块的问题 
2.修复KSU用户无法安装LSPosed模块的问题 
3.修复春秋检测 检测出Found Injection(c) 
4.添加Nohello模块(仅APatch) 
5.取消配置LSPosed模块的功能 
6.可选择嵌入Nohello内核模块(仅APatch高版本) 
7.优化对错误输出的处理 
8.禁止校验一键模块 

#### v4.9_Nothing (v2)
1.大大减小了一键模块下载的体积  
2.禁止校验一键模块  
3.添加了对SukiSU的识别  
4.修复了一些已知的问题  
