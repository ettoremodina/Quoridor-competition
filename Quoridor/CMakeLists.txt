cmake_minimum_required(VERSION 3.23)
project(Quoridor)

set(CMAKE_CXX_STANDARD 14)

add_executable(Quoridor main.cpp Tile.cpp Position.cpp Board.cpp Player.cpp
        Board_move.cpp Board_helper_functions.cpp Board_graph_algo.cpp)
