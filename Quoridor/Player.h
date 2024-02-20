//
// Created by modin on 03/09/2023.
//

#ifndef QUORIDOR_PLAYER_H
#define QUORIDOR_PLAYER_H

#include "Position.h"
class Player {
private:
    Position position;
    unsigned num_walls = 10;
public:
    bool operator==(const Player &rhs) const;

    bool operator!=(const Player &rhs) const;

public:
    Player(Position position):position(position){
    }

    const Position &getPosition() const {
        return position;
    }

    void setPosition(const Position &position) {
        Player::position = position;
    }

    unsigned int getNumWalls() const;


    void subWall();
};


#endif //QUORIDOR_PLAYER_H
