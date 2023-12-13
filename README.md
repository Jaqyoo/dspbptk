# DSP Blueprint Toolkit

> 项目开发中，以下内容仅供参考

## 简介

这是一个蓝图解码/编码库，用于处理游戏[戴森球计划](https://store.steampowered.com/app/1366540/_/)中的工厂蓝图。

## 优点

1. 纯C语言编写，且代码经过深度优化，解析全球蓝图仅用时0.025秒。
2. 全缓冲，编解码的中间过程无需申请/使用额外的内存。
3. 多线程友好，每个编解码器使用的内存相互独立。

## 局限
1. 约100万或更多建筑的蓝图可能导致越界访问。这可以通过扩大缓冲区解决，但通常没有必要。因为即使是目前最高密度的全球白糖蓝图也只有约26万建筑。
2. 编码/解码过程只检查常见错误，只要md5f通过校验即信任蓝图。故意构造的恶意蓝图可能导致越界访问，或其它未定义行为。

## 开发计划

1. 计划支持Python API，具体实现还在探索中。

---

## 使用

1. 添加头文件
```C
#include "lib/libdspbptk.h"
```

2. 使用前需要先初始化编解码器
```C
dspbptk_coder_t coder;
dspbptk_init_coder(&coder);
```

3. 调用编码/解码函数
```C
blueprint_t blueprint;
blueprint_decode(&coder, &blueprint, string/*blueprint code*/);
// Edit blueprint here.
blueprint_encode(&coder, &blueprint, string_edited/*blueprint code edited*/);
```

4. 使用结束后必须释放编解码器和蓝图
```C
dspbptk_free_blueprint(&blueprint);
dspbptk_free_coder(&coder);
```

---

## 拓展标准的蓝图编码

`blueprint_t`类型是原版蓝图标准基础上的延伸，完全兼容原版蓝图，但在精度和数据类型上进行了拓展：
1. 原版标准的蓝图编码中，出现的最长的整形为32位精度，没有严格规定是否带符号。拓展标准的蓝图编码中，所有整形都会被转换为64位带符号整形的数据类型。
2. 原版标准的蓝图编码中，出现的最长的浮点数为32位单精度。拓展标准的蓝图编码中，所有浮点数都被转换为64位双精度。
3. 原版标准的蓝图编码中，坐标使用三维坐标xyz表示。拓展标准的蓝图编码中，坐标被拓展为齐次坐标xyzw。齐次坐标在线性变换中有许多良好性质。如果您不需要/不熟悉齐次坐标，可以把齐次坐标中的w分量设为1，只修改xyz，此时的齐次坐标与常见的三维坐标严格等价。
4. 原版标准的蓝图编码中，建筑的index使用uint32_t类型，必须从1开始连续编码，否则视为蓝图已损坏。拓展标准的蓝图编码中，建筑的index使用int64_t类型，仅被视为标识(id)，无需从1开始，也无需连续编码。生成蓝图的过程中，建筑的index将被自动维护。
5. 原版标准向拓展标准转换时，不会丢失任何精度与信息。拓展标准向原版标准转换时，精度溢出的部分将被丢弃。