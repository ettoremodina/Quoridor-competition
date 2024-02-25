module Quoridor
# chat gpt created

using UnicodePlots
using TerminalMenus

# export Game, print_board, move_pawn, place_wall, switch_player, calculate_distance_matrix, print_distance_matrix, play # for testing everything
export play # real one

const EMPTY, PAWN, WALL = 0, 1, 2
const DIRECTIONS = Dict('w' => (-1, 0), 's' => (1, 0), 'a' => (0, -1), 'd' => (0, 1))
const MAX_WALLS = 10

print("Board size: ")
const BOARD_SIZE = parse(Int64,readline())
# const BOARD_SIZE = 9


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

global choice_game,choice_ai,choice_ai1,choice_ai2

function Game()

    choice_game = request("Choose game",
        RadioMenu(["2 vs 2","1 vs AI","AI vs AI"], pagesize=4));

    if choice_game==1 
        print("Player 1 name: ")
        name1 = readline()
        print("Player 2 name: ")
        name2 = readline()
        println()

    elseif choice_game==2
        print("Player 1 name: ")
        name1 = readline()
        ais = ["rand AI", "smart AI"]
        choice_ai = request("Choose opponent AI", RadioMenu(ais, pagesize=4));
        name2 = ais[choice_ai]
        println()

    elseif choice_game==3
        ais = ["rand AI", "smart AI"]
        choice_ai1 = request("Choose opponent AI", RadioMenu(ais, pagesize=4));
        name1 = ais[choice_ai1]
        choice_ai2 = request("Choose opponent AI", RadioMenu(ais, pagesize=4));
        name2 = ais[choice_ai]
        println()
    end

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

function is_valid_dir(game::Game, direction::Char)
    if !(direction in keys(DIRECTIONS))
        @info "Provide a valid direction."
        return false
    end
    dr, dc = DIRECTIONS[direction]
    player = game.players[game.current_player]
    new_row, new_col = player.row + dr, player.col + dc
    if new_row >= 1 && new_row <= BOARD_SIZE && new_col >= 1 && new_col <= BOARD_SIZE
        if game.board[new_row, new_col] == EMPTY
            return true
        else
            @info "Can't move there! there is a wall. Select a valid move."
            return false
        end
    else
        @info "Can't move outside the board. Select a valid move."
        return false
    end
    return false
end

function move_pawn(game::Game, direction::Char)
    dr, dc = DIRECTIONS[direction]
    player = game.players[game.current_player]
    new_row, new_col = player.row + dr, player.col + dc

    player.row, player.col = new_row, new_col
end

function is_valid_wall(game::Game, row::Int, col::Int)
    if game.players[game.current_player].walls > 0
        if row >= 1 && row <= BOARD_SIZE && col >= 1 && col <= BOARD_SIZE && 
            game.board[row, col] == EMPTY &&
            !((game.players[1].row == row) && (game.players[1].col == col)) &&
            !((game.players[2].row == row) && (game.players[2].col == col))
    
            game.board[row, col] = WALL
            updated_board_pl1 = calculate_distance_matrix(game, 1)
            updated_board_pl2 = calculate_distance_matrix(game, 2)
            game.board[row, col] = EMPTY

            # pointwise comparison .==
            if all(updated_board_pl1[1,:] .== -1) || all(updated_board_pl2[BOARD_SIZE,:] .== -1)
                @info "Can't place a wall there. Would block the path for someone."
                return false
            else
                return true
            end
        else
            @info "Wrong coordinates. Select a valid move."
            return false
        end
    else
        @info "Walls finished. Select a valid move."
        return false
    end
end

function place_wall(game::Game, row::Int, col::Int)
    game.players[game.current_player].walls -= 1
    game.board[row, col] = WALL
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

function validate_move(game,input)
    moved = 0
    gioca = 1
    if occursin("wall", input)
        args = split(input)
        try
            row, col = parse(Int, args[2]), parse(Int, args[3])
            if is_valid_wall(game,row,col)==1
                place_wall(game, row, col)
                moved = 1
            end
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
                if is_valid_dir(game,input[1])==1
                    move_pawn(game,input[1])
                    moved=1
                end
            else
                @info "Incorrect or ambiguous direction." 
                moved = 0
            end
        catch e
            @error e
            @info "Something went wrong in moving. Select a valid move."
        end
    end
    return (gioca, moved)
end

function ask_user_move(game::Game)
    moved = 0
    printstyled("Pl", game.current_player, " ($(game.players[game.current_player].name))'s turn: ";bold=true)
    input = readline()
    return input
end


##############
##   AIs    ######################################################
##############
function rand_ai(game::Game)
    return string(rand(keys(DIRECTIONS)))
end

function smart_ai(game::Game)
    distance_matrix = calculate_distance_matrix(game, game.current_player)
    if game.current_player==1 
        target_row = 1

        cur_pos = [game.players[game.current_player].row,game.players[game.current_player].col]
        target_pos = [target_row,argmin(replace(distance_matrix[target_row,:],-1=>+Inf64))]

        cur_pos[2]==target_pos[2] && is_valid_dir(game,'w') && return "w"
        cur_pos[2]< target_pos[2] && is_valid_dir(game,'d') && return "d"
        cur_pos[2]>=target_pos[2] && is_valid_dir(game,'a') && return "a"
        return "s"
    else 
        target_row = BOARD_SIZE

        cur_pos = [game.players[game.current_player].row,game.players[game.current_player].col]
        target_pos = [target_row,argmin(replace(distance_matrix[target_row,:],-1=>+Inf64))]

        cur_pos[2]==target_pos[2] && is_valid_dir(game,'s') && return "s"
        cur_pos[2]< target_pos[2] && is_valid_dir(game,'d') && return "d"
        cur_pos[2]>=target_pos[2] && is_valid_dir(game,'a') && return "a"
        return "w"
    end
end
##################
##   end AIs    ######################################################
##################


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

        if isdefined(Quoridor, :UnicodePlots)
            println(heatmap(distance_matrix,array=true,colormap=:devon,
                zlabel="Pl$(game.current_player) ($(game.players[game.current_player].name))"))
        # else
            # print_distance_matrix(distance_matrix)
        end
        print_distance_matrix(distance_matrix)

        moved = 0
        iter = 0
        while moved==0 && iter<100
            if game.current_player==1 
                input = ask_user_move(game) 
            else 
                # input = rand_ai(game)
                input = smart_ai(game)
            end
            iter+=1
            (gioca, moved) = validate_move(game,input)
            if moved==1 println("Player $(game.current_player) played $input.\n") end
        end

        if game.current_player==1 && game.players[1].row == 1
            printstyled("\nPlayer 1 wins!\n", blink=true, bold=true)
            print_board(game)
            break
        elseif game.current_player==2 && game.players[2].row == BOARD_SIZE
            printstyled("\nPlayer 2 wins!\n", blink=true, bold=true)
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
