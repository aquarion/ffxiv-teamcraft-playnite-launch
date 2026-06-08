#!/usr/bin/env python3
"""XVI Authenticator - sends a TOTP code to XIVLauncher."""

import argparse
import configparser
import os
import platform
import sys
import time
import hmac
import hashlib
import struct
import base64
import urllib.parse
import urllib.request
import urllib.error

APP_NAME="xvi-authenticator"
CONFIG_SECTION = "xvi-authenticator"
INT_KEYS = ("digits", "period")


def config_dir() -> str:
    """Return the OS-appropriate config directory for the application."""
    system = platform.system()
    if system == "Windows":
        base = os.environ.get("APPDATA", os.path.expanduser("~/AppData/Roaming"))
    elif system == "Darwin":
        base = os.path.expanduser("~/Library/Application Support")
    else:
        base = os.environ.get("XDG_CONFIG_HOME", os.path.expanduser("~/.config"))
    return os.path.join(base, APP_NAME)


def config_path() -> str:
    return os.path.join(config_dir(), "config.ini")


def load_config() -> dict:
    path = config_path()
    parser = configparser.ConfigParser(interpolation=None)
    if not parser.read(path) or not parser.has_section(CONFIG_SECTION):
        return {}
    section = parser[CONFIG_SECTION]
    cfg = {}
    for key in section:
        if key in INT_KEYS:
            cfg[key] = section.getint(key)
        elif key == "ips":
            cfg[key] = [ip.strip() for ip in section[key].split(";") if ip.strip()]
        else:
            cfg[key] = section[key]
    return cfg


def save_config(cfg: dict) -> None:
    d = config_dir()
    os.makedirs(d, exist_ok=True)
    parser = configparser.ConfigParser(interpolation=None)
    parser[CONFIG_SECTION] = {}
    for key, value in cfg.items():
        if key == "ips":
            parser[CONFIG_SECTION][key] = ";".join(value)
        else:
            parser[CONFIG_SECTION][key] = str(value)
    with open(config_path(), "w") as f:
        parser.write(f)
    print(f"Config saved to {config_path()}")


ALGORITHMS = {
    "SHA1": hashlib.sha1,
    "SHA256": hashlib.sha256,
    "SHA512": hashlib.sha512,
}


def generate_totp(
    secret: str, algorithm: str = "SHA1", interval: int = 30, digits: int = 6
) -> str:
    """Generate a TOTP code from a base32 secret (Google Authenticator compatible)."""
    secret = secret.upper().replace(" ", "")
    secret += "=" * ((8 - len(secret) % 8) % 8)
    key = base64.b32decode(secret)

    hash_func = ALGORITHMS.get(algorithm.upper(), hashlib.sha1)

    counter = int(time.time()) // interval
    counter_bytes = struct.pack(">Q", counter)

    mac = hmac.new(key, counter_bytes, hash_func).digest()

    offset = mac[-1] & 0x0F
    code = struct.unpack(">I", mac[offset : offset + 4])[0] & 0x7FFFFFFF

    return str(code % (10**digits)).zfill(digits)


def send_to_xivlauncher(ip: str, otp: str, timeout: int = 60, interval: int = 5) -> bool:
    """Send OTP to XIVLauncher, retrying until timeout if connection is refused."""
    url = f"http://{ip}:4646/ffxivlauncher/{otp}"
    deadline = time.time() + timeout
    attempt = 0
    while True:
        attempt += 1
        try:
            urllib.request.urlopen(url, timeout=5)
            print(f"Sent OTP to {ip}")
            return True
        except urllib.error.URLError as e:
            if time.time() + interval > deadline:
                print(f"Failed to reach {ip} after {timeout}s: {e}")
                return False
            if attempt == 1:
                print(f"Waiting for {ip}...", end="", flush=True)
            else:
                print(".", end="", flush=True)
            time.sleep(interval)
        except Exception:
            # XIVLauncher's HTTP server may close the connection oddly
            print(f"Sent OTP to {ip} (connection closed by server)")
            return True


def main():
    parser = argparse.ArgumentParser(description="Send TOTP code to XIVLauncher")
    parser.add_argument(
        "--set-secret",
        metavar="SECRET",
        help="Save a base32 TOTP secret or otpauth:// URI to config",
    )
    parser.add_argument(
        "--set-ip",
        metavar="IP",
        help="Save XIVLauncher IP(s) to config (semicolon-separated)",
    )
    parser.add_argument(
        "--code",
        action="store_true",
        help="Treat positional argument as a literal OTP code instead of generating one",
    )
    parser.add_argument(
        "--show-config", action="store_true", help="Print config path and contents"
    )
    parser.add_argument(
        "-q",
        "--quit-after-send",
        action="store_true",
        help="Exit immediately after sending the OTP",
    )
    parser.add_argument(
        "--timeout",
        type=int,
        default=60,
        help="Seconds to retry connecting to XIVLauncher (default: 60)",
    )
    parser.add_argument(
        "otp_code",
        nargs="?",
        help="Literal OTP code to send (use with --code)",
    )
    args = parser.parse_args()

    cfg = load_config()

    # Handle config setters
    if args.set_secret or args.set_ip:
        if args.set_secret:
            value = args.set_secret
            if value.startswith("otpauth://"):
                parsed = urllib.parse.urlparse(value)
                params = urllib.parse.parse_qs(parsed.query)
                if "secret" not in params:
                    parser.error("otpauth:// URI missing 'secret' parameter")
                cfg["secret"] = params["secret"][0]
                if "algorithm" in params:
                    cfg["algorithm"] = params["algorithm"][0].upper()
                if "digits" in params:
                    cfg["digits"] = int(params["digits"][0])
                if "period" in params:
                    cfg["period"] = int(params["period"][0])
                if "issuer" in params:
                    cfg["issuer"] = params["issuer"][0]
                # Extract account name from path (strip leading /totp/)
                label = urllib.parse.unquote(parsed.path).lstrip("/")
                if label.startswith("totp/"):
                    label = label[5:]
                elif label.startswith("hotp/"):
                    label = label[5:]
                if label:
                    cfg["account_name"] = label
            else:
                cfg["secret"] = value
        if args.set_ip:
            cfg["ips"] = [ip.strip() for ip in args.set_ip.split(";") if ip.strip()]
        save_config(cfg)
        return

    if args.show_config:
        print(f"Config file: {config_path()}")
        if os.path.exists(config_path()):
            with open(config_path(), "r") as f:
                print(f.read().rstrip())
        else:
            print("(no config saved)")
        return

    # Generate or accept OTP
    if args.code:
        if not args.otp_code:
            parser.error("--code requires an OTP code argument")
        otp = args.otp_code
    else:
        secret = cfg.get("secret")
        if not secret:
            parser.error(
                "No secret configured. Use --set-secret SECRET to save one first."
            )
        otp = generate_totp(
            secret,
            algorithm=cfg.get("algorithm", "SHA1"),
            interval=cfg.get("period", 30),
            digits=cfg.get("digits", 6),
        )

    print(f"OTP: {otp}")

    ips = cfg.get("ips", ["127.0.0.1"])
    for ip in ips:
        send_to_xivlauncher(ip, otp, timeout=args.timeout)

    if args.quit_after_send:
        sys.exit(0)


if __name__ == "__main__":
    main()
