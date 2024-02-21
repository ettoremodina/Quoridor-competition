#include "Board.h"
// Created by modin on 10/09/2023.
//


std::string Board::playersAreClose() { // POV OF PLAYER 1
    if(player1.getPosition().getX()-player2.getPosition().getX()==1 && player1.getPosition().getY()==player2.getPosition().getY())
        return "d";
    if(player1.getPosition().getX()-player2.getPosition().getX()==-1&& player1.getPosition().getY()==player2.getPosition().getY())
        return "u";
    if(player1.getPosition().getY()-player2.getPosition().getY()==1&& player1.getPosition().getX()==player2.getPosition().getX())
        return "r";
    if(player1.getPosition().getY()-player2.getPosition().getY()==-1&& player1.getPosition().getX()==player2.getPosition().getX())
        return "l";
    return "0";
}

std::string Board::switch_direction( std::string dir) {
    if(dir=="u"){
        dir="d";
    }
    else if(dir=="d"){
        dir="u";
    }
    else if(dir=="l"){
        dir="r";
    }
    else if (dir=="r"){
        dir="l";
    }
    return dir;

}

void Board::jumpMove(Player &p,std::set<std::string>& availMoves) {

    std::string other_player_dir = playersAreClose(); // relative position of p1
    Tile other_player_tile = board[player2.getPosition().getX()][player2.getPosition().getY()];
    if (p == player2){
        other_player_dir = switch_direction(other_player_dir);
        other_player_tile = board[player1.getPosition().getX()][player1.getPosition().getY()];
    }

    std::set<std::string> other_player_free_pos = getFreeDirections(other_player_tile);
    // immediate opposite position is free
    if(other_player_free_pos.find(switch_direction(other_player_dir))!=other_player_free_pos.cend()){
        std::string new_dir = switch_direction(other_player_dir).append("1");
        availMoves.insert(new_dir);

    }else{ //opposite position is blcocked, add all, remove one occupied by
        for(auto &dir:other_player_free_pos){
            if(dir!= other_player_dir)
                availMoves.insert(switch_direction(other_player_dir).append(dir));
        }

    }
    availMoves.erase(switch_direction(other_player_dir));

}


void Board::move_from_input(Player &p, const std::set<std::string>& availMoves) {
    std::cout<<"\n the available moves are ";
    for(auto&m: availMoves){
        std::cout<<m<<" ";
    }

    std::string dir;
    std::cout << "\nChoose direction: ";
    std::cin >> dir;
    bool flag = true;
    while(flag) {
        if (availMoves.find(dir) != availMoves.end())
            flag = false;
        else{
            std::cout << "\nWrong direction: ";
            std::cin >> dir;
        }
    }

    std::pair<int,int> increment;
    increment=compute_increment(dir);
    move_final(p,increment);

}

std::set<std::string> Board::getFreeDirections(const Tile &tile) {
    std::set<std::string> freeDir;
    if(tile.getD()==1){
        freeDir.insert("d");
    }
    if(tile.getU()==1){
        freeDir.insert("u");
    }
    if(tile.getL()==1){
        freeDir.insert("l");
    }
    if(tile.getR()==1){
        freeDir.insert("r");
    }
    return freeDir;
}



std::pair<int, int> Board::compute_increment(const std::string& dir) {
    std::pair<int,int> increment;
    if(dir == "u"){
        increment.first=-1;
        increment.second=0;

    }
    else if(dir == "d"){
        increment.first=1;
        increment.second=0;

    }
    else if(dir == "l"){
        increment.first=0;
        increment.second=-1;
    }
    else if(dir == "r"){
        increment.first=0;
        increment.second=1;
    }
    else if(dir == "u1"){
        increment.first=-2;
        increment.second=0;
    }
    else if(dir == "d1"){
        increment.first=2;
        increment.second=0;
    }
    else if(dir == "l1"){
        increment.first=0;
        increment.second=-2;
    }
    else if(dir == "r1"){
        increment.first=0;
        increment.second=2;
    }
    else if(dir == "ul"||dir == "lu"){
        increment.first=-1;
        increment.second=-1;
    }
    else if(dir == "ur"||dir == "ru"){
        increment.first=-1;
        increment.second=1;
    }
    else if(dir == "dl"||dir == "ld"){
        increment.first=1;
        increment.second=-1;
    }
    else if(dir == "dr"||dir == "rd"){
        increment.first=1;
        increment.second=1;
    }
    return increment;
}


void Board::move_final(Player &p, std::pair<int, int>& increment) {
    // change occupancy
    board[p.getPosition().getX()+increment.first][p.getPosition().getY()+increment.second].setOccupancy(board[p.getPosition().getX()][p.getPosition().getY()].getOccupancy());
    board[p.getPosition().getX()][p.getPosition().getY()].setOccupancy(0);
    //move player
    p.setPosition(Position(p.getPosition().getX()+increment.first,p.getPosition().getY()+increment.second));
}



void Board::move(Player&p) {
    std::set<std::string> availMoves;
    Position curr=p.getPosition();
    Tile currTile=board[curr.getX()][curr.getY()];

    std::set<std::string> availMoves_temp=getFreeDirections(currTile);
    availMoves.insert(availMoves_temp.begin(),availMoves_temp.end());


    if(playersAreClose()!="0"){
        jumpMove(p,availMoves);
    }

    move_from_input(p,availMoves);
}




