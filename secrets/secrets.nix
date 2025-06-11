let
    id = builtins.readFile ./id.pub;
in {
    "github.age".publicKeys = [ id ];
    "xmr.age".publicKeys = [ id ];
    ".kdbx.kdbx.age".publicKeys  = [ id ];
}
