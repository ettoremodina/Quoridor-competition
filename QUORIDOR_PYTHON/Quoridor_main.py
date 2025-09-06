import numpy as np
from typing import Dict, List, Tuple
from enum import Enum

class CellType(Enum):
    EMPTY = 0
    PL1 = 1
    PL2 = 2
    WALL = 3

WALLH_STR = "──"
WALLV_STR = "│ "

DIRECTIONS = {
    'w': (-1, 0), 'x': (1, 0), 'a': (0, -1), 'd': (0, 1),
    'q': (-1, -1), 'c': (1, 1), 'z': (1, -1), 'e': (-1, 1)
}
NORMAL_DIRECTIONS = {'w': (-1, 0), 'x': (1, 0), 'a': (0, -1), 'd': (0, 1)}
SPECIAL_DIRECTIONS = {'q': (-1, -1), 'c': (1, 1), 'z': (1, -1), 'e': (-1, 1)}

MAX_WALLS = 10
BOARD_SIZE = 9
ACTUAL_BOARD_SIZE = BOARD_SIZE * 2 - 1

class Player:
    def __init__(self, row: int, col: int, walls: int, name: str):
        self.row = row
        self.col = col
        self.walls = walls
        self.name = name

class Game:
    def __init__(self):
        self.board = np.zeros((ACTUAL_BOARD_SIZE, ACTUAL_BOARD_SIZE), dtype=int)
        self.wall_board = np.full((ACTUAL_BOARD_SIZE, ACTUAL_BOARD_SIZE), " ", dtype=str)
        pl1_col = BOARD_SIZE if BOARD_SIZE % 2 == 0 else BOARD_SIZE + 1
        pl2_col = BOARD_SIZE - 1 if BOARD_SIZE % 2 == 0 else BOARD_SIZE
        self.players = [
            Player(ACTUAL_BOARD_SIZE, pl1_col, MAX_WALLS, "Player 1"),
            Player(1, pl2_col, MAX_WALLS, "Player 2")
        ]
        self.current_player = 0
        self.board[ACTUAL_BOARD_SIZE - 1, pl1_col - 1] = CellType.PL1.value
        self.board[0, pl2_col - 1] = CellType.PL2.value

def is_inside(rowcol: int) -> bool:
    return 1 <= rowcol <= ACTUAL_BOARD_SIZE

def opposite_dir(dir: str) -> str:
    opposites = {'w': 'x', 'x': 'w', 'a': 'd', 'd': 'a',
                 'q': 'c', 'e': 'z', 'c': 'q', 'z': 'e'}
    return opposites.get(dir, '')
def print_board(game: Game):
    PAD = 2
    print(" " * (PAD + 1), end="")
    for col in range(ACTUAL_BOARD_SIZE):
        if col % 2 == 1:
            print(f"{(col + 1) // 2 % 10:>{PAD}}", end="")
        else:
            print("  ", end="")
    print("\n" + " " * PAD + "+" + "-" * (PAD * ACTUAL_BOARD_SIZE) + "+")

    for row in range(ACTUAL_BOARD_SIZE):
        if row % 2 == 1:
            print(f"{(row + 1) // 2:>{PAD}}|", end="")
        else:
            print(" " * (PAD - 1) + " |", end="")

        for col in range(ACTUAL_BOARD_SIZE):
            if col % 2 == 1:  # case possible wall
                if game.board[row, col] == CellType.WALL.value:
                    print(game.wall_board[row, col], end="")
                else:
                    print("  ", end="")
            else:
                if game.board[row, col] == CellType.WALL.value:
                    print(game.wall_board[row, col], end="")
                elif game.players[0].row == row + 1 and game.players[0].col == col + 1:
                    print("1 " if game.current_player != 0 else "*1 ", end="")
                elif game.players[1].row == row + 1 and game.players[1].col == col + 1:
                    print("2 " if game.current_player != 1 else "*2 ", end="")
                elif row % 2 == 1:
                    print("  ", end="")
                else:
                    print(". ", end="")

        if row == ACTUAL_BOARD_SIZE - 2:
            print(f"| Player 1 ({game.players[0].name}) Walls: {game.players[0].walls}")
        elif row == ACTUAL_BOARD_SIZE - 1:
            print(f"| Player 2 ({game.players[1].name}) Walls: {game.players[1].walls}")
        else:
            print("|")

    print(" " * PAD + "+" + "-" * (PAD * ACTUAL_BOARD_SIZE) + "+")
    
    
    

