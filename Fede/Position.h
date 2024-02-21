//
// Created by modin on 03/09/2023.
//

#ifndef QUORIDOR_POSITION_H
#define QUORIDOR_POSITION_H
#include "iostream"

class Position {
private:
    unsigned x; // righe
    unsigned y; // colonne
public:
    bool operator<(const Position &rhs) const;

    bool operator>(const Position &rhs) const;

    bool operator<=(const Position &rhs) const;

    bool operator>=(const Position &rhs) const;

    Position(unsigned x, unsigned y):x(x),y(y){};
    unsigned int getX() const;
    unsigned int getY() const;

    void setX(unsigned int x);

    void setY(unsigned int y);
    void print() const;



    bool operator==(const Position &rhs) const;
    bool operator!=(const Position &rhs) const;
};


#endif //QUORIDOR_POSITION_H
