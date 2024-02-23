module Quoridor
# chat gpt created

using UnicodePlots

export Game, print_board, move_pawn, place_wall, switch_player, calculate_distance_matrix, print_distance_matrix, play # for testing everything
# export play # real one

const EMPTY, PAWN, WALL = 0, 1, 2
const DIRECTIONS = Dict('w' => (-1, 0), 's' => (1, 0), 'a' => (0, -1), 'd' => (0, 1))
const BOARD_SIZE = 4
const MAX_WALLS = 10

mutable struct Player
    row::Int
    col::Int
    walls::Int
    name::String
end

mutable struct Game
    board::Array{Int,2}
    players::Array{Player,1}
    current_player::Int
end

function Game()
    print("Player 1 name: ")
    name1 = readline()
    print("Player 2 name: ")
    name2 = readline()
    println()

    board = fill(EMPTY, BOARD_SIZE, BOARD_SIZE)
    # board[BOARD_SIZE, ceil(Int, BOARD_SIZE / 2)] = 1
    # board[1, ceil(Int, BOARD_SIZE / 2)] = 2
    players = [Player(BOARD_SIZE, ceil(Int, BOARD_SIZE / 2), MAX_WALLS,name1),
               Player(1, ceil(Int, BOARD_SIZE / 2), MAX_WALLS,name2)]
    return Game(board, players, 1)
end


function print_board(game::Game)
    PAD = 2
    print(" "^(PAD+1))
    for col in 1:BOARD_SIZE
        print("$(col%10==0 ? " " : col%10) ")
    end
    print("\n  ┌")
    print("──"^(BOARD_SIZE),"┐")
    print("\n")
    for row in 1:BOARD_SIZE
        print(row%10==0 ? " "^PAD : rpad(row%10,PAD) ,"│")
        for col in 1:BOARD_SIZE
            if all([(p.row == row) && (p.col == col) for p in game.players])
                # @show game.players[1]
                # print("B ")
                print("½ ")
            elseif (game.players[1].row == row && game.players[1].col == col)
                print("1 ")
            elseif (game.players[2].row == row && game.players[2].col == col)
                print("2 ")
            elseif game.board[row, col] == WALL
                print("# ")
            else
                print(". ")
            end
        end

        if row == BOARD_SIZE-1
            println("│ Player 1 ($(game.players[1].name)) Walls: ", game.players[1].walls)
        elseif row == BOARD_SIZE
            println("│ Player 2 ($(game.players[2].name)) Walls: ", game.players[2].walls)
        else
            println("│")
        end

    end
    println(" "^PAD,"└","──"^BOARD_SIZE,"┘")
    # println("Player 1 ($(game.players[1].name)) Walls: ", game.players[1].walls, " Player 2 ($(game.players[2].name)) Walls: ", game.players[2].walls)
end

function move_pawn(game::Game, direction::Char)
    # @show direction
    if !(direction in keys(DIRECTIONS))
        @info "Provide a valid direction."
        return 0
    end

    dr, dc = DIRECTIONS[direction]
    player = game.players[game.current_player]
    new_row, new_col = player.row + dr, player.col + dc

    if new_row >= 1 && new_row <= BOARD_SIZE && new_col >= 1 && new_col <= BOARD_SIZE
        if game.board[new_row, new_col] == EMPTY
            player.row, player.col = new_row, new_col
            return 1
        else
            @info "Can't move there! there is a wall. Select a valid move."
            return 0
        end
    else
        @info "Can't move outside the board. Select a valid move."
        return 0
    end
end

