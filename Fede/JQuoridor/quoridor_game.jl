module Quoridor

using UnicodePlots
using TerminalMenus

export Game, print_board, move_pawn, place_wall, switch_player, calculate_distance_matrix, print_distance_matrix, play # for testing everything
# export play # real one

const EMPTY, WALL = 0, 2
wall_char = "██" #'▇' '█'

const DIRECTIONS = Dict('w' => (-1, 0), 's' => (1, 0), 'a' => (0, -1), 'd' => (0, 1))
const MAX_WALLS = 10

print("Board size: ")
const BOARD_SIZE = parse(Int64,readline())
# const BOARD_SIZE = 9
const ACTUAL_BOARD_SIZE = BOARD_SIZE*2-1


mutable struct Player
    row::Int
    col::Int
    walls::Int
    name::String
end

mutable struct Wall
    row::Int
    col::Int
    dir::Char
end

mutable struct Game
    board::Array{Int,2}
    players::Array{Player,1}
    current_player::Int
end

function Game()

    choice_game = request("Choose game",
        RadioMenu(["1 vs 1","1 vs AI","AI vs 1","AI vs AI"], pagesize=4));
    global choice_game

    ais = ["rand AI", "smart AI"]

    if choice_game==1 
        print("Player 1 name: ")
        name1 = readline()
        print("Player 2 name: ")
        name2 = readline()
        println()

    elseif choice_game==2
        print("Player 1 name: ")
        name1 = readline()
        choice_ai = request("Choose opponent AI", RadioMenu(ais, pagesize=4));
        global choice_ai
        name2 = ais[choice_ai]
        println()

    elseif choice_game==3
        choice_ai = request("Choose opponent AI", RadioMenu(ais, pagesize=4));
        global choice_ai
        name1 = ais[choice_ai]
        print("Player 2 name: ")
        name2 = readline()
        println()

    elseif choice_game==4
        choice_ai1 = request("Choose opponent AI", RadioMenu(ais, pagesize=4));
        global choice_ai1
        name1 = ais[choice_ai1]
        choice_ai2 = request("Choose opponent AI", RadioMenu(ais, pagesize=4));
        global choice_ai2
        name2 = ais[choice_ai2]
        println()
    end

    board = fill(EMPTY, BOARD_SIZE*2-1, BOARD_SIZE*2-1)
    pl1_col = BOARD_SIZE%2==0 ? BOARD_SIZE+1 : BOARD_SIZE
    pl2_col = BOARD_SIZE%2==0 ? BOARD_SIZE-1 : BOARD_SIZE

    # board[ACTUAL_BOARD_SIZE, pl1_col] = PAWN
    # board[1, pl2_col] = PAWN
    players = [Player(ACTUAL_BOARD_SIZE, pl1_col, MAX_WALLS,name1),
               Player(1, pl2_col, MAX_WALLS,name2)]
    return Game(board, players, 1)
end


function print_board(game::Game)
    PAD = 2
    print(" "^(PAD+1))
    for col in 1:size(game.board)[1]
        if col%2==0
            print(rpad(div(col,2)%10,PAD))
        else
            print("  ")
        end
    end
    print("\n"," "^PAD,"┌")
    print("─"^(PAD*size(game.board)[1]),"┐")
    print("\n")

    for row in 1:ACTUAL_BOARD_SIZE
        if row%2==0
            print(rpad(div(row,2),PAD),"│")
        else
            print(" "^PAD,"│")
        end

        for col in 1:ACTUAL_BOARD_SIZE
            if col%2==0 # case possible wall
                if game.board[row, col] == WALL
                    print(wall_char)
                else
                    print("  ")
                end
            else
                if game.board[row,col] == WALL print(wall_char)
                elseif (game.players[1].row == row && game.players[1].col == col) print("1 ")
                elseif (game.players[2].row == row && game.players[2].col == col) print("2 ")
                elseif row%2==0 print("  ")
                else print(". ") # dots ˙·.
                end
            end
        end
        if row == ACTUAL_BOARD_SIZE-1
            println("│ Player 1 ($(game.players[1].name)) Walls: ", game.players[1].walls)
        elseif row == ACTUAL_BOARD_SIZE
            println("│ Player 2 ($(game.players[2].name)) Walls: ", game.players[2].walls)
        else
            println("│")
        end

    end

    println(" "^PAD,"└","─"^(PAD*size(game.board)[1]),"┘")
    # println("Player 1 ($(game.players[1].name)) Walls: ", game.players[1].walls, " Player 2 ($(game.players[2].name)) Walls: ", game.players[2].walls)
end

