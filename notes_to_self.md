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

## note
make sure to `git add` changes before running commands (else can cause weird errors)

