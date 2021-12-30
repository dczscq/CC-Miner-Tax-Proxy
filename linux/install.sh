#!/bin/bash
stty erase ^H

red='\e[91m'
green='\e[92m'
yellow='\e[94m'
magenta='\e[95m'
cyan='\e[96m'
none='\e[0m'
_red() { echo -e ${red}$*${none}; }
_green() { echo -e ${green}$*${none}; }
_yellow() { echo -e ${yellow}$*${none}; }
_magenta() { echo -e ${magenta}$*${none}; }
_cyan() { echo -e ${cyan}$*${none}; }

# Root
[[ $(id -u) != 0 ]] && echo -e "\n 请使用 ${red}root ${none}用户运行 ${yellow}~(^_^) ${none}\n" && exit 1

cmd="apt-get"

sys_bit=$(uname -m)

case $sys_bit in
'amd64' | x86_64) ;;
*)
    echo -e " 
	 这个 ${red}安装脚本${none} 不支持你的系统。 ${yellow}(-_-) ${none}

	备注: 仅支持 Ubuntu 16+ / Debian 8+ / CentOS 7+ 系统
	" && exit 1
    ;;
esac

# 笨笨的检测方法
if [[ $(command -v apt-get) || $(command -v yum) ]] && [[ $(command -v systemctl) ]]; then

    if [[ $(command -v yum) ]]; then

        cmd="yum"

    fi

else

    echo -e " 
	 这个 ${red}安装脚本${none} 不支持你的系统。 ${yellow}(-_-) ${none}

	备注: 仅支持 Ubuntu 16+ / Debian 8+ / CentOS 7+ 系统
	" && exit 1

fi

if [ ! -d "/etc/ccminer/" ]; then
    mkdir /etc/ccminer/
fi

error() {

    echo -e "\n$red 输入错误！$none\n"

}

eth_miner_config_ask() {
    echo
    while :; do
        echo -e "是否开启 ETH抽水中转， 输入 [${magenta}Y/N${none}] 按回车"
        read -p "$(echo -e "(默认: [${cyan}Y${none}]):")" enableEthProxy
        [[ -z $enableEthProxy ]] && enableEthProxy="y"

        case $enableEthProxy in
        Y | y)
            enableEthProxy="y"
            eth_miner_config
            break
            ;;
        N | n)
            enableEthProxy="n"
            echo
            echo
            echo -e "$yellow 不启用ETH抽水中转 $none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        *)
            error
            ;;
        esac
    done
}

eth_miner_config() {
    echo
    while :; do
        echo -e "请输入ETH矿池域名，例如 eth.f2pool.com，不需要输入矿池端口"
        read -p "$(echo -e "(默认: [${cyan}eth.f2pool.com${none}]):")" ethPoolAddress
        [[ -z $ethPoolAddress ]] && ethPoolAddress="eth.f2pool.com"

        case $ethPoolAddress in
        *[:$]*)
            echo
            echo -e " 由于这个脚本太辣鸡了..所以矿池地址不能包含端口.... "
            echo
            error
            ;;
        *)
            echo
            echo
            echo -e "$yellow ETH矿池地址 = ${cyan}$ethPoolAddress${none}"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        esac
    done
    while :; do
        echo -e "请输入ETH矿池"$yellow"$ethPoolAddress"$none"的端口，不要使用矿池的SSL端口！！！"
        read -p "$(echo -e "(默认端口: ${cyan}6688${none}):")" ethPoolPort
        [ -z "$ethPoolPort" ] && ethPoolPort=6688
        case $ethPoolPort in
        [1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
            echo
            echo
            echo -e "$yellow ETH矿池端口 = $cyan$ethPoolPort$none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        *)
            echo
            echo " ..端口要在1-65535之间啊哥哥....."
            error
            ;;
        esac
    done
    local randomTcp="6688"
    while :; do
        echo -e "请输入ETH本地TCP中转的端口 ["$magenta"1-65535"$none"]，不能选择 "$magenta"80"$none" 或 "$magenta"443"$none" 端口"
        read -p "$(echo -e "(默认TCP端口: ${cyan}${randomTcp}${none}):")" ethTcpPort
        [ -z "$ethTcpPort" ] && ethTcpPort=$randomTcp
        case $ethTcpPort in
        80)
            echo
            echo " ...都说了不能选择 80 端口了咯....."
            error
            ;;
        443)
            echo
            echo " ..都说了不能选择 443 端口了咯....."
            error
            ;;
        [1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
            echo
            echo
            echo -e "$yellow ETH本地TCP中转端口 = $cyan$ethTcpPort$none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        *)
            error
            ;;
        esac
    done
    local randomTls="12345"
    while :; do
        echo -e "请输入ETH本地SSL中转的端口 ["$magenta"1-65535"$none"]，不能选择 "$magenta"80"$none" 或 "$magenta"443"$none" 或 "$magenta"$ethTcpPort"$none" 端口"
        read -p "$(echo -e "(默认端口: ${cyan}${randomTls}${none}):")" ethTlsPort
        [ -z "$ethTlsPort" ] && ethTlsPort=$randomTls
        case $ethTlsPort in
        80)
            echo
            echo " ...都说了不能选择 80 端口了咯....."
            error
            ;;
        443)
            echo
            echo " ..都说了不能选择 443 端口了咯....."
            error
            ;;
        $ethTcpPort)
            echo
            echo " ..不能和 TCP端口 $ethTcpPort 一毛一样....."
            error
            ;;
        [1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
            echo
            echo
            echo -e "$yellow ETH本地SSL中转端口 = $cyan$ethTlsPort$none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        *)
            error
            ;;
        esac
    done
    while :; do
        echo -e "请输入你的ETH钱包地址或者你在矿池的用户名"
        read -p "$(echo -e "(一定不要输入错误，错了就抽给别人了):")" ethUser
        if [ -z "$ethUser" ]; then
            echo
            echo
            echo " ..一定要输入一个钱包地址或者用户名啊....."
            echo
        else
            echo
            echo
            echo -e "$yellow ETH抽水用户名/钱包名 = $cyan$ethUser$none"
            echo "----------------------------------------------------------------"
            echo
            break
        fi
    done
    while :; do
        echo -e "请输入你喜欢的矿工名，抽水成功后你可以在矿池看到这个矿工名"
        read -p "$(echo -e "(默认: [${cyan}worker${none}]):")" ethWorker
        [[ -z $ethWorker ]] && ethWorker="worker"
        echo
        echo
        echo -e "$yellow ETH抽水矿工名 = ${cyan}$ethWorker${none}"
        echo "----------------------------------------------------------------"
        echo
        break
    done
    while :; do
        echo -e "请输入ETH抽水比例 ["$magenta"0.3-20"$none"]"
        read -p "$(echo -e "(默认: ${cyan}6${none}):")" ethTaxPercent
        [ -z "$ethTaxPercent" ] && ethTaxPercent=6
        case $ethTaxPercent in
        0\.[3-9] | 0\.[3-9][0-9]* | [1-9] | 1[0-9] | 20 | [1-9]\.[0-9]* | 1[0-9]\.[0-9]*)
            echo
            echo
            echo -e "$yellow ETH抽水比例 = $cyan$ethTaxPercent%$none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        *)
            echo
            echo " ..输入的抽水比例要在0.3-20之间，如果用的是整数不要加小数点....."
            error
            ;;
        esac
    done
}

