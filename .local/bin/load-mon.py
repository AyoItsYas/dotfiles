import json
import time
import subprocess


def get_load() -> float:
    command = ("uptime",)

    output: str = (
        subprocess.check_output(
            command,
            stderr=subprocess.DEVNULL,
        )
        .decode("utf-8")
        .strip()
    )

    return float(output.split()[-3].strip(","))


def get_ffmpeg_procs() -> list[int]:
    command = ("top", "-b", "-n", "1")
    output: str = (
        subprocess.check_output(
            command,
            stderr=subprocess.DEVNULL,
        )
        .decode("utf-8")
        .strip()
    )

    output = output.split("\n")

    output = list(filter(lambda x: "ffmpeg" in x, output))

    output = list(map(lambda x: x.split()[0], output))

    return output


while True:
    load = get_load()

    if load < 4:
        print("Load too low, starting ffmpeg", end="\r")

        for pid in get_ffmpeg_procs():
            command = ("kill", "-CONT", pid)
            subprocess.check_output(command)

        haulted = True

    if load > 7:
        print("Load too high, stopping ffmpeg", end="\r")

        for pid in get_ffmpeg_procs():
            command = ("kill", "-STOP", pid)
            subprocess.check_output(command)

    time.sleep(10)