def valid_directions(game: Game, row: int, col: int, player: int) -> Dict[str, Tuple[int, int]]:
    opponent = 1 if player == 0 else 0
    
    if not is_inside(row) or not is_inside(col):
        raise ValueError("Cell position outside the board.")
    if row % 2 != 1 or col % 2 != 1:
        print("Warning: Strange cell to be in for a player.")
        return {}

    dirs = DIRECTIONS.copy()

    # Check normal directions
    if (row == 1 or
        (row >= 3 and game.board[row - 2, col - 1] == CellType.WALL.value) or
        (row == 3 and game.board[row - 2, col - 1] == opponent + 1) or
        (row >= 5 and game.board[row - 2, col - 1] == opponent + 1 and game.board[row - 4, col - 1] == CellType.WALL.value)):
        dirs.pop('w', None)

    if (row == ACTUAL_BOARD_SIZE or
        (row <= ACTUAL_BOARD_SIZE - 2 and game.board[row, col - 1] == CellType.WALL.value) or
        (row == ACTUAL_BOARD_SIZE - 2 and game.board[row + 1, col - 1] == opponent + 1) or
        (row <= ACTUAL_BOARD_SIZE - 4 and game.board[row + 1, col - 1] == opponent + 1 and game.board[row + 3, col - 1] == CellType.WALL.value)):
        dirs.pop('x', None)

    if (col == 1 or
        (col >= 3 and game.board[row - 1, col - 2] == CellType.WALL.value) or
        (col == 3 and game.board[row - 1, col - 2] == opponent + 1) or
        (col >= 5 and game.board[row - 1, col - 2] == opponent + 1 and game.board[row - 1, col - 4] == CellType.WALL.value)):
        dirs.pop('a', None)

    if (col == ACTUAL_BOARD_SIZE or
        (col <= ACTUAL_BOARD_SIZE - 2 and game.board[row - 1, col] == CellType.WALL.value) or
        (col == ACTUAL_BOARD_SIZE - 2 and game.board[row - 1, col + 1] == opponent + 1) or
        (col <= ACTUAL_BOARD_SIZE - 4 and game.board[row - 1, col + 1] == opponent + 1 and game.board[row - 1, col + 3] == CellType.WALL.value)):
        dirs.pop('d', None)

    # Check special directions
    if col == 1:
        dirs.pop('q', None)
        dirs.pop('z', None)
    if col == ACTUAL_BOARD_SIZE:
        dirs.pop('e', None)
        dirs.pop('c', None)
    if row == 1:
        dirs.pop('q', None)
        dirs.pop('e', None)
    if row == ACTUAL_BOARD_SIZE:
        dirs.pop('z', None)
        dirs.pop('c', None)

    # Additional checks for diagonal moves
    if not (row >= 3 and col >= 3 and (
        (game.board[row - 3, col - 1] == opponent + 1 and game.board[row - 2, col - 1] != CellType.WALL.value and game.board[row - 3, col - 2] != CellType.WALL.value and
         (not is_inside(row - 4) or game.board[row - 4, col - 1] == CellType.WALL.value)) or 
        (game.board[row - 1, col - 3] == opponent + 1 and game.board[row - 1, col - 2] != CellType.WALL.value and game.board[row - 2, col - 3] != CellType.WALL.value and
         (not is_inside(col - 4) or game.board[row - 1, col - 4] == CellType.WALL.value))
    )):
        dirs.pop('q', None)

    if not (row >= 3 and col <= ACTUAL_BOARD_SIZE - 2 and (
        (game.board[row - 3, col - 1] == opponent + 1 and game.board[row - 2, col - 1] != CellType.WALL.value and game.board[row - 3, col] != CellType.WALL.value and
         (not is_inside(row - 4) or game.board[row - 4, col - 1] == CellType.WALL.value)) or 
        (game.board[row - 1, col + 1] == opponent + 1 and game.board[row - 1, col] != CellType.WALL.value and game.board[row - 2, col + 1] != CellType.WALL.value and
         (not is_inside(col + 2) or game.board[row - 1, col + 2] == CellType.WALL.value))
    )):
        dirs.pop('e', None)
    
    if not (row <= ACTUAL_BOARD_SIZE - 2 and col >= 3 and (
        (game.board[row + 1, col - 1] == opponent + 1 and game.board[row, col - 1] != CellType.WALL.value and game.board[row + 1, col - 2] != CellType.WALL.value and
         (not is_inside(row + 2) or game.board[row + 2, col - 1] == CellType.WALL.value)) or
        (game.board[row - 1, col - 3] == opponent + 1 and game.board[row - 1, col - 2] != CellType.WALL.value and game.board[row, col - 3] != CellType.WALL.value and
         (not is_inside(col - 4) or game.board[row - 1, col - 4] == CellType.WALL.value))
    )):
        dirs.pop('z', None)

    if not (row <= ACTUAL_BOARD_SIZE - 2 and col <= ACTUAL_BOARD_SIZE - 2 and (
        (game.board[row + 1, col - 1] == opponent + 1 and game.board[row, col - 1] != CellType.WALL.value and game.board[row + 1, col] != CellType.WALL.value and
         (not is_inside(row + 2) or game.board[row + 2, col - 1] == CellType.WALL.value)) or 
        (game.board[row - 1, col + 1] == opponent + 1 and game.board[row - 1, col] != CellType.WALL.value and game.board[row, col + 1] != CellType.WALL.value and
         (not is_inside(col + 2) or game.board[row - 1, col + 2] == CellType.WALL.value))
    )):
        dirs.pop('c', None)

    return dirs

