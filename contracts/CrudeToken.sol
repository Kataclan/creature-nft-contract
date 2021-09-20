pragma solidity 0.8.0;

import '../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol';

import '../node_modules/@openzeppelin/contracts/access/Ownable.sol';

contract CreatureToken is ERC721 , Ownable {

  uint256 nextCreatureId = 0;

  uint16 public constant LVL_1_XP = 0;
  uint16 public constant LVL_2_XP = 300;
  uint16 public constant LVL_3_XP = 750;
  uint16 public constant LVL_4_XP = 1500;
  uint16 public constant LVL_5_XP = 3000;

  uint16 public constant MAX_ENERGY = 100;
  uint256 public constant BASE_RESTING_TIME = 24 hours;

  struct CreatureStats {
    uint16 hp; // Health Points
    uint16 str; // Strength Power
    uint16 mp; // Magical Power
    uint16 ag; // Agility Points 
    uint16 pDef; // Phisical Defense
    uint16 mDef; // Magical defense
    uint256 restingTime; // Time to rest
  }

  struct Creature {
    uint8 level; // 0 - 10 || 0 == kid
    uint16 xp; // XP Points: 0 -> LVL_N_XP 
    string tribe;
    CreatureStats stats;
    uint8 energy; // 0 - 100 - 0 cannot be traded and cannot play
    uint256 restingEndTimestamp; // Timestamp when Creature is recovered. if != 0 cannot be traded and cannot play
  }

  mapping(string => CreatureStats) private _tribeStats;
  mapping(uint256 => Creature) private _tokenDetails;
  constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

  modifier isRested(uint256 tokenId){
    require(_tokenDetails[tokenId].restingEndTimestamp == 0,'This Creature is resting');
    _;
  }

  function getTribeDetails(string memory tribeName) public view returns (CreatureStats memory){
    return _tribeStats[tribeName];
  }

  function getTokenDetails(uint256 tokenId) public view returns (Creature memory){
    return _tokenDetails[tokenId];
  }

  function addTribe(
    string memory tribeName,
    uint8 hp,
    uint8 str,
    uint8 mp,
    uint8 ag,
    uint8 pDef,
    uint8 mDef
  ) public onlyOwner {
    require(_tribeStats[tribeName].hp == 0); // Check that tribe is not present (hp can't be 0)
    _tribeStats[tribeName] = CreatureStats(hp, str, mp, ag, pDef, mDef, BASE_RESTING_TIME);
  }

  function mint(
    string memory _tribe
  ) public onlyOwner {
    _tokenDetails[nextCreatureId] = Creature(0, 0, _tribe, _tribeStats[_tribe], 100, 0);
    _safeMint(msg.sender, nextCreatureId);
    nextCreatureId++;
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 tokenId
  ) internal override isRested(tokenId){}

  // [CHARACTER MANAGEMENT]

  // XP Management
  function addXP(
    uint256 tokenId,
    uint16 xpPoints
  ) public onlyOwner {
    require(xpPoints > 0); 
    require(_tokenDetails[tokenId].stats.hp != 0);
    require(_tokenDetails[tokenId].xp + xpPoints <= LVL_5_XP); 

    _tokenDetails[tokenId].xp += xpPoints;
    if (_tokenDetails[tokenId].xp > LVL_2_XP && _tokenDetails[tokenId].level < 2){
      _tokenDetails[tokenId].level = 2;
    }
    if (_tokenDetails[tokenId].xp > LVL_3_XP && _tokenDetails[tokenId].level < 3){
      _tokenDetails[tokenId].level = 3;
    }
    if (_tokenDetails[tokenId].xp > LVL_4_XP && _tokenDetails[tokenId].level < 4){
      _tokenDetails[tokenId].level = 4;
    }
    if (_tokenDetails[tokenId].xp == LVL_5_XP && _tokenDetails[tokenId].level < 5){
      _tokenDetails[tokenId].level = 5;
    }
  }
  
  // Energy Management
  function feed(
    uint256 tokenId,
    uint8 energyToRestore
  ) public onlyOwner isRested(tokenId) {
    require(energyToRestore > 0);
    require(_tokenDetails[tokenId].energy + energyToRestore <= 100);
    _tokenDetails[tokenId].energy += energyToRestore;
  }

  function exhaust(
    uint256 tokenId,
    uint8 energyToLose
  ) public onlyOwner isRested(tokenId) {
     require(energyToLose > 0);
     if (energyToLose - _tokenDetails[tokenId].energy < 0){
       _tokenDetails[tokenId].energy = 0;
       _tokenDetails[tokenId].restingEndTimestamp = block.timestamp + _tokenDetails[tokenId].stats.restingTime;
     } else {
       _tokenDetails[tokenId].energy -= energyToLose;
     }
  }
}

