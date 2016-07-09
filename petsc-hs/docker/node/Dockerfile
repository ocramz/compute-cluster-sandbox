FROM ocramz/compute-node

# PETSc and SLEPc versions

ENV PETSC_VERSION 3.7.2
ENV SLEPC_VERSION 3.7.1

# # env. variables

ENV PETSC_DIR /opt/petsc-$PETSC_VERSION
ENV SLEPC_DIR /opt/slepc-$SLEPC_VERSION
ENV PETSC_ARCH arch-linux2-c-debug
ENV SLEPC_ARCH arch-linux2-c-debug


# # # Update APT and install dependencies and tools
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y make \
                       gcc gfortran wget curl python pkg-config build-essential \
		       make gcc git libgmp-dev wget curl xz-utils \
                       valgrind \
		       openssh-client 


# # Download and extract PETSc.
WORKDIR /opt
RUN wget --no-verbose http://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-lite-$PETSC_VERSION.tar.gz && \
    gunzip -c petsc-lite-$PETSC_VERSION.tar.gz | tar -xof -

WORKDIR $PETSC_DIR

# # # Configure and build PETSc 

RUN echo "\n=== Configuring without batch mode\n"

RUN ./configure --with-cc=gcc --with-cxx=g++ --with-fc=gfortran --download-fblaslapack --download-mpich &&\
    make all && \
    make test




# # # Download and extract SLEPc.
WORKDIR /opt
RUN wget --no-verbose http://www.grycap.upv.es/slepc/download/distrib/slepc-$SLEPC_VERSION.tar.gz
RUN gunzip -c slepc-$SLEPC_VERSION.tar.gz | tar -xof -



WORKDIR $SLEPC_DIR



# # # Configure and build SLEPc.
RUN ./configure && \
    make all && \
    make test

# # remove .tar.gz
WORKDIR /opt
RUN rm *.tar.gz



# # Add the newly compiled libraries to the environment.
ENV LD_LIBRARY_PATH $PETSC_DIR/$PETSC_ARCH/lib:$SLEPC_DIR/$PETSC_ARCH/lib
ENV PKG_CONFIG_PATH $PETSC_DIR/$PETSC_ARCH/lib/pkgconfig:$SLEPC_DIR/$PETSC_ARCH/lib/pkgconfig



# # # clean temp data
RUN sudo apt-get clean && \
    apt-get purge && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


VOLUME $PETSC_DIR

WORKDIR /home



# # Update APT
RUN apt-get update -yq --fix-missing && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends ca-certificates && \
    apt-key update


# # Set up environment variables
ENV LOCAL_DIR $HOME/.local
ENV BIN_DIR $HOME/.local/bin
ENV SRC_DIR $HOME/src
ENV PETSCHS_DIR $SRC_DIR/petsc-hs


ENV PATH $BIN_DIR:$PATH

ENV PETSC_INCLUDE1 $PETSC_DIR/include/
ENV PETSC_INCLUDE2 $PETSC_DIR/$PETSC_ARCH/include/
ENV PETSC_LIB $PETSC_DIR/$PETSC_ARCH/lib/


# # NB : assumes SLEPC_ARCH is defined
ENV SLEPC_INCLUDE1 $SLEPC_DIR/include/
ENV SLEPC_INCLUDE2 $SLEPC_DIR/$SLEPC_ARCH/include/
ENV SLEPC_LIB $SLEPC_DIR/$SLEPC_ARCH/lib/


# # Create directories
RUN mkdir -p $LOCAL_DIR
RUN mkdir -p $BIN_DIR
RUN mkdir -p $SRC_DIR

# # print PETSc/SLEPc env variables to stdout:
RUN echo $PETSC_DIR 
RUN echo $PETSC_ARCH 
RUN echo $SLEPC_DIR 
RUN echo $SLEPC_ARCH 
RUN echo $PETSC_LIB 
RUN echo $SLEPC_LIB 
RUN echo $LD_LIBRARY_PATH 
RUN echo $PKG_CONFIG_PATH
RUN printenv | grep bin




# # Get `stack`
WORKDIR $BIN_DIR

RUN curl -L https://www.stackage.org/stack/linux-x86_64 | tar xz --wildcards --strip-components=1 -C $BIN_DIR '*/stack'

# # Add `stack` path
ENV PATH $(stack --stack-yaml stack.yaml path --local-install-root):$PATH

ENV DIST_DIR $(stack path --dist-dir)/build

ENV PATH $PETSC_DIR/$PETSC_ARCH/bin/:$PATH









WORKDIR $SRC_DIR


# # retrieve petsc-hs repository
RUN git clone https://github.com/ocramz/petsc-hs.git

WORKDIR $PETSCHS_DIR

# # setup + first build of petsc-hs
RUN stack setup 
RUN ./stack-build.sh "--dependencies-only" "$PETSC_DIR" "$PETSC_ARCH" "$SLEPC_DIR" "$SLEPC_ARCH"


# # install c2hs
RUN stack install c2hs

# # # where is runhaskell?
# RUN find ${HOME} -name runhaskell








WORKDIR $SRC_DIR

# # delete PETSc-hs sources and build artifacts (dependencies are compiled in /.stack/ and safe)
RUN rm -rf petsc-hs/

# # copy update script (NB: hardcoded dir `/src`)
ADD update-petsc-hs.sh /src/

# # <===== NB : starting point to fetch and build `petsc-hs` from the github repo














# # # clean temp data
RUN sudo apt-get clean && apt-get purge && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*