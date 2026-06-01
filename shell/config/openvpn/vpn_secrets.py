#!/usr/bin/env python3
"""VPN secrets: JSON store, arbitrary password symbols, TOTP, auth-user-pass file."""
from __future__ import annotations

import argparse
import base64
import hashlib
import hmac
import json
import re
import struct
import sys
import time
from pathlib import Path
from typing import Any


def totp(secret: str, period: int = 30, digits: int = 6) -> str:
    secret = secret.replace(" ", "").upper()
    pad = (-len(secret)) % 8
    key = base64.b32decode(secret + "=" * pad)
    counter = int(time.time()) // period
    msg = struct.pack(">Q", counter)
    digest = hmac.new(key, msg, hashlib.sha1).digest()
    offset = digest[-1] & 0x0F
    code = struct.unpack(">I", digest[offset : offset + 4])[0] & 0x7FFFFFFF
    return str(code % (10**digits)).zfill(digits)


def load_store(raw: str) -> dict[str, Any]:
    raw = raw.strip()
    if not raw:
        return {}
    if raw.startswith("{"):
        return json.loads(raw)
    return migrate_ini(raw)


def migrate_ini(text: str) -> dict[str, Any]:
    store: dict[str, Any] = {}
    section: str | None = None

    for line in text.splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        m = re.match(r"\[([^\]]+)\]", line)
        if m:
            section = m.group(1).strip()
            store.setdefault(section, {})
            continue
        if not section or "=" not in line:
            continue
        key, _, val = line.partition("=")
        key, val = key.strip(), val.strip()
        entry = store[section]
        if key == "username":
            entry["username"] = val
        elif key == "password_b64":
            entry["password"] = base64.b64decode(val).decode("utf-8")
        elif key == "password":
            entry["password"] = val
        elif key in ("totp_secret", "totp"):
            entry["totp_secret"] = val.replace(" ", "")
    return store


def dump_store(store: dict[str, Any]) -> str:
    return json.dumps(store, indent=2, ensure_ascii=False) + "\n"


def read_password_file(path: str) -> str:
    data = Path(path).read_bytes()
    try:
        return data.decode("utf-8")
    except UnicodeDecodeError as e:
        raise SystemExit(f"password file must be UTF-8: {e}") from e


def get_profile(
    store: dict[str, Any],
    profile: str,
    override_user: str | None = None,
) -> tuple[str, str, str]:
    if profile not in store:
        raise SystemExit(f"profile not in secrets: {profile}")
    entry = store[profile]
    if not isinstance(entry, dict):
        raise SystemExit(f"invalid secrets entry for {profile}")
    password = entry.get("password") or ""
    totp_secret = entry.get("totp_secret") or ""
    username = (override_user if override_user is not None else entry.get("username") or "").strip()
    if not username:
        raise SystemExit(f"username missing for {profile} — run: vpn secrets set {profile}")
    if not password:
        raise SystemExit(f"password missing for {profile}")
    if not totp_secret:
        raise SystemExit(f"totp_secret missing for {profile}")
    return username, password, totp(totp_secret)


def write_auth_file(path: Path, username: str, password: str, otp: str) -> None:
    path.write_text(f"{username}\n{password}{otp}\n", encoding="utf-8", newline="\n")
    path.chmod(0o600)


def hexdump(label: str, value: str) -> None:
    b = value.encode("utf-8")
    hexs = " ".join(f"{x:02x}" for x in b)
    print(f"  {label} bytes ({len(b)}): {hexs}", file=sys.stderr)


def cmd_merge(args: argparse.Namespace) -> None:
    store = load_store(sys.stdin.read())
    username = args.username.strip()
    if not username:
        raise SystemExit("username is required")
    password = read_password_file(args.password_file)
    totp_secret = args.totp_secret.replace(" ", "")
    store[args.profile] = {
        "username": username,
        "password": password,
        "totp_secret": totp_secret,
    }
    sys.stdout.write(dump_store(store))


def cmd_list(args: argparse.Namespace) -> None:
    store = load_store(sys.stdin.read())
    for name in sorted(store):
        print(name)


def cmd_resolve(args: argparse.Namespace) -> None:
    store = load_store(sys.stdin.read())
    user, password, otp = get_profile(store, args.profile, args.override_user)
    write_auth_file(Path(args.auth_file), user, password, otp)


def cmd_format(_args: argparse.Namespace) -> None:
    store = load_store(sys.stdin.read())
    sys.stdout.write(dump_store(store))


def cmd_debug(args: argparse.Namespace) -> None:
    store = load_store(sys.stdin.read())
    user, password, otp = get_profile(store, args.profile, args.override_user)
    combined = password + otp
    remaining = 30 - (int(time.time()) % 30)

    print(f"vpn debug: profile={args.profile}", file=sys.stderr)
    print("WARNING: secrets below — local use only", file=sys.stderr)
    print("---", file=sys.stderr)
    print(f"format:            JSON", file=sys.stderr)
    print(f"username ({len(user)}): {user!r}", file=sys.stderr)
    print(f"password ({len(password)}): {password!r}", file=sys.stderr)
    hexdump("password", password)
    print(f"otp ({len(otp)}): {otp!r} (expires in {remaining}s)", file=sys.stderr)
    hexdump("otp", otp)
    print(f"combined ({len(combined)}): {combined!r}", file=sys.stderr)
    hexdump("combined", combined)
    print("--- auth-user-pass:", file=sys.stderr)
    print(f"  line1: {user}", file=sys.stderr)
    print(f"  line2: {combined}", file=sys.stderr)

    if args.auth_file:
        path = Path(args.auth_file)
        write_auth_file(path, user, password, otp)
        print("--- auth temp file:", file=sys.stderr)
        print(f"  path: {path}", file=sys.stderr)
        print(f"  mode: {oct(path.stat().st_mode)[-3:]}", file=sys.stderr)
        print("  contents:", file=sys.stderr)
        for line in path.read_text(encoding="utf-8").splitlines():
            print(f"    {line}", file=sys.stderr)


def main() -> None:
    p = argparse.ArgumentParser()
    sub = p.add_subparsers(dest="cmd", required=True)

    m = sub.add_parser("merge")
    m.add_argument("profile")
    m.add_argument("--username", required=True)
    m.add_argument("--password-file", required=True)
    m.add_argument("--totp-secret", required=True)

    sub.add_parser("list")
    sub.add_parser("format")

    r = sub.add_parser("resolve")
    r.add_argument("profile")
    r.add_argument("auth_file")
    r.add_argument("--override-user", default=None)

    d = sub.add_parser("debug")
    d.add_argument("profile")
    d.add_argument("--auth-file", default="")
    d.add_argument("--override-user", default=None)

    args = p.parse_args()
    if args.cmd == "merge":
        cmd_merge(args)
    elif args.cmd == "list":
        cmd_list(args)
    elif args.cmd == "format":
        cmd_format(args)
    elif args.cmd == "resolve":
        cmd_resolve(args)
    elif args.cmd == "debug":
        cmd_debug(args)


if __name__ == "__main__":
    main()
