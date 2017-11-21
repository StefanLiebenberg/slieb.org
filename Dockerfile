FROM	base/archlinux
RUN	pacman -Sy
RUN	pacman -Sy archlinux-keyring --noconfirm
RUN	pacman -Su --noconfirm
RUN	pacman-db-upgrade
RUN	trust extract-compat

RUN	pacman -S ruby --noconfirm --needed
RUN	pacman -S base-devel --noconfirm --needed
RUN	pacman -S nodejs --noconfirm --needed
RUN	pacman -S ruby-pkg-config libxslt libxml2 --noconfirm --needed
RUN     echo export PATH=\"\$\(ruby -e \'print Gem.user_dir\'\)/bin:$PATH\" >> /etc/profile.d/gem.sh
RUN	gem update --no-document -- --use-system-libraries
RUN     gem update --system --no-document -- --use-system-libraries

RUN	useradd jekyll -G users -m 
RUN	mkdir /srv/jekyll && chown jekyll:jekyll -R /srv/jekyll
RUN	gem install bundler jekyll compass nokogiri --no-user-install --no-document -- --use-system-libraries
RUN	echo 'jekyll ALL=NOPASSWD:ALL' >> /etc/sudoers

USER	jekyll
WORKDIR	/srv/jekyll
VOLUME	/srv/jekyll
EXPOSE  4000


