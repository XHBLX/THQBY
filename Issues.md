# Issues
<hr/>
## General Issues:
<hr/>
- all contracts and functions need to be optimized
<hr/>
<hr/>
## EndGame的问题：

**能够终止游戏`TryEndGame == true`的条件（其中之一）:**

- `EndGameCondition` Met
- 游戏成员以外的 manager 发出终止游戏指令

<hr/>

**达到`EndGameCondition`条件（其中之一）：**
- `killer`方人数不小于`police`和`citizen`人数总和（killer方获胜）
- `killer`方人数为0（killer方失败）
<hr/>
<hr/>

**终止游戏方式：**
通过判断TryEndGame，`selfdestruct`或其他非自毁合约的锁定方式
<hr/>
<hr/>

**何时调用终止游戏（call `EndGame`)：**
在玩家人数发生改变的时候
<hr/>
<hr/>
**问题：**

- 需要考虑玩家退出的问题么?
- 如何捕捉玩家人数发生改变的状态？