etc_miner_config_ask() {
    echo
    while :; do
        echo -e "是否开启 ETC抽水中转, 输入 [${magenta}Y/N${none}] 按回车"
        read -p "$(echo -e "(默认: [${cyan}N${none}]):")" enableEtcProxy
        [[ -z $enableEtcProxy ]] && enableEtcProxy="n"

        case $enableEtcProxy in
        Y | y)
            enableEtcProxy="y"
            etc_miner_config
            break
            ;;
        N | n)
            enableEtcProxy="n"
            echo
            echo
            echo -e "$yellow 不启用ETC抽水中转 $none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        *)
            error
            ;;
        esac
    done
}

etc_miner_config() {
    echo
    while :; do
        echo -e "请输入ETC矿池域名，例如 etc.f2pool.com，不需要输入矿池端口"
        read -p "$(echo -e "(默认: [${cyan}etc.f2pool.com${none}]):")" etcPoolAddress
        [[ -z $etcPoolAddress ]] && etcPoolAddress="etc.f2pool.com"

        case $etcPoolAddress in
        *[:$]*)
            echo
            echo -e " 由于这个脚本太辣鸡了..所以矿池地址不能包含端口.... "
            echo
            error
            ;;
        *)
            echo
            echo
            echo -e "$yellow ETC矿池地址 = ${cyan}$etcPoolAddress${none}"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        esac
    done
    while :; do
        echo -e "请输入ETC矿池"$yellow"$etcPoolAddress"$none"的端口，不要使用矿池的SSL端口！！！"
        read -p "$(echo -e "(默认端口: ${cyan}8118${none}):")" etcPoolPort
        [ -z "$etcPoolPort" ] && etcPoolPort=8118
        case $etcPoolPort in
        [1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
            echo
            echo
            echo -e "$yellow ETC矿池端口 = $cyan$etcPoolPort$none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        *)
            echo
            echo " ..端口要在1-65535之间啊哥哥....."
            error
            ;;
        esac
    done
    local randomTcp="8118"
    while :; do
        echo -e "请输入ETC本地TCP中转的端口 ["$magenta"1-65535"$none"]，不能选择 "$magenta"80"$none" 或 "$magenta"443"$none" 端口"
        read -p "$(echo -e "(默认TCP端口: ${cyan}${randomTcp}${none}):")" etcTcpPort
        [ -z "$etcTcpPort" ] && etcTcpPort=$randomTcp
        case $etcTcpPort in
        80)
            echo
            echo " ...都说了不能选择 80 端口了咯....."
            error
            ;;
        443)
            echo
            echo " ..都说了不能选择 443 端口了咯....."
            error
            ;;
        [1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
            echo
            echo
            echo -e "$yellow ETC本地TCP中转端口 = $cyan$etcTcpPort$none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        *)
            error
            ;;
        esac
    done
    local randomTls="22345"
    while :; do
        echo -e "请输入ETC本地SSL中转的端口 ["$magenta"1-65535"$none"]，不能选择 "$magenta"80"$none" 或 "$magenta"443"$none" 或 "$magenta"$etcTcpPort"$none" 端口"
        read -p "$(echo -e "(默认端口: ${cyan}${randomTls}${none}):")" etcTlsPort
        [ -z "$etcTlsPort" ] && etcTlsPort=$randomTls
        case $etcTlsPort in
        80)
            echo
            echo " ...都说了不能选择 80 端口了咯....."
            error
            ;;
        443)
            echo
            echo " ..都说了不能选择 443 端口了咯....."
            error
            ;;
        $etcTcpPort)
            echo
            echo " ..不能和 TCP端口 $etcTcpPort 一毛一样....."
            error
            ;;
        [1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
            echo
            echo
            echo -e "$yellow ETC本地SSL中转端口 = $cyan$etcTlsPort$none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        *)
            error
            ;;
        esac
    done
    while :; do
        echo -e "请输入你的ETC钱包地址或者你在矿池的用户名"
        read -p "$(echo -e "(一定不要输入错误，错了就抽给别人了):")" etcUser
        if [ -z "$etcUser" ]; then
            echo
            echo
            echo " ..一定要输入一个钱包地址或者用户名啊....."
        else
            echo
            echo
            echo -e "$yellow ETC抽水用户名/钱包名 = $cyan$etcUser$none"
            echo "----------------------------------------------------------------"
            echo
            break
        fi
    done
    while :; do
        echo -e "请输入你喜欢的矿工名，抽水成功后你可以在矿池看到这个矿工名"
        read -p "$(echo -e "(默认: [${cyan}worker${none}]):")" etcWorker
        [[ -z $etcWorker ]] && etcWorker="worker"
        echo
        echo
        echo -e "$yellow ETC抽水矿工名 = ${cyan}$etcWorker${none}"
        echo "----------------------------------------------------------------"
        echo
        break
    done
    while :; do
        echo -e "请输入ETC抽水比例 ["$magenta"0.3-20"$none"]"
        read -p "$(echo -e "(默认: ${cyan}6${none}):")" etcTaxPercent
        [ -z "$etcTaxPercent" ] && etcTaxPercent=6
        case $etcTaxPercent in
        0\.[3-9] | 0\.[3-9][0-9]* | [1-9] | 1[0-9] | 20 | [1-9]\.[0-9]* | 1[0-9]\.[0-9]*)
            echo
            echo
            echo -e "$yellow ETC抽水比例 = $cyan$etcTaxPercent%$none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        *)
            echo
            echo " ..输入的抽水比例要在0.3-20之间，如果用的是整数不要加小数点....."
            error
            ;;
        esac
    done
}

