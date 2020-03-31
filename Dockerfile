FROM ubuntu:18.04
EXPOSE 8080

RUN apt-get update && \
    apt-get install -y cmake libjpeg8-dev g++ wget curl unzip psmisc git \
        python-virtualenv virtualenv python-dev libffi-dev build-essential ffmpeg

RUN cd /tmp/ && \
    wget https://github.com/jacksonliam/mjpg-streamer/archive/master.zip && \
    unzip master

RUN cd /tmp/mjpg-streamer-master/mjpg-streamer-experimental/ && \
    make && \
    make install

EXPOSE 5000

ENV CURA_VERSION=15.04.6
ARG tag=master

WORKDIR /opt/octoprint

# Cleanup
RUN rm -Rf /tmp/*

#install Cura
RUN cd /tmp \
  && wget https://github.com/Ultimaker/CuraEngine/archive/${CURA_VERSION}.tar.gz \
  && tar -zxf ${CURA_VERSION}.tar.gz \
    && cd CuraEngine-${CURA_VERSION} \
    && mkdir build \
    && make \
    && mv -f ./build /opt/cura/ \
  && rm -Rf /tmp/*

#Install Slic3r
COPY latestslic3r.py /opt/latestslic3r.py
RUN cd /opt/ \
  && curl https://dl.slic3r.org/linux/$(/opt/latestslic3r.py) | tar xj

# Dev builds have disappeared???
  #&& curl https://dl.slic3r.org/dev/linux/Slic3r-master-latest.tar.bz2 | tar xj

#Create an octoprint user
RUN useradd -ms /bin/bash octoprint && adduser octoprint dialout
RUN chown octoprint:octoprint /opt/octoprint
USER octoprint

#This fixes issues with the volume command setting wrong permissions
RUN mkdir /home/octoprint/.octoprint

#Install Octoprint
RUN git clone --branch $tag https://github.com/foosel/OctoPrint.git /opt/octoprint \
  && virtualenv venv \
    && ./venv/bin/python setup.py install

RUN /opt/octoprint/venv/bin/python -m pip install \
https://github.com/FormerLurker/Octolapse/archive/master.zip \
https://github.com/pablogventura/Octoprint-ETA/archive/master.zip \
https://github.com/1r0b1n0/OctoPrint-Tempsgraph/archive/master.zip \
https://github.com/dattas/OctoPrint-DetailedProgress/archive/master.zip \
https://github.com/kennethjiang/OctoPrint-Slicer/archive/master.zip \
https://github.com/marian42/octoprint-preheat/archive/master.zip \
https://github.com/jneilliii/OctoPrint-TasmotaMQTT/archive/master.zip \
https://github.com/mikedmor/OctoPrint_MultiCam/archive/master.zip \
https://github.com/OctoPrint/OctoPrint-Slic3r/archive/master.zip \
https://github.com/mmone/OctoPrintKlipper/archive/master.zip \
https://github.com/jneilliii/OctoPrint-TabOrder/archive/master.zip \
https://github.com/OctoPrint/OctoPrint-MQTT/archive/master.zip \
https://github.com/fraschetti/Octoslack/archive/master.zip \
https://github.com/MoonshineSG/OctoPrint-MultiColors/archive/master.zip \
https://github.com/OctoPrint/OctoPrint-CuraLegacy/archive/master.zip \
https://github.com/imrahil/OctoPrint-PrintHistory/archive/master.zip \
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

RUN ./klipper/scripts/install-ubuntu-18.04.sh

RUN cp klipper/config/printer-anet-a8-2017.cfg /home/octoprint/printer.cfg

USER root

# Clean up hack for install script
RUN rm -f /bin/systemctl

COPY start.py /
COPY runklipper.py /

CMD ["/start.py"]
