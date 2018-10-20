/*
 * OOP implementation of THQBY in Solidity
 */

pragma solidity ^0.4.25;


/////////////////////// Main Function To Be ReModeled ////////////////////

/*
contract Main is ITHQBYPlayerInterface, IDependencyInjection {
	//fields from DependencyInjection
	ITHQBY_PlayerManager  _playerManager;
	IClock                _clock;
	SceneNIGHT_KILLER     _sceneNIGHT_KILLER;
	SceneNIGHT_POLICE     _nIGHT_POLICE;
	IPlayerFactory        _playerfact;
	IRoleBidder           _roleBidder;
	SceneDAY              _sceneDAY;
	SceneDAY_PK           _sceneDAY_PK;
	ISceneManager         _sceneManager;
	ITHQBY_Settings       _tHQBY_Settings;


	//fields from THQBYPlayerInterface
	THQBY_PLayer          _PLayer;
	uint                  _id;
	ITHQBY_Settings       _settings;
	ChatLog               _log;
	IBallot               _ballot;
	THQBYRoleBidder       _roleBider;

	//For game play
	IPlayer[] private _players;

	//Feasible structure


    // contract constructor
	constructor () public {
		//bid for 5 players (from previous test)

		//bid process

		//assign role
		_players = _roleBider.CreateRoles();
		IPlayerFactory factory = PlayerFactoryFactory();
		_tHQBY_Settings = SettingsFactory();

		//assign id
		for (uint i = 0; i < 5; i++) {
			_players[i].SetId(i);
		}
	}

	function Players() public returns(IPlayer[]) {
		return this._PLayers;
	}

	//AsTransient
	function BallotFactory() public returns(IBallot) {
		

	}

	function Bid(uint pliceAmount, uint KillerAmount, uint citizenAmount)
	{
		_roleBidder = RoleBidderFactory();
		_roleBidder = Initialize();
		_roleBidder = InitRoles();

		_roleBidder.Bid(_id, _settings.POLICE(), policeAmount);
		_roleBidder.Bid(_id, _settings.KILLER(), KillerAmount);
		_roleBidder.Bid(_id, _settings.CITIZEN(), citizenAmount);
	}

	//AsTransient
	function ChatLogFactory() public returns(IChatLog) 
	{
		IClock clock = ClockFactory();
		return new ChatLog(clock);
	}

	//AsTransient
	function ChatterFactory() public returns(IChatter)
	{
		ITimeLimitable TimeLimitableFact = TimeLimitableFactory();
		IChatLog chatLog = ChatLogFactory();
		return new Chatter(TimeLimitableFact, chatLog);
	}

	//AsSingle
	function ClockFactory() public returns(IClock)
	{

	}
}

*/

          
//////////////////////////////////////////////////////////////////////////


contract THQBYRoleBidder is RoleBidderBase
{
	ITHQBY_Settings _settings;

	constructor(ITHQBY_Settings settings, IPlayerFactory PlayerFactory)
	{
		RoleBidderBase._playerFactory = PlayerFactory;
		_settings = settings;
	}
}