function is_valid_dir(game::Game, direction::Char)
    if !(direction in keys(DIRECTIONS))
        @info "Provide a valid direction."
        return false
    end
    dr, dc = DIRECTIONS[direction]
    player = game.players[game.current_player]
    next_row, next_col = player.row + dr, player.col + dc
    new_row, new_col = player.row + 2*dr, player.col + 2*dc

    if new_row >= 1 && new_row <= ACTUAL_BOARD_SIZE && new_col >= 1 && new_col <= ACTUAL_BOARD_SIZE
        if game.board[new_row, new_col] == EMPTY && game.board[next_row,next_col]==EMPTY
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

function is_free_cell(game::Game,row,col)
    return 1<=row<=ACTUAL_BOARD_SIZE && 1<=col<=ACTUAL_BOARD_SIZE && game.board[row,col]==EMPTY
end

function move_pawn(game::Game, direction::Char)
    dr, dc = DIRECTIONS[direction]
    player = game.players[game.current_player]
    opponent = game.players[3-game.current_player]
    new_row, new_col = player.row + 2*dr, player.col + 2*dc
    opp_row, opp_col = opponent.row, opponent.col

    @show player.row, player.col

    if new_row==opp_row && new_col==opp_col
        @info "Jumping!"
        # @show direction
        # @show is_free_cell(game, player.row+4, player.col)
        # @show player.row+4, player.col

        if direction=='w' && is_free_cell(game, player.row-4, player.col) && is_free_cell(game, player.row-3, player.col)
            player.row, player.col = player.row-4, player.col
        elseif direction=='a' && is_free_cell(game, player.row, player.col-4) && is_free_cell(game, player.row, player.col-3)
            player.row, player.col = player.row, player.col-4
        elseif direction=='s' && is_free_cell(game, player.row+4, player.col) && is_free_cell(game, player.row+3, player.col)
            player.row, player.col = player.row+4, player.col
        elseif direction=='d' && is_free_cell(game, player.row, player.col+4) && is_free_cell(game, player.row, player.col+3)
            player.row, player.col = player.row, player.col+4
        else
            if is_free_cell(game,player.row+2*dr, player.col+2*dc) && is_free_cell(game,player.row+2*dr, player.col+2*) 
                println("Clarify (u/p) where to move among the possibilities: $direction-up or $direction-down: ")
                clarification = ""
                while clarification != "u" || clarification != "d"
                    clarification = readline()
                    if clarification=="u"
                        player.row, player.col = player.row+2*dr-1, player.col+2*dr
                        break
                    elseif clarification=="d"
                        player.row, player.col = player.row+2*dr+1, player.col+2*dr
                        break
                    else
                        print("Just specify u or d: ")
                    end
                end
            elseif is_free_cell(game,player.row+2*dr+1, player.col+2*dr)
                player.row, player.col = player.row+2*dr+1, player.col+2*dr
            elseif is_free_cell(game,player.row+2*dr-1, player.col+2*dr)
                player.row, player.col = player.row+2*dr-1, player.col+2*dr
            end
        end
    else
        player.row, player.col = new_row, new_col
    end
    @show player.row, player.col
end

function is_valid_wall(game::Game, row::Int, col::Int,orientation::Char)
    if game.players[game.current_player].walls <= 0
        @info "Walls finished. Select a valid move."
        return false
    end
    if !(orientation in ['h','v'])
        @info "Wrong orientation."
        return false
    end
    if row >= 1 && row <= BOARD_SIZE && col >= 1 && col <= BOARD_SIZE 
        actual_row = row*2
        actual_col = col*2

        if orientation=='h' && game.board[actual_row, actual_col-1] == EMPTY && 
            game.board[actual_row, actual_col] == EMPTY && 
            game.board[actual_row, actual_col+1] == EMPTY

            game.board[actual_row, actual_col-1] = WALL
            game.board[actual_row, actual_col] = WALL
            game.board[actual_row, actual_col+1] = WALL
            updated_board_pl1 = calculate_distance_matrix(game, 1)
            updated_board_pl2 = calculate_distance_matrix(game, 2)
            game.board[actual_row, actual_col-1] = EMPTY
            game.board[actual_row, actual_col] = EMPTY
            game.board[actual_row, actual_col+1] = EMPTY

            # pointwise comparison .==
            if all(updated_board_pl1[1,:] .== -1) || all(updated_board_pl2[BOARD_SIZE,:] .== -1)
                @info "Can't place a wall there. Would block the path for someone."
                return false
            else
                return true
            end

        elseif orientation=='v' && game.board[actual_row-1, actual_col] == EMPTY && 
            game.board[actual_row, actual_col] == EMPTY && 
            game.board[actual_row+1, actual_col] == EMPTY

            game.board[actual_row-1, actual_col] = WALL
            game.board[actual_row, actual_col] = WALL
            game.board[actual_row+1, actual_col] = WALL
            updated_board_pl1 = calculate_distance_matrix(game, 1)
            updated_board_pl2 = calculate_distance_matrix(game, 2)
            game.board[actual_row-1, actual_col] = EMPTY
            game.board[actual_row, actual_col] = EMPTY
            game.board[actual_row+1, actual_col] = EMPTY

            # pointwise comparison .==
            if all(updated_board_pl1[1,:] .== -1) || all(updated_board_pl2[BOARD_SIZE,:] .== -1)
                @info "Can't place a wall there. Would block the path for someone."
                return false
            else
                return true
            end
        end
    else
        @info "Wrong coordinates. Select a valid move."
        return false
    end
