FROM ocramz/petsc-docker
# # here we-reinstall petsc-hs following petsc-hs-docker

# ------------------------------------------------------------
# Add an 'mpirun' user
# ------------------------------------------------------------

ENV MPIUSER mpirun

RUN adduser --disabled-password --gecos "" ${MPIUSER} && \
    echo "${MPIUSER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

ENV MPIHOME=/home/${MPIUSER} \
    SSHDIR=${MPIHOME}/.ssh


# ------------------------------------------------------------
# Env. variables and directories
# ------------------------------------------------------------

RUN printenv | grep PETSC
RUN printenv | grep SLEPC

# # Set up environment variables
ENV LOCAL_DIR=$HOME/.local \
    BIN_DIR=$HOME/.local/bin \
    SRC_DIR=$HOME/src \
    PETSCHS_DIR=$SRC_DIR/petsc-hs \
    PATH=$BIN_DIR:$PATH \

ENV PETSC_INCLUDE1=${PETSC_DIR}/include/ \
    PETSC_INCLUDE2=${PETSC_DIR}/${PETSC_ARCH}/include/ \
    PETSC_LIB=${PETSC_DIR}/${PETSC_ARCH}/lib/


# # NB : assumes SLEPC_ARCH is defined
ENV SLEPC_INCLUDE1=${SLEPC_DIR}/include/ \
    SLEPC_INCLUDE2=${SLEPC_DIR}/$SLEPC_ARCH/include/ \
    SLEPC_LIB=${SLEPC_DIR}/${SLEPC_ARCH}/lib/


# # augment PATH
ENV PATH $BIN_DIR:$PATH

# # # Create directories
RUN mkdir -p $LOCAL_DIR && \
    mkdir -p $BIN_DIR && \
    mkdir -p $SRC_DIR && \
    mkdir -p ${SSHDIR} && \
    mkdir -p ${MPIHOME}/bin && \
    mkdir -p ${MPIHOME}/example

# ------------------------------------------------------------
# APT-Install dependencies and tools
# ------------------------------------------------------------

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates && \
    apt-key update && \
    apt-get -qq install -y --no-install-recommends \
          make bzip2 unzip gcc git libgmp-dev wget curl xz-utils openssh-server \
        # libmunge-dev libmunge2 munge slurm-llnl \
 && apt-get clean && apt-get purge && rm -rf /var/lib/apt/lists/*


# ------------------------------------------------------------
# Get the Haskell `stack` build tool
# ------------------------------------------------------------
WORKDIR $BIN_DIR

RUN curl -L https://www.stackage.org/stack/linux-x86_64 | tar xz --wildcards --strip-components=1 -C $BIN_DIR '*/stack'

# # Add `stack` path

RUN export STACK_PATH_1=$(stack --stack-yaml stack.yaml path --local-install-root)
ENV PATH STACK_PATH_1:$PATH

RUN export DIST_DIR_1=$(stack path --dist-dir)/build

ENV PATH ${PETSC_DIR}/${PETSC_ARCH}/bin/:$PATH



# ------------------------------------------------------------
# petsc-hs : clone repository and `stack setup`
# ------------------------------------------------------------
WORKDIR $SRC_DIR

# # retrieve petsc-hs repository
RUN git clone https://github.com/ocramz/petsc-hs.git

WORKDIR $PETSCHS_DIR

# # setup + first build of petsc-hs
RUN stack setup 
RUN ./stack-build.sh "--dependencies-only" "$PETSC_DIR" "$PETSC_ARCH" "$SLEPC_DIR" "$SLEPC_ARCH"


# # install c2hs
RUN stack install c2hs


# ------------------------------------------------------------
# petsc-hs : delete PETSc-hs sources and build artifacts (dependencies are compiled in /.stack/ and safe)
# ------------------------------------------------------------
WORKDIR $SRC_DIR

# # delete PETSc-hs sources and build artifacts (dependencies are compiled in /.stack/ and safe)
RUN rm -rf petsc-hs/

# # copy update script (NB: hardcoded dir `/src`)
ADD update-petsc-hs.sh /src/

# # <===== NB : starting point to fetch and build `petsc-hs` from the github repo




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








EXPOSE 22

# # use the default cmd from petsc-hs-docker
# CMD ["/usr/sbin/sshd", "-D"]


RUN chown -R root ${MPIHOME}