def move_pawn(game: Game, direction: str):
    dr, dc = DIRECTIONS[direction]
    player = game.players[game.current_player]
    opp = game.players[1 - game.current_player]
    pl_row, pl_col = player.row, player.col
    opp_row, opp_col = opp.row, opp.col

    game.board[pl_row - 1, pl_col - 1] = CellType.EMPTY.value

    if pl_row + 2*dr == opp_row and pl_col + 2*dc == opp_col:
        print("Jumping!")
        if direction in NORMAL_DIRECTIONS:
            player.row = pl_row + 4*dr
            player.col = pl_col + 4*dc
            game.board[pl_row + 4*dr - 1, pl_col + 4*dc - 1] = game.current_player + 1
        else:
            player.row = pl_row + 2*dr
            player.col = pl_col + 2*dc
            game.board[pl_row + 2*dr - 1, pl_col + 2*dc - 1] = game.current_player + 1
    else:
        player.row = pl_row + 2*dr
        player.col = pl_col + 2*dc
        game.board[pl_row + 2*dr - 1, pl_col + 2*dc - 1] = game.current_player + 1

def is_valid_wall(game: Game, row: int, col: int, orientation: str) -> bool:
    if game.players[game.current_player].walls <= 0:
        print("Walls finished. Select a valid move.")
        return False
    if orientation not in ['h', 'v']:
        print("Wrong orientation.")
        return False
    if not (1 <= row <= BOARD_SIZE - 1 and 1 <= col <= BOARD_SIZE - 1):
        print("Coordinates outside of the game board. Select a valid cell.")
        return False

    actual_row = row * 2