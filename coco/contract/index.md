---
layout: 	coco
title: 		"合约[未开始]"
subtitle: 	"区块链相关"
date: 		2018-06-10 12:00:00
author: 	"凤凰牌老熊"
chapter:	"7"
---  




## 一、区块链基础  

对程序员来说，区块链的概念并不难理解。 
虽然了解区块链的底层概念，比如挖矿、哈希、加密等，对solidity开发有一定帮助。
但对程序员来说，这些概念如同硬件系统、JVM一样。除非你要做区块链底层开发，即设计出一个新的区块链系统，否则只需要了解这些特性，不一定非要了解底层的实现细节，就可以使用solidity来开发区块链应用。 
以下介绍solidity开发需要了解的一些基础知识。 这些知识如果有不了解的地方，可以跳过。学习solidity过程中会逐步理解这些内容。 


### 1.1 交易/事务

区块链是全球共享的、事务数据库。 
这意味着每个人只要加入到这个网络中来，就可以读取整个数据库的数据。 
这就意味着，如果需要对这个数据库做修改，那就需要创建一个被网络中所有的人所认可的事务。 
这里所谓的事务，是指如果一次修改中涉及到2条或者2条以上的数据变更，那这些变更，要么都变更成功，要么就都失败了。 
还有当这个事务在修改数据的时候，其他事务是不能同时做修改的。 

比如在转账操作里面， 需要从一个账户中扣减金额，另一个账户添加金额。 这两个操作必须同时完成。
如果扣减失败，那添加金额操作也不能完成。 

此外，区块链上的事务还要求由创建者来加签，这就可以控制对库中特定数据的修改。 
比如在电子货币中，这种签名校验可以确保只有持有账户秘钥的用户才可以从这个账户发起转账操作。 

### 1.2 区块 

在比特币中要解决的一个大难题，被称为“双花攻击 (double-spend attack)”：如果网络存在两笔交易，都想花光同一个账户的钱时会发生什么情况？
在区块链上，这不是问题。
链上发生的每一笔交易，都会被按照时间顺序来形成一个线性序列。
负责打包的矿工会对这些交易进行验证。 
有些不通过验证的交易，如双花攻击的交易，会被拒绝的，不会被打包到区块中。 
每个区块中会打包多个交易，最终区块会被按照一定时间间隔（以太坊是17秒）添加到链上，形成“区块链”。 
被加入到链中的交易，可能有时会发生块（blocks）被回滚的情况，但仅在链的“末端”。末端增加的块越多，其发生回滚的概率越小。
因而交易在打包后又被回滚甚至从区块链中抹除，这是有可能的。
但随着入块的时间流逝，间隔越长，这种情况发生的概率就越小。

## 二、以太坊虚拟机

以太坊虚拟机 EVM 是智能合约的运行环境。它不仅是沙盒封装的，而且是完全隔离的，也就是说在 EVM 中运行代码是无法访问网络、文件系统和其他进程的。甚至智能合约之间的访问也是受限的。

### 2.1 账户  

以太坊中有两类账户（它们共用同一个地址空间）：   
- 外部账户： 由公钥-私钥对来控制；其中私钥是有账户所有者掌握。 
- 合约账户:  由和账户存储在一起的代码控制。 

外部账户的地址是由公钥决定的，而合约账户的地址是在创建该合约时确定的， 它是通过合约创建者的地址和交易序号来计算得到的。 
交易序号，即所谓的nounce, 是指从某指定地址发出的交易数量。
无论帐户是否存储代码，这两类账户对 EVM 来说是一样的。
每个账户都有一个持久化存储块，可以保存键值对类型的数据， 其中 key 和 value 的长度都是256位。 
此外，每个账户会有一个以太币余额（ balance ）（单位是“Wei”）。我们可以通过给这个账户发送交易请求来修改余额。 

### 2.2 交易

交易可以看作是从一个帐户（源账户）发送到另一个帐户（目标账户）的消息。
这里源账户和目标账户可以是同一个账户，还有可能是一种特殊的账户，叫做零账户，下文会详细描述。 
交易中会包含一些二进制数据和以太币。 这里的二进制代码也被称为交易的有效载荷（payload）。 

如果目标账户里含有代码，那此时这些代码会被执行， 载荷被当做代码的输入数据。 

如果目标账户是零账户（账户地址为 0 )，这交易就变成一个创建新合约的操作。 
如前文所述，合约的地址不是零地址，而是通过合约创建者的账户地址和交易序列计算出来的地址。 
这个用来创建合约的交易中的 payload 会被转换为 EVM 字节码并被执行。执行的结果将作为合约代码被永久存储。
这意味着，为创建一个合约，你不需要发送实际的合约代码，而是发送能够产生合约可执行代码的代码。

> 在合约创建的过程中，它的代码还是空的。所以直到构造函数执行结束，你都不应该在其中调用合约自己函数。

