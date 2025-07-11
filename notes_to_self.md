## rebuild
```
cd nixcfg
sudo nixos-rebuild switch --flake '.#nixpc'
```

## home manager
```
cd nixcfg
nix-shell -p home-manager
./hm '.#allen@nixpc'
```

## manually decrypt a secret
```
cd secrets
age -d -i id -o decrypted encrypted.age

```

**Note:** `git add` path changes before home manager switching