/// @dev This is also an abstract contract.
/// SetSpotsOfRoles and InitRoles shall be tracked.
contract RoleBidderBase is IRoleBidder 
{
	IPlayerFactory               _playerFactory;
	bool                         _isClassActive    = true; //init usable 
	uint                         _playerCount;
	uint                         _numRoles;
	int[][]                      _matrix;
	bool[]                       isVote;
	mapping(uint => string)      _roleOfPlayerID;
	mapping(string => uint[](2)) _string2RoleIndx;
	mapping(int => string)       _roleIndx2String;
	mapping(string => uint)      _spotsOfRole;

	/*
	 * Abstract Contracts
	 */
	function InitRoles() public;
	function SetSpotsOfRoles() public; 
	function Initialize() public;

	/*
	 * Public finctions
	 */
	constructor (IPlayerFactory playerFactory) public {
		_roleOfPlayerID = playerFactory;
	}

	function Initialize(string[] roles) public 
	{
		_numRoles = roles.length;
		for (uint i = 0; i < _numRoles; i++) {
			string memory role = roles[i];
			_string2RoleIndx[role][0] = 1;
			_string2RoleIndx[role][1] = i;
			_roleIndx2String[i] = role;
		}
	}

	function Bid(uint playerID, string role, uint bidAmount) 
	{
		bool _bidCheck = (playerID < _playerCount && _string2RoleIndx[role][0] != 0);
		require(_bidCheck, "Invalid input!");
		_matrix[playerID][_string2RoleIndx[role][1]] = bidAmount;
	}

	function FindMaxNumRole() 
	{
		uint tempMax = 0;
		for (uint i = 0; i < _numRoles; i++) {
			uint tempRoleNum = _spotsOfRole[_roleIndx2String[i]];
			if (tempRoleNum > tempMax) {
				tempMax = tempRoleNum;
			}
		}
		return tempRoleNum;
	}

	function CreateRoles() public returns(IPlayer[])
	{
		uint             totalRole       = 0;
		uint             maxRoleNum      = FindMaxNumRole();
		uint             totalIteration  = maxRoleNum * _numRoles;
		IPlayer[] memory res             = new IPlayer[](_playerCount);
		bool[]    memory isAssignedRole  = new bool[](_playerCount);
		uint[]    memory numRoleAssigned = new uint[](_numRoles);
		uint 		     curRoleIndex 	 = 0;
        uint 			 matrixColumn	 = 0;

		for (uint i = 0; i < _numRoles; i++) {
			totalRole += _spotsOfRole[_roleIndx2String[i]];
		}
		require(totalRole == _playerCount, "numbers of role != numbers of players");

		for (uint j = 0; j < totalIteration; j++) 
		{
			int  tempMax = -1;
			uint tempPos = 2**256-1;
			curRoleIndex = j % _numRoles; // //0->police; 1->citi; 2->killer
			if (numRoleAssigned[curRoleIndex] >= _spotsOfRole[_roleIndx2String[int(curRoleIndex)]])
			{
				continue;
			}
			for (uint k = 0; k < _playerCount; k++) {
				if (!isAssignedRole[k] && (_matrix[k][matrixColumn] > tempMax))
				{
					tempMax = _matrix[k][matrixColumn];
					tempPos = k;
				}
			}
			isAssignedRole[tempPos] = true;
			IPlayer p = IPlayerFactory.Create(_roleIndx2String[int(curRoleIndex)]);
			p.SetId(tempPos);
			res[tempPos] = p;
			numRoleAssigned[curRoleIndex]++;
			matrixColumn = (matrixColumn + 1) % _numRoles;

		}
		_isClassActive = false;
		return res;
	}

	function GetIsActive() returns(bool)
	{
		return _isClassActive;
	}

	function HasEveryoneBid() returns(bool) 
	{
		for (uint i = 0; i < _matrix.length; i++) 
		{
			for (uint j = 0; j < _matrix[0].length; j++)
			{
				if (_matrix[i][j] < 0)
				{
					return false;
				}
			}
		}
		return true;
	}

	function SetPlayersCount(uint playersCount)
	{
		_playerCount = playersCount;
		isVote = new bool[](playersCount);
		_matrix = new int[][](playersCount);
		for (uint i = 0; i < playersCount; i++) 
		{
			_matrix[i] = new int[](_numRoles);
			for (uint j = 0; j < _numRoles; j++) 
			{
				_matrix[i][j] = -1;
			}
		}
	}

}


contract ParticipatableBase is IParticipatable
{
	IPlayer[]                internal  _players;
	mapping(IPlayer => bool) internal  _canParticipate; //我暂时把 address 改成IPlayer

	function  GetParticipants() public returns(IPlayer[] memory)
	{
		return _players;
	}

	function  EnableParticipant(IPlayer player)  public 
	{
		_canParticipate[player.SenderAddress()] = true;
	}

	function  DisableParticipant(IPlayer player) public 
	{
		_canParticipate[player.SenderAddress()] = false;
	}

	function  DisableAllParticipants() public 
	{
		SetAllParticibility(false);
	}

	function  EnableAllParticipants() public 
	{
		SetAllParticibility(true);
	}

	function  SetAllParticibility(bool canParticipate) private
	{
		for (uint i = 0; i < _players.length; i++)
		{
			_canParticipate[_players[i].SenderAddress()] = canParticipate;
		}
	}

	function Initializable(IPlayer[] memory players) public 
	{
		_players = players;

		EnableAllParticipants();
	}

	function  IsRegisteredParticipant(IPlayer player) public  returns(bool)
	{
		//  return _players.Contains(player);
		for (uint i = 0; i< _players.length; i++)
		{
			if    (_players[i]==player)
			{return true;}
		}
		return false;
	}

	function  CanParticipate(IPlayer player) public  returns(bool)
	{
		if (!IsRegisteredParticipant(player))
		{
			return false;
		}
		return _canParticipate[player.SenderAddress()];
	}

	function  ParticipatablePlayersCount()  public returns(uint)
	{
		uint ans = 0;

		for (uint i = 0; i < _players.length; i++)
		{
			if (CanParticipate(_players[i]))
			{
				ans++;
			}
		}
		return ans;
	}
}


contract Clock
{
	uint _day               = 0;
	uint _realTimeInSeconds = 0;

	function  GetNth_day() public returns(uint)
	{
		return _day;
	}

	function  DayPlusPlus() public 
	{
		_day++;
	}

	function  GetRealTimeInSeconds() public returns(uint)
	{
		return now;
	}
}


