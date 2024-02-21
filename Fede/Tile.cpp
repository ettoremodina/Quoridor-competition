//
// Created by modin on 03/0dim/2023.
//

#include "Tile.h"
#include "Position.h"

const unsigned & Tile::getOccupancy() const {
    return occupancy;
}

void Tile::setOccupancy(unsigned int occupancy) {
    Tile::occupancy = occupancy;
}

int Tile::getU() const {
    return u;
}

void Tile::setU(int u) {
    Tile::u = u;
}

int Tile::getD() const {
    return d;
}

void Tile::setD(int d) {
    Tile::d = d;
}

int Tile::getL() const {
    return l;
}

void Tile::setL(int l) {
    Tile::l = l;
}

int Tile::getR() const {
    return r;
}

void Tile::setR(int r) {
    Tile::r = r;
}

Tile::Tile(const Position &pos) {
    if(pos.getY()==0)
        l = 0;
    else
        l = 1;

    if(pos.getY()==dim-1)
        r = 0;
    else
        r = 1;

    if(pos.getX()==0)
        u = 0;
    else
        u = 1;
    if(pos.getX()==dim-1)
        d = 0;
    else
        d = 1;

}





