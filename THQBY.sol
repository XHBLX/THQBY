pragma solidity ^0.4.25;


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
	IPlayer[] _players;

	//Feasible structure



    /*
     * Public functions
     */
     /// contract constructor
	constructor () public {
		//bid for 5 players (from previous test)

		//bid process

		//assign role
		_players = _roleBider.CreateRoles();
		IPlayerFactory factory = PlayerFactoryFactory();
		_tHQBY_Settings = 



	}

	function Players() public returns(IPlayer[] _players) {
		return this._PLayers;
	}

}






contract IPlayer 
{

	function SenderAddress() public returns(address);
	function  GetVotingWeightAsPercent() public returns(uint);
	function  GetRole() public returns(string memory);
	function  GetId() public returns(uint);

	function  SetId(uint id) public ;
	function  GetIsAlive() public returns(bool);
	function  KillMe() public ;
	//function  Speak(string message) public ;
	//bool TryVote(uint playerID) public ;

}



contract IParticipatable 
{
	function  GetParticipants() public returns(IPlayer[] memory);
	function  EnableParticipant(IPlayer player)  public ;
	function  DisableParticipant(IPlayer player) public ;
	function  DisableAllParticipants() public ;
	function  EnableAllParticipants() public ;

	function  IInitializable(IPlayer[] memory players) public ;


	function  IsRegisteredParticipant(IPlayer player) public  returns(bool);
	function  CanParticipate(IPlayer player) public  returns(bool);
	function  ParticipatablePlayersCount()  public returns(uint);

}



contract ParticipatableBase is IParticipatable
{
	IPlayer[] internal _players;
	mapping(address => bool) internal  _canParticipate;



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

contract IClock
{
	function  GetNth_day() public returns(uint);
	function  DayPlusPlus() public ;
	function  GetRealTimeInSeconds() public returns(uint);
}

contract Clock
{
	uint _day = 0;

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


contract IInitializableIPlayerArr
{
	function Initialize(IPlayer[] memory) public;
}



contract ChatMessage
{
	uint public  timestamp;
	int public  byWho;
	string public  message;



	constructor  (uint ts, int bw,  string memory msg ) public
	{
		timestamp=ts;
		byWho=bw;
		message=msg;
	}

	

}



contract ITimeLimitable is IClock
{

	function  IsOverTime() public returns(bool);
	function  SetTimeLimit(uint secondss) public ;
	function  IncrementTimeLimit(int secondss) public ;
	function  SetTimerOn() public ;

}



contract TimeLimitable is IClock, ITimeLimitable
{


	IClock _clock;



	constructor(IClock clock) public
	{
		_clock = clock;
	}

	uint _startingTimeInSeconds;
	uint _timeLimitInSeconds;


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
		return GetRealTimeInSeconds() >= _startingTimeInSeconds + _timeLimitInSeconds;
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










contract ITimeLimitForwardable is ITimeLimitable
{

	function  TryMoveForward(IPlayer player) public returns(bool);
}















contract IVoteHistory
{
	function WhoDidThePlayerVote(IPlayer player) public  returns(IPlayer);
}












contract IBallot is IVoteHistory, IParticipatable
{
	function DidVote(IPlayer player) public  returns(bool);
	function TryVote(IPlayer byWho, IPlayer toWho) public returns(bool);

	function GetWinners() public returns(IPlayer[] memory);

	function IsSoloWinder() public returns(bool);
	function IsZeroWinders() public returns(bool);
	function IsEveryVotableOnesVoted() public returns(bool);

}



//this class is unfinished...!!!!!!!!!!
contract Ballot is IBallot, ParticipatableBase
{
	mapping(address=>IPlayer)  _playerVotedwho;

	mapping(address=> uint)	 _votesReceivedByPlayer;

	IPlayerManager _playerManager;

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




















contract IChatable
{
	function  TryChat(IPlayer player, string memory message) public returns(bool);
}











contract IChatLog is  IParticipatable, IChatable
{
	function GetAllMessages() public returns(ChatMessage[] memory);
	function  GetNewestMessage() public returns(ChatMessage );



	function  PrintSystemMessage(string memory message ) public ;
}



contract ChatLog is ParticipatableBase , IChatLog
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





















contract IChatter is IChatLog, ITimeLimitable, IInitializableIPlayerArr
{



}


contract ISequentialChatter is IChatter, ITimeLimitForwardable
{

	function  GetSpeakingPlayer() public returns(IPlayer);
	function  HaveEveryoneSpoke() public returns(bool);
}


contract IPlayerFactory 
{

	function Create(string memory str) public returns(IPlayer);
}


contract IPlayerManager is IInitializableIPlayerArr
{
	function  GetPlayer(uint id) public returns(IPlayer);


	function  GetAllPlayers() public returns(IPlayer[] memory);
	function  GetAllLivingPlayers() public returns(IPlayer[] memory);

	



	function  GetDeadPlayers() public returns(IPlayer[] memory);
}



contract IRoleBidder is IInitializable
{


	function Bid(uint playerID, string memory role, uint bidAmount) public ;
	function  HasEveryoneBid() public returns(bool);
	function  SetPlayersCount(uint playersCount) public ;


	function CreateRoles() public returns(IPlayer[] memory);
	function  GetIsActive() public returns(bool);
}








contract ISceneManager is ITimeLimitForwardable, IInitializable
{


	function  GetCurrentScene() public returns(IScene);

}

contract ISceneManagerFriendToScene is ISceneManager
{

	function  MoveForwardToNewScene(IScene newScene) public ;

}

contract IScene is ITimeLimitable, ITimeLimitForwardable
{
	function Initialize(ISceneManagerFriendToScene  sceneMng, IPlayer[] memory players) public ;

	function  GetSceneName() public returns(string memory);//return this.GetType().ToString();

	function  Ballot() public returns(IBallot);
	function  Chatter() public returns(IChatter);

	function  Refresh() public ;





}

contract IPrivateScene is IScene
{
	function  ZeroVotingResultHandler() public ;
	function  OneVotingResultHandler(IPlayer result) public ;
	function  MoreVotingResultHandler(IPlayer[] memory result) public ;

	function  DoesPlayerHavePrivilageToMoveForward(IPlayer player) public returns(bool);

}

contract ITHQBYPlayerInterface
{
	//starting game
	function Bid(string memory role, uint bidAmount) public ;

	//accessing 
	function  getID(uint id) public returns(uint);
	function  getRole(string memory role) public returns(string memory);
	function  getChatLog(ChatMessage[] memory msgs) public returns(IChatLog);

	//communicating
	function  TryChat(string memory message) public returns(bool);

	//action method
	function  TryVote(uint playerID) public returns(bool);

}




contract ITHQBY_PlayerManager is IPlayerManager
{
	function  GetLivingPolicePlayers() public  returns(IPlayer[] memory);
	function  GetLivingCitizenPlayers() public returns(IPlayer[] memory);
	function  GetLivingKillerPlayers() public returns(IPlayer[] memory);
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




