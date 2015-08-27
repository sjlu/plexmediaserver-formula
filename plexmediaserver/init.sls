plex-source:
  pkgrepo.managed:
    - humanname: plexmediaserver
    - name: deb http://shell.ninthgate.se/packages/debian wheezy main
    - file: /etc/apt/sources.list.d/plexmediaserver.list
    - key_url: http://shell.ninthgate.se/packages/shell-ninthgate-se-keyring.key
    - dist: wheezy

plex-install:
  pkg.installed:
    - pkgs: [plexmediaserver]
  
plex-init:
  file.replace:
    - name: /etc/init.d/plexmediaserver
    - pattern: su -l \$PLEX_MEDIA_SERVER_USER -c
    - repl: sudo -u $PLEX_MEDIA_SERVER_USER -- sh -c

plex-default:
  file.replace:
    - name: /etc/default/plexmediaserver
    - pattern: PLEX_MEDIA_SERVER_USER=plex
    - repl: PLEX_MEDIA_SERVER_USER=www-data

plex-restart:
  cmd.run:
    - name: /etc/init.d/plexmediaserver restart; sleep 2
    - onchanges:
      - file: plex-default

plex-stop:
  cmd.run:
    - name: /etc/init.d/plexmediaserver stop
    - prereq:
      - file: plex-preferences

plex-start:
  cmd.run:
    - name: /etc/init.d/plexmediaserver start; sleep 2
    - onchanges:
      - file: plex-preferences

plex-preferences:
  file.managed:
    - name: /var/www/Library/Application Support/Plex Media Server/Preferences.xml
    - source: salt://plexmediaserver/files/Preferences.xml
    - user: www-data
    - group: www-data
    - mode: 600
    - template: jinja
