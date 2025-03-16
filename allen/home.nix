{ config, ... }:

# if home-manager isn't creating all the symlinks, make sure all changes are being tracked by git

{
    home.username = "allen";
    home.homeDirectory = "/home/allen";

    home.file = {
        ".config/nvim" = { source = ./dotfiles/nvim; recursive = true; };
        ".gitconfig".source = ./dotfiles/git/.gitconfig;
        ".gnupg/gpg-agent.conf".source = ./dotfiles/gpg/gpg-agent.conf;
        ".tmux.conf".source = ./dotfiles/tmux/.tmux.conf;
        ".zsh_profile".source = ./dotfiles/zsh/.zsh_profile;
        ".zshrc".source = ./dotfiles/zsh/.zshrc;
    };

    # let home manager install and manage itself.
    programs.home-manager.enable = true;

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    home.stateVersion = "24.05"; # Did you read the comment?
}