function place_wall(game::Game, row::Int, col::Int)
    if game.players[game.current_player].walls > 0
        if row >= 1 && row <= BOARD_SIZE && col >= 1 && col <= BOARD_SIZE && 
            game.board[row, col] == EMPTY &&
            !((game.players[1].row == row) && (game.players[1].col == col)) &&
            !((game.players[2].row == row) && (game.players[2].col == col))
    
            game.board[row, col] = WALL
            updated_board_pl1 = calculate_distance_matrix(game, 1)
            updated_board_pl2 = calculate_distance_matrix(game, 2)

            # pointwise comparison .==
            if any(updated_board_pl1[1,:] .== -1) || any(updated_board_pl1[BOARD_SIZE,:] .== -1)
                @info "Can't place a wall there. Would block the path for someone."
                game.board[row, col] = 0
                return 0
            else
                game.players[game.current_player].walls -= 1
                return 1
            end
        else
            @info "Wrong coordinates. Select a valid move."
            return 0
        end
    else
        @info "Walls finished. Select a valid move."
    end
end

function switch_player(game::Game)
    game.current_player = 3 - game.current_player
end


function calculate_distance_matrix(game::Game, player_num::Int)
    player = game.players[player_num]
    player_pos = (player.row, player.col)
    
    distance = fill(-1, BOARD_SIZE, BOARD_SIZE)
    visited = falses(BOARD_SIZE, BOARD_SIZE)
    
    queue = [(player_pos, 0)]
    visited[player_pos...] = true
    distance[player_pos...] = 0
    
    while !isempty(queue)
        (current_row, current_col), dist = popfirst!(queue)
        neighbors = [(current_row + dr, current_col + dc) for (dr, dc) in values(DIRECTIONS)]
        
        for (next_row, next_col) in neighbors
            if next_row in 1:BOARD_SIZE && next_col in 1:BOARD_SIZE && !visited[next_row, next_col] && game.board[next_row, next_col] != WALL
                push!(queue, ((next_row, next_col), dist + 1))
                visited[next_row, next_col] = true
                distance[next_row, next_col] = dist + 1
            end
        end
    end
    return distance
end

function print_distance_matrix(distance::Array{Int,2})
    for row in 1:BOARD_SIZE
        for col in 1:BOARD_SIZE
            print(rpad(distance[row, col], 3))
        end
        println()
    end
end

function play()
    game = Game()
    gioca=1
    while gioca==1
        println("Current board:")
        print_board(game)
        # printstyled("Player ", game.current_player, " ($(game.players[game.current_player].name))";bold=true)
        # println("'s turn. Move (w/a/s/d) or place wall (e.g., 'wall x y'):")

        println("Move (w/a/s/d) or place wall (e.g., 'wall x y').")

        distance_matrix = calculate_distance_matrix(game, game.current_player)

        # if isdefined(Quoridor, :UnicodePlots)
            println(heatmap(distance_matrix,array=true,colormap=:devon,
                zlabel="Pl$(game.current_player) ($(game.players[game.current_player].name))"))
        # else
            print_distance_matrix(distance_matrix)
        # end

        moved = 0
        while moved==0
            printstyled("Pl", game.current_player, " ($(game.players[game.current_player].name))'s turn: ";bold=true)
            input = readline()
            if occursin("wall", input)
                args = split(input)
                try    
                    row, col = parse(Int, args[2]), parse(Int, args[3])
                    moved = place_wall(game, row, col)
                catch e
                    @error e
                    @info "Something went wrong in placing the wall. Select a valid move."
                end
            elseif input=="quit" || input=="q"
                moved=1
                gioca=0
                println("Ending the game.")
            else
                try
                    if any(input .== ["w", "a", "s", "d"])
                        moved = move_pawn(game, input[1])
                    else
                        @info "Incorrect or ambiguous direction." 
                        moved = 0
                    end
                catch e
                    @error e
                    @info "Something went wrong in moving. Select a valid move."
                end
                
            end
        end

        if game.current_player==1 && game.players[1].row == 1
            println("Player 1 wins!")
            print_board(game)
            break
        elseif game.current_player==2 && game.players[2].row == BOARD_SIZE
            println("Player 2 wins!")
            print_board(game)
            break
        end


        switch_player(game)

        # Add winning condition check here
        # If a player reaches the opposite side, they win.
    end
end

end # module

# To play, uncomment the next line and run this script
# Quoridor.play()
