FROM ocramz/petsc-hs-docker

ENV MPIUSER mpirun

# ------------------------------------------------------------
# Add an 'mpirun' user
# ------------------------------------------------------------

RUN adduser --disabled-password --gecos "" ${MPIUSER} && \
    echo "${MPIUSER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers


ENV MPIHOME /home/${MPIUSER}


# # augment PATH
ENV PATH $BIN_DIR:$PATH

# # # Create directories
RUN mkdir -p ${MPIHOME}/.ssh && \
    mkdir -p ${MPIHOME}/bin && \
    mkdir -p ${MPIHOME}/example



# # update TLS-related stuff and install dependencies
RUN apt-get update && \
    # apt-get -qq install -y --no-install-recommends ca-certificates debian-keyring debian-archive-keyring && \
    # apt-key update && \
    # apt-get -qq update && \
    apt-get -qq install -y --no-install-recommends \
          make bzip2 unzip wget curl openssh-server \
        # libmunge-dev libmunge2 munge slurm-llnl \
 && apt-get clean && apt-get purge && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# SSH
# ------------------------------------------------------------

RUN echo 'root:${MPIUSER}' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked out after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd


RUN pwd
RUN ls -lsA
RUN printenv


# # # COPY SSH KEYS :
ADD ssh/config ${SSHDIR}/config

# # # template:
ADD ssh/id_rsa.mpi ${SSHDIR}/id_rsa
ADD ssh/id_rsa.mpi.pub ${SSHDIR}/id_rsa.pub
ADD ssh/id_rsa.mpi.pub ${SSHDIR}/authorized_keys

# # # 


RUN chmod -R 600 ${SSHDIR}* && \
    chown -R ${MPIUSER}:${MPIUSER} ${SSHDIR}




# # $SRC_DIR == /src (was defined in petsc-hs-docker Dockerfile)
WORKDIR $SRC_DIR

ADD update-petsc-hs-0.sh ${SRC_DIR}/update-petsc-hs-0.sh






EXPOSE 22

# # use the default cmd from petsc-hs-docker
# CMD ["/usr/sbin/sshd", "-D"]


RUN chown -R root ${HOME}

