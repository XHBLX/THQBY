# Issues

## General Issues:
- all contracts and functions need to be optimized
<br/>

## EndGame的问题：
**能够终止游戏`TryEndGame == true`的条件（其中之一）:**
- `EndGameCondition` Met
- 游戏成员以外的 manager 发出终止游戏指令
<br/>

**达到`EndGameCondition`条件（其中之一）：**
- `killer`方人数不小于`police`和`citizen`人数总和（killer方获胜）
- `killer`方人数为0（killer方失败）
<br/>

**终止游戏方式：** <br/>
- 通过判断`TryEndGame`，通过`selfdestruct`或其他非自毁合约的锁定方式
<br/>

**何时调用终止游戏（call `EndGame`)：** <br/>
- 在玩家人数发生改变的时候
<br/>

**问题：**
- 作为有临时游戏终止权的 GameManager 需要以怎么样的地址形式注入？
- 需要考虑玩家退出的问题么?
- 如何捕捉玩家人数发生改变的状态？




## 关系树 ##

**DependencyInjection**
- THQBY_PlayerManager
- Clock
- SceneNIGHT_KILLER
- SceneNIGHT_POLICE
- PlayerFactory
- RoleBidder 
- SceneDAY
- SceneDAY_PK
- SceneManager
- THQBY_Settings

**THQBY_PlayerManager**
- PlayerManager
- THQBY_Settings

**SceneNIGHT_KILLER**
- THQBY_Scene

**SceneNIGHT_POLICE**
- THQBY_Scene

**PlayerFactoryBase**

**RoleBidder**
- PlayerFactoryBase

**SceneDAY**
- THQBY_Scene

**SceneDAY_PK**
- THQBY_Scene

**SceneManagerBase**
- Scene

**PlayerManager**
- Player

**THQBY_Settings**

**Player**
- ChatLog
- Ballot

**Scene**
- Chatter
- TimeLimitable
- SceneManagerFriendToScene






