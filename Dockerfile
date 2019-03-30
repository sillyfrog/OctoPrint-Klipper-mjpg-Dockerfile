
FROM python:2.7
EXPOSE 8080

RUN apt-get update && \
    apt-get install -y cmake libjpeg62-turbo-dev g++ wget unzip psmisc

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

#install ffmpeg
RUN cd /tmp \
  && wget -O ffmpeg.tar.xz https://www.johnvansickle.com/ffmpeg/old-releases/ffmpeg-4.0.3-32bit-static.tar.xz \
    && mkdir -p /opt/ffmpeg \
    && tar xvf ffmpeg.tar.xz -C /opt/ffmpeg --strip-components=1 \
  && rm -Rf /tmp/*

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

RUN echo v1.3.10

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
https://github.com/MoonshineSG/OctoPrint-MultiColors/archive/master.zip

# Installing from sillyfrog until the PR is merged to master
RUN /opt/octoprint/venv/bin/python -m pip install https://github.com/sillyfrog/OctoPrint-PrintHistory/archive/master.zip


VOLUME /home/octoprint/.octoprint


### Klipper setup ###

USER root

RUN apt-get install -y sudo

COPY klippy.sudoers /etc/sudoers.d/klippy

RUN useradd -ms /bin/bash klippy

USER octoprint

WORKDIR /home/octoprint

RUN git clone https://github.com/KevinOConnor/klipper

RUN ./klipper/scripts/install-octopi.sh

RUN cp klipper/config/printer-anet-a8-2017.cfg /home/octoprint/printer.cfg

USER root

COPY start.py /
COPY runklipper.py /

CMD ["/start.py"]
