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

# manually decrypt a secret
```
age --decrypt -i secrets/id -o somesecret secrets/somesecret.age
```

# use git ssh key for repo
```
git remote set-url origin git@github.com:waverider0/nixcfg.git
```

make sure to `git add` all changes before running commands (else can cause weird errors)