contract ChatMessage
{
	uint   public  timestamp;
	int    public  byWho;
	string public  message;

	constructor (uint ts, int bw,  string memory msg ) public
	{
		timestamp = ts;
		byWho     = bw;
		message   = msg;
	}	
}


contract TimeLimitable is IClock, ITimeLimitable
{
	IClock  _clock;
	uint    _startingTimeInSeconds;
	uint    _timeLimitInSeconds;

	constructor(IClock clock) public
	{
		_clock = clock;
	}

	function  GetNth_day() public returns(uint)
	{
		return _clock.GetNth_day();
	}

	function  DayPlusPlus() public 
	{
		_clock.DayPlusPlus();
	}

	function  GetRealTimeInSeconds() public returns(uint)
	{
		return _clock.GetRealTimeInSeconds();
	}

	function  IsOverTime() public returns(bool)
	{
		return GetRealTimeInSeconds() >= (_startingTimeInSeconds + _timeLimitInSeconds);
	}

	function  SetTimeLimit(uint secondss) public 
	{
		_timeLimitInSeconds = secondss;
	}

	function  IncrementTimeLimit(int secondss) public 
	{
		if (secondss < 0)
		{
			int temp=int(_timeLimitInSeconds);
			if (-secondss > temp)
			{
				_timeLimitInSeconds = 0;
				return;
			}
		}
		_timeLimitInSeconds = uint(int(_timeLimitInSeconds) + secondss);
	}

	function  SetTimerOn() public 
	{
		_startingTimeInSeconds = _clock.GetRealTimeInSeconds();
	}
}


contract Ballot is IBallot, ParticipatableBase, IParticipatable
{	
	struct IPlayerVoted {
		bool     _voted;
		IPlayer  _votedIPlayer;
	}

	mapping(IPlayer => IPlayerVoted)  _playerVotedwho;
	mapping(IPlayer => uint)	      _votesReceivedByPlayer;
	IPlayerManager                    _playerManager;

	constructor (IPlayerManager playerManager) public
	{
		_playerManager = playerManager;
	}

	// Function overriden
	function Initializable(IPlayer[] participants)
	{
		// Here modifying the fucnction upon logic, while not confirmed yet.
		ParticipatableBase.Initializable(participants);
		
		IPlayer[] allplayers = _playerManager.GetAllPlayers();
		for (uint i = 0; i < allplayers.length; i++)
		{
			_votesReceivedByPlayer[allplayers[i]] = 0;
			_playerVotedwho[allplayers[i]]._voted = false;
		}
	}

	// Function overriden
	function CanParticipate(IPlayer player) public
	{
		if (!player.GetIsAlive())
		{
			return false;
		}
		return IParticipatable.CanParticipate(player);
	}

	function GetWinners() public returns(IPlayer[]) 
	{
		IPlayer[] ans;
		uint      max  = 0;
		for (uint i = 0; i < _players.length; i++) 
		{
			uint maxCandidate = _votesReceivedByPlayer[_pLayers[i]];
			if (maxCandidate > max)
			{
				max = maxCandidate;
				ans = new IPlayer[];
				ans.push(_players[i]);
			} 
			else if (maxCandidate == max)
			{
				ans.push(_pLayers[i]);
			}
		}
		return ans;
	}

	function IsEveryVotableOnesVoted() public returns(bool)
	{	
		return VotedPlayerCount() == ParticipatablePlayersCount();
	}

	function TryVote(IPlayer byWho, IPlayer toWho) public returns(bool)
	{	
		if (DidVote(byWho))
		{
			return false;
		}
		bool voteSuccess = CanParticipate(byWho);
		if (voteSuccess) 
		{
			_playerVotedwho[byWho]._votedIPlayer = toWho;
			_votesReceivedByPlayer[toWho] += byWho.GetVotingWeightAsPercent();
		}
		return voteSuccess;
	}

	function VotedPlayerCount() public returns(uint)
	{
		uint ans = 0;
		for (uint i = 0; i < _players.length; i++)
			{
				IPlayer player = _players[i];
				if (DidVote(player))
				{
					ans++;
				}
			}
			return ans;
	}

	function WhoDidThePlayerVote(IPlayer player) public returns(IPlayer)
	{
		if (_playerVotedwho[player]._voted == true) 
		{
			return _playerVotedwho[player]._votedIPlayer;
		} else {
			return 0;
		}
	}

	function DidVote(IPlayer player) public returns(bool)
	{
		return WhoDidThePlayerVote(player) != 0;
	}

	function IsSoloWinder() public returns(bool)
	{
		return GetWinners().length == 1;
	}

	function IsZeroWinders() public returns(bool)
	{
		return GetWinners().length == 0;
	}	

}


