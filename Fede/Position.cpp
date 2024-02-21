//
// Created by modin on 03/09/2023.
//

#include "Position.h"

unsigned int Position::getX() const {
    return x;
}

unsigned int Position::getY() const {
    return y;
}

bool Position::operator==(const Position &rhs) const {
    return x == rhs.x &&
           y == rhs.y;
}

bool Position::operator!=(const Position &rhs) const {
    return !(rhs == *this);
}

void Position::setX(unsigned int x) {
    Position::x = x;
}

void Position::setY(unsigned int y) {
    Position::y = y;
}

bool Position::operator<(const Position &rhs) const {
    if (x < rhs.x)
        return true;
    if (rhs.x < x)
        return false;
    return y < rhs.y;
}

bool Position::operator>(const Position &rhs) const {
    return rhs < *this;
}

bool Position::operator<=(const Position &rhs) const {
    return !(rhs < *this);
}

bool Position::operator>=(const Position &rhs) const {
    return !(*this < rhs);
}

void Position::print() const{
    std::cout<<"\n x: "<<x<<" y: "<<y;

}

