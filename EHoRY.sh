#!/bin/sh
#################################################################################################################################
#Create By yu13140,
YUSHELLVERSION="开源版本v1"

# 颜色定义
RED='\033[1;31m'
GR='\033[1;32m'
YE='\033[1;33m'
RE='\033[0m'
WH='\033[1;37m'

waitingstart() {
    if [ ! "$(whoami)" = "root" ]; then
        echo "当前脚本的所有者为: $(whoami)"
        echo "- 本脚本未获得 Root 权限，请授权"
        exit 1
    fi
    
    TMP_DIR="/data/local/tmp/yshell"  
    rm -rf "${TMP_DIR}"
    yudir="$(dirname $0)"

    if [ ! -d "${TMP_DIR}" ]; then
        mkdir -p "${TMP_DIR}"
    fi
    
    if [[ $yudir != $TMP_DIR ]]; then
        cp -af $0 $TMP_DIR/start.sh
        chmod -R 777 $TMP_DIR
        sh $TMP_DIR/start.sh
    fi    
}

detect_environment() {    
ENVIRONMENT=""
KERNELSU_FLAG=0
APATCH_FLAG=0
MAGISK_FLAG=0

[ -d "/data/adb/ksu" ] && [ -f "/data/adb/ksud" ] && KERNELSU_FLAG=1
[ -d "/data/adb/ap" ] && [ -f "/data/adb/apd" ] && APATCH_FLAG=1
[ -d "/data/adb/magisk" ] && [ -f "/data/adb/magisk.db" ] && MAGISK_FLAG=1

ENV_COUNT=$(( KERNELSU_FLAG + APATCH_FLAG + MAGISK_FLAG ))

if [ $ENV_COUNT -gt 1 ]; then
    echos "$WH  "   
    echos "- 错误：检测到多环境共存！"
    echos "- 我猜你的adb没有清理干净"  
    if [ $KERNELSU_FLAG -eq 1 ] && [ $APATCH_FLAG -eq 1 ]; then
        echos "- 逆天环境：检测到了KSU和APatch共存"
    elif [ $KERNELSU_FLAG -eq 1 ] && [ $MAGISK_FLAG -eq 1 ]; then
        echos "- 逆天环境：检测到了KSU和Magisk共存"
    elif [ $MAGISK_FLAG -eq 1 ] && [ $APATCH_FLAG -eq 1 ]; then
        echos "- 逆天环境：检测到了Magisk和APatch共存"
    else
        echos "- 究极逆天环境：检测到了Magisk和KSU和APatch在你的设备上"
    fi           
    echos "- 请确保设备上只安装一个Root方案$RE"          
    exit 1
fi

if [ $KERNELSU_FLAG -eq 1 ]; then
    ENVIRONMENT="KernelSU"    
    KSU_VERSION="$(/data/adb/ksud -V | sed 's/ksud//g')"
    KSU_APP_VER="$(dumpsys package me.weishu.kernelsu | grep versionCode | sed 's/^.*versionCode=//g' | sed 's/minSdk.*$//g')"
    BUSY="/data/adb/ksu/bin/busybox"

elif [ $APATCH_FLAG -eq 1 ]; then
    ENVIRONMENT="APatch"   
    BUSY="/data/adb/ap/bin/busybox" 
    APATCH_VERSION="$(sed -n '1p' /data/adb/ap/version 2>/dev/null)"

elif [ $MAGISK_FLAG -eq 1 ]; then
    ENVIRONMENT="Magisk"
    BUSY="/data/adb/magisk/busybox"
    MAGISK_VERSION="$(magisk -V 2>/dev/null)"
    MAGISK_F="$(magisk -v 2>/dev/null)"  
fi

[ -z "$ENVIRONMENT" ] && echos "$WH- 警告：未检测到Root环境$RE" >&2
}

downloader() {
if [[ $SHELL == *mt* ]]; then
    DOWN1="curl --progress-bar -LJ"
    DOWN2="-o "$MODULE_DE""
else        
    DOWN1="$BUSYBOX_PATH --progress-bar -LJ"
    DOWN2="-o "$MODULE_DE""     
fi
}

warmtocdn() {
if [ $WARM_CDN = "true" 2>/dev/null ]; then
    echos "$YE检测到逆天的网络波动，请连接正常的网络后再使用$RE"
    exit 1
else
    return
fi
}

speedforcheck() {
SPEED1="" && SPEED2="" && SPEED3="" && SPEED4="" && SPEED5="" && SPEED6=""
echos "$GR正在为您测试网速，选择一个最佳线路(这可能需要30秒)$RE"
speedcheck_url="https://github.com/yu13140/yuhideroot/raw/refs/heads/main/check.sh"
expected_size=99461
CDNUM=1
total=6  # 总测试数

# 初始化进度条
printf "${GR}[%-${total}s] 0/${total}${RE}" "" | tr ' ' '.'  # 用点表示未完成

while [ $CDNUM -le $total ]; do
    cdncheck
    target_url=${CDN}${speedcheck_url}    
    curl_output=$(curl -L -o /dev/null -sSf --connect-timeout 5 -m 20 -w "%{time_total} %{http_code} %{size_download}" "$target_url" 2>/dev/null)      
    check_time=$(echo "$curl_output" | awk '{print $1}')
    http_code=$(echo "$curl_output" | awk '{print $2}')
    actual_size=$(echo "$curl_output" | awk '{print $3}')

    if [ $? -eq 0 ] && [ "$http_code" -eq 200 ] && [ "$actual_size" -eq "$expected_size" ]; then
      eval "SPEED$CDNUM=$check_time"
    else
      eval "SPEED$CDNUM='INVALID'"
    fi

    # 更新进度条
    bar=$(printf "%${CDNUM}s" | tr ' ' '#')  # 已完成用#
    remain=$((total - CDNUM))
    dots=$(printf "%${remain}s" | tr ' ' '.')  # 未完成用.
    printf "\r${GR}[%s%s] %d/${total}${RE}" "$bar" "$dots" "$CDNUM"
    
    CDNUM=$((CDNUM+1))
done
printf "\n"

fastest_time=999
fastest_num=0
CDNUM=1
while [ $CDNUM -le 6 ]; do
    eval "current=\$SPEED$CDNUM"
      
    if [ "$current" != "INVALID" ] && \
       [ $(echo "$current < $fastest_time" | bc) -eq 1 ]; then
      fastest_time=$current
      fastest_num=$CDNUM
    fi
    
    CDNUM=$((CDNUM+1))
done

if [ $fastest_num -ne 0 ]; then
    CDNUM=$fastest_num
    echos "$GR为您测试了所有CDN服务，选择了其中最快的，延时为${fastest_time}s$RE"
else
    echos "$YE错误：未检测到有用的CDN服务，即将从线路一开始下载$RE"
    CDNUM=1
fi

return
}

cdncheck() {
case $CDNUM in
    1)
    CDN="https://github.moeyy.xyz/" ;;
    2)
    CDN="https://ghproxy.click/" ;;        
    3)
    CDN="https://ghfile.geekertao.top/" ;;
    4)
    CDN="https://ghf.xn--eqrr82bzpe.top/" ;;
    5)
    CDN="https://ghproxy.net/" ;;
    6)
    CDN="https://gh.llkk.cc/" ;;
    7)
    CDN="" ;;
    *)
    WARM_CDN="true"
esac
}

down_cdn() {
module_install() {
echos " "                                       
echos "$YE正在为您安装模块$RE"
installer
rm -f "$MODULE_DE" && mod=0
}
warmtocdn
cdncheck
[ -z $THISHA ] || THISHA="$1"
MOD_URL="${CDN}$cdn_url"
sizer
$DOWN1 $MOD_URL $DOWN2
while [ $? -ne 0 ]; do
    if [ $fastest_num -ne 0 ]; then
        echos "$YE检测到最快线路失败，请您选择是否连接VPN下载"
        echos "1.回退到线路一      2.连接VPN下载(需要自己动手)$RE"
        case $CDNUM in
        1)
        CDNUM=1 ;;
        2)
        CDNUM=7 ;;        
        3)
        echos "$YE输入错误，默认选择回退到线路一$RE"; CDNUM=1 ;;
        esac
        fastest_num=0 
    else
        echos "$YE检测到下载失败，正在为您切换下载线路$RE"
        CDNUM=$(($CDNUM+1))
    fi        
    down_cdn  