contract ChatLog is ParticipatableBase, IChatLog
{
	ChatMessage[] _messages;
	uint _messageCount = 0;

	IClock _clock;
	constructor(IClock clock) public
	{
		_clock = clock;
		//_messages = new List<ChatMessage>();
		_messageCount=0;
	}

	function  TryChat(IPlayer player, string memory message) public returns(bool)
	{
		if (!CanParticipate(player))
		{
			return false;
		}
		ChatMessage chatMessage = new ChatMessage(GetTimeAsSeconds(),int(player.GetId()), message);
		PushMessage(chatMessage);
		return true;
	}

	function GetTimeAsSeconds() private returns(uint) 
	{
		return _clock.GetRealTimeInSeconds();
	}

	function GetAllMessages() public returns(ChatMessage[] memory)
	{
		return _messages;
	}

	function  GetNewestMessage() public returns(ChatMessage )
	{
		return _messages[uint(_messageCount - 1)];
	}

	function  PrintSystemMessage(string memory message ) public
	{
		ChatMessage chatMessage = new ChatMessage(GetTimeAsSeconds(),-1,message);
		PushMessage(chatMessage);
	}


	function PushMessage(ChatMessage message) private
	{
		_messages.push(message);
		_messageCount++;
	}

}



	
// This is also an Abstract contract
contract Scene is ITimeLimitable, IScene, IPrivateScene 
{
	uint                       roundTime       = 60 seconds;
	IBallot                    _ballot;
	IChatter                   _chatter;
	ITimeLimitable             _timeLimitable;
	ITHQBY_Settings            _settings;
	ISceneManagerFriendToScene _sceneManager;
	string                     _sceneName;

	// public event Action movedForward;
	event                      movedForward(string);
	event                      print(string);

	constructor(IBallot ballot, IChatter chatter, ITimeLimitable timeLimitable, ITHQBY_Settings settings)
		public
	{
		_ballot = ballot;
		_chatter = chatter;
		_timeLimitable = timeLimitable;
		_settings = settings;
	}

	function DoesPlayerHavePrivilageToMoveForward(IPlayer player) public returns(bool);
	function ZeroVotingResultHandler() public;
	function OneVotingResultHandler(IPlayer result) public;
	function MoreVotingResultHandler(IPlayer[] result) public;


	function Ballot() public returns(IBallot)
	{
		return _ballot;
	}

	function Chatter() public returns(IChatter)
	{
		returns _chatter;
	}

	function DayPlusPlus() public 
	{
		_timeLimitable.DayPlusPlus();
	}


	function GetNth_day() public returns(uint)
	{
		_timeLimitable.GetNth_day();
	}

	function GetRealTimeInSeconds() public returns(uint)
	{
		return _timeLimitable.GetRealTimeInSeconds();
	} 

	function GetSceneName() public returns (string)
	{
		return _sceneName;
	}

	function Initialize(ISceneManagerFriendToScene sceneManager, IPlayer[] participants)
	{
		_sceneManager = sceneManager;
		_ballot.Initialize(participants);
		_chatter.Initialize(participants);
	}

	function IsOverTime() public returns (bool)
	{
		return _timeLimitable.IsOverTime();
	}

	function SetTimeLimit(uint seconds) public 
	{
		_timeLimitable.SetTimeLimit(seconds);
	}

	function SetTimerOn() public 
	{
		_timeLimitable.SetTimerOn();
	}

	function TryMoveForward(IPlayer player) public returns(bool)
	{
		if (IsOverTime())
		{
			MoveForward();
			return true;
		}
		else if (DoesPlayerHavePrivilageToMoveForward(player))
		{
			MoveForward();
			return true;
		}
		else
		{
			return false;
		}
	}

	function MoveForward() public 
	{
		int votingCount = VotingResultCount();
		if (votingCount == 0)
		{
			ZeroVotingResultHandler();
		}
		else if (votingCount == 1)
		{
			OneVotingResultHandler(VotingResult()[0]);
		}
		else 
		{
			MoreVotingResultHandler(VotingResult());	
		}
	}

	function VotingResult() public returns(IPlayer[])
	{
		return Ballot().GetWinners();
	}

	function VotingResultCount() returns(int)
	{
		return VotingResult().length;
	}

	function KillSomebody(IPlayer somebody) public
	{
		somebody.KillMe();
		PrintMessagePlayerDead(somebody);
	}

	function PrintMessagePlayerDead(IPlayer somebody) public 
	{
		// However, event is actually different to printSystemMessage in C#
		_chatter.PrintSystemMessage("______________________");
		_chatter.PrintSystemMessage("Killed Play with ID=");
		_chatter.PrintSystemMessage(someobdy.GetId().ToString());
		_chatter.PrintSystemMessage("______________________");
	}

	function IncrementTimeLimit(int seconds) public
	{
		_timeLimitable.IncrementTimeLimit(seconds);
	}

	function Refresh() public
	{
		_chatter.SetTimeLimit(roundTime);
		_timeLimitable.SetTimeLimit(roundTime * _ballot.ParticipatablePlayersCount() + roundTime);
		SetTimerOn();
	}

}