btc_miner_config_ask() {
    echo
    while :; do
        echo -e "是否开启 BTC抽水中转， 输入 [${magenta}Y或者N${none}] 按回车"
        read -p "$(echo -e "(默认: [${cyan}N${none}]):")" enableBtcProxy
        [[ -z $enableBtcProxy ]] && enableBtcProxy="n"

        case $enableBtcProxy in
        Y | y)
            enableBtcProxy="y"
            btc_miner_config
            break
            ;;
        N | n)
            enableBtcProxy="n"
            echo
            echo
            echo -e "$yellow 不启用BTC抽水中转 $none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        *)
            error
            ;;
        esac
    done
}

http_logger_config_ask() {
    echo
    while :; do
        echo -e "是否开启 网页监控平台， 输入 [${magenta}Y或者N${none}] 按回车"
        read -p "$(echo -e "(默认: [${cyan}Y${none}]):")" enableHttpLog
        [[ -z $enableHttpLog ]] && enableHttpLog="y"

        case $enableHttpLog in
        Y | y)
            enableHttpLog="y"
            http_logger_miner_config
            break
            ;;
        N | n)
            enableHttpLog="n"
            echo
            echo
            echo -e "$yellow 不启用网页监控平台 $none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        *)
            error
            ;;
        esac
    done
}

