FROM ubuntu:20.04
EXPOSE 8080


# Override this for your location
ENV TZ=Australia/Brisbane

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y cmake libjpeg8-dev g++ unzip wget git ffmpeg \
        python2 virtualenv python3-dev

RUN cd /tmp/ && \
    wget https://github.com/jacksonliam/mjpg-streamer/archive/master.zip && \
    unzip master

RUN cd /tmp/mjpg-streamer-master/mjpg-streamer-experimental/ && \
    make && \
    make install

EXPOSE 5000

ARG tag=master

WORKDIR /opt/octoprint

# Cleanup
RUN rm -Rf /tmp/*

#Create an octoprint user
RUN useradd -ms /bin/bash octoprint && adduser octoprint dialout
RUN chown octoprint:octoprint /opt/octoprint
USER octoprint

#This fixes issues with the volume command setting wrong permissions
RUN mkdir /home/octoprint/.octoprint

#Install Octoprint
RUN git clone --branch $tag https://github.com/foosel/OctoPrint.git /opt/octoprint \
  && virtualenv venv \
    && ./venv/bin/pip install .

RUN /opt/octoprint/venv/bin/python -m pip install \
https://github.com/FormerLurker/Octolapse/archive/master.zip \
https://github.com/AlexVerrico/Octoprint-Display-ETA/archive/master.zip \
https://github.com/1r0b1n0/OctoPrint-Tempsgraph/archive/master.zip \
https://github.com/marian42/octoprint-preheat/archive/master.zip \
https://github.com/jneilliii/OctoPrint-TasmotaMQTT/archive/master.zip \
https://github.com/mikedmor/OctoPrint_MultiCam/archive/master.zip \
https://github.com/AliceGrey/OctoprintKlipperPlugin/archive/master.zip \
https://github.com/jneilliii/OctoPrint-TabOrder/archive/master.zip \
https://github.com/OctoPrint/OctoPrint-MQTT/archive/master.zip \
https://github.com/fraschetti/Octoslack/archive/master.zip \
https://github.com/MoonshineSG/OctoPrint-MultiColors/archive/master.zip \
https://github.com/OllisGit/OctoPrint-PrintJobHistory/releases/latest/download/master.zip \
https://github.com/Kragrathea/OctoPrint-PrettyGCode/archive/master.zip


VOLUME /home/octoprint/.octoprint


### Klipper setup ###

USER root

RUN apt-get install -y sudo

COPY klippy.sudoers /etc/sudoers.d/klippy

RUN useradd -ms /bin/bash klippy

# This is to allow the install script to run without error
RUN ln -s /bin/true /bin/systemctl

USER octoprint

WORKDIR /home/octoprint

RUN git clone https://github.com/KevinOConnor/klipper

# Update the install script for Ubuntu 20
RUN sed -i 's/python-virtualenv //' ./klipper/scripts/install-ubuntu-18.04.sh

RUN ./klipper/scripts/install-ubuntu-18.04.sh

RUN cp klipper/config/printer-anet-a8-2017.cfg /home/octoprint/printer.cfg

USER root

# Clean up hack for install script
RUN rm -f /bin/systemctl

COPY start.py /
COPY runklipper.py /

CMD ["/start.py"]