contract THQBY_Scene is Scene
{
	SceneDAY          _sceneDay;
	SceneDAY_PK       _scenePK;
	SceneNIGHT_KILLER _sceneKiller;
	SceneNIGHT_POLICE _scecenPOLICE;

	constructor (IBallot ballot
			   , IChatter chatter
			   , ITimeLimitable timeLimitable
			   , ITHQBY_Settings settings) 
		public
	{
		_ballot = ballot;
		_chatter = chatter;
		_timeLimitable = timeLimitable;
		_settings = settings;
	}

	// setter
	function Set_sceneDay(SceneDAY sceneDay) public
	{
		_sceneDay = sceneDay;
	}

	function Set__scenePK(SceneDAY scenePK) public
	{
		_scenePK = scenePK;
	}

	function Set_sceneKiller(SceneDAY sceneKiller) public
	{
		_sceneKiller = sceneKiller;
	}

	function Set_scecenPOLICE(SceneDAY scecenPOLICE) public
	{
		_scecenPOLICE = scecenPOLICE;
	}

	function DoesPlayerHavePrivilageToMoveForward(IPlayer player) public returns (bool)
	{
		return _ballot.IsEveryVotableOnesVoted();
	}

	function KillSomebody(IPlayer someobdy) public
	{
		super.KillSomebody(someobdy);
	}

}


contract SceneDAY is THQBY_Scene
{
	constructor (IBallot ballot
			   , ISequentialChatter chatter
			   , ITimeLimitable timeLimitable
			   , ITHQBY_Settings settings) 
		public
	{
		_ballot = ballot;
		_chatter = chatter;
		_timeLimitable = timeLimitable;
		_settings = settings;
		_sceneName = _settings.DAY();
	}

	function MoreVotingResultHandler(IPlayer[] result)
	{
		_sceneManager.MoveForwardToNewScene(_scenePK);
		//must do after scene change
		_scenePK.Chatter().DisableAllParticipants();
		for (int i = 0; i < result.Length; i++)
		{
			IPlayer player = result[i];
			_scenePK.Chatter().EnableParticipant(player);
		}
	}

	function OneVotingResultHandler(IPlayer result)
	{
		KillSomebody(result);
		GotoKillerScene();
	}

	function GotoKillerScene() private
	{
		_sceneManager.MoveForwardToNewScene(_sceneKiller);
	}

	function ZeroVotingResultHandler() public 
	{
		GotoKillerScene();
	}

}


contract SceneDAY_PK is THQBY_Scene
{
	constructor (IBallot ballot
			   , ISequentialChatter chatter
			   , ITimeLimitable timeLimitable
			   , ITHQBY_Settings settings) 
		public
	{
		_ballot = ballot;
		_chatter = chatter;
		_timeLimitable = timeLimitable;
		_settings = settings;
		_sceneName = _settings.DAY();
	}

	function MoreVotingResultHandler(IPlayer[] result) public
	{
		GotoKillerScene();
	}

	function OneVotingResultHandler(IPlayer result)
	{
		KillSomebody(result);
		GotoKillerScene();
	}

	function ZeroVotingResultHandler() public 
	{
		GotoKillerScene();
	}

	function GotoKillerScene() private
	{
		_sceneManager.MoveForwardToNewScene(_sceneKiller);
	}

}


contract SceneNIGHT_KILLER is THQBY_Scene
{
	constructor (IBallot ballot
			   , IChatter chatter
			   , ITimeLimitable timeLimitable
			   , ITHQBY_Settings settings) 
		public
	{
		_ballot = ballot;
		_chatter = chatter;
		_timeLimitable = timeLimitable;
		_settings = settings;
	}

	function MoreVotingResultHandler(IPlayer[] result) public
	{
		GotoKillerScene();
	}

	function OneVotingResultHandler(IPlayer result)
	{
		KillSomebody(result);
		_sceneDay.KillSomebody(result);
		GotoKillerScene();
	}

	function ZeroVotingResultHandler() public 
	{
		GotoKillerScene();
	}

	function GotoKillerScene() private
	{
		_sceneManager.MoveForwardToNewScene(_sceneKiller);
	}

	function Refresh() public
	{
		_chatter.SetTimeLimit(2 * roundTime);
		_timeLimitable.SetTimeLimit(2 * roundTime);
		SetTimerOn();
	}

}



