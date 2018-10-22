# docker_elastic_curator
This is an implementation of Elasticsearch Curator in a docker machine. There is a simple script that executes the curator command on a timed loop. CentOS7 is the base image of the docker machine.

#example docker command:
docker run -e "CURATOR_ARG=--dry-run" -e "SLEEP_DELAY=43200" -e "LOOP_COUNT=-1" -e "ELASTIC_HOSTS=localhost" -e "HTTP_AUTH=elastic:password" -v /home/docker/curator/action.yml:/etc/curator/action.yml elastic-curator

#example compose:
version: '2.2'
services:
  curator:
    image: nateshull/elastic_curator-5.5
    container_name: curator
    restart: always
    environment:
      - ELASTIC_HOSTS=localhost:9200
      - HTTP_AUTH=elastic:password
      - LOOP_COUNT=-1
      - SLEEP_DELAY=43200
    mem_reservation: 4g
    cpus: 4
    volumes:
      - /home/docker/curator/action.yml:/etc/curator/action.yml
    networks:
      - network
networks:
  network:
    driver: bridge
    ipam:
       driver: default
       config:
           - subnet: 192.168.250.0/24
             gateway: 192.168.250.1


