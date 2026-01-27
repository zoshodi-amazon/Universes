import pygame

KEYMAPS = {
    pygame.K_w: "move_up",
    pygame.K_s: "move_down",
    pygame.K_a: "move_left",
    pygame.K_d: "move_right",
    pygame.K_SPACE: "action",
    pygame.K_ESCAPE: "pause",
    pygame.K_F5: "quicksave",
    pygame.K_F9: "quickload",
}

def get_action(key: int) -> str | None:
    return KEYMAPS.get(key)
