let
	id = builtins.readFile ./id.pub;
in {
	".kdbx.kdbx.age".publicKeys  = [ id ];
	"github.age".publicKeys = [ id ];
	"wg_laptop.age".publicKeys = [ id ];
	"wg_server.age".publicKeys = [ id ];
}
