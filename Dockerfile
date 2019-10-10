FROM fedora:29

MAINTAINER Sam Lyon <s.d.lyon@users.noreply.github.com>
LABEL description Robot Framework in Docker.

# Setup volumes for input and output
VOLUME /opt/robotframework/reports
VOLUME /opt/robotframework/tests
VOLUME /dev/shm

# Setup X Window Virtual Framebuffer
ENV SCREEN_COLOUR_DEPTH 24
ENV SCREEN_HEIGHT 1080
ENV SCREEN_WIDTH 1920

# Set number of threads for parallel execution
# By default, no parallelisation
ENV ROBOT_THREADS 1

# Dependency versions
ENV PYTHON_PIP_VERSION 18.0*
ENV XVFB_VERSION 1.20.*

# Install system dependencies
RUN dnf upgrade -y \
  && dnf install -y \
  python2-pip-$PYTHON_PIP_VERSION \
  xauth \
  xorg-x11-server-Xvfb-$XVFB_VERSION \
  which \
  unzip \
  jq \
  wget
ENV CHROMIUM_VERSION *
# # Install chrome dependencies
RUN dnf install -y \
  chromedriver$CHROMIUM_VERSION \
  chromium$CHROMIUM_VERSION \
  && dnf clean all

# Install Robot Framework and Selenium Library
ENV FAKER_VERSION 4.2.0
ENV PABOT_VERSION 0.53
ENV REQUESTS_VERSION 0.5.0
ENV ROBOT_FRAMEWORK_VERSION 3.1.1
ENV SELENIUM_LIBRARY_VERSION 3.3.1
RUN pip install \
  robotframework==$ROBOT_FRAMEWORK_VERSION \
  robotframework-faker==$FAKER_VERSION \
  robotframework-pabot==$PABOT_VERSION \
  robotframework-requests==$REQUESTS_VERSION \
  robotframework-seleniumlibrary==$SELENIUM_LIBRARY_VERSION \
  robotframework-selenium2library \
  robotframework-sshlibrary \
  tornado \
  nose

# Download Gecko drivers directly from the GitHub repository
ENV GECKO_DRIVER_VERSION v0.22.0
RUN wget -q "https://github.com/mozilla/geckodriver/releases/download/$GECKO_DRIVER_VERSION/geckodriver-$GECKO_DRIVER_VERSION-linux64.tar.gz" \
  && tar xzf geckodriver-$GECKO_DRIVER_VERSION-linux64.tar.gz \
  && mkdir -p /opt/robotframework/drivers/ \
  && mv geckodriver /opt/robotframework/drivers/geckodriver \
  && rm geckodriver-$GECKO_DRIVER_VERSION-linux64.tar.gz

# Prepare binaries to be executed
COPY bin/chromedriver.sh /opt/robotframework/bin/chromedriver
COPY bin/chromium-browser.sh /opt/robotframework/bin/chromium-browser
COPY bin/run-tests-in-virtual-screen.sh /opt/robotframework/bin/

# FIXME: below is a workaround, as the path is ignored
RUN mv /usr/lib64/chromium-browser/chromium-browser /usr/lib64/chromium-browser/chromium-browser-original \
  && ln -sfv /opt/robotframework/bin/chromium-browser /usr/lib64/chromium-browser/chromium-browser

# Update system path
ENV PATH=/opt/robotframework/bin:/opt/robotframework/drivers:$PATH

RUN curl https://releases.hashicorp.com/vault/0.10.3/vault_0.10.3_linux_amd64.zip -o vault.zip && \
  unzip vault.zip && \
  chmod +x vault && \
  mv vault /usr/bin/vault && \
  vault --version

RUN wget http://downloads.lambdatest.com/tunnel/linux/64bit/LT_Linux.zip && \
  unzip LT_Linux.zip && \
  chmod +x LT && \
  mv LT /usr/bin/LT

RUN wget https://github.com/crossbrowsertesting/cbt-tunnel-nodejs/releases/download/v0.9.10/cbt_tunnels-linux-x64.zip && \
  unzip cbt_tunnels-linux-x64.zip && ls -alh cbt_tunnels-linux-x64 && \
  chmod +x cbt_tunnels-linux-x64 && \
  mv cbt_tunnels-linux-x64 /usr/bin/cbt_tunnels

ARG CACHEBUST=1 
RUN curl -H 'Cache-Control: no-cache, no-store' https://cli.goodpractice.cloud/install.sh | sh && \
    gp --version

# Execute all robot tests
CMD ["run-tests-in-virtual-screen.sh"]