done
integritycheck
sleep 0.1
[ "$MODULE_DE" = "$YSHELL_PATH/installmodule.zip" ] || MODULE_DE="$YSHELL_PATH/installmodule.zip"
unset -v THISHA && unset -v cdn_url
[ $mod = 1 ] && module_install || return
}

sizer() {
FILE_SIZE="$(curl --max-time 10 -sLI $MOD_URL 2>/dev/null | awk '/^[Cc][Oo][Nn][Tt][Ee][Nn][Tt]-[Ll][Ee][Nn][Gg][Tt][Hh]/ { bytes = $2; kb = bytes / 1024; if (kb < 1024) printf "%.2f KB\n", kb; else printf "%.2f MB\n", kb / 1024 }')"
echos "$WH本次下载的文件大小：$FILE_SIZE$RE"
}

integritycheck() {
if [ ! -f $MODULE_DE ]; then
    echos "$YE未检测到模块，请确认是否下载完毕$RE"
    exit 1
fi
SHACHECK="$(sha256sum "$MODULE_DE" | cut -d " " -f1)"
    if [ "$SHACHECK" = "$THISHA" 2>/dev/null ]; then
        echos "${GR}sha256完整性校验通过$RE"
    else
        echos "${YE}sha256完整性校验未通过$RE"
        echos "${YE}请检查模块是否已经下载100%$RE"
        echos "${YE}如果未发现其他问题，请私信@yu13140报告此错误$RE"
        exit 1
    fi
}

#变量区
BUSYBOX_PATH="/data/yshell/busybox"
YSHELL_PATH="/data/local/tmp/yshell"
DEVELOP="$(settings get global development_settings_enabled)"
MODULE_DE="$YSHELL_PATH/installmodule.zip"
file1="$YSHELL_PATH/config.json"
backup_dir="/sdcard/一键解决隐藏问题/"
backup_file="${backup_dir}/$(basename "$file2")"

installer() {
chmod 755 "$MODULE_DE"
case $ENVIRONMENT in
    Magisk) magisk --install-module "$MODULE_DE" ;;
    APatch) /data/adb/apd module install "$MODULE_DE" ;;
    KernelSU) /data/adb/ksud module install "$MODULE_DE" ;;
esac
}

echos() { echo -e "$@"; }

ends() {
    while true; do
        echos "$GR操作已完成$RE"
        echos "                                        "
        echos "----------------------------------------"
        echos "$YE是否继续操作？"
        echos "1. 返回主菜单"
        echos "2. 返回上级菜单"
        echos "3. 退出脚本$RE"
        echos "----------------------------------------"
        echos "$YE请输入选项：$RE\c"
        read out
        case $out in
        1) 
        clear; selmenu; break ;;
        2) 
        clear; menu; break ;;
        3) 
        echos "$YE正在退出脚本$RE"; exit 0 ;;
        *) 
        echos "$YE输入错误❌请输入1或2！"; echos "请等待2秒$RE" ;sleep 1.4; clear ;;
        esac
    done
}

downout() {
if [ $? -ne 0 ]; then
    echos "$WH可能有问题出现咯，请截图下来私信酷安@yu13140$RE"
    exit 0
else
    while true; do
        echos "$GR模块安装完成$RE"
        echos "                                        "
        echos "$YE模块需要重启手机以生效$RE"
        echos "                                        "
        echos "----------------------------------------"
        echos "$YE是否继续操作？"
        echos "1. 重启手机"
        echos "2. 返回主菜单"
        echos "3. 退出脚本$RE"
        echos "----------------------------------------"
        echos "$YE请输入选项：$RE\c"
        read dot
        case $dot in
        1) 
        echos "$WH三秒后即将重启手机$RE"; sleep 3; reboot ;;
        2) 
        clear; selmenu; break ;;
        3) 
        echos "$YE正在退出脚本$RE"; exit 0 ;;
        *) 
        echos "$YE输入错误❌请输入1或2或3！"; echos "请等待2秒$RE" ;sleep 1.4; clear ;;
        esac
    done
fi
}

examm() { [ $? -ne 0 ] && echos "$WH可能有问题出现咯，请截图下来私信酷安@yu13140$RE" || ends ; }

systemmount() {
	echos "$GR正在生成模块$RE"
	mkdir -p /data/adb/modules/Solve_systemmount 2>/dev/null
	echos "id=Solve_systemmout
name=解决数据未加密，挂载参数被修改问题
version=test
versionCode=1.0
author=酷安@yu13140
description=解决momo提示数据未加密，挂载参数被修改" >>/data/adb/modules/Solve_systemmount/module.prop
	echos "ro.crypto.state=encrypted" >>/data/adb/modules/Solve_systemmount/system.prop
	sleep 1.4	
}

topmiaohan() {
	echos "                                        "
	echos "                                        "
	echos "- 本脚本制作于2024年09月17日"
	echos "- 脚本作者:酷安用户 topmiaohan"
	echos "- 脚本功能:生成一个可在每次开机时重置verifiedBoot哈希值的Magisk模块，并自动把这个模块刷入手机"
	if [ -d /data/adb/modules/tricky_store ]; then
		mkdir -p /data/adb/modules/Reset_BootHash
		rm -f /data/adb/modules/Reset_BootHash/service.sh
		rm -f /data/adb/modules/Reset_BootHash/module.prop
		echos "id=Reset_BootHash
name=重置哈希值
version=搬运 @yu13140
versionCode=20240917
author=topmiaohan
description=辅助Tricky Store，实现增强BL隐藏。" >>/data/adb/modules/Reset_BootHash/module.prop
		echos "                                        "
		echos "脚本正在生成模块...\033[0;32m完成\033[0m"
		echos "脚本正在把生成的模块安装到手机...\033[0;32m完成\033[0m"
		echos "                                        "
		echos "接下来还有非常重要的一步，请按照以下步骤手动完成:"
		echos "                                        "
		echos "\033[0;33m请从密钥认证APP里获取你本人手机的verifiedBootHash值\033[0m"
		echos "\033[0;33m然后粘贴到下边，按回车键确认!\033[0m"
		echos "                                        "
		echos "\033[0;33m请从密钥认证APP里获取你本人手机的verifiedBootHash值\033[0m"
		echos "\033[0;33m然后粘贴到下边，按回车键确认!\033[0m"
		echos "                                        "
		echos "\033[0;33m请从密钥认证APP里获取你本人手机的verifiedBootHash值\033[0m"
		echos "\033[0;33m然后粘贴到下边，按回车键确认!\033[0m"
		echos "                                        "
		read Name
		if [ -z "$Name" ]; then
			echos "$(echos "\033[0;33m未输入任何内容，脚本将不执行任何操作。\033[0m")"
			rm -rf /data/adb/modules/Reset_BootHash/
			exit 0
		else
			echos "resetprop -n ro.boot.vbmeta.digest $Name" >>/data/adb/modules/Reset_BootHash/service.sh
			echos "把输入的verifiedBootHash值添加到模块...\033[0;32m完成\033[0m"
		fi
		echos "                                        "
		echos "脚本执行完毕，请重启手机后查看牛头人应用！"
		echos "脚本执行完毕，请重启手机后查看牛头人应用！"
		echos "脚本执行完毕，请重启手机后查看牛头人应用！"
	else
		echos "                                        "
		echos "  正在运行脚本...\033[0;31m失败\033[0m"
		echos "  正在分析失败原因...\033[0;31m未安装TrickyStore模块！\033[0m"
		echos "                                        "
		echos "  正在下载Tricky Store模块"
		echos "  安装完请重启手机后，再执行脚本"
		downtricky
		downout	
	fi
}

Development() {
    Volume_key_monitoring(){
    local choose
    local branch
        while :;do
            choose="$(getevent -qlc 1|awk '{ print $3 }')"
            case "$choose" in
                KEY_VOLUMEUP)branch="0";;
                KEY_VOLUMEDOWN)branch="1";;
                *)continue
            esac
            echos "$branch"
            break
        done
}
echos  "                                        "
echos  "                                        "
echos "$WH- 本脚本制作于2024年12月21日"
echos "- 脚本作者:酷安用户 @yu13140"
echos "- 脚本功能:让你更方便地开关开发者模式$RE"
echos  "$GR按音量键＋:开启开发者模式"
echos  "按音量键－: 关闭开发者模式"
echos  "如果失效，请多按几次$RE"
echos  "$YE—————————————————————————————————————$RE"
if [[ $(Volume_key_monitoring) == 0 ]];then
    echos  "$GR正在为您开启开发者模式$RE"
    settings put global adb_enabled 1
    settings put global development_settings_enabled 1
