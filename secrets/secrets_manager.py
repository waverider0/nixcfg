#!/usr/bin/env python3
import os, sys, secrets, tempfile, getpass
from cryptography.hazmat.primitives.kdf.scrypt import Scrypt
from cryptography.hazmat.primitives.ciphers.aead import AESGCM

sys.dont_write_bytecode = True

SECRETS = {
	".kdbx.kdbx.e": ("/dev/shm/secrets/.kdbx.kdbx", "/home/allen/.kdbx.kdbx"),
	"github.e": ("/dev/shm/secrets/github", "/home/allen/.ssh/github"),
}
PUBLIC = {
	"github.pub": "/home/allen/.ssh/github.pub",
	"ssh_config": "/home/allen/.ssh/config",
}

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
SALT_FILE = os.path.join(BASE_DIR, "salt.bin")

def atomic_write(path, data, mode=0o600):
	fd, tmp = tempfile.mkstemp(dir=os.path.dirname(path))
	with os.fdopen(fd, "wb") as f:
		f.write(data)
	os.chmod(tmp, mode)
	os.replace(tmp, path)

def derive_key(pwd, salt):
	return Scrypt(salt, 32, 2**15, 8, 1).derive(pwd.encode())

def encrypt(data, key):
	nonce = secrets.token_bytes(12)
	return nonce + AESGCM(key).encrypt(nonce, data, None)

def decrypt(data, key):
	return AESGCM(key).decrypt(data[:12], data[12:], None)

def rotate_all():
	encrypted = [f for f in SECRETS if os.path.exists(os.path.join(BASE_DIR, f))]
	plaintext = [f[:-2] for f in SECRETS if os.path.exists(os.path.join(BASE_DIR, f[:-2]))]

	old_key = None
	if encrypted:
		old_pwd = getpass.getpass("Old password: ")
		old_salt = open(SALT_FILE, "rb").read()
		old_key = derive_key(old_pwd, old_salt)

	while True:
		new_pwd = getpass.getpass("New password: ")
		new_pwd2 = getpass.getpass("Confirm new password: ")
		if new_pwd == new_pwd2:
			break
		print("Passwords do not match. Try again.", file=sys.stderr)

	new_salt = secrets.token_bytes(16)
	new_key = derive_key(new_pwd, new_salt)

	for fname in encrypted:
		path = os.path.join(BASE_DIR, fname)
		data = decrypt(open(path, "rb").read(), old_key)
		atomic_write(path, encrypt(data, new_key))
		print(f"rotated -> {path}")

	for fname in plaintext:
		plain_path = os.path.join(BASE_DIR, fname)
		data = open(plain_path, "rb").read()
		enc_path = plain_path + ".e"
		atomic_write(enc_path, encrypt(data, new_key))
		os.remove(plain_path)
		print(f"encrypted {plain_path} -> {enc_path}")

	atomic_write(SALT_FILE, new_salt)

def load_and_symlink():
	os.umask(0o077)
	os.makedirs("/dev/shm/secrets", 0o700, exist_ok=True)

	pwd = getpass.getpass("Password: ")
	key = derive_key(pwd, open(SALT_FILE, "rb").read())

	for enc, (ram, link) in SECRETS.items():
		data = decrypt(open(os.path.join(BASE_DIR, enc), "rb").read(), key)
		atomic_write(ram, data)
		if os.path.exists(link) or os.path.islink(link):
			os.remove(link)
		os.makedirs(os.path.dirname(link), exist_ok=True)
		os.symlink(ram, link)
		print(f"loaded and linked {ram} -> {link}")

	for src, dst in PUBLIC.items():
		src_path = os.path.join(BASE_DIR, src)
		if os.path.exists(dst) or os.path.islink(dst):
			os.remove(dst)
		os.makedirs(os.path.dirname(dst), exist_ok=True)
		os.symlink(src_path, dst)
		print(f"linked {src_path} -> {dst}")

def decrypt_single(target):
	enc_path = os.path.join(BASE_DIR, target)
	if not os.path.exists(enc_path):
		sys.exit(f"File not found: {enc_path}")

	pwd = getpass.getpass("Password: ")
	key = derive_key(pwd, open(SALT_FILE, "rb").read())

	data = decrypt(open(enc_path, "rb").read(), key)
	plain_path = enc_path[:-2] if target.endswith(".e") else enc_path
	atomic_write(plain_path, data)
	os.remove(enc_path)
	print(f"decrypted {enc_path} -> {plain_path}")

if __name__ == "__main__":
    if len(sys.argv) < 2 or sys.argv[1] not in ("-e", "-d", "-l"):
        sys.exit(f"Usage: {sys.argv[0]} -e | -d <file> | -l")

    if sys.argv[1] == "-e":
        rotate_all()
    elif sys.argv[1] == "-d":
        if len(sys.argv) == 2:
            load_and_symlink()
        elif len(sys.argv) == 3:
            decrypt_single(sys.argv[2])
        else:
            sys.exit(f"Usage: {sys.argv[0]} -d | -d <file>")
    elif sys.argv[1] == "-l":
        load_and_symlink()
    else:
        sys.exit(f"Usage: {sys.argv[0]} -e | -d <file> | -l")