end

function place_wall(game::Game, row::Int, col::Int,orientation::Char)
    row = row*2
    col = col*2

    game.players[game.current_player].walls -= 1
    if (orientation=='h')
        game.board[row, col-1] = WALL
        game.board[row, col] = WALL
        game.board[row, col+1] = WALL
        # game.board[row, col+2] = WALL
    else
        game.board[row-1, col] = WALL
        game.board[row, col] = WALL
        game.board[row+1, col] = WALL
        # game.board[row+2, col] = WALL
    end
end


function switch_player(game::Game)
    game.current_player = 3 - game.current_player
end

function calculate_distance_matrix(game::Game, player_index::Int)
    player = game.players[player_index]
    distance_matrix = fill(-1, BOARD_SIZE, BOARD_SIZE)

    queue = [(player.row, player.col)]
    distance_matrix[div(player.row+1,2), div(player.col+1,2)] = 0

    while !isempty(queue)
        # @show distance_matrix
        # @show queue
        current_row, current_col = popfirst!(queue)

        for (dr, dc) in values(DIRECTIONS)
            next_row = current_row + 2*dr
            next_col = current_col + 2*dc
            next_cell_row = current_row + dr
            next_cell_col = current_col + dc

            if 1<= next_row <= ACTUAL_BOARD_SIZE && 1<= next_col <= ACTUAL_BOARD_SIZE &&
                1<= next_cell_row <= ACTUAL_BOARD_SIZE && 1<= next_cell_col <= ACTUAL_BOARD_SIZE &&
                game.board[next_row, next_col] == EMPTY && 
                game.board[next_cell_row, next_cell_col] == EMPTY && 
                distance_matrix[div(current_row+2*dr+1,2), div(current_col+2*dc+1,2)] == -1

                distance_matrix[div(current_row+2*dr+1,2), div(current_col+2*dc+1,2)] = distance_matrix[div(current_row+1,2), div(current_col+1,2)] + 1
                push!(queue, (next_row, next_col))
            end
        end
    end

    return distance_matrix
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
            orientation = args[4][1]
            if is_valid_wall(game,row,col,orientation)==1
                place_wall(game, row, col,orientation)
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

include("quoridor_ai.jl")

function play()
    game = Game()
    gioca=1
    turn = 1
    while gioca==1
        println("Current board: (turn $turn)")
        turn+=1
        print_board(game)
        # printstyled("Player ", game.current_player, " ($(game.players[game.current_player].name))";bold=true)
        # println("'s turn. Move (w/a/s/d) or place wall (e.g., 'wall x y'):")

        println("Move (w/a/s/d) or place wall (e.g., 'wall x y h/v').")

        distance_matrix = calculate_distance_matrix(game, game.current_player)

        if isdefined(Quoridor, :UnicodePlots)
            println(heatmap(distance_matrix,array=true,colormap=:devon, zlabel="Pl$(game.current_player) ($(game.players[game.current_player].name))"))
        end
        print_distance_matrix(distance_matrix)
        
        moved = 0
        iter = 0
        while moved==0 && iter<100
            if choice_game==1 functions = [ask_user_move,ask_user_move] end
            if choice_game==2 functions = [ask_user_move,ais_functions[choice_ai]] end
            if choice_game==3 functions = [ais_functions[choice_ai],ask_user_move] end
            if choice_game==4 functions = [ais_functions[choice_ai1],ais_functions[choice_ai2]] end

            if game.current_player==1 
                input = functions[1](game) 
            else 
                # input = rand_ai(game)
                input = functions[2](game)
            end
            iter+=1
            (gioca, moved) = validate_move(game,input)
            if moved==1 println("Player $(game.current_player) played $input.\n") end
        end

        if game.current_player==1 && game.players[1].row == 1
            printstyled("\nPlayer 1 wins!\n", blink=true, bold=true)
            print_board(game)
            break
        elseif game.current_player==2 && game.players[2].row == ACTUAL_BOARD_SIZE
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