else
    echos  "$GR正在为您关闭开发者模式$RE"
    settings put global adb_enabled 0
    settings put global development_settings_enabled 0
fi
}

solve_Development() {
	echos "$GR正在生成模块$RE"
	mkdir -p /data/adb/modules/Solve_Development
	echos "id=Solve_Development
name=解决处于调试环境问题
version=test
versionCode=1.0
author=酷安@yu13140
description=解决momo提示处于调试环境" >/data/adb/modules/Solve_Development/module.prop
    echos "ro.debuggable=0" >/data/adb/modules/Solve_Development/system.prop
	sleep 1.4	
}

downbusybox() {
echos "$GR正在配置环境$RE"  
mkdir -p /data/yshell
CDNUM=1
speedforcheck
cdncheck
$BUSY wget -nc --output-document="$BUSYBOX_PATH" ${CDN}https://github.com/yu13140/yuhideroot/raw/refs/heads/main/curl/busybox --no-check-certificate
chmod -R 755 /data/yshell/
clear
}

zynlist() {
enableznctl() {
znctl enforce-denylist enabled
[ $ENVIRONMENT = "Magisk" ] && magisk denylist add me.garfieldhan.holmes
znctl enforce-denylist disabled   
}
[ ! -d /data/adb/modules/zygisksu ] && echo "$YE此方法依赖zygisk next模块，请去安装模块后再来执行$RE" && ends && return
if [ -f /data/adb/zygisksu/denylist_enforce ]; then
    ZNLIST="$(sed -n '1p' /data/adb/zygisksu/denylist_enforce 2>/dev/null)"
	[ $ZNLIST = 1 ] && znctl enforce-denylist disabled || enableznctl   
else
    enableznctl
fi
}

usezyn() {
if [ -d /data/adb/modules/zygisk-maphide ]; then
    echos "                                        "
    echos "${YE}将要删除Zygisk Maphide模块(如果有的话)$RE"
    rm -rf /data/adb/modules/zygisk-maphide/
fi

if [ -d /data/adb/modules/zygisksu ]; then
    echos "                                        "
    ZNVERSION="$(sed -n '4p' /data/adb/modules/zygisksu/module.prop 2>/dev/null)"
	if [ $ZNVERSION = "versionCode=512" ]; then
	    zynlist
	else
        echos "$YE你的Zygisk Next模块不是最新$RE"
	    echos "$YE安装模块后重启，打开Holmes应用，如果仍有9ff请再执行一次脚本$RE"
	    downzyn	
    fi
else
    echos "${YE}安装模块后重启，打开Holmes应用，如果仍有9ff请再执行一次脚本$RE"
    downzyn
fi
}

momodevelop() {
        clear
		echos "$GR正在关闭调试模式$RE"
		settings put global adb_enabled 0
		settings put global development_settings_enabled 0
		if [ "$DEVELOP" = 1 ]; then
			echos -e "$GR调试模式未关闭，红魔手机请不要使用此选项$RE"
			echos -e "$GR其他手机请联系酷安@yu13140$RE"
		else
		    sleep 1.4			
		fi
}

momosdk() {
		echos "$GR正在解决 非SDK接口的限制失效 问题$RE"
		settings delete global hidden_api_policy
        settings delete global hidden_api_policy_p_apps
        settings delete global hidden_api_policy_pre_p_apps
        settings delete global hidden_api_blacklist_exemptions
        settings delete global hidden_api_blacklist_exe
		sleep 1.4
}

momotee() {
if [ -d /data/adb/modules/tricky_store ]; then
    pm list packages $flag | sed 's/package://g' > /data/adb/tricky_store/target.txt
    sed -i '/^$/! s/$/!/' /data/adb/tricky_store/target.txt
    echo "teeBroken=true" >/data/adb/tricky_store/tee_status
else
    echos "$YE你没有安装Tricky Store，请去安装所需模块$RE"
    exit 0
fi
}

fhten() {
path=$(pm list packages -f | grep icu.nullptr.nativetest | sed 's/package://' | awk -F'base' '{print $1}')
		find $path -type f -name "*.*dex" -exec rm {} \;
}

fheight() {
if [ -d /data/adb/modules/playintegrityfix ]; then
    echos "$YE这是实验性功能，可能会不起作用。$RE"
    touch /data/adb/modules/playintegrityfix/remove
    echos "$YE重启后再试试效果吧！$RE"
else
    echos "$YE这个方案可能不适合你的设备，请向酷安@yu13140反馈情况$RE"
fi
}

