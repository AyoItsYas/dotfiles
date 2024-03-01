#!/usr/bin/python3

import os
import requests


def process_usage_data(data, day_time_quota, night_time_quota):
    data = data["dataBundle"]["dailylist"]

    day_time_usage = 0
    night_time_usage = 0

    for day in data:
        usages = day["usages"]

        try:
            day_time_usage += (
                x := float(usages[0]["volumes"]["pdl"])
                + float(usages[0]["volumes"]["pul"])
            )
            night_time_usage += (
                y := float(usages[0]["volumes"]["opdl"])
                + float(usages[0]["volumes"]["opul"])
            )
            print(f"{day['date']} >>> Day Time: {x:5.2f}GB Night Time: {y:5.2f}GB")
        except TypeError:
            continue

    print("")

    sample_size = len(data)
    total_usage = day_time_usage + night_time_usage
    total_quota = day_time_quota + night_time_quota

    day_time_remaining = day_time_quota - day_time_usage
    night_time_remaining = night_time_quota - night_time_usage
    overall_remaining = day_time_remaining + night_time_remaining

    day_time_percentage = (day_time_usage / day_time_quota) * 100
    night_time_percentage = (night_time_usage / night_time_quota) * 100
    overall_percentage = (total_usage / (day_time_quota + night_time_quota)) * 100

    daily_day_time_average = day_time_usage / sample_size
    daily_night_time_average = night_time_usage / sample_size
    daily_total_average = total_usage / sample_size

    daily_day_time_average_left = day_time_remaining / (31 - sample_size)
    daily_night_time_average_left = night_time_remaining / (31 - sample_size)
    daily_total_average_left = overall_remaining / (31 - sample_size)

    data = {
        "sample_size": sample_size,
        "day_time_usage": {
            "usage": day_time_usage,
            "quota": day_time_quota,
            "remaining": day_time_remaining,
            "percentage": day_time_percentage,
            "daily_average": daily_day_time_average,
            "daily_average_left": daily_day_time_average_left,
        },
        "night_time_usage": {
            "usage": night_time_usage,
            "quota": night_time_quota,
            "remaining": night_time_remaining,
            "percentage": night_time_percentage,
            "daily_average": daily_night_time_average,
            "daily_average_left": daily_night_time_average_left,
        },
        "overall": {
            "usage": total_usage,
            "quota": total_quota,
            "remaining": overall_remaining,
            "percentage": overall_percentage,
            "daily_average": daily_total_average,
            "daily_average_left": daily_total_average_left,
        },
    }

    return data


def process_package_data(data):
    result = {
        "status": data["dataBundle"]["status"],
        "package": data["dataBundle"]["my_package_info"]["package_name"],
        "day_time_quota": float(
            data["dataBundle"]["my_package_info"]["usageDetails"][0]["limit"]
        ),
    }

    result["night_time_quota"] = (
        float(data["dataBundle"]["my_package_info"]["usageDetails"][1]["limit"])
        - result["day_time_quota"]
    )

    return result


def main():
    AUTH_TOKEN = (
        os.environ.get("SLT_AUTH_TOKEN")
        or "bearer y55REFLxr8hTkpXzpEe0FcMry3NRdgJz65IJ6lJ153Iav12YGqB2Hg_5cuNTSmcqyAp8bdK_yOcyyHGszvfX0W4m8wekxwnBFLs1Bhc1jEJBYSjOo_x1yMyHoGI0pwNOxiW3kG8glOqKHzYxz2jWLOSCmMwFuxRNQ-ixab2n0ItJA6UOvvUZTwT6skq7jIWFz9obelrYKmHZFNGvsG6XD_JXormg928pzs31jiyui4rixC1OeM_vkUzHH0ZKWUy1mJyPHkfDza4bMsWDMjVPA-g2QKIeayjoLEsMCpOQNPleqJub"
    )
    PHONE_NUMBER = os.environ.get("SLT_PHONE_NUMBER") or "94112087494"
    IBM_CLIENT_ID = (
        os.environ.get("SLT_IBM_CLIENT_ID") or "41aed706-8fdf-4b1e-883e-91e44d7f379b"
    )

    payload = {}
    headers = {
        "Accept": "application/json, text/plain, */*",
        "X-IBM-Client-Id": IBM_CLIENT_ID,
        "Authorization": AUTH_TOKEN,
    }

    url = f"https://omniscapp.slt.lk/mobitelint/slt/api/BBVAS/UsageSummary?subscriberID={PHONE_NUMBER}"

    response = requests.request("GET", url, headers=headers, data=payload)

    if response.status_code == 200:
        data = process_package_data(response.json())
    else:
        print("Failed to fetch package data!")
        return 1

    url = f"https://omniscapp.slt.lk/mobitelint/slt/api/BBVAS/EnhancedCurrentDailyUsage?subscriberID={PHONE_NUMBER}&billDate=01"

    response = requests.request("GET", url, headers=headers, data=payload)

    if response.status_code == 200:
        data.update(
            process_usage_data(
                response.json(), data["day_time_quota"], data["night_time_quota"]
            )
        )
    else:
        print("Failed to fetch usage data!")
        return 1

    f = "5.1f"
    g = "4.1f"

    message = (
        "SLT Usage Report",
        "\nPackage Details",
        f" - Package    : {data['package']}",
        f" - Status     : {data['status']}",
        "\nTotal Usage,",
        f" - Day Time   : {data['day_time_usage']['usage']:{f}} / {data['day_time_usage']['quota']:{f}} GB ({data['day_time_usage']['percentage']:{g}}% used)",
        f" - Night Time : {data['night_time_usage']['usage']:{f}} / {data['night_time_usage']['quota']:{f}} GB ({data['night_time_usage']['percentage']:{g}}% used)",
        f" - Overall    : {data['overall']['usage']:{f}} / {data['overall']['quota']:{f}} GB ({data['overall']['percentage']:{g}}% used)",
        f"\nAvg Usage, ({data['sample_size']} days)",
        f" - Day Time   : {data['day_time_usage']['daily_average']:{f}} GB (per day)",
        f" - Night Time : {data['night_time_usage']['daily_average']:{f}} GB (per day)",
        f" - Overall    : {data['overall']['daily_average']:{f}} GB (per day)",
        f"\nRecomended Maintain, ({31 - data['sample_size']} days)",
        f" - Day Time   : {data['day_time_usage']['daily_average_left']:{f}} GB (per day)",
        f" - Night Time : {data['night_time_usage']['daily_average_left']:{f}} GB (per day)",
        f" - Overall    : {data['overall']['daily_average_left']:{f}} GB (per day)",
    )

    print((message := "\n".join(message)))

    return 0


if __name__ == "__main__":
    exit(main())
