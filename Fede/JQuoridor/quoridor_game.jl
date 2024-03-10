module Quoridor

# usage
# 1. open julia repl in this folder
# 2. type ] activate . (the ] is to go into pkg mode)
# 3. exit pkg mode with canc or ctrl+c
# 4. type include("quoridor_game.jl"); Quoridor.play()

using UnicodePlots
using TerminalMenus

# using Term
# import Term: Panel

export Game, print_board, move_pawn, place_wall, switch_player, calculate_distance_matrix, print_distance_matrix, play # for testing everything
# export play # real one

const EMPTY, PL1, PL2, WALL = 0, 1, 2, 3
wallh_str = "──" # "██"
wallv_str = "│ " 

const DIRECTIONS = Dict('w' => (-1, 0), 'x' => (1, 0), 'a' => (0, -1), 'd' => (0, 1),
    'q' => (-1, -1), 'c' => (1, 1), 'z' => (1, -1), 'e' => (-1, 1))
const NORMAL_DIRECTIONS = Dict('w' => (-1, 0), 'x' => (1, 0), 'a' => (0, -1), 'd' => (0, 1))
const SPECIAL_DIRECTIONS = Dict('q' => (-1, -1), 'c' => (1, 1), 'z' => (1, -1), 'e' => (-1, 1))

function opposite_dir(dir::Char)
    dir=='w' && return 'x'
    dir=='x' && return 'w'
    dir=='a' && return 'd'
    dir=='d' && return 'a'

    dir=='q' && return 'c'
    dir=='e' && return 'z'
    dir=='c' && return 'q'
    dir=='z' && return 'e'
end

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

mutable struct Cell
    row::Int
    col::Int
end

mutable struct Game
    board::Array{Int,2}
    wall_board::Array{String,2}
    players::Array{Player,1}
    current_player::Int
end

function Game()
    choice_game = request("Choose game",
        RadioMenu(["1 vs 1","1 vs AI","AI vs 1","AI vs AI"], pagesize=4));
    global choice_game

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
    wall_board = fill(" ", BOARD_SIZE*2-1, BOARD_SIZE*2-1)
    pl1_col = BOARD_SIZE%2==0 ? BOARD_SIZE+1 : BOARD_SIZE
    pl2_col = BOARD_SIZE%2==0 ? BOARD_SIZE-1 : BOARD_SIZE

    board[ACTUAL_BOARD_SIZE, pl1_col] = PL1
    board[1, pl2_col] = PL2
    players = [Player(ACTUAL_BOARD_SIZE, pl1_col, MAX_WALLS,name1),
               Player(1, pl2_col, MAX_WALLS,name2)]
    return Game(board, wall_board, players, 1)
end

function Base.copy(game::Game)
    board_copy = copy(game.board)
    wall_board_copy = copy(game.wall_board)
    players_copy = copy(game.players)
    current_player_copy = copy(game.current_player)
    return Game(board_copy, wall_board_copy, players_copy, current_player_copy)
end

is_inside(rowcol::Int) = 1 <= rowcol <= ACTUAL_BOARD_SIZE


##########################
##   Print functions    ##
##########################

function print_matrix(matrix)
    rows, cols = size(matrix)
    for i in 1:rows
        for j in 1:cols
            print(rpad(matrix[i,j],3))
        end
        print("\n")
    end
    return nothing
end

function print_board_text(game::Game)
    for rr in 1:ACTUAL_BOARD_SIZE
        for cc in 1:ACTUAL_BOARD_SIZE
            print(game.board[rr,cc]," ")
        end
        println()
    end
end 

function print_board(game::Game)
    PAD = 2
    print(" "^(PAD+1))
    for col in 1:size(game.board)[1]
        if col%2==0
            print(rpad(div(col,2)%10,PAD))
        else
            # possible symbols "↓∨⇣⇢⇓⇒⇁⇂↪↳↴↦↧")
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
            print(" "^(PAD-1)," │")
        end

        for col in 1:ACTUAL_BOARD_SIZE
            if col%2==0 # case possible wall
                if game.board[row, col] == WALL
                    print(game.wall_board[row,col])
                else
                    print("  ")
                end
            else
                if game.board[row,col] == WALL 
                    print(game.wall_board[row,col])
                elseif (game.players[1].row == row && game.players[1].col == col) 
                    if game.current_player==1 printstyled("1", reverse=true,blink=true); print(" ")
                    else print("1 ") end
                elseif (game.players[2].row == row && game.players[2].col == col)
                    if game.current_player==2 printstyled("2", reverse=true,blink=true); print(" ")
                    else print("2 ") end
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
end