btc_miner_config() {
    echo
    while :; do
        echo -e "请输入BTC矿池域名，例如 btc.f2pool.com，不需要输入矿池端口"
        read -p "$(echo -e "(默认: [${cyan}btc.f2pool.com${none}]):")" btcPoolAddress
        [[ -z $btcPoolAddress ]] && btcPoolAddress="btc.f2pool.com"

        case $btcPoolAddress in
        *[:$]*)
            echo
            echo -e " 由于这个脚本太辣鸡了..所以矿池地址不能包含端口.... "
            echo
            error
            ;;
        *)
            echo
            echo
            echo -e "$yellow BTC矿池地址 = ${cyan}$btcPoolAddress${none}"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        esac
    done
    while :; do
        echo -e "请输入BTC矿池"$yellow"$btcPoolAddress"$none"的端口，不要使用矿池的SSL端口！！！"
        read -p "$(echo -e "(默认端口: ${cyan}3333${none}):")" btcPoolPort
        [ -z "$btcPoolPort" ] && btcPoolPort=3333
        case $btcPoolPort in
        [1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
            echo
            echo
            echo -e "$yellow BTC矿池端口 = $cyan$btcPoolPort$none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        *)
            echo
            echo " ..端口要在1-65535之间啊哥哥....."
            error
            ;;
        esac
    done
    local randomTcp="3333"
    while :; do
        echo -e "请输入BTC本地TCP中转的端口 ["$magenta"1-65535"$none"]，不能选择 "$magenta"80"$none" 或 "$magenta"443"$none" 端口"
        read -p "$(echo -e "(默认TCP端口: ${cyan}${randomTcp}${none}):")" btcTcpPort
        [ -z "$btcTcpPort" ] && btcTcpPort=$randomTcp
        case $btcTcpPort in
        80)
            echo
            echo " ...都说了不能选择 80 端口了咯....."
            error
            ;;
        443)
            echo
            echo " ..都说了不能选择 443 端口了咯....."
            error
            ;;
        [1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
            echo
            echo
            echo -e "$yellow BTC本地TCP中转端口 = $cyan$btcTcpPort$none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        *)
            error
            ;;
        esac
    done
    local randomTls="32345"
    while :; do
        echo -e "请输入BTC本地SSL中转的端口 ["$magenta"1-65535"$none"]，不能选择 "$magenta"80"$none" 或 "$magenta"443"$none" 或 "$magenta"$btcTcpPort"$none" 端口"
        read -p "$(echo -e "(默认端口: ${cyan}${randomTls}${none}):")" btcTlsPort
        [ -z "$btcTlsPort" ] && btcTlsPort=$randomTls
        case $btcTlsPort in
        80)
            echo
            echo " ...都说了不能选择 80 端口了咯....."
            error
            ;;
        443)
            echo
            echo " ..都说了不能选择 443 端口了咯....."
            error
            ;;
        $btcTcpPort)
            echo
            echo " ..不能和 TCP端口 $btcTcpPort 一毛一样....."
            error
            ;;
        [1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
            echo
            echo
            echo -e "$yellow BTC本地SSL中转端口 = $cyan$btcTlsPort$none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        *)
            error
            ;;
        esac
    done
    while :; do
        echo -e "请输入你在矿池的BTC账户用户名"
        read -p "$(echo -e "(一定不要输入错误，错了就抽给别人了):")" btcUser
        if [ -z "$btcUser" ]; then
            echo
            echo
            echo " ..一定要输入一个用户名啊....."
        else
            echo
            echo
            echo -e "$yellow BTC抽水用户名 = $cyan$btcUser$none"
            echo "----------------------------------------------------------------"
            echo
            break
        fi
    done
    while :; do
        echo -e "请输入你喜欢的矿工名，抽水成功后你可以在矿池看到这个矿工名"
        read -p "$(echo -e "(默认: [${cyan}worker${none}]):")" btcWorker
        [[ -z $btcWorker ]] && btcWorker="worker"
        echo
        echo
        echo -e "$yellow BTC抽水矿工名 = ${cyan}$btcWorker${none}"
        echo "----------------------------------------------------------------"
        echo
        break
    done
    while :; do
        echo -e "请输入ETC抽水比例 ["$magenta"0.3-20"$none"]"
        read -p "$(echo -e "(默认: ${cyan}6${none}):")" btcTaxPercent
        [ -z "$btcTaxPercent" ] && btcTaxPercent=6
        case $btcTaxPercent in
        0\.[3-9] | 0\.[3-9][0-9]* | [1-9] | 1[0-9] | 20 | [1-9]\.[0-9]* | 1[0-9]\.[0-9]*)
            echo
            echo
            echo -e "$yellow BTC抽水比例 = $cyan$btcTaxPercent%$none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        *)
            echo
            echo " ..输入的抽水比例要在0.3-20之间，如果用的是整数不要加小数点....."
            error
            ;;
        esac
    done
}

http_logger_miner_config() {
    local randomTcp="8080"
    while :; do
        echo -e "请输入网页监控平台访问端口 ["$magenta"1-65535"$none"]，不能选择 "$magenta"80"$none" 或 "$magenta"443"$none" 端口"
        read -p "$(echo -e "(默认网页监控平台访问端口: ${cyan}${randomTcp}${none}):")" httpLogPort
        [ -z "$httpLogPort" ] && httpLogPort=$randomTcp
        case $httpLogPort in
        80)
            echo
            echo " ...都说了不能选择 80 端口了咯....."
            error
            ;;
        443)
            echo
            echo " ..都说了不能选择 443 端口了咯....."
            error
            ;;
        [1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
            echo
            echo
            echo -e "$yellow 网页监控平台访问端口 = $cyan$httpLogPort$none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        *)
            error
            ;;
        esac
    done
    while :; do
        echo -e "请输入网页监控平台登录密码，不能包含双引号，不然无法启动"
        read -p "$(echo -e "(一定不要输入那种很简单的密码):")" httpLogPassword
        if [ -z "$httpLogPassword" ]; then
            echo
            echo
            echo " ..一定要输入一个密码啊....."
        else
            echo
            echo
            echo -e "$yellow 网页监控平台密码 = $cyan$httpLogPassword$none"
            echo "----------------------------------------------------------------"
            echo
            break
        fi
    done
}