cleanlsplog() {
rm -f /data/adb/lspd/log/*
rm -f /data/adb/lspd/log.old/*
if [ $ENVIRONMENT = "KernelSU" ]; then
    /data/adb/ksu/bin/resetprop -n persist.logd.size ""
    /data/adb/ksu/bin/resetprop -n persist.logd.size.crash ""
    /data/adb/ksu/bin/resetprop -n persist.logd.size.main ""
    /data/adb/ksu/bin/resetprop -n persist.logd.size.tag ""
else
    resetprop -n persist.logd.size ""
    resetprop -n persist.logd.size.crash ""
    resetprop -n persist.logd.size.main ""
    resetprop -n persist.logd.size.tag ""
fi
}

haxiz() {
VERSIONCODE="$(sed -n '4p' /data/adb/modules/tricky_store/module.prop 2>/dev/null)"
		if [ $VERSIONCODE = "versionCode=158" ]; then
			echos "$GR正在运行topmiaohan创建的脚本$RE"
			topmiaohan
			sleep 1.4
		else
			NOWVERSION="$(sed -n '3p' /data/adb/modules/tricky_store/module.prop 2>/dev/null)"
			echos "$GR当前设备上的trick-store版本为$RE"
			echos "$YE$NOWVERSION$RE" | sed 's/version://'
			echos "$GR你的trick-store版本不是最新，或你使用了修改版本
    目前最高版本为$RE$YE v1.2.1 (158-51390a7-release)$RE"
            exit 1
		fi
}

aptroot() {
rm -f /data/local/tmp/*
rm -f /data/swap_config.conf
rm -rf /data/core /data/dumpsys /data/duraspeed
sleep 1.4
}

ctsfix(){
if [ -f /data/adb/modules/playintegrityfix/pif.json ]; then
	FINGERPRINT="$(getprop ro.system.build.fingerprint)"
	NOWFP="$(sed -n '2p' /data/adb/modules/playintegrityfix/pif.json 2> /dev/null)"
    MODIFIED_FINGERPRINT="  \"FINGERPRINT\": \"$FINGERPRINT\","
    sed -i "s|$NOWFP|$MODIFIED_FINGERPRINT|" /data/adb/modules/playintegrityfix/pif.json
	sleep 1.4
else
	echos "$GR您未刷入playintegrityfix模块，请刷入此模块$RE"
	exit 1
fi
}

rurudelete() {
echos "$GR这可能会导致你的XPrivacyLua或Xposed Edge模块不可用$RE"
rm -rf /data/xedge /data/xlua /sdcard/TWRP
sleep 1.4
}

detectorlsp() {		
pathd=$(pm list packages -f | grep com.reveny.nativecheck | sed 's/package://' | awk -F'base' '{print $1}')
		find $pathd -type f -name "*.odex" -exec rm {} \;
}

ndhideboot() {
echos "$GR正在生成模块$RE"
	mkdir -p /data/adb/modules/hide_vbmeta_error 2>/dev/null
	echos "id=hide_vbmeta_error
name=解决Boot状态异常问题
version=test
versionCode=1.0
author=酷安@yu13140
description=解决Native Detector提示检测到Boot状态异常问题" >>/data/adb/modules/hide_vbmeta_error/module.prop
	echos "ro.boot.vbmeta.invalidate_on_error=yes" >/data/adb/modules/hide_vbmeta_error/system.prop
	echos "ro.boot.vbmeta.hash_alg=sha256" >>/data/adb/modules/hide_vbmeta_error/system.prop
	echos "ro.boot.vbmeta.size=6529" >>/data/adb/modules/hide_vbmeta_error/system.prop
	echos "ro.boot.vbmeta.device_state=locked" >>/data/adb/modules/hide_vbmeta_error/system.prop
	echos "ro.boot.vbmeta.avb_version=1.2" >>/data/adb/modules/hide_vbmeta_error/system.prop
	sleep 1.4	
}

ndzygiskhide() {
if [ -d /data/adb/modules/zygisksu/ ]; then
    ZVC="$(sed -n '4p' /data/adb/modules/zygisksu/module.prop 2>/dev/null)"
    if [ $ZVC = "versionCode=512" ]; then
        touch /data/adb/zygisksu/no_mount_znctl
        sleep 1.4
    else
        echos "$YE请去下载最新的Zygisk Next$RE"
        exit 1
    fi
else
    echos "$YE请去下载最新的Zygisk Next$RE"
    exit 1
fi
}

huntermiui() {				
echos "$GR目前仅适用于米系手机(小米，红米)$RE"
pm disable --user 0 com.miui.securitycenter/com.xiaomi.security.xsof.MiSafetyDetectService
sleep 1.4
}

huntershizuku() {
rm -rf /data/local/tmp/shizuku/
rm -f /data/local/tmp/shizuku_starter
sleep 1.4
}

somethingw() {
sw1() { cmd package compile -m interpret-only -f $1 ; }
sw2() { cmd package compile -m everything -f $1 ; }
echos "$GR感谢酷安@but_you_forget提供的思路$RE"
echos "$GR这可能需要一两分钟的时间，因机而异$RE"
sop=$(sw1 "com.android.settings")
if echo "$sop" | grep -iq "Failure"; then
    echo "$YE❌ 执行出现错误！请私信作者报告错误$RE" && ends && return
fi
sw1 "me.garfieldhan.holmes"
rm -f /data/dalvik-cache/arm/*
rm -f /data/dalvik-cache/arm64/*
sw2 "com.android.settings"
sw2 "me.garfieldhan.holmes"
echos "$YE如果你想从根本解决问题，请换更高版本的LSPosed$RE"
sleep 1.4
}

lunawan() {
rm -rf /storage/emulated/0/Android/data/com.byyoung.setting
rm -rf /storage/emulated/0/Android/obb/com.byyoung.setting
rm -rf /storage/emulated/0/Android/obb/com.byyoung.setting
rm -rf /storage/emulated/0/Android/data/com.byyoung.setting
sleep 1.4
}

nouses() {
echos "$RED高危选项！操作需要删除system分区里的addon.d文件夹"	
echos "删除这个文件夹，可能会使设备开机后不能写入system分区$RE"
echos "$YE你确定要继续吗？(  1.继续    2.退出  )：\c$RE"
read addonc
if [ $addonc = 2 ]; then
    echo "$WH你选择了退出$RE" && ends && return
fi		
echos "$GR正在生成模块$RE"
mkdir -p /data/adb/modules/delete_addond	    
mkdir -p /data/adb/modules/delete_addond/addon.d
touch /data/adb/modules/delete_addond/addon.d/.replace
echo "sleep 10 && rm -rf /data/adb/modules/delete_addond/" > /data/adb/modules/delete_addond/service.sh
echos "id=sysaddons
name=解决设备正在使用非原厂系统问题
version=test
versionCode=1.0
author=酷安@yu13140
description=解决momo提示设备正在使用非原厂系统" >/data/adb/modules/delete_addond/module.prop	
sleep 1.4	
}

shamiko_modules() {
echo " "    
SHAMOD="/data/adb/shamiko/"
if [ -d $SHAMOD ]; then
    [ -f $SHAMOD/whitelist ] && rm -f $SHAMOD/whitelist && echos "${YE}Shamiko已设置黑名单模式$RE" || touch $SHAMOD/whitelist && echos "${YE}Shamiko已设置白名单模式$RE"
else
   echos "$YE你没有安装Shamiko！$RE"
   exit 0
fi
}

# 脚本操作选择
select_option() {
    case $1 in
    a)
    clear; selmenu ;;    
    1) 
    clear; echos "$GR正在切换Shamiko模式$RE"; shamiko_modules; examm ;;
    2) 
    clear; echos "$GR正在清理LSPosed日志$RE"; cleanlsplog; examm ;;
    3) 
    clear; echos "$GR正在清理Magisk日志$RE"; rm -f /cache/magisk.log; rm -f /cache/magisk.log.bak; examm ;;
    4) 
    clear; echos "$GR正在启动$RE"; Development; examm ;;
    5)
    clear; Momo ;;
    6)
    clear; native_test ;;
    7) 
    clear; echos "$GR正在解决 Root|BootLoader|Magisk|Lsposed$RE"; aptroot; examm ;;
    8) 
    clear; echos "$GR正在匹配CTS配置文件$RE"; ctsfix; examm ;;
    9) 
    clear; echos "$GR正在解决Miscellaneous Check (a)$RE"; somethingw; examm ;;
    10) 
    clear; echos "$GR正在删除有问题的文件夹$RE"; rurudelete; examm ;;
    11) 
    clear; echos "$GR正在解决Detected LSPosed (5)$RE"; detectorlsp; examm ;;
    12) 
    clear; echos "$GR正在解决SafetyDetectClient Check Root/Unlock$RE"; huntermiui; examm ;;
    13) 
    clear; echos "$GR正在解决Find Risk File$RE"; huntershizuku; examm ;;
    14) 
    clear; echos "$GR正在解决Something Wrong$RE"; somethingw; examm ;;
    15) 
    clear; echos "$GR正在解决zygote注入问题$RE"; usezyn; downout ;;
    16) 
    clear; echos "$GR正在解决Bootloader锁问题$RE"; echos "com.zhenxi.hunter" >> /data/adb/tricky_store/target.txt; examm ;;
    17)
    clear; echos "$GR正在检测到Boot状态异常问题$RE"; ndhideboot; downout ;;
    18)
    clear; echos "$GR正在解决Magic Mount泄露$RE"; ndzygiskhide; examm ;;
    19)
    clear; echos "$GR正在解决爱玩机因权限泄露问题$RE"; lunawan; examm ;;
    20)
    clear; echos "$GR正在解决哈希值问题$RE"; haxiz; downout ;; 
    f) 
    echos "$GR正在退出脚本$RE"; exit 0 ;;
    *) 
    echos "$YE输入错误，请重新选择$RE"; echos "$GR请等待2秒$RE"; sleep 1.4; menu ;;
    esac
}

native_test() {
niutous=(
        "$YE- a.返回上一级$RE$GR"
        "1.Native Test：Futile Hide (10)(重启后可能失效)"
        "2.Native Test：Conventional Tests (8)+Partition Modified"    
        "3.Native Test：Futile Hide (01)"
        "4.(实验)Native Test：Futile Hide (8)$RE"
        )
        for nt in "${!niutous[@]}"; do
        echos "${niutous[$nt]}"
        sleep 0.007
        done
        echos "$YE请输入选项：$RE\c"
        read dent        	    
        case $dent in
        a)
        clear; menu ;;
        1) 
        clear; echos "$GR正在解决Futile Hide (10)$RE"; fhten; downout ;;
        2) 
        clear; echos "$GR正在解决哈希值问题$RE"; haxiz; downout ;;
        3) 
        clear; echos "$GR正在解决Futile Hide (01)$RE"; znctl enforce-denylist disabled; examm ;;
        4)
        clear; echos "$GR正在解决Futile Hide (8)$RE"; fheight; downout ;;
        *) 
        echos "$GR输入错误，请重新输入$RE"; native_test ;;
        esac
}

Momo() {
Momos=(
        "$YE- a.返回上一级$RE$GR"
        "1.Momo：已开启调试模式"
        "2.Momo：处于调试环境"
        "3.Momo：非SDK接口的限制失效"
        "4.Momo：数据未加密，挂载参数被修改"
        "5.Momo：设备正在使用非原厂系统"
        "6.Momo：tee损坏$RE"       
        )
        for m in "${!Momos[@]}"; do
        echos "${Momos[$m]}"
        sleep 0.007
        done
        echos "$YE请输入选项：$RE\c"
        read demo
        case $demo in
        a)
        clear; menu ;;
        1) 
        clear; echos "$GR正在关闭调试模式$RE"; momodevelop; examm ;;
        2) 
        clear; echos "$GR解决 处于调试环境 问题$RE"; solve_Development; downout ;;                
        3) 
        clear; echos "$GR正在解决 非SDK接口的限制失效 问题$RE"; momosdk; examm ;;
        4) 
        clear; echos "$GR正在解决 数据未加密，挂载参数被修改 问题$RE"; systemmount; downout ;;
        5) 
        clear; echos "$GR正在解决 设备正在使用非原厂系统 问题$RE"; nouses; downout ;;
        6) 
        clear; echos "$GR正在解决tee损坏$RE"; momotee; examm ;;      
        *) 
        echos "$GR输入错误，请重新输入$RE"; Momo ;;
        esac
}

menu() {
    clear   
     
    OPTIONS=(
        "$GR您正在使用 过检测软件 功能"
        "以下是隐藏功能列表：$RE$YE"        
        "a.返回主菜单$RE$GR"
        "1.切换Shamiko模式"
        "2.清理LSPosed日志"
        "3.清理magisk日志"
        "4.快捷开关 开发者模式$RE$YE"
        "5.解决Momo问题"
        "6.解决牛头 (Native Test) 问题$RE$GR"              
        "7.APT检测：Root|BootLoader|Magisk|Lsposed"
        "8.YASNAC/SPIC：匹配CTS配置文件❌"
        "9.Holmes：Miscellaneous Check (a)"
        "10.Ruru：TWRP/XPrivacyLua/Xposed Edge"
        "11.Native Detector：Detected LSPosed (5)"
        "12.Hunter：SafetyDetectClient Check [Root/Unlock]"
        "13.Hunter：Find Risk File(shizuku)"
        "14.Holmes：Something Wrong"
        "15.(实验)Holmes：Found Injection (9ff)"
        "/Evil Modification (7)"
        "16.Hunter：当前手机 已经被解锁/Boot分区签名失败"
        "17.Native Detector：检测到Boot状态异常"
        "18.(实验)Native Detector：Magic Mount"
        "19.Luna：发现风险应用(com.byyoung.setting)"
        "20.Holmes：Property Modified (1)$RE"        
    )

    for i in "${!OPTIONS[@]}"; do
        echos "${OPTIONS[$i]}"
        sleep 0.001
    done
    echos "$YE(输入 f 退出脚本)请输入选项：$RE\c"
    read yc
    select_option $yc
}

selmenu() {
clear
# 选择root管理器
    if [ $ENVIRONMENT = "Magisk" ]; then
        if echos "$MAGISK_F" | grep -qi "kitsune"; then
	    	MANAGER="$YE检测到你已root
你的root管理器为Kitsune Mask("$MAGISK_VERSION")$RE"
        elif echos "$MAGISK_F" | grep -qi "alpha"; then
            MANAGER="$YE检测到你已root
你的root管理器为Magisk Alpha("$MAGISK_VERSION")$RE"
        else
            MANAGER="$YE检测到你已root
你的root管理器为Magisk("$MAGISK_VERSION")$RE"
        fi
	elif [ $ENVIRONMENT = "KernelSU" ]; then
		MANAGER="$YE检测到你已root
你的root管理器为KernelSU("$KSU_VERSION")$RE"   
    elif [ $ENVIRONMENT = "APatch" ]; then           
    APATCH_NEXT_VERSIONS="11008 11010 11021"
        if echos " $APATCH_NEXT_VERSIONS " | grep -q " $APATCH_VERSION "; then
            MANAGER="$YE检测到你已root
你的root管理器为APatch Next($APATCH_VERSION)$RE"
            NEXT_AP=1               
        else
            MANAGER="$YE检测到你已root
你的root管理器为APatch($APATCH_VERSION)$RE"
            NEXT_AP=0
        fi
	else
		MANAGER="$YE检测到你已root
未知root管理器，请谨慎使用脚本$RE"
	fi
	
MENU=(
        "                                        "
       "$GR————————————————————————————————————————————————"
        "                                        "
        "    $GR欢 迎 使 用$GR$GR R$GR${GR}O$GR${GR}O$GR${GR}T$GR$GR 隐$GR$GR 藏$GR$GR 脚$GR$GR 本$GR"        
        "                                        "
        "————————————————————————————————————————————————"
        "                                        "
        "${YE}AUTHOR：酷安@yu13140$RE"
        "$YE当前脚本的版本号为：$YUSHELLVERSION$RE"        
        "$MANAGER"
        "                                        "
        "$GR请选择你需要使用的功能"
        "1.过检测软件功能"
        "                                        "
        "2.配置隐藏应用列表(可过Luna)"
        "                                        "
        "3.一键安装隐藏所需模块"
        "                                        "
        "4.一键安装检测软件10件套"
        "                                        "
        "5.安装当前设备上的指定模块"
        "                                        "
        "6.(实验)切换Root方案"
        "                                        $RE"
    )
    
    for act in "${!MENU[@]}"; do
        echos "${MENU[$act]}"
        sleep 0.009
    done
    echos "$YE(输入 f 退出脚本)请输入选项以执行下一步：$RE\c"
    read ssmenu
    menuss $ssmenu
}

chlist() {
NUMLIST=(
           "$GR你正在使用 配置隐藏应用列表 功能"
           "此功能只适合下面含有包名的隐藏应用列表使用"
           "不支持的应用，会把配置文件下载到/sdcard/Download/文件夹内"
           "支持的包名：com.tsng.hidemyapplist"
           "支持的包名：com.tencent.wifimanager"
           "支持的包名：com.hicorenational.antifraud"
           "1.配置隐藏应用列表"
           "2.恢复原配置"
           "3.退出脚本$RE"
	       "                                        "
	       )
	for coh in "${!NUMLIST[@]}"; do
        echos "${NUMLIST[$coh]}"
        sleep 0.1
    done
	echos "$YE请输入对应的数字：$RE\c"
	read ch
    case $ch in
    1)
    hidemyapplist ;;
    2)
    recoverapplist ;;
    3) 
    echos "$GR正在退出脚本……$RE"; exit 0 ;;        
    *) 
    echos "$GR输入错误，请重新输入$RE"; chlist ;;
    esac
}

installapks() {
echos " "
echos "$YE正在下载必要文件中$RE"
CDNUM=1
speedforcheck
cdn_url="https://github.com/yu13140/yuhideroot/raw/refs/heads/main/module/apk.zip"
down_cdn "5a703ca791322f3f9295ab741fff860eb214ba971071ba38b387ba0976e4c8a1"
    
    sleep 0.1
    echos "                                        "
    pm uninstall icu.nullptr.nativetest >/dev/null 2>&1
    pm uninstall com.android.nativetest >/dev/null 2>&1
    pm uninstall com.reveny.nativecheck >/dev/null 2>&1
    pm uninstall com.zhenxi.hunter >/dev/null 2>&1
    pm uninstall me.garfieldhan.holmes >/dev/null 2>&1
    echos "${YE}正在为您安装检测软件$RE"
    unzip -o ""$MODULE_DE"" -d "/data/local/tmp/yshell/apks/"
    for apk_file in /data/local/tmp/yshell/apks/*; do
        if [ -f "$apk_file" ] && echo "$apk_file" | grep -iqE '\.apk$'; then
            apk_name="$(basename $apk_file .apk)"
            install_output=$(pm install "$apk_file")
            if echo "$install_output" | grep -iq "Success"; then
                echos "$WH$apk_name安装完成$RE"                
            else
                echos "$WH$apk_name安装失败"
            fi
        fi
    done    
}                  

hidemyapplist() {
echos "                                        "
if [ -d /data/data/com.tsng.hidemyapplist ] || [ -d /data/data/com.tencent.wifimanager ] || [ -d /data/data/com.hicorenational.antifraud ]; then
    if [ -d /data/data/com.tsng.hidemyapplist ]; then
        file2="/data/data/com.tsng.hidemyapplist/files/config.json"
    elif [ -d /data/data/com.tencent.wifimanager ]; then
        file2="/data/data/com.tencent.wifimanager/files/config.json"
    elif [ -d /data/data/com.tsng.hidemyapplist ]; then
        file2="/data/data/com.hicorenational.antifraud/files/config.json"
    fi
    echos "$GR正在下载配置文件$RE"
    CDNUM=1
    speedforcheck
    MODULE_DE="$YSHELL_PATH/config.json"
    cdn_url="https://github.com/yu13140/yuhideroot/raw/refs/heads/main/module/config.json"
    down_cdn "a54af8e29e47c2d9d9a3d35b2b028b6e34194ea3a2f3ab810dcc1e293881bb7f"
    sleep 0.1
    echos "                                        "
    if [ -f "$file1" ]; then
        if [ ! -d "$backup_dir" ]; then
            mkdir -p "$backup_dir"    
        fi
    
        if [ -f "$file2" ]; then
            cp "$file2" "$backup_file"
            echos "$YE备份完成：已将原配置文件备份到$backup_dir$RE"
        else
            echos "$YE警告：原配置文件不存在，跳过备份$RE"
        fi    
        cat "$file1" > "$file2"
        sleep 1.4
        echos "$GR配置已完成$RE" 
    fi
rm -f $file1
ends
else
    echos "$YE没有找到隐藏应用列表应用"
    echos "下载下来的配置文件将存放在/sdcard/Download/文件夹里"
    echos "需要您手动到隐藏应用列表里点击还原配置$RE"
    echos "$GR正在下载配置文件$RE"
    $DOWN1 https://fs-im-kefu.7moor-fs1.com/ly/4d2c3f00-7d4c-11e5-af15-41bf63ae4ea0/1737828707591/config.json $DOWN3
    sleep 0.1
    echos " "
    mv -f $file1 /sdcard/Download/配置隐藏应用列表.json
    echos "已将配置文件保存在 /sdcard/Download/ 中"
    ends
fi
}

recoverapplist() {
echos " "
if [ -d /data/data/com.tsng.hidemyapplist ] || [ -d /data/data/com.tencent.wifimanager ]; then
    if [ -d /data/data/com.tsng.hidemyapplist ]; then
        file2="/data/data/com.tsng.hidemyapplist/files/config.json"
    elif [ -d /data/data/com.tencent.wifimanager ]; then
        file2="/data/data/com.tencent.wifimanager/files/config.json"
    elif [ -d /data/data/com.tencent.wifimanager ]; then
        file2="/data/data/com.hicorenational.antifraud/files/config.json"
    fi
    if [ -f "$backup_file" ]; then
       cat "$backup_file" > "$file2"
       rm -f $backup_file
       sleep 1
       echos "$YE恢复备份成功$RE"
       ends
    else
       echos "$YE错误：备份文件不存在！$RE"
       exit 0
    fi
else
    echos "$YE未找到手机上的隐藏应用列表$RE"
    exit 0
fi
}

extramodule() {
extraout() {
        echos "1.回到主菜单       2.继续输入         3.退出此脚本$RE"
	    echos " "
	    echos "$GR请输入选项：$RE\c"
	    read whextra
	    case $whextra in
        1) 
        clear; selmenu ;;
        2) 
        clear; extramodule ;;
        3) 
        echos "$GR正在退出脚本……$RE"; sleep 1; exit 0 ;;
        *)
        echos "$GR输入错误，默认返回主菜单$RE"; clear; selmenu ;; 
        esac
}

IMODULELIST=(
           "$GR你正在使用 安装设备上的指定模块 功能$RE"           
           "                              "
           "$GR你可以输入一个文件夹，自动识别该文件夹内的压缩包"
           "需要安装的模块的上一级路径，请确认没有同名文件夹或文件，不然可能会出现问题"          
           "你也可以输入需要安装的模块的绝对路径"
           "                          $RE"                              
	       )
	for exm in "${!IMODULELIST[@]}"; do
        echos "${IMODULELIST[$exm]}"
        sleep 0.07
    done
    echos "$YE请输入你需要安装的模块的路径"
    echos "路径：$RE\c"   
	read wmo
	if [ -d $wmo ]; then
	    MODULE_DE=""
	    module_found=0
	    for MODULE_DE in "$wmo"/*; do	        
	        if [ -f "$MODULE_DE" ] && echo "$MODULE_DE" | grep -iqE '\.zip$'; then
	            installer
	            module_found=1
	            if [ $? -ne 0 ]; then
	                echos "$YE模块：$MODULE_DE安装失败$RE"   
	            fi
	        fi	        
	    done
	    if [ $module_found -eq 0 ]; then	    
	        echos "$YE你输入的文件夹里好像没有压缩包呢，需要退出此功能吗$RE"
	        extraout    
	    fi    
	    MODULE_DE="$YSHELL_PATH/installmodule.zip"
	    downout
	elif [ -f $wmo ]; then
	    MODULE_DE="$wmo"
	    installer
	    MODULE_DE="$YSHELL_PATH/installmodule.zip"
	    downout
        if [ $? -ne 0 ]; then
	        echos "$YE模块：$MODULE_DE安装失败$RE"   
	    fi
	else
	    echos "$YE你输入的好像不是一个压缩包或者一个文件夹呢，需要退出此功能吗$RE"
	    extraout
    fi	      
}

switchroot() {
ddQualcomm() {
platform=$(getprop ro.board.platform 2>/dev/null)
if echo "$platform" | grep -qiE '^(msm|apq|qsd)'; then
    echos "$GR检测到高通处理器（平台：$platform）$RE"
    return
fi
hardware=$(getprop ro.hardware 2>/dev/null)
[ -z "$hardware" ] && hardware=$(getprop ro.boot.hardware 2>/dev/null)
if echo "$hardware" | grep -qi 'qcom'; then
    echos "$GR检测到高通处理器（硬件：$hardware）$RE" 
    return   
fi
if grep -qiE 'qualcomm|qcom' /proc/cpuinfo 2>/dev/null; then
    echos "$GR检测到高通处理器（来自/proc/cpuinfo）$RE"  
    return  
fi
if [ -f /system/build.prop ]; then
    if grep -qiE 'qualcomm|qcom' /system/build.prop 2>/dev/null; then
        echos "$GR检测到高通处理器（来自/system/build.prop）$RE"  
        return      
    fi
fi

echos "$YE未检测到高通处理器$RE"
exit 0
}
ddQualcomm 
echos "$GR你正在使用 快捷切换Root方案 功能"
echos "此功能的实现都在模块内完成"
echos "感谢酷安@Aurora星空_Z的AMMF框架！"
echos "正在下载必要文件……$RE"
CDNUM=1
speedforcheck
cdn_url="https://github.com/yu13140/RootSwitcher/releases/download/v2.3.0_development/RootSwitcher_v2.3.0_development.zip"
down_cdn "04d23e833db2aa2dde7c37234491230baf6812cc0a6e33cd04799a61806fbd6e"
}

awarmlist() {
clear
CDNUM=1
speedforcheck
clear
if [ $CDNUM = 1 ]; then
    echos "$YE在刷入模块之前，检测到您的网络存在较大波动"
    echos "建议您不要选择将全部模块删除 ！! ！$RE"
    echos " "
fi
WARMLIST=(
           "$GR你正在使用 一键刷入所需模块 功能$RE"           
           "                              "
           "$YE非常感谢酷安@Aurora星空_Z的自动化安装模块！"
           "非常感谢酷安@传说中的小菜叶提供的技术支持$RE"
           "                              "
           "$GR请手动选择是否把当前所有模块全部删除"
           "1.删除当前所有模块"
           "2.保留当前所有模块(可能会导致隐藏效果不好)$RE"
	       )
	for don in "${!WARMLIST[@]}"; do
        echos "${WARMLIST[$don]}"
        sleep 0.1
    done
    echos "$YE请输入对应的数字：$RE\c"
	read deleteyn
    case $deleteyn in
    1) 
    echos "$GR你选择了删除所有模块$RE"; rm -rf /data/adb/modules/*; rm -rf /data/adb/shamiko/; rm -rf /data/adb/lspd/; rm -rf /data/adb/zygisksu/; rm -rf /data/adb/tricky_store/; rm -rf /data/adb/modules_update/; yuhide ;;
    2) 
    echos "$GR你选择了保留当前模块$RE"; yuhide ;;
    *) 
    echos "$GR输入错误，请重新输入$RE"; awarmlist ;;
    esac
}

ddpeekaboo() {
if [ ! $ENVIRONMENT = "APatch" ]; then
    echos "$YE非APatch用户请不要安装peekaboo"
    echos "默认跳转到主菜单……$RE"
    selmenu
fi   
echos "$RED这是一个高危选项，请确保手机自备救砖能力$RE"
echos " "
echos "$GR若你已经确认过风险，并选择安装，请输入 1 "
echos "1.安装                         2.不安装"
echos "请输入对应的选项：$RE\c"

if [[ $SHELL == *mt* ]]; then    
    DOWN3="-o "$YSHELL_PATH/peekaboo.kpm""
else    
    DOWN3="-o "$YSHELL_PATH/peekaboo.kpm""
fi

read warnpeekaboo
    case $warnpeekaboo in
    1) 
    echos "$GR正在进入安装模块环节$RE";;
    2) 
    echos "$YE你选择退出安装peekaboo$RE"; return ;;
    *)
    clear; continue ;;
    esac

echos " "
echos "$YE请输入当前APatch的超级密钥，这不会侵犯您的任何隐私"  
echos "输入超级密钥：$RE\c"
read super_key

if [ $super_key = " " ]; then
    echos " "
    echos "$YE超级密钥不能为空！"
    echos "请再次输入超级密钥：$RE\c"
    read super_key
fi

if [ -d /data/data/me.garfieldhan.apatch.next ] && [ $NEXT_AP = 1 ]; then
    APP_AP_PATH="/data/data/me.garfieldhan.apatch.next/patch"
elif [ -d /data/data/me.bmax.apatch ] && [ $NEXT_AP = 0 ]; then
    APP_AP_PATH="/data/data/me.bmax.apatch/patch"
else
    echos "$YE未找到你的APatch，请确认是否安装了APatch管理器$RE"
fi

if [[ ! -d "/dev/block/by-name" ]]; then   
    SITE="/dev/block/bootdevice/by-name"
    if [[ ! -d "/dev/block/bootdevice/by-name" ]]; then
        echos "$YE未检测到分区路径，接下来不会嵌入peekboo$RE"
        return
    fi 
else
    SITE="/dev/block/by-name" 
fi
    if [ $($APP_AP_PATH/kpatch "$super_key" kpm num) -ne 0 ]; then
        echos "$YE检测到已经装有内核模块"
        echos "如果仍要使用会把已经安装的内核模块删除"
        echos " "
        echos "1.仍要安装                        2.不安装"
        echos "请输入对应的选项：$RE\c"
        read peekabooinit
        case $peekabooinit in
        1) 
        echos "$GR你选择了仍要安装$RE";;
        2) 
        echos "$YE你选择退出安装peekaboo$RE"; return ;;
        *)
        echos "$YE输入错误，默认不安装$RE"; return ;;
        esac
    fi
CDNUM=1
cdn_url="${CDN}https://github.com/yu13140/yuhideroot/raw/refs/heads/main/module/peekaboo/cherish_peekaboo_${pvs}.kpm"
MODULE_DE="$YSHELL_PATH/cherish_peekaboo_${pvs}.kpm"
if [ $APATCH_VERSION -eq 11021 ]; then
    echos "$WH检测到您正在使用APatch Next(11021)"
    echos "推荐使用cherish_peekaboo_1.5.5" && pvs=1.5.5
    echos "正在下载中……$RE"
    speedforcheck
    down_cdn "a34f454b446ce3a15a08f3927b9129a1656b54875998ac220b7612cf6ab7b390"     
elif [ $APATCH_VERSION -le 11010 ] && [ $APATCH_VERSION -ge 10983 ]; then
    echos "$WH检测到您正在使用APatch($APATCH_VERSION)"
    echos "推荐使用cherish_peekaboo_1.5" && pvs=1.5
    echos "正在下载中……$RE"
    speedforcheck
    down_cdn "dec811b081676f21c8dcaeeda54b38a87049f08d7567cb191be28dddf84280e7"    
else 
    echos "$WH检测到您正在使用APatch($APATCH_VERSION)"
    echos "推荐使用cherish_peekaboo_1.3.1_test"
    echos "正在下载中……$RE"
    speedforcheck
    down_cdn "ee57d7e3316ffe973a62857589234f068a38f8851edf32cf7e9268ad09d4c02b"
fi

set -e

cd $YSHELL_PATH
cp /data/adb/ap/bin/magiskboot $YSHELL_PATH/
command -v ./magiskboot >/dev/null 2>&1 || { >&2 echo "- Command magiskboot not found!"; exit 1; }
command -v $APP_AP_PATH/kptools >/dev/null 2>&1 || { >&2 echo "- Command kptools not found!"; exit 1; }
if [ ! -f $APP_AP_PATH/new-boot.img ]; then
    echos "$WH未找到APatch修补后的boot.img！$RE"
    exit 1
fi
cp $APP_AP_PATH/new-boot.img $YSHELL_PATH/ 

./magiskboot unpack $YSHELL_PATH/new-boot.img
if [ ! $($APP_AP_PATH/kptools -i $YSHELL_PATH/kernel -l | grep patched=false) ]; then
    $APP_AP_PATH/kptools -u --image "$YSHELL_PATH"/kernel --out "$YSHELL_PATH"/rekernel
else
    mv kernel rekernel
fi

rm -f kernel
$APP_AP_PATH/kptools -p -i $YSHELL_PATH/rekernel -s "$super_key" -k $APP_AP_PATH/kpimg -o $YSHELL_PATH/kernel -M $YSHELL_PATH/peekaboo.kpm -V pre-kernel-init -T kpm
rm -f rekernel
mv new-boot.img boot.img
./magiskboot repack boot.img
rm -f boot.img
rm -f peekaboo.kpm
mv new-boot.img boot.img

BOOTAB="$(getprop ro.build.ab_update)"
Partition_location=$(getprop ro.boot.slot_suffix)
if [[ $BOOTAB = "true" ]]; then
    echos "检测到设备支持A/B分区"    
        if [[ "$Partition_location" == "_a" ]]; then
            echos "$GR你目前处于 A 分区$RE"
            position=$(ls -l $SITE/boot_a | awk '{print $NF}')
        elif [[ "$Partition_location" == "_b" ]]; then
            echos "$GR你目前处于 B 分区$RE"
            position=$(ls -l $SITE/boot_b | awk '{print $NF}')
        elif [[ "$Partition_location" == "" ]]; then 
            echos "$YE未检测到设备目前处于哪个槽位，请选择你需要刷入的槽位"
            echos "音量上：刷入a槽                       音量下：刷入b槽$RE"
            echo "a" > $MODPATH/ab.txt ; echo "b" >> $MODPATH/ab.txt
            select_on_magisk "$MODPATH/ab.txt"
            case $SELECT_OUTPUT in 
            a) 
            position=$(ls -l $SITE/boot_a | awk '{print $NF}') ;;
            b) 
            position=$(ls -l $SITE/boot_b | awk '{print $NF}') ;;
            *)
            echos "$YE输入错误，默认安装到a槽$RE"; position=$(ls -l $SITE/boot_a | awk '{print $NF}') ;;
           esac
        fi
else
    position=$(ls -l $SITE/boot | awk '{print $NF}')
fi        

dd if=boot.img of="$position" bs=4M
echos "$GR已成功刷入peekaboo模块$RE"
rm -rf $YSHELL_PATH/*      
}

yuhide() {    
    echos "$WH临时把Selinux切换至宽容模式，这是安装需要的。$RE"
    setenforce 1
    setenforce 0
    echos "$YE正在下载必要文件中$RE"
    mod=1    
    cdn_url="https://github.com/yu13140/yuhideroot/raw/refs/heads/main/module/ARMIAS.zip"
    down_cdn "39ac2b238429db3659273f2e4950f5ae81d75e07c510a04c41a45ebcc9113b6d"   
     
    BOOTHASH="$(getprop ro.boot.vbmeta.digest 2>/dev/null)"
    three_party="$(printf '0%.0s' {1..64})"
    if [ ! $BOOTHASH = " " ] || [ ! $BOOTHASH = "$three_party" ]; then
        mkdir -p /data/adb/modules/Reset_BootHash		
		echos "id=Reset_BootHash
name=重置哈希值
version=搬运 @yu13140
versionCode=20240917
author=topmiaohan
description=辅助Tricky Store，实现增强BL隐藏。" >>/data/adb/modules/Reset_BootHash/module.prop
        echos "resetprop -n ro.boot.vbmeta.digest $BOOTHASH" >>/data/adb/modules/Reset_BootHash/service.sh
    else
       echos "$GR未检测到哈希值或哈希值错误，自动跳过"
    fi
    
    if [ $ENVIRONMENT = "APatch" ]; then
        echos "$YE选择是否需要刷入cherish_peekaboo模块$RE$RED(高危选项)$RE$YE"
        echos "1.安装                         2.不安装"
        echos "请输入对应的选项：$RE\c"
        read inspeekaboo
        case $inspeekaboo in
        1) 
        ddpeekaboo ;;
        2) 
        echos "$YE你选择不安装peekaboo模块$RE" ;;
        *)
        echos "$YE输入错误，默认不安装$RE" ;;
        esac
    fi            

    if [[ $ENVIRONMENT != "APatch" ]]; then   
        echos " "    
        echos "$YE选择是否安装自动神仙救砖模块(APatch可能会出问题)"
        echos "1.安装                         2.不安装"
        echos "请输入对应的选项：$RE\c"
        read installs
        case $installs in
        1) 
        downautomatic ;;
        2) 
        echos "$YE你选择不安装自动神仙救砖模块$RE" ;;
        *)
        echos "$YE输入错误，默认不安装$RE" ;;
        esac
    fi            
    
    echos " "    
    echos "$YE选择是否安装检测软件10件套"
    echos "1.安装                         2.不安装"
    echos "请输入对应的选项：$RE\c"
read installsapk
    case $installsapk in
    1) 
    installapks ;;
    2) 
    echos "$YE你选择不安装检测软件10件套$RE" ;;
    *)
    echos "$YE输入错误，默认不安装$RE" ;;
    esac
    
    clear
    echos "$YE正在清理残余垃圾，请稍等……$RE"
    rm -f /data/local/tmp/wget-log
    rm -f "$MODULE_DE"
    sleep 1
    setenforce 0
    setenforce 1
    downout
}

menuss() {
case $1 in
    1) 
    clear; menu ;;
    2)
    clear; chlist ;;
    3)
    clear; awarmlist ;;
    4)
    clear; installapks; examm ;;
    5)
    clear; extramodule ;;
    6)
    clear; switchroot ;;    
    f) 
    echos "$GR正在退出脚本$RE"; exit 0 ;;
    *) 
    echos "$YE输入错误，请重新选择$RE"; echos "$GR请等待2秒$RE"; sleep 1.4; selmenu ;;
    esac
}

start() {
	echos "                                        "
	echos "$WH现在时间是：$(date +"%Y年%m月%d日周%w %H时%M分%S秒")$RE"
	echos "$GR您正在使用适用于REDMI 8的简易隐藏root脚本"
    echos "作者：酷安@yu13140$RE"
	echos "                                        "
	echos "$YE本脚本纯免费，如遇到需要缴费使用此脚本的情况"
    echos "说明你被骗了，请立即联系骗子来避免不必要的损失"
    echos "需要给作者打赏，"
    echos "请联系QQ：3031633309或者酷安私信@yu13140"
	echos "                                        "
	echos "注意！！！！！！！！！！！！！！！！"
    echos "在使用脚本前，请你先检查"
    echos "1.手机是否自备救砖能力"
    echos "2.脚本是否使用root权限运行"
    echos "3.国外手机使用此脚本可能没有用(如红魔，索尼)$RE"
    echos "                                        "
	echos "$RED请仔细阅读上面的注意事项$RE"
	echos " "
	echos "$YE当前版本：$YUSHELLVERSION$RE$WH"
	echos " "
	echos "- - - - - - -NOTICE- - - - - - -"	
	echos "1.当执行使用开源版本的脚本时，"
	echos "原作者将不会承担其带来的任何后果"
    echos "2.可以进行二改，但请署上原作者名字"
    echos "3.根据许可证，此脚本禁止用于商业用途"
    echos "4.如果想要反馈问题，请联系原作者"
	sleep 1.2
	echos "                                        $RE"
	echos "$GR若需要使用此脚本，请输入 1"
    echos "若需要退出，请输入 2$RE"
	echos "                                        "
	echos "$YE请输入对应的数字：$RE\c "
	read cf
    case $cf in
    1) 
    echos "$GR正在配置脚本"; echos "这可能需要等待几秒钟……$RE"; sleep 1.4; selmenu ;;
    2) 
    echos "$GR正在退出脚本……$RE"; exit 0 ;;
    *) 
    echos "$GR输入错误，退出脚本$RE"; exit 0 ;;
    esac
}       

rm -f $MODULE_DE
trap "settings put global adb_enabled 0;settings put global development_settings_enabled 0" EXIT
clear
settings put global adb_enabled 1
settings put global development_settings_enabled 1
detect_environment
waitingstart

if [[ $SHELL != *mt* ]]; then
    if [[ $SHELL == *termux* ]]; then
        echos "$WH请不要在Termux环境执行此脚本，可能会出现问题$RE"
        exit 1
    fi
    
    if [ ! -f "/data/yshell/busybox" ]; then
        echos "$WH检测到脚本正在使用系统环境，需要额外的配置"
        echos "确定下载吗？(下载过之后就不需要再下载了)"
        echos "1.下载                    2.不下载"
        echos "请输入选项：$RE\c"
        read downelse
        case $downelse in
        1) 
        downbusybox ;;
        2) 
        echos "$GR那就请你使用扩展包选项$RE"; exit 0 ;;
        *) 
        echos "$GR输入错误，退出脚本$RE"; exit 1 ;;
        esac       
    fi
fi    

if [ $ENVIRONMENT = "APatch" ]; then
    if [[ $APATCH_VERSION == 10933 ]]; then
        if [[ $SHELL != *mt* ]]; then
                echos "$YE "           
                echos "APatch10933请使用MT扩展包选项！$RE"
                exit 1
        fi        
        BIN_PATH="$(echo $SHELL | sed 's/bash//g')"
        if [ ! -f $BIN_PATH/cmd ]; then
            echos "$WH  "               
            echos "Oops！你的APatch版本为10933"                          
            echos "或许需要一些额外设置，才能使用脚本"
            echos "正在下载中(如果觉得下载慢，可以开启VPN)$RE"                
            CDNUM=1 && MODULE_DE="$YSHELL_PATH/cmd"
            speedforcheck
            cdn_url="https://github.com/yu13140/yuhideroot/raw/refs/heads/main/cmd"
            down_cdn "08da8ac23b6e99788fd3ce6c19c7b5a083b2ad48be35963a48d01d6ee7f3bb6d"
            mv "$YSHELL_PATH/cmd" "$BIN_PATH"
            echos "$WH重新执行脚本以生效$RE"
            exit 0
        fi
    fi
fi

downloader  
start