#####################
##   Directions    ##
#####################


function valid_directions(game::Game, row::Int, col::Int, player::Int)
    opponent = player==1 ? 2 : 1
    
    # players can only move on odd valued cells for row and cols
    # walls can only be on even valued cells for row and cols

    # @show ACTUAL_BOARD_SIZE

    if !is_inside(row) || !is_inside(col) 
        @error "Cell position outside the board."
        return
    end
    if row%2 !=1 || col%2 !=1
        @warn "Strange cell to be in for a player."
        return
    end

    dirs = copy(DIRECTIONS)

    # normal directions
    if (row==1) ||
        (row>=3 && game.board[row-1,col]==WALL) ||
        (row==3 && game.board[row-2,col]==opponent) ||
        (row>=5 && game.board[row-2,col]==opponent && game.board[row-3,col]==WALL)
        delete!(dirs,'w') end

    if (row==ACTUAL_BOARD_SIZE) ||
        (row<=ACTUAL_BOARD_SIZE-2 && game.board[row+1,col]==WALL) ||
        (row==ACTUAL_BOARD_SIZE-2 && game.board[row+2,col]==opponent) ||
        (row<=ACTUAL_BOARD_SIZE-4 && game.board[row+2,col]==opponent && game.board[row+3,col]==WALL)
        delete!(dirs,'x') end

    if (col==1) ||
        (col>=3 && game.board[row,col-1]==WALL) ||
        (col==3 && game.board[row,col-2]==opponent) ||
        (col>=5 && game.board[row,col-2]==opponent && game.board[row,col-3]==WALL)
        delete!(dirs,'a') end

    if (col==ACTUAL_BOARD_SIZE) ||
        (col<=ACTUAL_BOARD_SIZE-2 && game.board[row,col+1]==WALL) ||
        (col==ACTUAL_BOARD_SIZE-2 && game.board[row,col+2]==opponent) ||
        (col<=ACTUAL_BOARD_SIZE-4 && game.board[row,col+2]==opponent && game.board[row,col+3]==WALL) 
        delete!(dirs,'d') end

    # special directions
    if col==1 delete!(dirs,'q'); delete!(dirs,'z') end
    if col==ACTUAL_BOARD_SIZE delete!(dirs,'e'); delete!(dirs,'c') end

    if row==1 delete!(dirs,'q'); delete!(dirs,'e') end
    if row==ACTUAL_BOARD_SIZE delete!(dirs,'z'); delete!(dirs,'c') end

    if !(row>=3 && col>=3 && (
        (game.board[row-2,col]==opponent && game.board[row-1,col]!=WALL && game.board[row-2,col-1]!=WALL &&
            (is_inside(row-3) ? game.board[row-3,col]==WALL : true)) || 
        (game.board[row,col-2]==opponent && game.board[row,col-1]!=WALL && game.board[row-1,col-2]!=WALL &&
            (is_inside(col-3) ? game.board[row,col-3]==WALL : true))
        ))
        delete!(dirs,'q')
    end

    if !(row>=3 && col<=ACTUAL_BOARD_SIZE-2 && (
        (game.board[row-2,col]==opponent && game.board[row-1,col]!=WALL && game.board[row-2,col+1]!=WALL &&
            (is_inside(row-3) ? game.board[row-3,col]==WALL : true)) || 
        (game.board[row,col+2]==opponent && game.board[row,col+1]!=WALL && game.board[row-1,col+2]!=WALL &&
            (is_inside(col+3) ? game.board[row,col+3]==WALL : true))
        ))
        delete!(dirs,'e')
    end
    
    if !(row<=ACTUAL_BOARD_SIZE-2 && col>=3 && (
        (game.board[row+2,col]==opponent && game.board[row+1,col]!=WALL && game.board[row+2,col-1]!=WALL &&
            (is_inside(row+3) ? game.board[row+3,col]==WALL : true)) ||
        (game.board[row,col-2]==opponent && game.board[row,col-1]!=WALL && game.board[row+1,col-2]!=WALL &&
            (is_inside(col-3) ? game.board[row,col-3]==WALL : true))
        ))
        delete!(dirs,'z')
    end

    if !(row<=ACTUAL_BOARD_SIZE-2 && col<=ACTUAL_BOARD_SIZE-2 && (
        (game.board[row+2,col]==opponent && game.board[row+1,col]!=WALL && game.board[row+2,col+1]!=WALL &&
            (is_inside(row+3) ? game.board[row+3,col]==WALL : true)) || 
        (game.board[row,col+2]==opponent && game.board[row,col+1]!=WALL && game.board[row+1,col+2]!=WALL &&
            (is_inside(col+3) ? game.board[row,col+3]==WALL : true))
        ))
        delete!(dirs,'c')
    end

    return dirs
