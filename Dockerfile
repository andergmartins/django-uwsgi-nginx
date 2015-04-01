# Copyright 2015 Anderson Grudtner Martins
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM phusion/baseimage

MAINTAINER andergmartins

RUN apt-get update \
    && apt-get install -y \
        git \
        python \
        python-dev \
        python-setuptools \
        nginx \
        supervisor \
        python-software-properties \
        sqlite3 \
        libmysqlclient-dev \
    && apt-get purge -y \
    && rm -rf /var/lib/apt/lists/*

RUN easy_install pip

# install uwsgi now because it takes a little while
RUN pip install uwsgi

# install our code
ADD . /home/docker/code/

# setup all the configfiles
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN rm /etc/nginx/sites-enabled/default
RUN ln -s /home/docker/code/nginx-app.conf /etc/nginx/sites-enabled/
RUN ln -s /home/docker/code/supervisor-app.conf /etc/supervisor/conf.d/

# RUN pip install
RUN pip install -r /home/docker/code/app/requirements.txt

# install django, normally you would remove this step because your project would already
# be installed in the code/app/ directory
RUN django-admin.py startproject website /home/docker/code/app/

EXPOSE 8080
CMD ["supervisord", "-n"]