contract SceneNIGHT_POLICE is THQBY_Scene
{
	constructor (IBallot ballot
			   , IChatter chatter
			   , ITimeLimitable timeLimitable
			   , ITHQBY_Settings settings) 
		public
	{
		_ballot = ballot;
		_chatter = chatter;
		_timeLimitable = timeLimitable;
		_settings = settings;
	}

	function GotoDayScene()
	{
		_sceneManager.MoveForwardToNewScene(_sceneDay);
		DayPlusPlus();
	}

	function MoreVotingResultHandler(IPlayer[] result) public
	{
		GotoDayScene();
	}

	function OneVotingResultHandler(IPlayer result)
	{
		_chatter.PrintSystemMessage(result.GetRole());
		GotoDayScene();
	}

	function ZeroVotingResultHandler() public 
	{
		GotoDayScene();
	}

	function Refresh() public
	{
		_chatter.SetTimeLimit(2 * roundTime);
		_timeLimitable.SetTimeLimit(2 * roundTime);
		SetTimerOn();
	}

}


// This is an abstract contract
contract SceneManagerBase is ITimeLimitable, ITimeLimitForwardable, ISceneManager, ISceneManagerFriendToScene
{
	IScene _currentScene;

	constructor()
	{

	}

	event movedForward(string);
	event sceneUpdated(string);

	function Initialize() public;

	function DayPlusPlus() public
	{
		_currentScene.DayPlusPlus();
	}

	function GetNth_day() public returns(uint)
	{
		return _currentScene.GetNth_day();
	}

	function GetRealTimeInSeconds() public returns(uint)
	{
		return _currentScene.GetRealTimeInSeconds();
	}

	function IsOverTime() public returns (bool)
	{
		return _currentScene.IsOverTime();
	}

	function SetTimeLimit(uint seconds) 
	{
		_currentScene.SetTimeLimit(seconds);
	}

	function SetTimerOn()
	{
		_currentScene.SetTimerOn();
	}

	function TryMoveForward(IPlayer player) public returns (bool)
	{
		return _currentScene.TryMoveForward(player);
	}

	function OnChangeScene() public
	{
		//	Dafei confused by the operation below
		//  doesn't know how delegate in even works

		// movedForward?.Invoke();
		// sceneUpdated?.Invoke();
	}

	function GetCurrentScene() public returns (IScene)
	{
		return _currentScene;
	}

	function MoveForwardToNewScene(IScene newScene) 
	{
		_currentScene = newScene;
		_currentScene.Refresh();
		OnChangeScene();
	}

	function IncrementTimeLimit(uint seconds)
	{
		_currentScene.IncrementTimeLimit(seconds);
	}

}


contract Chatter is ITimeLimitable, IChatable, IChatLog, IChatter
{
	ITimeLimitable _timeLimitable;
	IChatLog       _chatLog;

	constructor (ITimeLimitable timeLimitable , IChatLog chatLog)
	{
		_timeLimitable = timeLimitable;
		_chatLog = chatLog;
	}

	// public event Action<uint, IPlayer, string> eventSpoken
	// 	{
	// 		add
	// 		{
	// 			_chatLog.eventSpoken += value;
	// 		}

	// 		remove
	// 		{
	// 			_chatLog.eventSpoken -= value;
	// 		}
	// 	}

	function CanParticipate(IPlayer player) public returns(bool)
	{
		return _chatLog.CanParticipate(player);
	}

	function DayPlusPlus() public
	{
		_timeLimitable.DayPlusPlus();
	}

	function DisableAllParticipants() public
	{
		_chatLog.DisableAllParticipants();
	}

	function DisableParticipant(IPlayer player) public 
	{
		_chatLog.DisableParticipant(player);
	}

	function EnableAllParticipants()
	{
		_chatLog.EnableAllParticipants();
	}

	function EnableParticipant(IPlayer player)
	{
		_chatLog.EnableParticipant(player);
	}

	function GetAllMessages() public returns(ChatMessage[])
	{
		return _chatLog.GetAllMessages();
	}

	function GetNewestMessage() public returns(ChatMessage)
	{
		return _chatLog.GetNewestMessage();
	}

	function GetNth_day() public returns(uint)
	{
		return _timeLimitable.GetNth_day();
	}

	function GetParticipants() public returns(IPlayer[])
	{
		return _chatLog.GetParticipants();
	}

	function GetRealTimeInSeconds() public returns(uint)
	{
		return _timeLimitable.GetRealTimeInSeconds();
	}

	function IncrementTimeLimit(int seconds) public
	{
		_timeLimitable.IncrementTimeLimit(seconds);
	}

	function Initialize(IPlayer[] participants)
	{
		_chatLog.Initialize(participants);
	}

	function IsOverTime() public returns(bool)
	{
		return _timeLimitable.IsOverTime();
	}

	function IsRegisteredParticipant(IPlayer player) public returns(bool)
	{
		return _chatLog.IsRegisteredParticipant(player);
	}

	function ParticipatablePlayersCount() public returns(uint)
	{
		return _chatLog.ParticipatablePlayersCount();
	}

	function PrintSystemMessage(string message)
	{
		_chatLog.PrintSystemMessage(message);
	}

	function SetTimeLimit(uint seconds) public 
	{
		_timeLimitable.SetTimeLimit(seconds);
	}

	function SetTimerOn() public 
	{
		_timeLimitable.SetTimerOn();
	}

	function TryChat(IPlayer player, string message) public returns (bool)
	{
		return _chatLog.TryChat(player, message);
	}

}