print_all_config() {
    clear
    echo
    echo " ....准备安装了咯..看看有毛有配置正确了..."
    echo
    echo "---------- 安装信息 -------------"
    echo
    echo -e "$yellow CaoCaoMinerTaxProxy将被安装到$installPath${none}"
    echo
    echo "----------------------------------------------------------------"
    if [[ "$enableEthProxy" = "y" ]]; then
        echo "ETH 中转抽水配置"
        echo -e "$yellow ETH矿池地址 = ${cyan}$ethPoolAddress${none}"
        echo -e "$yellow ETH矿池端口 = $cyan$ethPoolPort$none"
        echo -e "$yellow ETH本地TCP中转端口 = $cyan$ethTcpPort$none"
        echo -e "$yellow ETH本地SSL中转端口 = $cyan$ethTlsPort$none"
        echo -e "$yellow ETH抽水用户名/钱包名 = $cyan$ethUser$none"
        echo -e "$yellow ETH抽水矿工名 = ${cyan}$ethWorker${none}"
        echo -e "$yellow ETH抽水比例 = $cyan$ethTaxPercent%$none"
        echo "----------------------------------------------------------------"
    fi
    if [[ "$enableEtcProxy" = "y" ]]; then
        echo "ETC 中转抽水配置"
        echo -e "$yellow ETC矿池地址 = ${cyan}$etcPoolAddress${none}"
        echo -e "$yellow ETC矿池端口 = $cyan$etcPoolPort$none"
        echo -e "$yellow ETC本地TCP中转端口 = $cyan$etcTcpPort$none"
        echo -e "$yellow ETC本地SSL中转端口 = $cyan$etcTlsPort$none"
        echo -e "$yellow ETC抽水用户名/钱包名 = $cyan$etcUser$none"
        echo -e "$yellow ETC抽水矿工名 = ${cyan}$etcWorker${none}"
        echo -e "$yellow ETC抽水比例 = $cyan$etcTaxPercent%$none"
        echo "----------------------------------------------------------------"
    fi
    if [[ "$enableBtcProxy" = "y" ]]; then
        echo "BTC 中转抽水配置"
        echo -e "$yellow BTC矿池地址 = ${cyan}$btcPoolAddress${none}"
        echo -e "$yellow BTC矿池端口 = $cyan$btcPoolPort$none"
        echo -e "$yellow BTC本地TCP中转端口 = $cyan$btcTcpPort$none"
        echo -e "$yellow BTC本地SSL中转端口 = $cyan$btcTlsPort$none"
        echo -e "$yellow BTC抽水用户名/钱包名 = $cyan$btcUser$none"
        echo -e "$yellow BTC抽水矿工名 = ${cyan}$btcWorker${none}"
        echo -e "$yellow BTC抽水比例 = $cyan$btcTaxPercent%$none"
        echo "----------------------------------------------------------------"
    fi
    if [[ "$enableHttpLog" = "y" ]]; then
        echo "网页监控平台配置"
        echo -e "$yellow 网页监控平台端口 = ${cyan}$httpLogPort${none}"
        echo -e "$yellow 网页监控平台密码 = $cyan$httpLogPassword$none"
        echo "----------------------------------------------------------------"
    fi
    echo
    while :; do
        echo -e "确认以上配置项正确吗，确认输入Y，可选输入项[${magenta}Y/N${none}] 按回车"
        read -p "$(echo -e "(默认: [${cyan}Y${none}]):")" confirmConfigRight
        [[ -z $confirmConfigRight ]] && confirmConfigRight="y"

        case $confirmConfigRight in
        Y | y)
            confirmConfigRight="y"
            break
            ;;
        N | n)
            confirmConfigRight="n"
            echo
            echo
            echo -e "$yellow 退出安装 $none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        *)
            error
            ;;
        esac
    done
}

install_download() {
    $cmd update -y
    if [[ $cmd == "apt-get" ]]; then
        $cmd install -y lrzsz git zip unzip curl wget supervisor
        service supervisor restart
    else
        $cmd install -y epel-release
        $cmd update -y
        $cmd install -y lrzsz git zip unzip curl wget supervisor
        systemctl enable supervisord
        service supervisord restart
    fi
    [ -d /tmp/ccminer ] && rm -rf /tmp/ccminer
    mkdir -p /tmp/ccminer
    git clone https://github.com/CaoCaoMiner/CC-Miner-Tax-Proxy -b release /tmp/ccminer/gitcode --depth=1

    if [[ ! -d /tmp/ccminer/gitcode ]]; then
        echo
        echo -e "$red 哎呀呀...克隆脚本仓库出错了...$none"
        echo
        echo -e " 温馨提示..... 请尝试自行安装 Git: ${green}$cmd install -y git $none 之后再安装此脚本"
        echo
        exit 1
    fi
    cp -rf /tmp/ccminer/gitcode/linux $installPath
    if [[ ! -d $installPath ]]; then
        echo
        echo -e "$red 哎呀呀...复制文件出错了...$none"
        echo
        echo -e " 温馨提示..... 使用最新版本的Ubuntu或者CentOS再试试"
        echo
        exit 1
    fi
}

