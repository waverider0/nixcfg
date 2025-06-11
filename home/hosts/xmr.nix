{ config, ... }:

{
    programs.tmux.extraConfig = config.programs.tmux.extraConfig + ''
        bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'wl-copy'
    '';
}
