"""Fill a wallpaper dir: elementary + KDE Plasma (curated, no AI), dharmx/walls
categories, Wallhaven toplist (AI filtered). Only landscape >= 2560 px wide; dharmx
files are sized from their first 64 KiB so small ones are never downloaded.

    python3 -I scripts/fetch-wallpapers.py ~/Pictures/wallpapers
"""
import concurrent.futures as cf
import json
import os
import re
import struct
import sys
import time
import urllib.parse
import urllib.request

OUT = sys.argv[1]
MIN_W = 2560
UA = {"User-Agent": "dotfiles-wallpaper-fetch/1.0"}
os.makedirs(OUT, exist_ok=True)
log = open(os.path.join(os.path.dirname(OUT.rstrip("/")), "wallpapers-fetch.log"), "w")


def get(url, rng=None, timeout=60):
    h = dict(UA)
    if rng:
        h["Range"] = f"bytes=0-{rng - 1}"
    with urllib.request.urlopen(urllib.request.Request(url, headers=h), timeout=timeout) as r:
        return r.read()


def dims(b):
    if b[:8] == b"\x89PNG\r\n\x1a\n":
        return struct.unpack(">II", b[16:24])
    if b[:2] == b"\xff\xd8":
        i = 2
        while i < len(b) - 9:
            if b[i] != 0xFF:
                i += 1
                continue
            m = b[i + 1]
            if m in (0xC0, 0xC1, 0xC2):
                h, w = struct.unpack(">HH", b[i + 5:i + 9])
                return w, h
            i += 2 + struct.unpack(">H", b[i + 2:i + 4])[0]
    if b[:4] == b"RIFF" and b[8:12] == b"WEBP" and b[12:16] == b"VP8X":
        return 1 + int.from_bytes(b[24:27], "little"), 1 + int.from_bytes(b[27:30], "little")
    return None


def ok(b):
    d = dims(b)
    return d is not None and d[0] >= MIN_W and d[0] > d[1], d


def safe(name):
    return re.sub(r"[^A-Za-z0-9._-]+", "_", name)[:120]


def save(url, name):
    dest = os.path.join(OUT, safe(name))
    if os.path.exists(dest):
        return "exists"
    try:
        data = get(url, timeout=120)
    except Exception as e:  # noqa: BLE001
        log.write(f"FAIL {url} {e}\n")
        return "fail"
    good, d = ok(data)
    if not good:
        log.write(f"SKIP {url} {d}\n")
        return "skip"
    with open(dest, "wb") as f:
        f.write(data)
    return "ok"


def tree(repo, branch):
    t = json.loads(get(f"https://api.github.com/repos/{repo}/git/trees/{branch}?recursive=1"))
    return [e["path"] for e in t["tree"] if e["type"] == "blob" and re.search(r"\.(jpe?g|png|webp)$", e["path"], re.I)]


def raw(repo, branch, path):
    return f"https://raw.githubusercontent.com/{repo}/{branch}/" + urllib.parse.quote(path)


jobs = []  # (url, name, precheck)

for p in tree("elementary/wallpapers", "main"):
    if p.startswith("backgrounds/"):
        jobs.append((raw("elementary/wallpapers", "main", p), "elementary-" + os.path.basename(p), False))

kde = {}
for p in tree("KDE/plasma-workspace-wallpapers", "master"):
    m = re.match(r"([^/]+)/contents/images/(\d+)x(\d+)\.\w+$", p)
    if m and int(m.group(2)) > int(m.group(3)):
        w = int(m.group(2))
        if w > kde.get(m.group(1), (0, ""))[0]:
            kde[m.group(1)] = (w, p)
for name, (w, p) in kde.items():
    if w >= MIN_W:
        jobs.append((raw("KDE/plasma-workspace-wallpapers", "master", p), f"kde-{name}{os.path.splitext(p)[1]}", False))

DHARMX = {"nature", "mountain", "aerial", "fogsmoke", "cold", "calm", "flowers", "fauna",
          "minimal", "monochrome", "abstract", "centered", "geometry", "poly", "paper",
          "architecture", "interior", "painting", "stalenhag", "retro",
          "anime", "manga", "evangelion", "m-26.jp", "girl"}
for p in tree("dharmx/walls", "main"):
    cat = p.split("/")[0]
    if cat in DHARMX:
        jobs.append((raw("dharmx/walls", "main", p), f"dharmx-{cat}-{os.path.basename(p)}", True))

for q in ["landscape", "minimalism", "space", "city"]:
    api = ("https://wallhaven.cc/api/v1/search?" + urllib.parse.urlencode({
        "q": q, "categories": "110", "purity": "100", "atleast": "2560x1440", "ratios": "16x9",
        "sorting": "toplist", "topRange": "1y", "ai_art_filter": "1"}))
    data = json.loads(get(api))["data"][:15]
    for w in data:
        jobs.append((w["path"], f"wallhaven-{q}-{w['id']}{os.path.splitext(w['path'])[1]}", False))
    time.sleep(2)

print("candidates:", len(jobs), flush=True)


def run(job):
    url, name, precheck = job
    if precheck:
        try:
            good, d = ok(get(url, rng=65536))
        except Exception as e:  # noqa: BLE001
            log.write(f"FAIL-HEAD {url} {e}\n")
            return "fail"
        if not good:
            return "small"
    return save(url, name)


stats = {}
with cf.ThreadPoolExecutor(8) as ex:
    for r in ex.map(run, jobs):
        stats[r] = stats.get(r, 0) + 1
print("result:", stats, flush=True)
log.close()
