//
// Created by modin on 11/09/2023.
//
#include "Board.h"

std::vector<std::vector<int>>  Board::distance_graph(Position &p){
    std::queue<Position> coda;
    std::set<Position> visited;
    visited.insert(p);
    coda.push(p);
    std::vector<std::vector<int>> graph_dist=std::vector<std::vector<int>>(dim, std::vector<int>(dim, 0));



    while (!coda.empty()) {
        Position posC = coda.front();
        coda.pop();


        Position newPosU(posC.getX()-1, posC.getY());
        if (board[posC.getX()][posC.getY()].getU() == 1  && visited.find(newPosU) == visited.end()) {
            graph_dist[posC.getX()-1][posC.getY()]=graph_dist[posC.getX()][posC.getY()]+1;
            coda.push(newPosU);
            visited.insert(newPosU);
        }


        Position newPosD(posC.getX()+1, posC.getY());
        if (board[posC.getX()][posC.getY()].getD() == 1 && visited.find(newPosD)== visited.end()) {
            graph_dist[posC.getX()+1][posC.getY()]=graph_dist[posC.getX()][posC.getY()]+1;;
            coda.push(newPosD);
            visited.insert(newPosD);
        }

        Position newPosR(posC.getX(), posC.getY() + 1);
        if (board[posC.getX()][posC.getY()].getR() == 1 && visited.find(newPosR)== visited.end()) {
            graph_dist[posC.getX()][posC.getY()+1]=graph_dist[posC.getX()][posC.getY()]+1;
            coda.push(newPosR);
            visited.insert(newPosR);

        }

        Position newPosL(posC.getX(), posC.getY() - 1);
        if (board[posC.getX()][posC.getY()].getL() == 1  && visited.find(newPosL)== visited.end()) {
            graph_dist[posC.getX()][posC.getY()-1]=graph_dist[posC.getX()][posC.getY()]+1;
            coda.push(newPosL);
            visited.insert(newPosL);
        }


    }
    print_graph(graph_dist);

    return graph_dist;
}



std::list<std::string> Board::shortest_path(std::vector<std::vector<int>> &graph, int goal){
    std::list<std::string> moves;
    int min=dim*dim;
    std::pair<int,int> pos_min; /// consider also the case with multiples min
    if(goal==0){
        pos_min.first=0;
        for(size_t i=0; i<dim;i++){
            if(graph[0][i]<min && graph[0][i]>0){
                min=graph[0][i];
                pos_min.second=i;
            }
        }
    }
    if(goal==dim){
        pos_min.first=dim-1;
        for(size_t i=0; i<dim;i++){
            if(graph[dim-1][i]<min && graph[dim-1][i]>0){
                min=graph[dim-1][i];
                pos_min.second=i;
            }
        }
    }

    /// SBAGLIATO
    while(min>=0){
        if(pos_min.first-1>=0 && graph[pos_min.first-1][pos_min.second]==min-1 ){
            pos_min.first=pos_min.first-1;
            moves.push_front("d");
        }
        else if(pos_min.first+1<dim && graph[pos_min.first+1][pos_min.second]==min-1 ){
            pos_min.first=pos_min.first+1;
            moves.push_front("u");
        }
        else if(pos_min.second-1>=0 && graph[pos_min.first][pos_min.second-1]==min-1  ){
            pos_min.second=pos_min.second-1;
            moves.push_front("r");
        }
        else if(pos_min.second+1<dim && graph[pos_min.first][pos_min.second+1]==min-1 ){
            pos_min.second=pos_min.second+1;
            moves.push_front("l");
        }
        min--;
    }
    print_list(moves);
    return moves;
}