end

function move_pawn(game::Game, direction::Char)
    dr, dc = DIRECTIONS[direction]
    player = game.players[game.current_player]
    opp = game.players[3-game.current_player]
    pl_row, pl_col = player.row, player.col
    opp_row, opp_col = opp.row, opp.col

    game.board[pl_row, pl_col] = EMPTY
    # set to EMPTY the pl current cell

    if pl_row+2*dr==opp_row && pl_col+2*dc==opp_col
        @info "Jumping!"
        if direction in keys(NORMAL_DIRECTIONS)
            player.row = pl_row + 4*dr
            player.col = pl_col + 4*dc
            game.board[pl_row + 4*dr, pl_col + 4*dc] = game.current_player
            # set to PAWN the pl current cell
        else
            player.row = pl_row + 2*dr
            player.col = pl_col + 2*dc
            game.board[pl_row + 2*dr, pl_col + 2*dc] = game.current_player
            # set to PAWN the pl current cell
        end
    else
        player.row = pl_row + 2*dr
        player.col = pl_col + 2*dc
        game.board[pl_row + 2*dr, pl_col + 2*dc] = game.current_player
        # set to PAWN the pl current cell
    end
end



################
##   Walls    ##
################

function is_valid_wall(game::Game, row::Int, col::Int,orientation::Char)
    if game.players[game.current_player].walls <= 0
        @info "Walls finished. Select a valid move."
        return false
    end
    if !(orientation in ['h','v'])
        @info "Wrong orientation."
        return false
    end
    if !(row >= 1 && row <= BOARD_SIZE-1 && col >= 1 && col <= BOARD_SIZE-1)
        @info "Coordinates outside of the game board. Select a valid cell."
        return false
    end

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
        else return true end
    end

    if orientation=='v' && game.board[actual_row-1, actual_col] == EMPTY && 
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
        else return true end
    end

    # else to both
    @info "Cant intersect walls."
    return false
end

function matrix_to_board(rowcol::Int)
    return rowcol*2-1
end
function board_to_matrix(rowcol::Int)
    return div(rowcol+1,2)
end

function matrix_to_board_cell(cmatrix::Cell)
    cboard = Cell(0,0)
    cboard.row = cmatrix.row*2-1
    cboard.col = cmatrix.col*2-1
    return cboard
end

function board_to_matrix_cell(cboard::Cell)
    cmatrix = Cell(0,0)
    cmatrix.row = div(cboard.row+1,2)
    cmatrix.col = div(cboard.col+1,2)
    return cmatrix
end


function place_wall(game::Game, row::Int, col::Int, orientation::Char)
    row = row*2
    col = col*2

    game.players[game.current_player].walls -= 1
    if (orientation=='h')
        game.board[row, col-1] = WALL
        game.board[row, col] = WALL
        game.board[row, col+1] = WALL

        game.wall_board[row, col-1] = wallh_str
        game.wall_board[row, col] = wallh_str
        game.wall_board[row, col+1] = wallh_str
    else
        game.board[row-1, col] = WALL
        game.board[row, col] = WALL
        game.board[row+1, col] = WALL

        game.wall_board[row-1, col] = wallv_str
        game.wall_board[row, col] = wallv_str
        game.wall_board[row+1, col] = wallv_str

    end
end



#########################
##   Game execution    ##
#########################

function switch_player(game::Game)
    game.current_player = 3 - game.current_player
end

