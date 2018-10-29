/*
* OOP implementation of THQBY in Solidity
*/
pragma solidity ^0.4.25;
//pragma experimental ABIEncoderV2;

/*
* The following contracts should be categorized as 'abstract contract'
* rather than 'interface' since interface cannot inherit any other 
* contract or interface.
*/

/////////////////////////////////////////////////////////////////////////
////////////////////////// Abstact Contracts ////////////////////////////

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
// this abstact contract should be added by field to implement 'null' case 
contract IClock
{
    function GetNth_day() public returns(uint);
    function DayPlusPlus() public;
    function GetRealTimeInSeconds() public returns(uint);
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
    function TryMoveForward(IPlayer player) public returns(bool);
}

contract IVoteHistory
{
    function WhoDidThePlayerVote(IPlayer player) public returns(IPlayer);
}

contract IInitializable
{
    function Initialize() public;
}
contract IInitializableIPlayerArr
{
    function Initialize(IPlayer[] memory participants) public;
}




contract IParticipatable is IInitializableIPlayerArr
{
    function GetParticipants() public returns(IPlayer[] memory);
    function EnableParticipant(IPlayer player)  public ;
    function DisableParticipant(IPlayer player) public ;
    function DisableAllParticipants() public ;
    function EnableAllParticipants() public ;
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


// contract ISpokenEvent
// {
//  /// Occurs when event spoken. arguments are timestamp, player, message.
//  event eventSpoken(uint timestamp, IPlayer player, string message);
// }


contract IChatLog is IParticipatable, IChatable//, ISpokenEvent
{
    function GetAllMessages() public returns(ChatMessage[] memory);   
    function GetNewestMessage() public returns(ChatMessage );
    function PrintSystemMessage(string memory message) public ;
}








contract IGameController
{
    function GetLivingPlayers() public returns(IPlayer[] memory);
    function GetDeadPlayers() public returns(IPlayer[] memory);
    function RegisterNewPlayerAndReturnID(address player) public returns(uint); // object address
}


contract IPlayer //is ISpokenEvent
{
    function Senderaddress() public returns(address);
    function GetVotingWeightAsPercent() public returns(uint);
    function GetRole() public returns(string memory);
    function GetId() public returns(uint);
    function SetId(uint id) public ;
    function GetIsAlive() public returns(bool);
    function KillMe() public ;
    //function  Speak(string message) public ;
    //bool TryVote(uint playerID) public ;
    //  function speak (string message) public;
    //  function TryVote (uint playerID) returns(bool);
}


contract IPlayerFactory 
{
    function Create(string memory str, address addrs) public returns(IPlayer);
}




contract IPlayerManager is IInitializableIPlayerArr
{
    function GetPlayer(uint id) public returns(IPlayer);
    function GetAllPlayers() public returns(IPlayer[] memory);
    function GetAllLivingPlayers() public returns(IPlayer[] memory);
    function GetDeadPlayers() public returns(IPlayer[] memory);
}


contract IChatter is IChatLog, ITimeLimitForwardable//, IInitializableIPlayerArr
{
}

contract IRoleBidder is IInitializable
{
    function Bid(uint playerID, string memory role, uint bidAmount) public ;
    function HasEveryoneBid() public returns(bool);
    function SetPlayersCount(uint playersCount) public ;
    function CreateRoles() public returns(IPlayer[] memory);
    function GetIsActive() public returns(bool);
    function SetID2Address(uint id, address adrs) public;
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
    function Bid(uint pliceAmount, uint KillerAmount, uint citizenAmount) public;
    //accessing 
    function getID(uint id) public returns(uint);
    function getRole() public returns(string memory);
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


contract ISequentialChatter is IChatter//, ITimeLimitForwardable
{
    function GetSpeakingPlayer() public returns(IPlayer);
    function HaveEveryoneSpoke() public returns(bool);
}














































contract THQBY_Settings is ITHQBY_Settings
{
    constructor() public
    {
    }

    function CITIZEN() public returns(string memory )
    {
        return "CITIZEN";
    }

    function DAY() public returns(string memory )
    {
        return "DAY";
    }

    function DAY_PK() public returns(string memory )
    {
        return "DAY_PK";
    }

    function KILLER() public returns(string memory )
    {
        return "KILLER";
    }

    function NIGHT_KILLER() public returns(string memory )
    {
        return "NIGHT_KILLER";
    }

    function NIGHT_POLICE() public returns(string memory )
    {
        return "NIGHT_POLICE";
    }

    function POLICE() public returns(string memory )
    {
        return "POLICE";
    }


}




/// @dev DN: This is an abstract contract.
contract PlayerFactoryBase is IPlayerFactory
{
    uint        _idCounter = 0;

    function Create(string memory role, address addrs) public returns(IPlayer);

    constructor () public
    {

    }
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

/////////// implement

contract StrArr
{
    
    string[]  _strArr;
    
    constructor() public
    {
        
    }
    
    function GetStrI(uint i) returns(string)
    {
        return _strArr[i];
    }
    
    function GetLength() returns (uint)
    {
        return _strArr.length;
    }
    
    function PushStr(string str) public
    {
        _strArr.push(str);
    }
}

/// @dev DN: This is an abstract contract.
contract RoleBidderBase is IRoleBidder 
{
    IPlayerFactory               _playerFactory;
    bool                         _isClassActive    = true; //init usable 
    uint                         _playerCount;
    uint                         _numRoles;
    int[][]                      _matrix;
    bool[]                       isVote;
    mapping(uint => string)      _roleOfPlayerID;
    mapping(string => uint[])    _string2RoleIndx;
    mapping(int => string)       _roleIndx2String;
    mapping(string => uint)      _spotsOfRole;
    mapping(uint=> address)      _id2address;
    
    function SetID2Address(uint id, address adrs) public
    {
        _id2address[id]=adrs;
    }
    
    /*
    * Abstract Contracts
    */
    function InitRoles() internal;
    function SetSpotsOfRoles() internal; 
    function Initialize() public;

    /*
    * Public finctions
    */
    constructor (IPlayerFactory playerFactory) public {
        _playerFactory = playerFactory;
    }

    // attempt to change signiture to be uint[] 
    function Initialize(StrArr roles) public 
    {
        _numRoles = roles.GetLength();
        for (uint i = 0; i < _numRoles; i++) {
            string memory role = roles.GetStrI(i);
            _string2RoleIndx[role][0] = 1;
            _string2RoleIndx[role][1] = i;
            _roleIndx2String[int(i)] = role;
        }
    }

    function Bid(uint playerID, string memory role, uint bidAmount)   public
    {
        bool _bidCheck = (playerID < _playerCount && _string2RoleIndx[role][0] != 0);
        require(_bidCheck, "Invalid input!");
        _matrix[playerID][_string2RoleIndx[role][1]] = int(bidAmount);
    }

    function FindMaxNumRole() public returns(uint)
    {
        uint tempRoleNum;
        uint tempMax = 0;
        for (uint i = 0; i < _numRoles; i++) {
            tempRoleNum = _spotsOfRole[_roleIndx2String[int(i)]];
            if (tempRoleNum > tempMax) {
                tempMax = tempRoleNum;
            }
        }
        return tempMax;
    }

    function CreateRoles() public returns(IPlayer[] memory)
    {
        uint             totalRole       = 0;
        uint             maxRoleNum      = FindMaxNumRole();
        uint             totalIteration  = maxRoleNum * _numRoles;
        IPlayer[] memory res             = new IPlayer[](_playerCount);
        bool[]    memory isAssignedRole  = new bool[](_playerCount);
        uint[]    memory numRoleAssigned = new uint[](_numRoles);
        uint             curRoleIndex    = 0;
        uint             matrixColumn    = 0;

        for (uint i = 0; i < _numRoles; i++) {
            totalRole += _spotsOfRole[_roleIndx2String[int(i)]];
        }
        require(totalRole == _playerCount, "numbers of role != numbers of players");
        for (uint j = 0; j < totalIteration; j++) {
            int  tempMax = -1;
            uint tempID = 2**256-1;
            curRoleIndex = j % _numRoles; // //0->police; 1->citi; 2->killer
            if (numRoleAssigned[curRoleIndex] >= _spotsOfRole[_roleIndx2String[int(curRoleIndex)]]) {
                continue;
            }
            for (uint k = 0; k < _playerCount; k++) {
                if (!isAssignedRole[k] && (_matrix[k][matrixColumn] > tempMax))
                {
                    tempMax = _matrix[k][matrixColumn];
                    tempID = k;
                }
            }
            isAssignedRole[tempID] = true;
            IPlayer p = _playerFactory.Create(_roleIndx2String[int(curRoleIndex)], _id2address[tempID]);
            p.SetId(tempID);
            res[tempID] = p;
            numRoleAssigned[curRoleIndex]++;
            matrixColumn = (matrixColumn + 1) % _numRoles;

        }
        _isClassActive = false;
        return res;
    }

    function GetIsActive() public returns(bool)
    {
        return _isClassActive;
    }

    function HasEveryoneBid() public returns(bool) 
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

    function SetPlayersCount(uint playersCount) public
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


contract Player is IPlayer
{
    IChatLog          _chatLog;
    IBallot           _ballot;

    bool     internal _isAlive = true;
    uint     internal _id;
    string   internal _role;
    uint     internal _votingWeight = 100;
    address internal _address;

    constructor(address addresss)  public
    {
        _address=addresss;
    }

    /*
     *   该部分需参照C#原文档对应合约性质处理
     *
    public event Action<uint, IPlayer, string> eventSpoken;

    */
    
    function Senderaddress() public returns(address)
    {
        return _address;
    }

    function GetId() public returns(uint)
    {
        return _id;
    }

    function GetIsAlive() public returns(bool)
    {
        return _isAlive;
    }

    function GetRole() public returns(string memory)
    {
        return _role;
    }

    function GetVotingWeightAsPercent() public returns(uint)
    {
        return _votingWeight;
    }

    function KillMe() public
    {
        _isAlive = false;
    }


    function SetId(uint id) public
    {
        _id = id;
    }
    
    
}


contract Clock is IClock
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





contract PlayerManager is IPlayerManager
{
    IPlayer[] _players;
    IPlayer[] _tempPlayersList;

    constructor()  public 
    {

    }

    function GetAllLivingPlayers() public returns(IPlayer[] memory)
    {
        //_tempPlayersList
        for (uint i = 0; i < _players.length; i++)
        {
            IPlayer player = _players[i];
            if (player.GetIsAlive())
            {
                _tempPlayersList.push(player);
            }
        }
        return _tempPlayersList;
    }

    function GetAllPlayers() public returns(IPlayer[] memory)
    {
        return _players;
    }

    function GetDeadPlayers() public returns(IPlayer[] memory)
    {
        //_tempPlayersList = new IPlayer[];
        for (uint i = 0; i < _players.length; i++)
        {
            IPlayer player = _players[i];
            if (!player.GetIsAlive())
            {
                _tempPlayersList.push(player);
            }
        }
        return _tempPlayersList;
    }

    function GetPlayer(uint id) public returns (IPlayer )
    {
        return _players[id];
    }

    function Initialize(IPlayer[] memory players) public 
    {
        _players = players;
    }
    
IPlayer[] players;
    function FindByRole(string memory desiredRoleName) internal returns(IPlayer[] memory)
    {
        
        IPlayer[] memory all     = GetAllPlayers();
        bool mustBeAlive       = true; // Initialized as that in original file
        for (uint i = 0; i < all.length; i++)
        {
            IPlayer x = all[i];
            string memory a;
            string memory b;
            a = x.GetRole();
            b = desiredRoleName;
            if (keccak256(a)==keccak256(b)) 
            {
                if (mustBeAlive) 
                {
                    if (x.GetIsAlive()) 
                    {
                        players.push(x);
                    }
                } 
                else 
                {
                    players.push(x);
                }
            }
        }
        return players;
    }
}


contract THQBYRoleBidder is RoleBidderBase
{
    ITHQBY_Settings _settings;
    StrArr       stra;

    constructor(ITHQBY_Settings settings, IPlayerFactory PlayerFactory)  RoleBidderBase(PlayerFactory)   public
    {
//      _playerFactory = PlayerFactory;
        _settings = settings;
        stra=new StrArr();
    }

    function InitRoles() internal 
    {
        stra.PushStr(_settings.POLICE());
        stra.PushStr(_settings.CITIZEN());
        stra.PushStr(_settings.KILLER());
    
        Initialize(stra);
        SetPlayersCount(12);
    }

    function SetSpotsOfRoles() internal
    {   
        _spotsOfRole[_settings.POLICE()]= 4;
        _spotsOfRole[_settings.CITIZEN()] =4;
        _spotsOfRole[_settings.KILLER()] =4;
    }
    
    function Initialize() public
    {
        SetSpotsOfRoles();
        InitRoles();
    }
}


contract THQBY_PLayer is Player
{
    constructor(ITHQBY_Settings settings, address addresss) Player(addresss) public
    {
    }
    
   
}


contract Police is THQBY_PLayer
{
    constructor(ITHQBY_Settings settings, address addresss) THQBY_PLayer(settings,addresss) public
    {
        // base(settings) from THQBY_PLayer
        _role = settings.POLICE();
    }
}


contract Killer is THQBY_PLayer
{
    constructor(ITHQBY_Settings settings, address addresss) THQBY_PLayer(settings,addresss) public
    {
        // base(settings) from THQBY_PLayer
        _role = settings.KILLER();
    }
}


contract Citizen is THQBY_PLayer
{
    constructor(ITHQBY_Settings settings, address addresss) THQBY_PLayer(settings,addresss) public
    {
        // base(settings) from THQBY_PLayer
        _role = settings.CITIZEN();
    }
}










contract ParticipatableBase is IParticipatable
{
    IPlayer[]                internal  _players;
    mapping(address => bool) internal  _canParticipate; 

    function  GetParticipants() public returns(IPlayer[] memory)
    {
        return _players;
    }

    function  EnableParticipant(IPlayer player)  public 
    {
        _canParticipate[player.Senderaddress()] = true;
    }

    function  DisableParticipant(IPlayer player) public 
    {
        _canParticipate[player.Senderaddress()] = false;
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
            _canParticipate[_players[i].Senderaddress()] = canParticipate;
        }
    }

    function Initialize(IPlayer[] memory players) public 
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
        return _canParticipate[player.Senderaddress()];
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


contract Ballot is  ParticipatableBase, IBallot
{   
    // 对于部分需判断合约（类）的存在性而创建的structure
    struct IPlayerVoted {
        bool     _voted;
        IPlayer  _votedIPlayer;
    }

    mapping(address => IPlayerVoted)  _playerVotedwho;
    mapping(address => uint)          _votesReceivedByPlayer;
    IPlayerManager                    _playerManager;
    IPlayer[]                         _winniers;

    constructor (IPlayerManager playerManager) public
    {
        _playerManager = playerManager;
    }

    // Function overriden
    function Initialize(IPlayer[] memory participants) public
    {
        // Here modifying the fucnction upon logic, while not confirmed yet.
        ParticipatableBase.Initialize(participants);
        IPlayer[] memory allplayers = _playerManager.GetAllPlayers();
        for (uint i = 0; i < allplayers.length; i++) {
            _votesReceivedByPlayer[allplayers[i].Senderaddress()] = 0;
            _playerVotedwho[allplayers[i].Senderaddress()]._voted = false;
        }
    }

    function CanParticipate(IPlayer player) public returns (bool)
    {
        if (!player.GetIsAlive()) {
            return false;
        }
        return ParticipatableBase.CanParticipate(player);
    }

    function GetWinners() public returns(IPlayer[] memory) 
    {
        uint             max  =  0;
        for (uint i = 0; i < _players.length; i++) 
        {
            uint maxCandidate = _votesReceivedByPlayer[_players[i].Senderaddress()];
            if (maxCandidate > max)
            {
                max = maxCandidate;
                IPlayer[] memory tempIPlayer;
                _winniers = tempIPlayer;
                _winniers.push(_players[i]);
            }
            else if (maxCandidate == max)
            {
                _winniers.push(_players[i]);

            }
        }
        return _winniers;
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
            _playerVotedwho[byWho.Senderaddress()]._votedIPlayer = toWho;
            _votesReceivedByPlayer[toWho.Senderaddress()] += byWho.GetVotingWeightAsPercent();
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
        if (_playerVotedwho[player.Senderaddress()]._voted == true) {
            return _playerVotedwho[player.Senderaddress()]._votedIPlayer;
        } 
        else 
        {
            //return 0;
            // 这里逻辑上好像应该报错，最经济的做法是revert
            revert("There is no vote to this player.");
        }
    }

    function DidVote(IPlayer player) public returns(bool)
    {
        return _playerVotedwho[player.Senderaddress()]._voted == true;
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


/*
*
*/
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
    function MoreVotingResultHandler(IPlayer[] memory result) public;

    function Ballot() public returns(IBallot)
    {
        return _ballot;
    }

    function Chatter() public returns(IChatter)
    {
        return _chatter;
    }

    function DayPlusPlus() public 
    {
        _timeLimitable.DayPlusPlus();
    }


    function GetNth_day() public returns(uint)
    {
        return _timeLimitable.GetNth_day();
    }

    function GetRealTimeInSeconds() public returns(uint)
    {
        return _timeLimitable.GetRealTimeInSeconds();
    } 

    function GetSceneName() public returns (string memory)
    {
        return _sceneName;
    }

    function Initialize(ISceneManagerFriendToScene sceneManager, IPlayer[] memory participants) public
    {
        _sceneManager = sceneManager;
        _ballot.Initialize(participants); // 
        _chatter.Initialize(participants);
    }

    function IsOverTime() public returns (bool)
    {
        return _timeLimitable.IsOverTime();
    }

    function SetTimeLimit(uint secondss) public 
    {
        _timeLimitable.SetTimeLimit(secondss);
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
        uint votingCount = VotingResultCount();
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

    function VotingResult() public returns(IPlayer[] memory)
    {
        return Ballot().GetWinners();
    }

    function VotingResultCount() public returns(uint)
    {
        return VotingResult().length;
    }

    function KillSomebody(IPlayer somebody) public
    {
        somebody.KillMe();
        PrintMessagePlayerDead(somebody);
    }


    // 不得不实现显示转换 uint -> string
    function uint2str(uint i) private returns (string memory){
        if (i == 0) return "0";
        uint j = i;
        uint length;
        while (j != 0){
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint k = length - 1;
        while (i != 0){
            bstr[k--] = byte(48 + i % 10);
            i /= 10;
        }
        return string(bstr);
    }

    function PrintMessagePlayerDead(IPlayer somebody) public 
    {
        _chatter.PrintSystemMessage("___________");
        _chatter.PrintSystemMessage("Killed Play with ID=");
        _chatter.PrintSystemMessage(uint2str(somebody.GetId()));
        _chatter.PrintSystemMessage("___________");
    }



    function IncrementTimeLimit(int secondss) public
    {
        _timeLimitable.IncrementTimeLimit(secondss);
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
        , ITHQBY_Settings settings) Scene(ballot, chatter, timeLimitable, settings)
    public
    {
//      _ballot = ballot;
//      _chatter = chatter;
//      _timeLimitable = timeLimitable;
//      _settings = settings;
    }

    // setter
    function Set_sceneDay(SceneDAY sceneDay) public
    {
        _sceneDay = sceneDay;
    }

    function Set_scenePK(SceneDAY_PK scenePK) public
    {
        _scenePK = scenePK;
    }

    function Set_sceneKiller(SceneNIGHT_KILLER sceneKiller) public
    {
        _sceneKiller = sceneKiller;
    }

    function Set_scecenPOLICE(SceneNIGHT_POLICE scecenPOLICE) public
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
        , IChatter chatter
        , ITimeLimitable timeLimitable
        , ITHQBY_Settings settings) THQBY_Scene(ballot, chatter, timeLimitable, settings)
    public
    {
//      _ballot = ballot;
//      _chatter = chatter;
//      _timeLimitable = timeLimitable;
//      _settings = settings;
        _sceneName = _settings.DAY();
    }

    function MoreVotingResultHandler(IPlayer[] memory result) public
    {
        _sceneManager.MoveForwardToNewScene(_scenePK);
        //must do after scene change
        _scenePK.Chatter().DisableAllParticipants();
        for (uint i = 0; i < result.length; i++)
        {
            IPlayer player = result[i];
            _scenePK.Chatter().EnableParticipant(player);
        }
    }

    function OneVotingResultHandler(IPlayer result) public
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
        , IChatter chatter
        , ITimeLimitable timeLimitable
        , ITHQBY_Settings settings) THQBY_Scene(ballot, chatter, timeLimitable, settings)
    public
    {
//      _ballot = ballot;
//      _chatter = chatter;
//      _timeLimitable = timeLimitable;
//      _settings = settings;
        _sceneName = _settings.DAY();
    }

    function MoreVotingResultHandler(IPlayer[] memory result) public
    {
        GotoKillerScene();
    }

    function OneVotingResultHandler(IPlayer result) public
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
        , ITHQBY_Settings settings) THQBY_Scene(ballot, chatter, timeLimitable, settings)
    public
    {
//      _ballot = ballot;
//      _chatter = chatter;
//      _timeLimitable = timeLimitable;
//      _settings = settings;
_sceneName=_settings.NIGHT_KILLER();
    }

    function MoreVotingResultHandler(IPlayer[] memory result) public
    {
        GotoKillerScene();
    }

    function OneVotingResultHandler(IPlayer result) public
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
        , ITHQBY_Settings settings) THQBY_Scene(ballot, chatter, timeLimitable, settings)
    public
    {
//      _ballot = ballot;
//      _chatter = chatter;
//      _timeLimitable = timeLimitable;
//      _settings = settings;
_sceneName=_settings.NIGHT_POLICE();
    }

    function GotoDayScene() public
    {
        _sceneManager.MoveForwardToNewScene(_sceneDay);
        DayPlusPlus();
    }

    function MoreVotingResultHandler(IPlayer[] memory result) public
    {
        GotoDayScene();
    }

    function OneVotingResultHandler(IPlayer result) public
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
contract SceneManagerBase is  ITimeLimitForwardable, ISceneManager, ISceneManagerFriendToScene
{
    IScene _currentScene;

    constructor() public
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

    function SetTimeLimit(uint secondss)  public
    {
        _currentScene.SetTimeLimit(secondss);
    }

    function SetTimerOn() public
    {
        _currentScene.SetTimerOn();
    }

    function TryMoveForward(IPlayer player) public returns (bool)
    {
        return _currentScene.TryMoveForward(player);
    }

    function OnChangeScene() public
    {
        // movedForward?.Invoke();
        // sceneUpdated?.Invoke();
    }

    function GetCurrentScene() public returns (IScene)
    {
        return _currentScene;
    }

    function MoveForwardToNewScene(IScene newScene)  public
    {
        _currentScene = newScene;
        _currentScene.Refresh();
        OnChangeScene();
    }

    function IncrementTimeLimit(int secondss) public
    {
        _currentScene.IncrementTimeLimit(secondss);
    }

}


contract Chatter is  IChatter
{
    ITimeLimitable _timeLimitable;
    IChatLog       _chatLog;

        constructor (ITimeLimitable timeLimitable , IChatLog chatLog) public
        {
            _timeLimitable = timeLimitable;
            _chatLog = chatLog;
        }

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

    function EnableAllParticipants() public
    {
        _chatLog.EnableAllParticipants();
    }

    function EnableParticipant(IPlayer player) public
    {
        _chatLog.EnableParticipant(player);
    }

    function GetAllMessages() public returns(ChatMessage[] memory)
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

    function GetParticipants() public returns(IPlayer[] memory)
    {
        return _chatLog.GetParticipants();
    }

    function GetRealTimeInSeconds() public returns(uint)
    {
        return _timeLimitable.GetRealTimeInSeconds();
    }

    function IncrementTimeLimit(int secondss) public
    {
        _timeLimitable.IncrementTimeLimit(secondss);
    }

    function Initialize(IPlayer[] memory participants) public
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

    function PrintSystemMessage(string memory message) public
    {
        _chatLog.PrintSystemMessage(message);
    }

    function SetTimeLimit(uint secondss) public 
    {
        _timeLimitable.SetTimeLimit(secondss);
    }

    function SetTimerOn() public 
    {
        _timeLimitable.SetTimerOn();
    }

    function TryChat(IPlayer player, string memory message) public returns (bool)
    {
        return _chatLog.TryChat(player, message);
    }

    function TryMoveForward(IPlayer player) public returns (bool) 
    {
        return false;
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
        , IPlayerManager playerManager) Chatter(timeLimitable, chatLog) public
    {
        _playerManager = playerManager;
//      _timeLimitable = timeLimitable;
        _timeLimitable.SetTimeLimit(30);

//      _chatLog = chatLog;
    }

    event moveForward(string);

    function OnNextPlayer() internal 
    {
        //movedForward?.Invoke();
    }

    function GetSpeakingPlayer() public returns(IPlayer)
    {
        return _speakingPlayer;
    }

    function HaveEveryoneSpoke() public returns (bool)
    {
        bool ans1 = _chatLog.ParticipatablePlayersCount() == 0;
        bool ans2 = _chatLog.GetParticipants().length == uint(_spokenPlayersCount);
        return ans1 && ans2;
    }

    function Initialize(IPlayer[] memory participants) public 
    {
        Chatter.Initialize(participants);
        _spokenPlayersCount = -1;
        _speakingPlayerIndex = -1;
        MoveForwardActionCore();
    }

    function ParticipatingPlayers() public returns(IPlayer[] memory)
    {
        return _chatLog.GetParticipants();
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

    function MoveForwardActionCore() internal
    {
        _spokenPlayersCount++;
        _speakingPlayerIndex++;
        if (_speakingPlayerIndex < int(_chatLog.GetParticipants().length))
        {
            _speakingPlayer = ParticipatingPlayers()[uint(_speakingPlayerIndex)];
        }

        _chatLog.DisableAllParticipants();
        //      if (_speakingPlayer != null)
        {
            _chatLog.EnableParticipant(_speakingPlayer);
        }
    }

    function MoveForward() private 
    {
        MoveForwardActionCore();
        OnNextPlayer();
    }

    function DoesPlayerHavePrivilageToMoveForward(IPlayer player) public returns(bool)
    {
        return player == _speakingPlayer;
    }

    function EnableParticipant(IPlayer player) public
    {
        Chatter.EnableParticipant(player);
        _timeLimitable.IncrementTimeLimit(int(_onePlayerSpeakingTime));
    }

    function DisableParticipant(IPlayer player) public
    {
        Chatter.DisableParticipant(player);
        _timeLimitable.IncrementTimeLimit(int(-_onePlayerSpeakingTime));
    }

}




contract DependencyInjection is IDependencyInjection
{
    ITHQBY_PlayerManager           _playerManager;
    IClock                         _clock;
    SceneNIGHT_KILLER              _sceneNIGHT_KILLER;
    SceneNIGHT_POLICE              _sceneNIGHT_POLICE;
    IPlayerFactory                 _playerfact;
    IRoleBidder                    _roleBidder;
    SceneDAY                       _sceneDAY;
    SceneDAY_PK                    _sceneDAY_PK;
    ISceneManager                  _sceneManager;
    ITHQBY_Settings                _tHQBY_Settings;


    // For game play
    IPlayer[]            private   _players;




THQBY_Scene private scn;//helper

function InitSceneHelper() private
{
            scn.Set_scecenPOLICE(_sceneNIGHT_POLICE);
            scn.Set_sceneDay(_sceneDAY);
            scn.Set_scenePK(_sceneDAY_PK);
            scn.Set_sceneKiller(_sceneNIGHT_KILLER);
}


    constructor() public
    {
            IBallot ballot = BallotFactory();
            IChatter chatter = ChatterFactory();
            ITimeLimitable timeLimitable = TimeLimitableFactory();
            ITHQBY_Settings settings = SettingsFactory();
            _sceneNIGHT_KILLER = new SceneNIGHT_KILLER(ballot, chatter, timeLimitable, settings);
               _sceneNIGHT_POLICE = new SceneNIGHT_POLICE(ballot, chatter, timeLimitable, settings);
               _sceneDAY = new SceneDAY(ballot, chatter, timeLimitable, settings);
            _sceneDAY_PK = new SceneDAY_PK(ballot, chatter, timeLimitable, settings);
            
           
            scn=_sceneNIGHT_KILLER;
            InitSceneHelper();
            scn=_sceneNIGHT_POLICE;
            InitSceneHelper();
            scn=_sceneDAY;
            InitSceneHelper();
            scn=_sceneDAY_PK;
            InitSceneHelper();
           
           
    }

    function Players() public returns(IPlayer[] memory)
    {
        return _players;
    }


    // AsTransient 
    function BallotFactory() public returns(IBallot)
    {
        IPlayerManager playerManager = PlayerManager();
        return new Ballot(playerManager);
    }

    // AsTransient
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

    //AsTransient
    function SequentialChatterFactory() public returns(ISequentialChatter) 
    {
        ITimeLimitable TimeLimitable = TimeLimitableFactory();
        IChatLog chatLog = ChatLogFactory();
        IPlayerManager playerManager = PlayerManager();
        return new SequentialChatter(TimeLimitable, chatLog, playerManager);
    }

    //AsSingle
    function ClockFactory() public returns(IClock)
    {
        // 一个可能可以处理null的方法是直接判断该合约地址是否为0x0
        // 所以其实下面if判定部分可以省略，
        if ( address(_clock) == address(0x0))
        {
            _clock = new Clock();
        }
        return _clock;
    }

    //AsSingle
    function NIGHT_KILLER_Factory() public returns(SceneNIGHT_KILLER)
    {
        
        return _sceneNIGHT_KILLER;
    }

    //AsSingle
    function NIGHT_POLICE_Factory() public returns(SceneNIGHT_POLICE)
    {
       
         
        
        return _sceneNIGHT_POLICE;
    }

    //AsTransient
    function ParticipatableFactory() public returns(IParticipatable)
    {
        return new ParticipatableBase();
    }

    //AsTransient
    function PlayerFactoryFactory() public returns(IPlayerFactory)
    {
        if (address(_playerfact) == address(0x0))
        {
            ITHQBY_Settings settings = SettingsFactory();
            _playerfact = new THQBY_PlayerFactory(settings);
        }
        return _playerfact;
    }

    //AsTransient
    function PlayerManager() public returns(ITHQBY_PlayerManager)
    {
        if (address(_playerManager) == address(0x0))
        {
            ITHQBY_Settings settings = SettingsFactory();
            _playerManager = new THQBY_PlayerManager(settings);
        }
        return _playerManager;
    }

    //AsTransient
    function RoleBidderFactory() public returns(IRoleBidder)
    {
        if (address(_roleBidder) == address(0x0))
        {
            IPlayerFactory playerFactory = PlayerFactoryFactory();
            ITHQBY_Settings settings = SettingsFactory();
            _roleBidder = new THQBYRoleBidder(settings, playerFactory);
        }
        return _roleBidder;
    }

    //AsTransient
    function SceneDAYFactory() public returns(SceneDAY)
    {
        
        return _sceneDAY;
    }

    //AsSingle
    function SceneDAY_PKFactory() public returns(SceneDAY_PK)
    {
       
        return _sceneDAY_PK;    
    }

    //AsSingle
    function SceneManagerFactory() public returns(ISceneManager)
    {
        if (address(_sceneManager) == address(0x0))
        {
            SceneDAY sceneDay = SceneDAYFactory();
            SceneDAY_PK scenePK = SceneDAY_PKFactory();
            SceneNIGHT_KILLER sceneNIGHT_KILLER = NIGHT_KILLER_Factory();
            SceneNIGHT_POLICE sceneNIGHT_POLICE = NIGHT_POLICE_Factory();
            ITHQBY_PlayerManager playerManager = PlayerManager();
            _sceneManager = new THQBY_SceneManager(sceneDay, scenePK, sceneNIGHT_KILLER, sceneNIGHT_POLICE, playerManager);
        }
        return _sceneManager;
    }

    //AsSingle
    function SettingsFactory() public returns(ITHQBY_Settings)
    {
        if (address(_tHQBY_Settings) ==address(0x0))
        {
            _tHQBY_Settings = new THQBY_Settings();
        }
        return _tHQBY_Settings;
    }

    //AsTransient
    function TimeLimitableFactory() public returns(ITimeLimitable)
    {
        IClock clock = ClockFactory();
        return new TimeLimitable(clock);
    }

    /*
    //AsTransient
    function tHQBYPlayerInterfaceFactory(uint id) returns (THQBYPlayerInterface)
    {

    }
    */


    function LateInitiizeAfterRoleBide() public 
    {
        
    }
    
    
    function Initialize() public 
    {
        
    }
}







// contract RoleBidder is IRoleBidder
// {
//  constructor() public 
//  {

//  }

//  function Bid (uint playerID, string memory role, uint bidAmount)  public 
//  {
//      uint roleId = RoleToNum(role);
//  }

//  function CreateRoles() public returns(IPlayer[] memory)
//  {
//      // throw new NotImplementedException();
//  }

//  function GetIsActive() public returns(bool)
//  {
//      // throw new NotImplementedException();
//  }

//  function HasEveryoneBid() public returns(bool)
//  {
//      // throw new NotImplementedException();
//  }

//  function SetPlayersCount(uint playersCount) public
//  {

//  }

//  function RoleToNum(string memory role) private returns(uint)
//  {
//      if (role == "POLICE")
//      { //DRY
//          return 0;
//      }
//      else if (role == "CITIZEN")
//      {
//          return 1;
//      }
//      else if (role == "KIILER")
//      {
//          return 2;
//      }
//      else
//      {
//          revert("Parameter cannot be null");
//      }
//  }

// }


//////////////// THQBY specific code //////////////


contract THQBY_PlayerFactory is PlayerFactoryBase
{
    ITHQBY_Settings _settings;

    //mannually DI
    constructor(ITHQBY_Settings settings)   PlayerFactoryBase() public
    {
        _settings = settings;
    }

    function Create(string memory role, address addrs) public returns(IPlayer)
    {
        IPlayer ans;
        if ( keccak256(role) ==  keccak256(_settings.CITIZEN()))
        {
            ans = new Citizen(_settings,addrs);
        }
        else if ( keccak256(role) ==  keccak256(_settings.KILLER()))
        {
            ans = new Killer(_settings,addrs);
        }
        else if ( keccak256(role) ==  keccak256(_settings.POLICE()))
        {
            ans = new Police(_settings,addrs);
        }
        else {
            revert("no such role");
        }
        ans.SetId(_idCounter);
        _idCounter++;
        return ans;
    }


}



contract THQBY_PlayerManager is PlayerManager, ITHQBY_PlayerManager
{
    ITHQBY_Settings _names;

    constructor(ITHQBY_Settings settings) public
    {
        _names = settings;
    }

    function GetLivingCitizenPlayers() public returns (IPlayer[] memory )
    {
        return FindByRole(_names.CITIZEN());
    }

    function GetLivingKillerPlayers() public returns (IPlayer[] memory )
    {
        return FindByRole(_names.KILLER());
    }

    function GetLivingPolicePlayers() public returns (IPlayer[] memory )
    {
        return FindByRole(_names.POLICE());
    }   

}



contract THQBY_SceneManager is SceneManagerBase
{
    SceneDAY _sceneDay;

    constructor(SceneDAY sceneDay
        , SceneDAY_PK scenePK
        , SceneNIGHT_KILLER sceneNIGHT_KILLER
        , SceneNIGHT_POLICE sceneNIGHT_POLICE
        , ITHQBY_PlayerManager playerManager) 
    public
    {
        _sceneDay = sceneDay;
        sceneDay.Initialize(this, playerManager.GetAllPlayers());
        scenePK.Initialize(this, playerManager.GetAllPlayers());
        sceneNIGHT_KILLER.Initialize(this, playerManager.GetLivingKillerPlayers());
        sceneNIGHT_POLICE.Initialize(this, playerManager.GetLivingPolicePlayers());
    }

    function Initialize() public 
    {
        MoveForwardToNewScene(_sceneDay);
    }

}






/////////////////////// Main Function To Be ReModeled ////////////////////
/*
*
*/


contract Main //is ITHQBYPlayerInterface 
{
    IDependencyInjection          _inject;
    THQBYRoleBidder               _roleBidder;
    THQBY_SceneManager            _sceneManager;
    IPlayer[]                _tHQBY_PLayers;
    ITHQBY_Settings               _settings;
    IPlayerManager                _PlayerManager;
    uint                          _curMaxId;
    mapping(address => uint)      _AddrToId;
    mapping(uint => THQBY_PLayer) _IdToPlayer;
    mapping(uint => address)      _IdToAddr;
    mapping(uint => bool)         _isBid;      //map<id, bidOrNot>
    address[]                     _addressSet;

    constructor() public
    {
        IDependencyInjection _inject = new DependencyInjection();
        _settings = _inject.SettingsFactory();
        _sceneManager = THQBY_SceneManager(_inject.SceneManagerFactory());
        _roleBidder = THQBYRoleBidder(_inject.RoleBidderFactory());
        _PlayerManager = _inject.PlayerManager();
        _roleBidder.Initialize();
    }

    //starting game
    function Bid(uint policeAmount, uint killerAmount, uint citizenAmount) public payable
    {
        uint sum= policeAmount+killerAmount+citizenAmount;
        uint coins= msg.value;
        uint invSum=uint(coins/sum);
        
       
        
        policeAmount*=invSum;
        killerAmount*=invSum;
        citizenAmount*=invSum;
        
        
        
        uint id = getMyID();
        _roleBidder.Bid(id, _settings.POLICE(), policeAmount);
        _roleBidder.Bid(id, _settings.KILLER(), killerAmount);
        _roleBidder.Bid(id, _settings.CITIZEN(), citizenAmount);
        //update structure
        _isBid[id] = true;
    }

    function getChatLog(ChatMessage[] memory msgs) public returns(IChatLog)
    {
        checkIsBid();
        return _sceneManager.GetCurrentScene().Chatter();
    }

    function getMyID() private returns(uint)
    {
        address addresss = GetMyAddress();
        uint    id       = Address2ID(addresss);
        return id;
    }

    function GetMyPlayer() public returns(THQBY_PLayer ){
        checkIsBid();
        return Id2Player(getMyID());
    }   

    //accessing 
    function GetMyAddress() private returns(address)
    {
        return msg.sender;
    }

    function getRole() public returns(string memory)
    {
        checkIsBid();
        THQBY_PLayer Player = GetMyPlayer();
        return Player.GetRole();
    }

    //communicating
    function TryChat(string memory message) public returns(bool)
    {
        checkIsBid();
        THQBY_PLayer _Player = GetMyPlayer();
        return _sceneManager.GetCurrentScene().Chatter().TryChat(_Player, message);
    }

    function TryEndBid() public returns(bool)
    {
        if (!_roleBidder.HasEveryoneBid())
        {
            return false; // someone not voted yet
        }
        //update players[] 
        
        for (uint id=0; id< _PlayerManager.GetAllPlayers().length;id++)
        {
            _roleBidder.SetID2Address(id,_IdToAddr[id]);
        }
        
        _tHQBY_PLayers = _roleBidder.CreateRoles();
        _sceneManager.Initialize();
        _PlayerManager.Initialize(_tHQBY_PLayers);
        return true;
    }

    //action method
    function TryEndChat() public returns(bool)
    {
        checkIsBid();
        THQBY_PLayer Player = GetMyPlayer();
        IScene scene = _sceneManager.GetCurrentScene();
        IChatter chatter = scene.Chatter();
        return chatter.TryMoveForward(Player);
    }

    function TryForwardScene() public
    {
        checkIsBid();
        THQBY_PLayer Player = GetMyPlayer();
        _sceneManager.TryMoveForward(Player);
    }

    function TryVote(uint playerID) public returns(bool)
    {
        checkIsBid();
        IPlayer toWhoPlayer = Id2Player(playerID);
        THQBY_PLayer Player = GetMyPlayer();
        return _sceneManager.GetCurrentScene().Ballot().TryVote(Player, toWhoPlayer);
    }

    function WhoDidThisPlayerVote(uint playerID) public returns(uint)
    {
        checkIsBid();
        IPlayer p = _sceneManager.GetCurrentScene().Ballot().WhoDidThePlayerVote(Id2Player(playerID));
        return p.GetId();
    }


    /*
    * helper functions
    */

    function Address2ID(address playerAddress) private returns(uint)
    {
        bool addressNotContain=false;
        for (uint i=0; i< _addressSet.length; i++)
        {
            if(_addressSet[i]==playerAddress)
            {
                addressNotContain=true;
                break;
            }
        }
        //如果input是新address，就给他asign个 id
        if (addressNotContain)
        {
            _AddrToId[playerAddress] = _curMaxId;
            _curMaxId++;
            return _AddrToId[playerAddress];
        }
        //如果是旧的address直接调用历史记录。（do nothing）
        return _AddrToId[playerAddress];
    }

    function Address2Player(address playerAddress) private returns (IPlayer)
    {
        checkIsBid();
        uint id = Address2ID(playerAddress);
        return Id2Player(id);
    }

    function Id2Player(uint id) private returns(THQBY_PLayer)
    {
        checkIsBid();
        if (address(_IdToPlayer[id])==0x0)
        {
            _IdToPlayer[id] = THQBY_PLayer(_tHQBY_PLayers[id]);
        }
        return _IdToPlayer[id];
    }

    function checkIsBid() private
    {
        uint id = getMyID();
        if (!_isBid[id])
        {
            revert("Please bid first");
        }
    }
}


