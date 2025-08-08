import logging
import re
from argparse import ArgumentParser
from asyncio import open_unix_connection, run
import subprocess
from typing import Mapping, Protocol

logging.basicConfig(level="INFO")
logger = logging.getLogger("openvpn_management")

argument_parser = ArgumentParser()
argument_parser.add_argument("secrets")
arguments = argument_parser.parse_args()

with open(arguments.secrets, "r") as file_handle:
    username, password = map(str.strip, file_handle.read().splitlines())


def totp() -> str:
    args = [
        "systemd-ask-password",
        "--icon",
        "network-vpn",
        "--system",
        "--echo",
        "Please confirm with second factor:",
    ]
    return subprocess.check_output(args, text=True).strip()


class Handler(Protocol):
    def __call__(self, **kwargs: str) -> None: ...


def log_failed_authentication(**kwargs: str) -> None:
    label = kwargs["label"]
    logger.error(f"Failed to authenticate with '{label}'")


def log_auth_token(**_: str) -> None:
    logger.info("Received auth-token from server")


def log(**kwargs: str) -> None:
    level = kwargs["level"]
    message = kwargs["message"].strip()
    {
        "FATAL": logger.critical,
        "ERROR": logger.error,
        "SUCCESS": logger.info,
        "INFO": logger.info,
    }[level](message)


# Adapted from https://github.com/larsks/openvpn-askpass/blob/b04ed01a6352ca7b300f5792a75e4402d1cbbe22/openvpn_askpass/askpass.py#L46
async def main() -> None:
    reader, writer = await open_unix_connection("/run/openvpn-charite-management.sock")

    def send(command: str) -> None:
        writer.write(f"{command}\n".encode())

    def send_username_password(**kwargs: str) -> None:
        label = kwargs["label"]

        send(f'username "{label}" "{username}"')
        send(f'password "{label}" "{password}{totp()}"')

    commands: Mapping[str, Handler] = {
        r">PASSWORD:Need '(?P<label>[^']*)' username/password": send_username_password,
        r">PASSWORD:Auth-Token:.+": log_auth_token,
        r">PASSWORD:Verification Failed: '(?P<label>[^']*)'": log_failed_authentication,
        r">?(?P<level>(SUCCESS|FATAL|ERROR|INFO)):(?P<message>.+)": log,
    }

    try:
        async for encoded_line in reader:
            line = encoded_line.decode().strip()
            for pattern, handler in commands.items():
                if match := re.match(pattern, line):
                    handler(**match.groupdict())
                    break
            else:
                logger.info(line)
    finally:
        try:
            send("quit")
        except OSError:
            pass


if __name__ == "__main__":
    try:
        run(main())
    except (ConnectionRefusedError, KeyboardInterrupt):
        pass