function calculate_distance_matrix(game::Game, player_index::Int)
    player = game.players[player_index]
    opponent = game.players[3-player_index]
    distance_matrix = fill(-1, BOARD_SIZE, BOARD_SIZE)

    queue = [(player.row, player.col)]
    distance_matrix[div(player.row+1,2), div(player.col+1,2)] = 0

    while !isempty(queue)
        # print_matrix(distance_matrix)
        current_row, current_col = popfirst!(queue)
        # println()

        filt_dirs = valid_directions(game, current_row, current_col, game.current_player)
        # @show filt_dirs

        for (dr, dc) in values(filt_dirs)
            next_row = current_row + 2*dr
            next_col = current_col + 2*dc
            if opponent.row==next_row && opponent.col==next_col
                next_row = current_row + 4*dr
                next_col = current_col + 4*dc
            end
            next_cell_row = current_row + dr
            next_cell_col = current_col + dc

            if 1<= next_row <= ACTUAL_BOARD_SIZE && 1<= next_col <= ACTUAL_BOARD_SIZE &&
                1<= next_cell_row <= ACTUAL_BOARD_SIZE && 1<= next_cell_col <= ACTUAL_BOARD_SIZE &&
                game.board[next_row, next_col] != WALL &&  
                game.board[next_cell_row, next_cell_col] != WALL && 
                distance_matrix[div(next_row+1,2), div(next_col+1,2)] == -1

                distance_matrix[div(next_row+1,2), div(next_col+1,2)] = distance_matrix[div(current_row+1,2), div(current_col+1,2)] + 1

                if (next_row, next_col) != (opponent.row, opponent.col)
                    push!(queue, (next_row, next_col))
                end
            end
        end
    end
    distance_matrix[div(opponent.row+1,2), div(opponent.col+1,2)] = -1
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

function validate_move(game::Game , input::String, valid_dirs::Dict)
    moved = 0
    gioca = 1
    input = lowercase(input)

    if occursin("wall", input)
        args = split(input)
        try
            row, col = parse(Int, args[2]), parse(Int, args[3])
            orientation = args[4][1]
            if is_valid_wall(game,row,col,orientation)==1
                place_wall(game,row,col,orientation)
                moved = 1
            end
        catch e
            @error e
            @info "Something went wrong in parsing your input."
        end
    elseif input=="quit"
        moved=1
        gioca=0
        println("Ending the game.")
    else
        try
            # if any(input .== string.(keys(DIRECTIONS)))
                if input[1] in keys(valid_dirs)
                    move_pawn(game,input[1])
                    moved=1
                end
            # else
                # @info "Incorrect or ambiguous direction." 
                # moved = 0
            # end
        catch e
            @error e
            @info "Something went wrong in parsing your input."
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
        println("\n","#"^(ACTUAL_BOARD_SIZE*2))
        println("Current board: (turn $turn)")
        turn+=1
        
        print_board(game)
        # print_board_text(game)
        
        # printstyled("Player ", game.current_player, " ($(game.players[game.current_player].name))";bold=true)
        # println("'s turn. Move (w/a/s/d) or place wall (e.g., 'wall x y'):")

        distance_matrix = calculate_distance_matrix(game, game.current_player)
        if isdefined(Quoridor, :UnicodePlots)
            println(heatmap(distance_matrix,array=true,colormap=:devon,zlabel="Pl$(game.current_player) ($(game.players[game.current_player].name))"))
        # else
            # print_distance_matrix(distance_matrix)
        end
        print_distance_matrix(distance_matrix)
        
        println("Move (with the keys around s) or place a wall (with 'wall x y h/v').")
        player = game.players[game.current_player]
        valid_dirs = valid_directions(game, player.row, player.col, game.current_player)
        println("You (Pl$(game.current_player)) are currently in ($(player.row), $(player.col)) cell and the availble directions are $(keys(valid_dirs)).")

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
            (gioca, moved) = validate_move(game, input, valid_dirs)
            if moved==1 println("Player $(game.current_player) played $input.\n") end
        end

        if game.current_player==1 && game.players[1].row == 1
            println("\n","#"^ACTUAL_BOARD_SIZE)
            printstyled("Player 1 wins!\n", blink=true, bold=true)
            print_board(game)
            break
        elseif game.current_player==2 && game.players[2].row == ACTUAL_BOARD_SIZE
            println("\n","#"^ACTUAL_BOARD_SIZE)
            printstyled("Player 2 wins!\n", blink=true, bold=true)
            print_board(game)
            break
        end
        switch_player(game)
    end
end

end # module

# To play, uncomment the next line and run this script
# Quoridor.play()
