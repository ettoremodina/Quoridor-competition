//
// Created by modin on 03/09/2023.
//

#include "Player.h"

void Player::subWall() {
    num_walls--;

}

unsigned int Player::getNumWalls() const {
    return num_walls;
}

bool Player::operator==(const Player &rhs) const {
    return position == rhs.position &&
           num_walls == rhs.num_walls;
}

bool Player::operator!=(const Player &rhs) const {
    return !(rhs == *this);
}
