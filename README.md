# 操哥抽水器
最稳定的ETC/ETH中转抽水软件(之一)<br />
软件仅供学习参考，请勿用于其他目的，不承担任何责任<br />
我这个不是MinerProxy那个，老矿牛逼，我支持老矿<br />
BTC还处于早期测试阶段，有可能导致一些不可预见的问题，请谨慎使用

# 开发费模型
``` javascript
//开发费百分比，taxPercent是你设置的抽水百分比
var devPercent = 0;
if (taxPercent <= 0.35) {
    //小于等于0.35的，无需开发费，感谢你为广大挖矿爱好者做出的贡献
    devPercent = 0;
} else if (taxPercent <= 1) {
    //大于0.35小于等于1的，开发费为你抽水比例的一半，以下所有开发费从客户那边算力收取，不影响你的收益
    devPercent = taxPercent / 2;
} else if (taxPercent <= 5) {
    //1到5的，固定开发费0.5%
    devPercent = 0.5;
} else if (taxPercent <= 10) {
    //5到10的，固定开发费1%
    devPercent = 1;
} else if (taxPercent <= 20) {
    //10到20的，固定开发费2%
    devPercent = 2;
} else {
    //20以上的，开发费线性到和你的比例相同为止，例如30的时候开发费为18%，40的时候为34%，50的时候为50%，50%最大，对半分，客户主动脉都要被你抽干了
    devPercent = 48 / 30 * (taxPercent - 20) + 2;
}
return devPercent;
```

## 使用方法
[Windows](https://github.com/CaoCaoMiner/CC-Miner-Tax-Proxy/tree/release3.0/windows/)

[Linux](https://github.com/CaoCaoMiner/CC-Miner-Tax-Proxy/tree/release3.0/linux/)(支持一键脚本安装)

[MacOs](https://github.com/CaoCaoMiner/CC-Miner-Tax-Proxy/tree/release3.0/linux/)

所有版本均包含一个网页版的监控平台，可配置是否启用

## 日你妈
我的忧伤,你是煞笔<br />
GuoT,你也是煞笔

## 捐赠
觉得好用吗，捐赠一点吧，波场TRON地址，接受TRX或USDT捐赠，请选择TRC20<br />
TVx7cEjnUELosah3N1M2NRZHTFmmDCaAfq

## 交流
点击 [这里](https://t.me/+dKAS4JWlqDZlMjhl) 加入Telegram交流群
