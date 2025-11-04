// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract ScoreStorage {
    struct PlayerScore {
        string playerName;
        uint256 score;
    }

    // Mapping de l’adresse du joueur vers son score
    mapping(address => PlayerScore) private scores;

    // Event pour log les nouveaux scores
    event ScoreSaved(address indexed player, string playerName, uint256 score);

    // Fonction pour enregistrer le score
    function storeScore(string memory _playerName, uint256 _score) public {
        scores[msg.sender] = PlayerScore(_playerName, _score);
        emit ScoreSaved(msg.sender, _playerName, _score);
    }

    // Fonction pour récupérer le score
    function getScore(address _player) public view returns (string memory, uint256) {
        PlayerScore memory playerData = scores[_player];
        return (playerData.playerName, playerData.score);
    }
}
