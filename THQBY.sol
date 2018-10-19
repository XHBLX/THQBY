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

	function  IInitializable(IPlayer[] memory players) public 
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


contract IInitializable
{
	function Initialize() public;
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


//this class is unfinished...!!!!!!!!!!
contract Ballot is IBallot, ParticipatableBase
{
	mapping(address => IPlayer)  _playerVotedwho;
	mapping(address => uint)	 _votesReceivedByPlayer;
	IPlayerManager               _playerManager;

	constructor (IPlayerManager playerManager) public
	{
		_playerManager=playerManager;
	}

	function Initialize(IPlayer[] participants)
	{
		base.Initialize(participants);
		_playerVotedwho = new Dictionary<IPlayer, IPlayer>();
		_votesReceivedByPlayer = new Dictionary<IPlayer, uint>();
		var allplayers = _playerManager.GetAllPlayers();
		for (int i = 0; i < allplayers.Length; i++)
		{
			_votesReceivedByPlayer[allplayers[i]] = 0;
			_playerVotedwho[allplayers[i]] = null;
		}
	}

	function DidVote(IPlayer player) public  returns(bool);
	function TryVote(IPlayer byWho, IPlayer toWho) public returns(bool);

	function GetWinners() public returns(IPlayer[] memory);

	function IsSoloWinder() public returns(bool);
	function IsZeroWinders() public returns(bool);
	function IsEveryVotableOnesVoted() public returns(bool);

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






/*
 * The following contracts should be categorized as 'abstract contract'
 * rather than 'interface' since interface cannot inherit any other 
 * contract or interface.
 */
/////////////////////////////////////////////////////////////////////////
////////////////////////// Abstact Contracts ////////////////////////////

contract IBallot is IVoteHistory, IParticipatable
{
	function DidVote(IPlayer player) public returns(bool);
	function TryVote(IPlayer byWho, IPlayer toWho) public returns(bool);
	function GetWinners() public returns(IPlayer[] memory);
	function IsSoloWinder() public returns(bool);
	function IsZeroWinders() public returns(bool);
	function IsEveryVotableOnesVoted() public returns(bool);
}


contract IVoteHistory
{
	function WhoDidThePlayerVote(IPlayer player) public returns(IPlayer);
}


contract IChatLog is IParticipatable, IChatable, ISpokenEvent
{
	function GetAllMessages() public returns(ChatMessage[] memory);
	function GetNewestMessage() public returns(ChatMessage );
	function PrintSystemMessage(string memory message) public ;
}


contract IChatable
{
	function TryChat(IPlayer player, string memory message) public returns(bool);
}

contract IChatter is IChatLog, ITimeLimitable, IInitializableIPlayerArr
{
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
	function RegisterNewPlayerAndReturnID(object address) public returns(uint);
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


contract ISpokenEvent
{
	/// Occurs when event spoken. arguments are timestamp, player, message.
	event eventSpoken(uint timestamp, Iplayer player, string message);
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