contract SequentialChatter is Chatter, ISequentialChatter
{
	uint           _onePlayerSpeakingTime = 60 seconds;
	IPlayerManager _playerManager;
	IPlayer        _speakingPlayer;
	int            _spokenPlayersCount    = -1;
	int            _speakingPlayerIndex   = -1;

	constructor (ITimeLimitable timeLimitable
		       , IChatLog chatLog
			   , IPlayerManager playerManage)
	{

	}
}


// To Do List:

//      Chatter
//      DependencyInjection
//      Player
//      PlayerFactoryBase
//      PlayerManager
//		SequentialChatter
//      RoleBidder
//		THQBYPlayerInterface
//		THQBYRoleBidder4TestingOnly	
//		THQBY_PLayer
//		THQBY_PlayerFactory
//		THQBY_PlayerManager
// 		THQBY_SceneManager
//		THQBY_Settings













/*
 * The following contracts should be categorized as 'abstract contract'
 * rather than 'interface' since interface cannot inherit any other 
 * contract or interface.
 */
/////////////////////////////////////////////////////////////////////////
////////////////////////// Abstact Contracts ////////////////////////////

pragma solidity ^0.4.25;


contract IVoteHistory
{
	function WhoDidThePlayerVote(IPlayer player) public returns(IPlayer);
}


contract IParticipatable
{
	function GetParticipants() public returns(IPlayer[] memory);
	function EnableParticipant(IPlayer player)  public ;
	function DisableParticipant(IPlayer player) public ;
	function DisableAllParticipants() public ;
	function EnableAllParticipants() public ;
	function IInitializable(IPlayer[] memory players) public ;
	function IsRegisteredParticipant(IPlayer player) public  returns(bool);
	function CanParticipate(IPlayer player) public  returns(bool);
	function ParticipatablePlayersCount()  public returns(uint);
}


contract IBallot is IVoteHistory, IParticipatable
{
	function DidVote(IPlayer player) public returns(bool);
	function TryVote(IPlayer byWho, IPlayer toWho) public returns(bool);
	function GetWinners() public returns(IPlayer[] memory);
	function IsSoloWinder() public returns(bool);
	function IsZeroWinders() public returns(bool);
	function IsEveryVotableOnesVoted() public returns(bool);
}


contract IChatable
{
	function TryChat(IPlayer player, string memory message) public returns(bool);
}

contract ISpokenEvent
{
	/// Occurs when event spoken. arguments are timestamp, player, message.
	event eventSpoken(uint timestamp, IPlayer player, string message);
}


contract IChatLog is IParticipatable, IChatable, ISpokenEvent
{
	function GetAllMessages() public returns(ChatMessage[]);   // havent realized ChatMessage
	function GetNewestMessage() public returns(ChatMessage );
	function PrintSystemMessage(string memory message) public ;
}


contract IChatter is IChatLog, ITimeLimitable, IInitializableIPlayerArr
{
}


contract IInitializable
{
	function Initialize() public;
}


contract ISequentialChatter is IChatter, ITimeLimitForwardable
{
	function GetSpeakingPlayer() public returns(IPlayer);
	function HaveEveryoneSpoke() public returns(bool);
}


// this abstact contract should be added by field to implement 'null' case 
contract IClock
{
	function GetNth_day() public returns(uint);
	function DayPlusPlus() public;
	function GetRealTimeInSeconds() public returns(uint);
}


contract IDependencyInjection
{
	function BallotFactory() public returns(IBallot);
	function ChatLogFactory() public returns(IChatLog);
	function ChatterFactory() public returns(IChatter);
	function ClockFactory() public returns(IClock);
	function PlayerFactoryFactory() public returns(IPlayerFactory);
	function PlayerManager() public returns(ITHQBY_PlayerManager);
	//IScene SceneFactory(string name); 
	function SettingsFactory() public returns(ITHQBY_Settings);
	function SceneManagerFactory() public returns(ISceneManager);
	function ParticipatableFactory() public returns(IParticipatable);
	function RoleBidderFactory() public returns(IRoleBidder);
	function SequentialChatterFactory() public returns(ISequentialChatter);
	function TimeLimitableFactory() public returns(ITimeLimitable);
	function SceneDAYFactory() public returns(SceneDAY);
	function SceneDAY_PKFactory() public returns(SceneDAY_PK);
	function NIGHT_POLICE_Factory() public returns(SceneNIGHT_POLICE);
	function NIGHT_KILLER_Factory() public returns(SceneNIGHT_KILLER);
	function Initialize() public;
	function LateInitiizeAfterRoleBide() public;
}