### 2.3 Gas

每笔交易在执行时都会被收取一定数量的 gas作为交易费用，目的是限制执行交易所需要的工作量和为交易支付手续费。
EVM 执行交易时，gas 将按特定规则逐渐消耗。

gas price 是交易发送者设置的一个值，发送者账户需要预付的手续费= gas_price * gas 。
如果交易执行后还有剩余， gas 会原路返还。

无论执行到什么位置，一旦 gas 被耗尽（比如降为负值），将会触发一个 out-of-gas 异常。当前调用帧（call frame）所做的所有状态修改都将被回滚。

> 调用帧（call frame），指的是下文讲到的EVM的运行栈（stack）中当前操作所需要的若干元素。

### 2.4 存储，内存和栈

每个账户有一块持久化内存区称为 存储 。 
存储是将256位字映射到256位字的键值存储区。 
在合约中，我们无法遍历存储中的数据，且读存储的相对开销很高，修改存储的开销甚至更高。
每个合约只能读写存储区内属于自己的部分。

第二个内存区称为 内存 ，在每次被调用时，合约就会被分配一块干净的内存实例。
内存是线性的可寻址，并且是按字节寻址，但读操作被限制为256位，而写操作可以是8位或256位。
当访问（无论是读还是写）之前从未访问过的内存字（word）时（无论是偏移到该字内的任何位置），内存将按字进行扩展（每个字是256位）。
扩容也将消耗一定的gas。 随着内存使用量的增长，其费用也会增高（以平方量级增加）。

EVM 不是基于寄存器的，而是基于栈的，因此所有的计算都在一个被称为 栈（stack） 的区域执行。 栈最大有1024个元素，每个元素长度是一个字（256位）。
对栈的访问只限于其顶端，限制方式为：允许拷贝最顶端的16个元素中的一个到栈顶，或者是将栈顶元素和下面16个元素中的一个进行交互。
所有其他操作都只能取最顶的两个（或一个，或更多，取决于具体的操作）元素，运算后，把结果压入栈顶。
当然可以把栈上的元素放到存储或内存中。但是无法只访问栈上指定深度的那个元素，除非先从栈顶移除其他元素。

### 2.5 指令集  

EVM的指令集量应尽量少，以最大限度地避免可能导致共识问题的错误实现。
所有的指令都是针对"256位的字（word）"这个基本的数据类型来进行操作。
具备常用的算术、位、逻辑和比较操作。
也可以做到有条件和无条件跳转。
此外，合约可以访问当前区块的相关属性，比如它的编号和时间戳。

### 2.6 消息调用

合约可以通过消息调用的方式来调用其它合约或者发送以太币到非合约账户。消息调用和交易非常类似，它们都有一个源、目标、数据、以太币、gas和返回数据。
事实上每个交易都由一个顶层消息调用组成，这个消息调用又可创建更多的消息调用。

合约可以决定在其内部的消息调用中，对于剩余的 gas ，应发送多少，保留多少。
如果在内部消息调用时发生了out-of-gas异常（或其他任何异常），这个错误会被压入栈顶。 
此时，只有与该内部消息调用一起发送的gas会被消耗掉。Solidity中，在这种情况下，发起调用的合约会默认地触发了一个特定的异常，它可以从调用栈里“冒泡出来”。 

如前文所述，被调用的合约（可以和调用者是同一个合约）会获得一块干净的内存，并可以访问调用时提供的payload数据。 这个payload会被放在一个被称为calldata的独立的区域中。
调用执行结束后，返回数据将被存放在调用方预先分配好的一块内存中。调用深度被 限制 为 1024 ，因此对于复杂的操作，我们应使用循环而不是递归。

### 2.7 委托调用/代码调用和库  

有一种特殊类型的消息调用，被称为 委托调用(delegatecall) 。
它和一般的消息调用的区别在于，目标地址的代码将在发起调用的合约的上下文中执行，并且 msg.sender 和 msg.value 不变。 
这意味着一个合约可以在运行时从另外一个地址动态加载代码。
存储、当前地址和余额都指向发起调用的合约，只有代码是从被调用地址获取的。 
这使得 Solidity 可以实现”库“能力：可复用的代码库可以放在一个合约的存储上，如用来实现复杂的数据结构的库。

### 2.8 日志  

有一种特殊的带索引的数据结构，其存储的数据可以一路映射直到区块层级。
这个特性被称为 日志(logs) ，Solidity用它来实现 事件(events) 。
合约创建之后就无法访问日志数据，但是这些数据可以从区块链外高效的访问。
因为部分日志数据被存储在 布隆过滤器（Bloom filter) 中，我们可以高效并且安全加密地搜索日志，所以那些没有下载整个区块链的网络节点（轻客户端）也可以找到这些日志。
