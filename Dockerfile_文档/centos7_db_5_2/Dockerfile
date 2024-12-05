
FROM centos7_db:v5.1
RUN  rm /self_starting.sh
COPY ./self_starting.sh /

RUN yum -y update && \
	yum -y install dos2unix && \
	yum -y install iproute && \
	yum -y install  net-tools && \
	dos2unix /self_starting.sh  && \
    chmod +x /self_starting.sh && \
	yum clean all

WORKDIR /
ENTRYPOINT /self_starting.sh && tail -f /dev/null
	
CMD ["/bin/bash"]