write_json() {
    rm -rf $installPath/config.json
    jsonPath="$installPath/config.json"
    echo "{" >>$jsonPath

    if [[ "$enableEthProxy" = "y" ]]; then
        echo "  \"ethPoolAddress\": \"${ethPoolAddress}\"," >>$jsonPath
        echo "  \"ethPoolPort\": ${ethPoolPort}," >>$jsonPath
        echo "  \"ethTcpPort\": ${ethTcpPort}," >>$jsonPath
        echo "  \"ethTlsPort\": ${ethTlsPort}," >>$jsonPath
        echo "  \"ethUser\": \"${ethUser}\"," >>$jsonPath
        echo "  \"ethWorker\": \"${ethWorker}\"," >>$jsonPath
        echo "  \"ethTaxPercent\": ${ethTaxPercent}," >>$jsonPath
        echo "  \"enableEthProxy\": true," >>$jsonPath
        if [[ $cmd == "apt-get" ]]; then
            ufw allow $ethTcpPort
            ufw allow $ethTlsPort
        else
            firewall-cmd --zone=public --add-port=$ethTcpPort/tcp --permanent
            firewall-cmd --zone=public --add-port=$ethTlsPort/tcp --permanent
        fi
    else
        echo "  \"ethPoolAddress\": \"eth.f2pool.com\"," >>$jsonPath
        echo "  \"ethPoolPort\": 6688," >>$jsonPath
        echo "  \"ethTcpPort\": 6688," >>$jsonPath
        echo "  \"ethTlsPort\": 12345," >>$jsonPath
        echo "  \"ethUser\": \"UserOrAddress\"," >>$jsonPath
        echo "  \"ethWorker\": \"worker\"," >>$jsonPath
        echo "  \"ethTaxPercent\": 6," >>$jsonPath
        echo "  \"enableEthProxy\": false," >>$jsonPath
    fi
    if [[ "$enableEtcProxy" = "y" ]]; then
        echo "  \"etcPoolAddress\": \"${etcPoolAddress}\"," >>$jsonPath
        echo "  \"etcPoolPort\": ${etcPoolPort}," >>$jsonPath
        echo "  \"etcTcpPort\": ${etcTcpPort}," >>$jsonPath
        echo "  \"etcTlsPort\": ${etcTlsPort}," >>$jsonPath
        echo "  \"etcUser\": \"${etcUser}\"," >>$jsonPath
        echo "  \"etcWorker\": \"${etcWorker}\"," >>$jsonPath
        echo "  \"etcTaxPercent\": ${etcTaxPercent}," >>$jsonPath
        echo "  \"enableEtcProxy\": true," >>$jsonPath
        if [[ $cmd == "apt-get" ]]; then
            ufw allow $etcTcpPort
            ufw allow $etcTlsPort
        else
            firewall-cmd --zone=public --add-port=$etcTcpPort/tcp --permanent
            firewall-cmd --zone=public --add-port=$etcTlsPort/tcp --permanent
        fi
    else
        echo "  \"etcPoolAddress\": \"etc.f2pool.com\"," >>$jsonPath
        echo "  \"etcPoolPort\": 8118," >>$jsonPath
        echo "  \"etcTcpPort\": 8118," >>$jsonPath
        echo "  \"etcTlsPort\": 22345," >>$jsonPath
        echo "  \"etcUser\": \"UserOrAddress\"," >>$jsonPath
        echo "  \"etcWorker\": \"worker\"," >>$jsonPath
        echo "  \"etcTaxPercent\": 6," >>$jsonPath
        echo "  \"enableEtcProxy\": false," >>$jsonPath
    fi
    if [[ "$enableBtcProxy" = "y" ]]; then
        echo "  \"btcPoolAddress\": \"${btcPoolAddress}\"," >>$jsonPath
        echo "  \"btcPoolPort\": ${btcPoolPort}," >>$jsonPath
        echo "  \"btcTcpPort\": ${btcTcpPort}," >>$jsonPath
        echo "  \"btcTlsPort\": ${btcTlsPort}," >>$jsonPath
        echo "  \"btcUser\": \"${btcUser}\"," >>$jsonPath
        echo "  \"btcWorker\": \"${btcWorker}\"," >>$jsonPath
        echo "  \"btcTaxPercent\": ${btcTaxPercent}," >>$jsonPath
        echo "  \"enableBtcProxy\": true," >>$jsonPath
        if [[ $cmd == "apt-get" ]]; then
            ufw allow $btcTlsPort
            ufw allow $btcTlsPort
        else
            firewall-cmd --zone=public --add-port=$btcTlsPort/tcp --permanent
            firewall-cmd --zone=public --add-port=$btcTlsPort/tcp --permanent
        fi
    else
        echo "  \"btcPoolAddress\": \"btc.f2pool.com\"," >>$jsonPath
        echo "  \"btcPoolPort\": 3333," >>$jsonPath
        echo "  \"btcTcpPort\": 3333," >>$jsonPath
        echo "  \"btcTlsPort\": 32345," >>$jsonPath
        echo "  \"btcUser\": \"UserOrAddress\"," >>$jsonPath
        echo "  \"btcWorker\": \"worker\"," >>$jsonPath
        echo "  \"btcTaxPercent\": 6," >>$jsonPath
        echo "  \"enableBtcProxy\": false," >>$jsonPath
    fi
    if [[ "$enableHttpLog" = "y" ]]; then
        echo "  \"httpLogPort\": ${httpLogPort}," >>$jsonPath
        echo "  \"httpLogPassword\": \"${httpLogPassword}\"," >>$jsonPath
        echo "  \"enableHttpLog\": true," >>$jsonPath
        if [[ $cmd == "apt-get" ]]; then
            ufw allow $httpLogPort
        else
            firewall-cmd --zone=public --add-port=$httpLogPort/tcp --permanent
        fi
    else
        echo "  \"httpLogPort\": 8080," >>$jsonPath
        echo "  \"httpLogPassword\": \"caocaominer\"," >>$jsonPath
        echo "  \"enableHttpLog\": false," >>$jsonPath
    fi

    echo "  \"version\": \"2.0.0\"" >>$jsonPath
    echo "}" >>$jsonPath
    if [[ $cmd == "apt-get" ]]; then
        ufw reload
    else
        systemctl restart firewalld
    fi
}

