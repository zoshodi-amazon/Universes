from ..Options.index import CoreConfig
import pygame

def main():
    cfg = CoreConfig()
    pygame.init()
    flags = pygame.FULLSCREEN if cfg.fullscreen else 0
    screen = pygame.display.set_mode((cfg.width, cfg.height), flags)
    pygame.display.set_caption(cfg.title)
    clock = pygame.time.Clock()
    
    running = True
    while running:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
        
        screen.fill((0, 0, 0))
        pygame.display.flip()
        clock.tick(cfg.fps)
    
    pygame.quit()

if __name__ == "__main__":
    main()
