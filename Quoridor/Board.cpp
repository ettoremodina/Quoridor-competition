//
// Created by modin on 03/09/2023.
//

#include "Board.h"



void Board::placeWall() {
    while(true){
        std::cout<<"\nDirection: H for horizontal V for vertical";
        std::string direction;
        std::cin>>direction;
        if(direction!="h"&&direction!="v"){
            std::cout<<"\nwrong input";
        }
        else{
            Position pos = get_coordinate();

            if(wallFree(pos,direction)) {
                wallUpdate(pos, direction);
                place_wall_final(pos,direction);
            }else{
                std::cerr<<"non piazzabile, c'è un muro o il bordo";
            }
            if (freePath(player1.getPosition(),dim-1) && freePath(player2.getPosition(),0)){
                return;
            }
            else{
                std::cerr<<"non piazzabile, occludi il passaggio";
                removeWall(pos,direction);
            }
        }
    }
}


void Board::wallsInit() {
    for(size_t i = 0;i<dim;i++){
        walls[dim-1][i].h=false;
        walls[dim-1][i].v=false;

        walls[i][dim-1].h=false;
        walls[i][dim-1].v=false;
    }
}

bool Board::wallFree(Position &pos, std::string direction) {
    if(direction=="h")
        return walls[pos.getX()][pos.getY()].h;
    if (direction=="v")
        return walls[pos.getX()][pos.getY()].v;
}

void Board::wallUpdate(Position &pos, std::string direction) {
    walls[pos.getX()][pos.getY()].h=false;
    walls[pos.getX()][pos.getY()].v=false;

    /// check you don't exceed boundarys
    if (direction=="h"){
        walls[pos.getX()][pos.getY()+1].h=false;
        if(pos.getY()!=0)
            walls[pos.getX()][pos.getY()-1].h=false;
    }
    if (direction=="v"){
        walls[pos.getX()+1][pos.getY()].v=false;
        if(pos.getX()!=0)
            walls[pos.getX()-1][pos.getY()].v=false;

    }


}




bool Board::freePath(Position p,const unsigned goal) {
    std::queue<Position> coda;
    std::set<Position> visited;
    visited.insert(p);
    coda.push(p);


    while (!coda.empty()) {
        Position posC = coda.front();
        coda.pop();

        if (posC.getX() == goal) {
            return true;
        }

        Position newPosU(posC.getX()-1, posC.getY());
        if (board[posC.getX()][posC.getY()].getU() == 1  && visited.find(newPosU) == visited.end()) {
            coda.push(newPosU);
            visited.insert(newPosU);
        }


        Position newPosD(posC.getX()+1, posC.getY());
        if (board[posC.getX()][posC.getY()].getD() == 1 && visited.find(newPosD)== visited.end()) {
            coda.push(newPosD);
            visited.insert(newPosD);
        }

        Position newPosR(posC.getX(), posC.getY() + 1);
        if (board[posC.getX()][posC.getY()].getR() == 1 && visited.find(newPosR)== visited.end()) {
            coda.push(newPosR);
            visited.insert(newPosR);

        }

        Position newPosL(posC.getX(), posC.getY() - 1);
        if (board[posC.getX()][posC.getY()].getL() == 1  && visited.find(newPosL)== visited.end()) {
            coda.push(newPosL);
            visited.insert(newPosL);
        }

    }

    return false; // Il giocatore non può raggiungere la destinazione
}
void Board::removeWall(Position &pos, const std::string& direction) {
    if(direction=="h") {
        board[pos.getX()][pos.getY()].setD(1);
        board[pos.getX()][pos.getY()+1].setD(1);

        board[pos.getX()+1][pos.getY()].setU(1);
        board[pos.getX()+1][pos.getY()+1].setU(1);
        return;

    }else if(direction == "v"){

        board[pos.getX()][pos.getY()].setR(1);
        board[pos.getX()+1][pos.getY()].setR(1);

        board[pos.getX()][pos.getY()+1].setL(1);
        board[pos.getX()+1][pos.getY()+1].setL(1);
        return;

    }
}

void Board::place_wall_final(Position pos,std::string direction) {
    if(direction=="h"){
        int h=1;
        board[pos.getX()][pos.getY()].setD(0);
        board[pos.getX()][pos.getY()+h].setD(0);

        board[pos.getX()+h][pos.getY()].setU(0);
        board[pos.getX()+h][pos.getY()+h].setU(0);
    }
    if(direction=="v"){
        int v = 1;
        board[pos.getX()][pos.getY()].setR(0);
        board[pos.getX()+v][pos.getY()].setR(0);

        board[pos.getX()][pos.getY()+v].setL(0);
        board[pos.getX()+v][pos.getY()+v].setL(0);
    }

}

Position Board::get_coordinate() {
    while(true){

        std::cout<<"\nX coordinate: ";
        int x;
        std::cin>>x;
        std::cout<<"\nY coordinate: ";
        int y;
        std::cin>>y;
        if(x>=0&&x<dim&&y>=0&&y<dim){
            Position pos(x,y);
            return pos;
        }else{
            std::cout<<"\nWrong inputs, try again ";
        }

    }
}








