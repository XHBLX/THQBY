pragma solidity ^0.4.25;

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
	function  GetPlayer(uint id) public returns(IPlayer);
	function  GetAllPlayers() public returns(IPlayer[] memory);
	function  GetAllLivingPlayers() public returns(IPlayer[] memory);
	function  GetDeadPlayers() public returns(IPlayer[] memory);
}


contract IInitializableIPlayerArr
{
	function Initialize(IPlayer[] memory) public;
}


contract IRoleBidder is IInitializable
{
	function Bid(uint playerID, string memory role, uint bidAmount) public ;
	function  HasEveryoneBid() public returns(bool);
	function  SetPlayersCount(uint playersCount) public ;

	function CreateRoles() public returns(IPlayer[] memory);
	function  GetIsActive() public returns(bool);
}


