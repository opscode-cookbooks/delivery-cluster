name 'delivery-cluster'
maintainer 'Chef Delivery Team'
maintainer_email 'delivery-team@chef.io'
license 'Apache 2.0'
description 'Deployment cookbook for standing up Delivery Clusters'
long_description 'Installs Chef Delivery, a solution for continuously ' \
                 'delivering applications and infrastructure safely at speed'

version '0.6.2'

depends 'chef-server-12'
depends 'chef-ingredient', '= 0.16.0'
depends 'git'
depends 'apt'
depends 'yum'
depends 'delivery_build'
depends 'chef-splunk'
