#!/bin/sh

/usr/bin/chromedriver --verbose --log-path=/var/log/chromedriver --disable-gpu --disable-impl-side-painting --disable-gpu-sandbox --disable-accelerated-2d-canvas --disable-accelerated-jpeg-decoding --no-sandbox --test-type=ui $@

