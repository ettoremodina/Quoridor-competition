//
// Created by modin on 03/09/2023.
//

#ifndef QUORIDOR_BOARD_H
#define QUORIDOR_BOARD_H

#include "iostream"
#include <cctype>
#include "map"
#include "vector"
#include "queue"
#include "set"
#include "unordered_set"
#include <string>
#include "list"

#include "Position.h"
#include "Tile.h"
#include "Player.h"

//#include "MyParameters.h"

struct wall_tile{
    bool h=true;
    bool v=true;
};



class Board {
private:
    unsigned dim;
    unsigned wall_limit;
    std::vector<std::vector<Tile>> board;
    std::vector<std::vector<wall_tile>> walls;
    std::vector<std::vector<int>> graph=std::vector<std::vector<int>>(dim, std::vector<int>(dim, 0));
    Player player1,player2;  // player1 {0->8} player2 {8->0}
public:
    Board(unsigned dim,unsigned wall_limit);


    void startGame();
    bool winCondition();
    void playturn(Player& player);

    void printBoard();

    Position get_coordinate();
    bool freePath(Position p,const unsigned goal);
    void removeWall(Position &pos, const std::string& direction);
    void placeWall();
    void place_wall_final(Position pos,std::string direction);
    void wallsInit();
    bool wallFree(Position &pos, std::string direction);
    void wallUpdate(Position &pos, std::string direction);



    void compileRow(int& row);

    void move(Player& p);
    std::string playersAreClose();
    void jumpMove(Player &player,std::set<std::string>& availMoves);
    void move_from_input(Player &player,const std::set<std::string> &availMoves);
    void move_final(Player &player, std::pair<int, int> &pair1);
    std::pair<int, int> compute_increment(const std::string& dir);


    std::set<std::string> getFreeDirections(const Tile&);
    std::string switch_direction(std::string dir);

    std::vector<std::vector<int>> distance_graph(Position &p);

    void print_graph(std::vector<std::vector<int>> &graph);

    std::list<std::string> shortest_path(std::vector<std::vector<int>> &graph, int goal);

    void print_list(std::list<std::string> &mlist);
};


#endif //QUORIDOR_BOARD_H