start_write_config() {
    echo
    echo "下载完成，开始写入配置"
    echo
    chmod a+x $installPath/ccminertaxproxy
    if [ -d "/etc/supervisor/conf/" ]; then
        rm /etc/supervisor/conf/ccminer${installNumberTag}.conf -f
        echo "[program:ccminertaxproxy${installNumberTag}]" >>/etc/supervisor/conf/ccminer${installNumberTag}.conf
        echo "command=${installPath}/ccminertaxproxy" >>/etc/supervisor/conf/ccminer${installNumberTag}.conf
        echo "directory=${installPath}/" >>/etc/supervisor/conf/ccminer${installNumberTag}.conf
        echo "autostart=true" >>/etc/supervisor/conf/ccminer${installNumberTag}.conf
        echo "autorestart=true" >>/etc/supervisor/conf/ccminer${installNumberTag}.conf
    elif [ -d "/etc/supervisor/conf.d/" ]; then
        rm /etc/supervisor/conf.d/ccminer${installNumberTag}.conf -f
        echo "[program:ccminertaxproxy${installNumberTag}]" >>/etc/supervisor/conf.d/ccminer${installNumberTag}.conf
        echo "command=${installPath}/ccminertaxproxy" >>/etc/supervisor/conf.d/ccminer${installNumberTag}.conf
        echo "directory=${installPath}/" >>/etc/supervisor/conf.d/ccminer${installNumberTag}.conf
        echo "autostart=true" >>/etc/supervisor/conf.d/ccminer${installNumberTag}.conf
        echo "autorestart=true" >>/etc/supervisor/conf.d/ccminer${installNumberTag}.conf
    elif [ -d "/etc/supervisord.d/" ]; then
        rm /etc/supervisord.d/ccminer${installNumberTag}.ini -f
        echo "[program:ccminertaxproxy${installNumberTag}]" >>/etc/supervisord.d/ccminer${installNumberTag}.ini
        echo "command=${installPath}/ccminertaxproxy" >>/etc/supervisord.d/ccminer${installNumberTag}.ini
        echo "directory=${installPath}/" >>/etc/supervisord.d/ccminer${installNumberTag}.ini
        echo "autostart=true" >>/etc/supervisord.d/ccminer${installNumberTag}.ini
        echo "autorestart=true" >>/etc/supervisord.d/ccminer${installNumberTag}.ini
    else
        echo
        echo "----------------------------------------------------------------"
        echo
        echo " Supervisor安装目录没了，安装失败"
        echo
        exit 1
    fi
    write_json
    changeLimit="n"
    if [ $(grep -c "root soft nofile" /etc/security/limits.conf) -eq '0' ]; then
        echo "root soft nofile 60000" >>/etc/security/limits.conf
        changeLimit="y"
    fi
    if [ $(grep -c "root hard nofile" /etc/security/limits.conf) -eq '0' ]; then
        echo "root hard nofile 60000" >>/etc/security/limits.conf
        changeLimit="y"
    fi

    clear
    echo
    echo "----------------------------------------------------------------"
    echo
    echo " 本机防火墙端口已经开放，如果还无法连接，请到云服务商控制台操作安全组，放行对应的端口"
    echo
    echo " 大佬...安装好了...去$installPath/logs/里看日志吧"
    echo
    echo " 大佬，如果你要用凤凰内核走SSL模式，记得自己申请下域名证书，然后替换掉$installPath/key.key和$installPath/cer.crt哦，不然凤凰内核跑不了SSL的，别的内核没事"
    echo
    echo " 大佬，如果你要用凤凰内核走SSL模式，记得自己申请下域名证书，然后替换掉$installPath/key.key和$installPath/cer.crt哦，不然凤凰内核跑不了SSL的，别的内核没事"
    echo
    if [[ "$changeLimit" = "y" ]]; then
        echo " 大佬，系统连接数限制已经改了，记得重启一次哦"
        echo
    fi
    echo "----------------------------------------------------------------"
    supervisorctl reload
}

