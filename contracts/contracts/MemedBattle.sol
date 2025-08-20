// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./MemedToken.sol";
import "./MemedFactory.sol";

contract YellowMemedBattle is Ownable {
    YellowMemedFactory public factory;
    uint256 public constant BATTLE_DURATION = 10 minutes;
    uint256 public constant MIN_TOKENS_TO_CREATE = 1000 * 10**18;
    uint256 public constant CREATION_FEE = 0.0002 ether;

    struct Battle {
        address token1;
        address token2;
        uint256 token1Votes;
        uint256 token2Votes;
        uint256 startTime;
        uint256 endTime;
        bool settled;
        address winner;
    }

    struct TokenScore {
        uint256 wins;
        uint256 totalBattles;
        uint256 totalVotes;
    }

    // New: Stats tracking
    struct TokenStats {
        uint256 totalBattlesInitiated;
        uint256 totalBattlesParticipated;
        uint256 totalWins;
        uint256 totalLosses;
        uint256 totalVotes;
        uint256 lastBattleTime;
        uint256 lastWinTime;
        bool isKing;
        uint256 kingCrownedTime;
    }

    struct MonthlyData {
        uint256[] battles;
        uint256[] wins;
    }

    mapping(uint256 => Battle) public battles;
    mapping(address => TokenScore) public tokenScores;
    mapping(uint256 => mapping(address => bool)) public hasVoted;
    mapping(uint256 => mapping(address => uint256)) public userVotingPower;
    
    // New: Enhanced stats mappings
    mapping(address => TokenStats) public tokenStats;
    mapping(address => mapping(uint256 => uint256)) public monthlyBattleCount;
    mapping(address => mapping(uint256 => uint256)) public monthlyWinCount;
    
    uint256 public battleCount;
    uint256 public feesBalance;
    address public currentKing;

    // Add mapping to track token battle combinations
    mapping(bytes32 => uint256) public lastBattleTimestamp;

    event BattleCreated(
        uint256 indexed battleId,
        address indexed token1,
        address indexed token2,
        uint256 startTime,
        uint256 endTime
    );
    event VoteCast(
        uint256 indexed battleId,
        address indexed voter,
        address indexed votedFor,
        uint256 votingPower
    );
    event BattleSettled(
        uint256 indexed battleId,
        address indexed winner,
        uint256 token1FinalVotes,
        uint256 token2FinalVotes
    );
    event NewKingCrowned(address indexed token, uint256 timestamp);

    constructor(address payable _factory) Ownable(msg.sender) {
        factory = YellowMemedFactory(_factory);
    }

    function createBattle(address _token1, address _token2) external payable {
        require(msg.value >= CREATION_FEE, "Insufficient creation fee");
        require(_token1 != _token2, "Cannot battle same token");
        
        // Check if this token combination has battled recently
        bytes32 battlePairHash = keccak256(abi.encodePacked(
            _token1 < _token2 ? _token1 : _token2,
            _token1 < _token2 ? _token2 : _token1
        ));
        require(
            lastBattleTimestamp[battlePairHash] == 0 || 
            block.timestamp >= lastBattleTimestamp[battlePairHash] + 10 minutes,
            "Token combination in cooldown"
        );

        // Get token data and check stage
        (,,,,,YellowMemedFactory.TokenStages stage1,,) = factory.tokenData(_token1);
        (,,,,,YellowMemedFactory.TokenStages stage2,,) = factory.tokenData(_token2);
        
        require(
            stage1 == YellowMemedFactory.TokenStages.GRADUATED &&
            stage2 == YellowMemedFactory.TokenStages.GRADUATED,
            "Only graduated tokens can battle"
        );

        MemedToken token1 = MemedToken(_token1);
        MemedToken token2 = MemedToken(_token2);
        require(
            token1.totalSupply() >= MIN_TOKENS_TO_CREATE &&
            token2.totalSupply() >= MIN_TOKENS_TO_CREATE,
            "Insufficient token supply"
        );

        uint256 battleId = battleCount++;
        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + BATTLE_DURATION;

        battles[battleId] = Battle({
            token1: _token1,
            token2: _token2,
            token1Votes: 0,
            token2Votes: 0,
            startTime: startTime,
            endTime: endTime,
            settled: false,
            winner: address(0)
        });

        // Update stats
        updateBattleStats(_token1, true);
        updateBattleStats(_token2, false);

        feesBalance += CREATION_FEE;

        // Update the last battle timestamp for this combination
        lastBattleTimestamp[battlePairHash] = block.timestamp;

        emit BattleCreated(battleId, _token1, _token2, startTime, endTime);
    }

    // New: Update battle statistics
    function updateBattleStats(address token, bool isInitiator) internal {
        TokenStats storage stats = tokenStats[token];
        uint256 currentMonth = (block.timestamp / 30 days) % 6;

        if(isInitiator) {
            stats.totalBattlesInitiated++;
        }
        stats.totalBattlesParticipated++;
        stats.lastBattleTime = block.timestamp;
        
        // Update monthly stats
        monthlyBattleCount[token][currentMonth]++;
    }

    function getTokenBasicStats(address token) external view returns (
        uint256 totalBattles,
        uint256 totalWins,
        uint256 totalLosses,
        uint256 totalVotes,
        bool isCurrentKing,
        uint256 kingTime
    ) {
        TokenStats storage stats = tokenStats[token];
        return (
            stats.totalBattlesParticipated,
            stats.totalWins,
            stats.totalLosses,
            stats.totalVotes,
            currentKing == token,
            stats.kingCrownedTime
        );
    }

    function getTokenMonthlyStats(address token) external view returns (
        uint256[] memory monthlyBattles,
        uint256[] memory monthlyWins
    ) {
        monthlyBattles = new uint256[](6);
        monthlyWins = new uint256[](6);
        
        uint256 currentMonth = (block.timestamp / 30 days) % 6;
        
        for(uint256 i = 0; i < 6; i++) {
            uint256 monthIndex = (currentMonth + i) % 6;
            monthlyBattles[i] = monthlyBattleCount[token][monthIndex];
            monthlyWins[i] = monthlyWinCount[token][monthIndex];
        }

        return (monthlyBattles, monthlyWins);
    }

    function vote(uint256 _battleId, address _votingFor) external {
        Battle storage battle = battles[_battleId];
        require(block.timestamp >= battle.startTime, "Battle not started");
        require(block.timestamp < battle.endTime, "Battle ended");
        require(!hasVoted[_battleId][msg.sender], "Already voted");
        require(
            _votingFor == battle.token1 || _votingFor == battle.token2,
            "Invalid token"
        );

        uint256 votingPower = calculateVotingPower(msg.sender, battle.token1, battle.token2);
        require(votingPower > 0, "No voting power");

        if (_votingFor == battle.token1) {
            battle.token1Votes += votingPower;
        } else {
            battle.token2Votes += votingPower;
        }

        // Update vote stats
        tokenStats[_votingFor].totalVotes += votingPower;

        hasVoted[_battleId][msg.sender] = true;
        userVotingPower[_battleId][msg.sender] = votingPower;

        emit VoteCast(_battleId, msg.sender, _votingFor, votingPower);
    }

    function settleBattle(uint256 _battleId) external {
        Battle storage battle = battles[_battleId];
        require(block.timestamp >= battle.endTime, "Battle not ended");
        require(!battle.settled, "Already settled");

        address winner;
        if (battle.token1Votes > battle.token2Votes) {
            winner = battle.token1;
            tokenStats[battle.token2].totalLosses++;
        } else if (battle.token2Votes > battle.token1Votes) {
            winner = battle.token2;
            tokenStats[battle.token1].totalLosses++;
        } else {
            winner = battle.token1Votes == 0 ? address(0) : 
                    block.timestamp % 2 == 0 ? battle.token1 : battle.token2;
            if (winner != address(0)) {
                // In case of a tie with votes, the loser still gets a loss
                address loser = winner == battle.token1 ? battle.token2 : battle.token1;
                tokenStats[loser].totalLosses++;
            }
        }

        battle.winner = winner;
        battle.settled = true;

        // Update tokenScores for both tokens
        tokenScores[battle.token1].totalBattles++;
        tokenScores[battle.token2].totalBattles++;
        tokenScores[battle.token1].totalVotes += battle.token1Votes;
        tokenScores[battle.token2].totalVotes += battle.token2Votes;

        if (winner != address(0)) {
            // Update winner stats
            TokenStats storage winnerStats = tokenStats[winner];
            winnerStats.totalWins++;
            winnerStats.lastWinTime = block.timestamp;
            monthlyWinCount[winner][(block.timestamp / 30 days) % 6]++;

            // Update tokenScores for winner
            tokenScores[winner].wins++;

            // Check for new king (e.g., if won 3 battles in current month)
            if (monthlyWinCount[winner][(block.timestamp / 30 days) % 6] >= 3 && 
                winner != currentKing) {
                currentKing = winner;
                winnerStats.isKing = true;
                winnerStats.kingCrownedTime = block.timestamp;
                emit NewKingCrowned(winner, block.timestamp);
            }
        }

        emit BattleSettled(
            _battleId,
            winner,
            battle.token1Votes,
            battle.token2Votes
        );
    }

    function calculateVotingPower(
        address _voter,
        address _token1,
        address _token2
    ) public view returns (uint256) {
        MemedToken token1 = MemedToken(_token1);
        MemedToken token2 = MemedToken(_token2);
        
        uint256 token1Balance = token1.balanceOf(_voter);
        uint256 token2Balance = token2.balanceOf(_voter);
        
        // Square root of token balance to prevent whale dominance
        uint256 power1 = sqrt(token1Balance);
        uint256 power2 = sqrt(token2Balance);
        
        return power1 + power2;
    }

    function getLeaderboard(uint256 limit) external view returns (
        address[] memory tokens,
        uint256[] memory wins,
        uint256[] memory totalBattles,
        uint256[] memory totalVotes
    ) {
        // Get all tokens from factory
        YellowMemedFactory.AllTokenData[] memory allTokens = factory.getTokens(address(0));
        
        // Create arrays for sorting
        address[] memory sortedTokens = new address[](allTokens.length);
        uint256[] memory sortedWins = new uint256[](allTokens.length);
        uint256[] memory sortedBattles = new uint256[](allTokens.length);
        uint256[] memory sortedVotes = new uint256[](allTokens.length);
        
        // Fill arrays
        for (uint i = 0; i < allTokens.length; i++) {
            address tokenAddr = allTokens[i].token;
            TokenScore memory score = tokenScores[tokenAddr];
            sortedTokens[i] = tokenAddr;
            sortedWins[i] = score.wins;
            sortedBattles[i] = score.totalBattles;
            sortedVotes[i] = score.totalVotes;
        }
        
        // Sort by wins (simple bubble sort)
        for (uint i = 0; i < sortedTokens.length; i++) {
            for (uint j = i + 1; j < sortedTokens.length; j++) {
                if (sortedWins[j] > sortedWins[i]) {
                    // Swap all arrays
                    (sortedTokens[i], sortedTokens[j]) = (sortedTokens[j], sortedTokens[i]);
                    (sortedWins[i], sortedWins[j]) = (sortedWins[j], sortedWins[i]);
                    (sortedBattles[i], sortedBattles[j]) = (sortedBattles[j], sortedBattles[i]);
                    (sortedVotes[i], sortedVotes[j]) = (sortedVotes[j], sortedVotes[i]);
                }
            }
        }
        
        // Return limited results
        uint256 resultSize = limit > sortedTokens.length ? sortedTokens.length : limit;
        tokens = new address[](resultSize);
        wins = new uint256[](resultSize);
        totalBattles = new uint256[](resultSize);
        totalVotes = new uint256[](resultSize);
        
        for (uint i = 0; i < resultSize; i++) {
            tokens[i] = sortedTokens[i];
            wins[i] = sortedWins[i];
            totalBattles[i] = sortedBattles[i];
            totalVotes[i] = sortedVotes[i];
        }
    }

    // Helper function to calculate square root
    function sqrt(uint256 x) internal pure returns (uint256) {
        if (x == 0) return 0;
        uint256 z = (x + 1) / 2;
        uint256 y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
        return y;
    }

    function withdrawFees() external onlyOwner {
        uint256 amount = feesBalance;
        feesBalance = 0;
        payable(owner()).transfer(amount);
    }

    // Add function to get active and all battles
    function getBattles(bool activeOnly) external view returns (
        uint256[] memory battleIds,
        address[] memory token1Addresses,
        address[] memory token2Addresses,
        uint256[] memory token1Votes,
        uint256[] memory token2Votes,
        uint256[] memory startTimes,
        uint256[] memory endTimes,
        bool[] memory settled,
        address[] memory winners
    ) {
        uint256 count = 0;
        
        // First pass to count battles that match criteria
        for (uint256 i = 0; i < battleCount; i++) {
            Battle storage battle = battles[i];
            if (!activeOnly || (!battle.settled && block.timestamp < battle.endTime)) {
                count++;
            }
        }
        
        // Initialize arrays with correct size
        battleIds = new uint256[](count);
        token1Addresses = new address[](count);
        token2Addresses = new address[](count);
        token1Votes = new uint256[](count);
        token2Votes = new uint256[](count);
        startTimes = new uint256[](count);
        endTimes = new uint256[](count);
        settled = new bool[](count);
        winners = new address[](count);
        
        // Second pass to fill arrays
        uint256 index = 0;
        for (uint256 i = 0; i < battleCount; i++) {
            Battle storage battle = battles[i];
            if (!activeOnly || (!battle.settled && block.timestamp < battle.endTime)) {
                battleIds[index] = i;
                token1Addresses[index] = battle.token1;
                token2Addresses[index] = battle.token2;
                token1Votes[index] = battle.token1Votes;
                token2Votes[index] = battle.token2Votes;
                startTimes[index] = battle.startTime;
                endTimes[index] = battle.endTime;
                settled[index] = battle.settled;
                winners[index] = battle.winner;
                index++;
            }
        }
    }
} 