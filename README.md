## home manager
```
cd nixcfg
nix-shell -p home-manager
./hm '.#allen@nixpc'
```

## rebuild
```
cd nixcfg
sudo nixos-rebuild switch --flake '.#nixpc'
```
