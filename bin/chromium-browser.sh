#!/bin/sh

/usr/lib64/chromium-browser/chromium-browser-original  --verbose --log-path=/var/log/chromiumdriver --disable-gpu --disable-impl-side-painting --disable-gpu-sandbox --disable-accelerated-2d-canvas --disable-accelerated-jpeg-decoding --no-sandbox --test-type=ui $@

