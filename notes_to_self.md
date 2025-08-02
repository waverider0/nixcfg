## rebuild
```
cd nixcfg
sudo nixos-rebuild switch --flake '.#nixpc'
```

## home manager
```
cd nixcfg
nix-shell -p home-manager
home-manager switch --flake '.#allen@nixpc'
```

**Note:** `git add` path changes before home manager switching
