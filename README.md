# compute-cluster-sandbox
A sandbox for experimenting with cluster computing

Travis CI: [![Build Status](https://travis-ci.org/ocramz/compute-cluster-sandbox.svg?branch=master)](https://travis-ci.org/ocramz/compute-cluster-sandbox)




## Components

compute-node: [![Build Status](https://travis-ci.org/ocramz/compute-node.svg?branch=master)](https://travis-ci.org/ocramz/compute-node)

compute-master-node: [![Build Status](https://travis-ci.org/ocramz/compute-master-node.svg?branch=master)](https://travis-ci.org/ocramz/compute-master-node)

compute-ca: [![Build Status](https://travis-ci.org/ocramz/compute-ca.svg?branch=master)](https://travis-ci.org/ocramz/compute-ca)

compute-kvs: [![Build Status](https://travis-ci.org/ocramz/compute-kvs.svg?branch=master)](https://travis-ci.org/ocramz/compute-kvs)



## Container hierarchy and cluster design notes

The arrows indicate dependency:

* `compute-node` -> `compute-master-node` -> `docker-phusion-supervisor`

* `compute-ca` -> `docker-phusion-supervisor`

* `compute-kvs` -> `docker-phusion-supervisor`

The images inherit from an Ubuntu-based image which contains `supervisord` and `consul-template`. These tools allow to manage system processes and rewrite configuration files if/when the cluster changes (the dynamic reconfiguration ideas were stolen from Christian 'qnib' https://www.github.com/ChristianKniep . Thanks Christian!).

`compute-node` contains GCC, GFortran, Python, Perl and a few other build tools.

`compute-ca` (Certificate Authority) generates TLS key pairs and distributes them to the nodes that belong to the cluster.

`compute-kvs` (Key-Value Store) contains Consul which dynamically manages the cluster information (member nodes, DNS information etc.). All networked processes in the cluster should report back to it.


## Base image

The base image is `docker-phusion-supervisor` :

* `docker-phusion-supervisor` -> `phusion/baseimage` (https://phusion.github.io/baseimage-docker/)