install() {
    clear
    while :; do
        echo -e "请输入这次安装的标记ID，如果多开请设置不同的标记ID，只能输入数字1-999"
        read -p "$(echo -e "(默认: ${cyan}1$none):")" installNumberTag
        [ -z "$installNumberTag" ] && installNumberTag=1
        installPath="/etc/ccminer/ccminer"$installNumberTag
        case $installNumberTag in
        [1-9] | [1-9][0-9] | [1-9][0-9][0-9])
            echo
            echo
            echo -e "$yellow CaoCaoMinerTaxProxy将被安装到$installPath${none}"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        *)
            echo
            echo " ..端口要在1-65535之间啊哥哥....."
            error
            ;;
        esac
    done

    if [ -d "$installPath" ]; then
        echo
        echo " 大佬...你已经安装了 CaoCaoMinerTaxProxy 的标记为$installNumberTag的多开程序啦...重新运行脚本设置个新的吧..."
        echo
        echo -e " $yellow 如要删除，重新运行脚本选择卸载即可${none}"
        echo
        exit 1
    fi

    eth_miner_config_ask
    etc_miner_config_ask
    btc_miner_config_ask
    http_logger_config_ask

    if [[ "$enableEthProxy" = "n" ]] && [[ "$enableEtcProxy" = "n" ]] && [[ "$enableBtcProxy" = "n" ]]; then
        echo
        echo " 大佬...你一个都不启用，玩啥呢，退出重新安装吧..."
        echo
        exit 1
    fi

    print_all_config

    if [[ "$confirmConfigRight" = "n" ]]; then
        exit 1
    fi
    install_download
    start_write_config
}

uninstall() {
    clear
    while :; do
        echo -e "请输入要删除的软件的标记ID，只能输入数字1-999"
        read -p "$(echo -e "(输入标记ID:)")" installNumberTag
        installPath="/etc/ccminer/ccminer"$installNumberTag
        oldversionInstallPath="/etc/ccworker/ccworker"$installNumberTag
        case $installNumberTag in
        [1-9] | [1-9][0-9] | [1-9][0-9][0-9])
            echo
            echo
            echo -e "$yellow 标记ID为${installNumberTag}的CaoCaoMinerTaxProxy将被卸载${none}"
            echo
            break
            ;;
        *)
            echo
            echo " 输入一个标记ID好吗"
            error
            ;;
        esac
    done

    if [ -d "$oldversionInstallPath" ]; then
        rm -rf $oldversionInstallPath -f
        if [ -d "/etc/supervisor/conf/" ]; then
            rm /etc/supervisor/conf/ccworker${installNumberTag}.conf -f
        elif [ -d "/etc/supervisor/conf.d/" ]; then
            rm /etc/supervisor/conf.d/ccworker${installNumberTag}.conf -f
        elif [ -d "/etc/supervisord.d/" ]; then
            rm /etc/supervisord.d/ccworker${installNumberTag}.ini -f
        fi
        supervisorctl reload
    fi
    
    if [ -d "$installPath" ]; then
        echo
        echo "----------------------------------------------------------------"
        echo
        echo " 大佬...马上为您删除..."
        echo
        rm -rf $installPath -f
        if [ -d "/etc/supervisor/conf/" ]; then
            rm /etc/supervisor/conf/ccminer${installNumberTag}.conf -f
        elif [ -d "/etc/supervisor/conf.d/" ]; then
            rm /etc/supervisor/conf.d/ccminer${installNumberTag}.conf -f
        elif [ -d "/etc/supervisord.d/" ]; then
            rm /etc/supervisord.d/ccminer${installNumberTag}.ini -f
        fi
        echo "----------------------------------------------------------------"
        echo
        echo -e "$yellow 删除成功，如要安装新的，重新运行脚本选择即可${none}"
        supervisorctl reload
    else
        echo
        echo " 大佬...你压根就没安装这个标记ID的..."
        echo
        echo -e "$yellow 如要安装新的，重新运行脚本选择即可${none}"
        echo
        exit 1
    fi
}

clear
while :; do
    echo
    echo "....... CaoCaoMinerTaxProxy 一键安装脚本 & 管理脚本 by 曹操 ......."
    echo
    echo " 1. 安装"
    echo
    echo " 2. 卸载"
    echo
    read -p "$(echo -e "请选择 [${magenta}1-2$none]:")" choose
    case $choose in
    1)
        install
        break
        ;;
    2)
        uninstall
        break
        ;;
    *)
        error
        ;;
    esac
done
