
FROM centos7_db:v1

COPY ./self_starting.sh /

RUN yum -y update && \
	yum -y install dos2unix && \
	yum -y install iproute && \
	yum -y install  net-tools && \
	dos2unix /self_starting.sh  && \
	yum install -y vsftpd && \
    	systemctl enable vsftpd.service && \
    	chmod +x /self_starting.sh  && \
     	rm -rf /home/radar && \
	rm -rf /home/temp  && \
        echo -e '\n# self add\n# pam_service_name=vsftpd\n# userlist_enable=YES\n# userlist_file=/etc/vsftpd/user_list\n# userlist_deny=NO\n# tcp_wrappers=YES\n# listen_port=8020\n# port_enable=NO\n# pasv_enable=YES\n# pasv_min_port=8021\n# pasv_max_port=8022\n# local_root=/ ' >> /etc/vsftpd/vsftpd.conf  && \
	sed -i '/root/d' /etc/vsftpd/ftpusers	

WORKDIR /
ENTRYPOINT /self_starting.sh && tail -f /dev/null
	
CMD ["/bin/bash"]


