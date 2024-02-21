//
// Created by modin on 11/09/2023.
//
#include "Board.h"
Board::Board(unsigned int dim, unsigned int wall_limit):
        dim(dim),wall_limit(wall_limit), player1(Position(0,(dim-1)/2)), player2(Position(dim-1,(dim-1)/2 )), walls(dim, std::vector<wall_tile>(dim)) {
     // build board and
    // set Tile occupancy in players position
    for(unsigned row=0;row<dim;row++){
        std::vector<Tile> row_vect;
        for(unsigned col=0;col<dim;col++){
            Tile tile=Tile(Position(row,col));
            if (player1.getPosition()==Position(row,col))
                tile.setOccupancy(1);
            if (player2.getPosition()==Position(row,col))
                tile.setOccupancy(2);
            row_vect.push_back(tile);
        }
        board.push_back(row_vect);
    }
    wallsInit();
}

void Board::printBoard() {
    for(int row = 0; row<dim; row++){
        std::cout<<"| "<<row<<" ";
    }
    std::cout<<"\n";


    for(int row = 0; row<dim; row++){
        compileRow(row);
    }
    for(size_t i = 0; i<dim; i++){
        std::cout<<"* * ";
    }
    std::cout<<"*"<<" __"<<"\n";

    /// print graph
    Position pos=player1.getPosition();
    std::vector<std::vector<int>> ming= distance_graph(pos);
    shortest_path(ming,dim);

    pos=player2.getPosition();
    ming=distance_graph(pos);
    shortest_path(ming,0);

}

void Board::print_list(std::list<std::string>& mlist){
    std::cout<<"\n";
    for(auto&i:mlist){
        std::cout<<i<<" ";
    }
    std::cout<<"\n";
}

void Board::print_graph(std::vector<std::vector<int>> &graph){
    for (int i = 0; i < dim; ++i) {
        for (int j = 0; j < dim; ++j) {
            std::cout << graph[i][j] << " ";
        }
        std::cout << std::endl;
    }
    std::cout << std::endl;
}

void Board::compileRow(int& row){
    for(size_t i = 0; i<dim; i++){
        std::string val = "*";
        if(board[row][i].getU()) val =".";
        if (row==0){
            std::cout<<"* "<<val<<" ";
        }
        else if(row!=0 && i==0){ //prima colonna (bordo sinistro sono *)
            std::cout<<"* "<<val<<" ";
        }else{
            std::cout<<". "<<val<<" ";
        }

    }
    std::cout<<"*"<<" __\n";

    for(size_t i = 0; i<dim; i++){
        std::string val = "*";
        if(board[row][i].getL()) val = ".";
        std::string occup = " ";
        if(board[row][i].getOccupancy()==1)
            occup = "1";
        else if(board[row][i].getOccupancy()==2)
            occup = "2";
        std::cout<<val<<" "<<occup<<" ";
    }
    std::cout<<"* "<<row<<"\n";
}


void Board::startGame() {
    std::cout<<"\n";
    printBoard();
    while(!winCondition()){
        std::cout<<"\nPlayer1 turn:\n";
        playturn(player1); //player 1
        if(winCondition())
            return;
        std::cout<<"\nPlayer2 turn:\n";
        playturn(player2); //player 2
    }
}

void Board::playturn(Player& player) {

    if(player.getNumWalls()>0){
        std::cout<<"\nm for move, w for wall";
        std::string action;
        std::cin>>action;
        if (!(action=="m"||action=="w")){ //if both false
            bool flag=true;
            while(flag){
                std::cout<<"\nwrong action! please enter m or w: ";
                std::cin>>action;
                if (action=="m"||action=="w")
                    flag=false;
            }
        }


        if (action=="m"){
            move(player);

        }
        if (action=="w" ){
            placeWall();
            player.subWall();

        }


    }else{
        move(player);
    }
    printBoard();
}

bool Board::winCondition() {
    if (player1.getPosition().getX()==dim-1){
        std::cout<<"player 1 win!";
        return true;
    }

    if (player2.getPosition().getX()==0){
        std::cout<<"player 2 win!";
        return true;
    }
    return false;
}
