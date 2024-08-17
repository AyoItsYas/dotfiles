import json
import time
import subprocess
import datetime


def get_temp() -> float:
    command = ("sensors", "-j")
    output: str = (
        subprocess.check_output(
            command,
            stderr=subprocess.DEVNULL,
        )
        .decode("utf-8")
        .strip()
    )

    output: dict = json.loads(output)

    temp = output["coretemp-isa-0000"]["Package id 0"]["temp1_input"]

    return temp


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


last_temp_samples = [get_temp()]
STOPPED_FLAG = False
while True:
    temp = get_temp()
    avg_temp = sum(last_temp_samples) / len(last_temp_samples)

    last_temp_samples.append(temp)

    if len(last_temp_samples) > 10:
        last_temp_samples.pop(0)

    if avg_temp > 90 and not STOPPED_FLAG:
        print(f"{datetime.datetime.now()} : Temp too high, stopping ffmpeg")

        for pid in get_ffmpeg_procs():
            command = ("kill", "-STOP", pid)
            subprocess.check_output(command)

        hault_time = time.time()
        avg_temp = sum(last_temp_samples) / len(last_temp_samples)
        while avg_temp > 70:
            wait = time.time() - hault_time
            if wait > 120:
                break

            print(f"Waiting for cooldown {wait:2.0f} Avg : {avg_temp:2.2f}", end="\r")

            temp = get_temp()
            last_temp_samples.append(temp)
            if len(last_temp_samples) > 10:
                last_temp_samples.pop(0)

            avg_temp = sum(last_temp_samples) / len(last_temp_samples)

            time.sleep(1)

        last_temp_samples = [get_temp()]

        STOPPED_FLAG = True
    elif STOPPED_FLAG:
        print(f"{datetime.datetime.now()} : Temp is ok, resuming ffmpeg")

        for pid in get_ffmpeg_procs():
            command = ("kill", "-CONT", pid)
            subprocess.check_output(command)

        STOPPED_FLAG = False

    print(
        f"{datetime.datetime.now()} : Temp {temp:2.2f} Avg {avg_temp:2.2f}",
        end="\r",
    )

    time.sleep(1)
