import random
from Quoridor_ai import *
from Quoridor_main import *

def switch_player(game: Game):
    game.current_player = 1 - game.current_player

def validate_move(game: Game, input_str: str, valid_dirs: Dict[str, Tuple[int, int]]) -> Tuple[bool, bool]:
    moved = False
    play_on = True
    input_str = input_str.lower()

    if "wall" in input_str:
        args = input_str.split()
        try:
            row, col = int(args[1]), int(args[2])
            orientation = args[3][0]
            if is_valid_wall(game, row, col, orientation):
                place_wall(game, row, col, orientation)
                moved = True
        except (IndexError, ValueError):
            print("Something went wrong in parsing your input.")
    elif input_str == "quit":
        moved = True
        play_on = False
        print("Ending the game.")
    else:
        try:
            if input_str[0] in valid_dirs:
                move_pawn(game, input_str[0])
                moved = True
        except IndexError:
            print("Something went wrong in parsing your input.")

    return play_on, moved

def ask_user_move(game: Game) -> str:
    print(f"Pl{game.current_player + 1} ({game.players[game.current_player].name})'s turn: ", end="", flush=True)
    return input()

def random_ai(game: Game) -> str:
    player = game.players[game.current_player]
    valid_dirs = valid_directions(game, player.row, player.col, game.current_player)
    
    if valid_dirs and random.random() < 0.7:  # 70% chance to move
        return random.choice(list(valid_dirs.keys()))
    else:  # 30% chance to place a wall
        row = random.randint(1, BOARD_SIZE - 1)
        col = random.randint(1, BOARD_SIZE - 1)
        orientation = random.choice(['h', 'v'])
        return f"wall {row} {col} {orientation}"

def play_game():
    game = Game()
    turn = 1
    play_on = True

    while play_on:
        print("\n" + "#" * (ACTUAL_BOARD_SIZE * 2))
        print(f"Current board: (turn {turn})")
        turn += 1
        
        print_board(game)
        
        print("Move (with the keys around s) or place a wall (with 'wall x y h/v').")
        player = game.players[game.current_player]
        valid_dirs = valid_directions(game, player.row, player.col, game.current_player)
        print(f"You (Pl{game.current_player + 1}) are currently in ({player.row}, {player.col}) cell and the available directions are {list(valid_dirs.keys())}.")

        moved = False
        iter_count = 0
        while not moved and iter_count < 100:
            # For simplicity, we'll use random AI for player 2
            if game.current_player == 0:
                input_str = ask_user_move(game)
            else:
                input_str = random_ai(game)
                print(f"AI move: {input_str}")
            
            iter_count += 1
            play_on, moved = validate_move(game, input_str, valid_dirs)
            if moved:
                print(f"Player {game.current_player + 1} played {input_str}.\n")

        if game.current_player == 0 and game.players[0].row == 1:
            print("\n" + "#" * ACTUAL_BOARD_SIZE)
            print("Player 1 wins!")
            print_board(game)
            break
        elif game.current_player == 1 and game.players[1].row == ACTUAL_BOARD_SIZE:
            print("\n" + "#" * ACTUAL_BOARD_SIZE)
            print("Player 2 wins!")
            print_board(game)
            break

        switch_player(game)

if __name__ == "__main__":
    play_game()