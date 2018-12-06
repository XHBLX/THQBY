# THQBY
天黑请闭眼:

To play the game, launch the Main Contract // don't worry about other auxiliary contracts 
you must find 12 players to start playing: 4 polices, 4 killers, 4 normal citizens.

The unique improvement of this blockchain game is that at first all players must bid token for the roles they want to play, then the game will assign roles to each player according to the amount they bid.

after each player has bid, call TryEndBid() to end the bidding phase and start the game.

And then play the game, chat, vote, as usual. 

# File Structure Explanation
This project uses "OOP" programming structure on "SOLIDITY" programming language with "dependency injection" programming style.
The interfaces (unimplemented classes) are seperated from the implementation, whereas the binding happens inside the factory in the main class. Thus, you'll see two copies for each class, one named IXXXXXXX unimplementaed and one (or more) named XXXXXXX with different implementations. A classic example is the IPlayer interface, which can implement to be the POLICE or the KILLER or the CITIZEN with polymorphic behaviors. 
Because this project will be run on the Celer network, therefore it can afford the relatively more expensive OOP programming style. 

# Files 

ChatMessage is the time-stamped chatting message. Because this is a chatting game, therefore the dialog security is also ensured by the blockchain network. Because this project will be run on the Celer network, therefore it can afford the massive amount of communication.

IClock keeps track of the gaming time.


ITimeLimitable interface enforces each gaming scene to have limited time, to avoid one player holding the progress of the entire game. 

ITimeLimitForwardable inheritates ITimeLimitable, To allow authorized players to choose to  end a scene early, and move forward to the next scene.

IVoteHistory lets the players to examing the history of some players' votes, i.e., WhoDidThePlayerVote.

IInitializable is a general interface for any object that needs to be initialzied

IInitializableIPlayerArr is for those object that needs to know all the players.

IParticipatable is for for activities that can enable and disable some players participation. For example, only the killers can vote to kill at night, only the police can vote to examine at night, one 1 player can speak at a time in daytime.

IBallot allows players to vote and calculates the voting result.


IChatable allows players to speak, it returns whether the attempt to speak is successful.


IChatLog allows players to speak and also hear what others are speaking.


IGameController manages the players.

IPlayer is a interface for each player. Players can view their own information here, such as their address and ID and whether is alive.

IPlayerFactory creates players with various rols: police, killer, citizen, and more in the future improved THQBY versions.

IPlayerManager can get player collections with certain requirement.

IChatter is IChatLog, ITimeLimitForwardable


IRoleBidder is a unique feature for this blockchain THQBY game. At the start of the game, instead of randomly gets assigned roles, players can use their real tokens to bid their desired roles. Whoever bids the most amoung on some role wins that role. For example, one can bid 100 tokens on police, 10 on killer, and 0 on citizen, and the player is most likely to become a police.


IScene is a high level abstract thing that let the player to get access to the chatter and ballot specific to the current state of the game. e.g., day / night.


IPrivateScene is not exposed to the players directly, it's for backend programming convenience. 

ISceneManager manages the scenes and returns the current scene.

ISceneManagerFriendToScene is a friend to scene, in order to call some private functions.

ITHQBYPlayerInterface is the ultimate interface the players are expose to directly. Players can do all the game moves via this interface. 


ITHQBY_PlayerManager is the player manage specific to this version of THQBY.


ITHQBY_Settings keeps track some const variables for gaming logic.


ISequentialChatter allows players to chat by taking turns.


and all other contract simply implements the interfaces above.