contract IGameController
{
	function GetLivingPlayers() public returns(IPlayer[] memory);
	function GetDeadPlayers() public returns(IPlayer[] memory);
	function RegisterNewPlayerAndReturnID(address player) public returns(uint); // object address
}


contract IPlayer is ISpokenEvent
{
	function SenderAddress() public returns(address);
	function GetVotingWeightAsPercent() public returns(uint);
	function GetRole() public returns(string memory);
	function GetId() public returns(uint);
	function SetId(uint id) public ;
	function GetIsAlive() public returns(bool);
	function KillMe() public ;
	//function  Speak(string message) public ;
	//bool TryVote(uint playerID) public ;
	function speak (string message) public;
	function TryVote (uint playerID) returns(bool);
}


contract IPlayerFactory 
{
	function Create(string memory str) public returns(IPlayer);
}


contract IPlayerManager is IInitializableIPlayerArr
{
	function GetPlayer(uint id) public returns(IPlayer);
	function GetAllPlayers() public returns(IPlayer[] memory);
	function GetAllLivingPlayers() public returns(IPlayer[] memory);
	function GetDeadPlayers() public returns(IPlayer[] memory);
}


contract IInitializableIPlayerArr
{
	function Initialize(IPlayer[] memory) public;
}


contract IRoleBidder is IInitializable
{
	function Bid(uint playerID, string memory role, uint bidAmount) public ;
	function HasEveryoneBid() public returns(bool);
	function SetPlayersCount(uint playersCount) public ;
	function CreateRoles() public returns(IPlayer[] memory);
	function GetIsActive() public returns(bool);
}


contract IScene is ITimeLimitable, ITimeLimitForwardable
{
	function Initialize(ISceneManagerFriendToScene  sceneMng, IPlayer[] memory players) public ;
	function GetSceneName() public returns(string memory);//return this.GetType().ToString();
	function Ballot() public returns(IBallot);
	function Chatter() public returns(IChatter);
	function Refresh() public ;
}


contract IPrivateScene is IScene
{
	function ZeroVotingResultHandler() public ;
	function OneVotingResultHandler(IPlayer result) public ;
	function MoreVotingResultHandler(IPlayer[] memory result) public ;
	function DoesPlayerHavePrivilageToMoveForward(IPlayer player) public returns(bool);
}


contract ISceneManager is ITimeLimitForwardable, IInitializable
{
	function GetCurrentScene() public returns(IScene);
}


contract ISceneManagerFriendToScene is ISceneManager
{
	function MoveForwardToNewScene(IScene newScene) public ;
}





contract ITHQBYPlayerInterface
{
	//starting game
	function Bid(string memory role, uint bidAmount) public ;
	//accessing 
	function getID(uint id) public returns(uint);
	function getRole(string memory role) public returns(string memory);
	function getChatLog(ChatMessage[] memory msgs) public returns(IChatLog);
	//communicating
	function TryChat(string memory message) public returns(bool);
	//action method
	function TryVote(uint playerID) public returns(bool);
}


contract ITHQBY_PlayerManager is IPlayerManager
{
	function GetLivingPolicePlayers() public returns(IPlayer[] memory);
	function GetLivingCitizenPlayers() public returns(IPlayer[] memory);
	function GetLivingKillerPlayers() public returns(IPlayer[] memory);
}


contract ITHQBY_Settings
{
	function  DAY() public  returns(string memory);
	function  DAY_PK() public  returns(string memory);
	function  NIGHT_KILLER() public  returns(string memory);
	function  NIGHT_POLICE() public  returns(string memory);
	function  POLICE() public  returns(string memory);
	function  CITIZEN() public  returns(string memory);
	function  KILLER() public  returns(string memory);
}


contract ITimeLimitable is IClock
{
	function  IsOverTime() public returns(bool);
	function  SetTimeLimit(uint secondss) public ;
	function  IncrementTimeLimit(int secondss) public ;
	function  SetTimerOn() public ;
}


contract ITimeLimitForwardable is ITimeLimitable
{
	event moveForward(Action); // ??? and I may in the future put all event in a seperate contract
	function  TryMoveForward(IPlayer player) public returns(bool);
}






