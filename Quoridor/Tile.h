//
// Created by modin on 03/09/2023.
//

#ifndef QUORIDOR_TILE_H
#define QUORIDOR_TILE_H

#include "Position.h"
//#include "MyParameters.h"

class Tile {
private:
    unsigned occupancy=0; //0 if free, 1 if player 1, 2 if player 2
    int u,d,l,r;  // basterebbe un bool: 0 se occupato da un muro o sul bordo, 1 se libero
    int dim=5;
public:
    explicit Tile(const Position &pos );

    int getU() const;
    void setU(int u);
    int getD() const;
    void setD(int d);
    int getL() const;
    void setL(int l);
    int getR() const;
    void setR(int r);
    const unsigned &getOccupancy() const;
    void setOccupancy(unsigned int occupancy);

};


#endif //QUORIDOR_TILE_H
