
FROM onlyoffice:u3

COPY ./self_starting.sh /

RUN mkdir -p /var/log/onlyoffice/documentserver/docservice/ && \
	mkdir -p /var/log/onlyoffice/documentserver/converter/ && \
	mkdir -p /var/log/onlyoffice/documentserver/metrics/ && \
	mkdir -p /var/log/onlyoffice/documentserver-example/  && \
        mkdir -p /etc/onlyoffice_mount && \
	chmod +x /self_starting.sh

WORKDIR /
ENTRYPOINT /self_starting.sh && tail -f /dev/null
	
CMD ["/bin/bash"]


