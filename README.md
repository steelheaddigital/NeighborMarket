Neighbor Market
===============
Neighbor Market is a free and open source, fully functional Ruby on Rails web application designed to help communities establish their own marketplaces and facilitate the exchange of goods and services between small scale local producers and consumers. Ideal for food hubs, farmer's markets, LETS communities, etc. It works around the idea of an 'order cycle', which can be as short or as long as you like. At the beginning of each cycle, sellers post their items for sale and buyers purchase them throughout the course of the cycle. At the end of the order cycle buyers and sellers meet up at a predefined location and time to complete their transactions. 

Payments are supported either in-person between individuals or through PayPal. One of the major goals of this project in the future is to remove the need for intermedaries such as PayPal (and their fees) to handle payments while removing the hassle that comes along with having to meet in person to complete cash transactions. To this end we are actively exploring alternative payment protocols such as Bitcoin, [Stellar](http://stellar.org), and [Ripple](https://ripple.com). We are also working on the possibility of facilitating deliveries.

Other features include a rating and review system that can be enabled by the site manager, theme support using [Bootstrap](http://getbootstrap.com/), Mobile optimized also thanks to Bootstrap, reporting features for both the site manager and sellers, and easy installation using the included Vagrant and Puppet scripts.

We have been using the software for a local marketplace in Portland, OR for the past year or so. You can check out the site in action at https://cully.neighbormarket.net

Install
=======

Development Environment
-----------------------
The easiest way to get up and running is to use the included Vagrant and Puppet scripts. To get started, download and install [Virtual Box](https://www.virtualbox.org/wiki/Downloads) and [Vagrant](https://www.vagrantup.com/) and then follow the steps below.

1. Clone the repository to your local machine

		git clone --recursive https://github.com/steelheaddigital/NeighborMarket.git
		cd neighbormarket

2. Add the below line to your hosts file, /etc/hosts on Mac and Linux
	
		192.168.11.3 development.neighbormarket.local
	
	On OSX, flush the DNS cache to make sure the changes take effect. In OSX Yosemite, the command is

		sudo discoveryutil mdnsflushcache;sudo discoveryutil udnsflushcaches;

	In Linux, restart the networking services

		/etc/init.d/networking restart

3. Create the VM and install all of the dependencies. This can take quite a while, so be patient.

		vagrant up development

4. Log in to your new VM.

		vagrant ssh development
		cd /vagrant

5. Set up the rails application

		bundle install
		rake db:test:prepare
		rake db:schema:load
		foreman run rake db:seed

6. Create your .env file

		cp development.env .env

7. Run the tests to make sure everything is set up correctly
	
		rake test

8. start up the application

		foreman start

9. navigate to http://development.neighbormarket.local in browser. You can log in with the default manager account, username: manager, password: Abc123!

Deploy a Live Site
--------------------
Scripts are also included for creating a VM on [Digital Ocean](https://digitalocean.com) and deploying the application there. The $5/month 512 MB VM from Digital Ocean is more than enough to run a small instance of Neighbor Market. To get started, you'll need to have a Digital Ocean account, your own domain, and an SSL certificate for that domain.

1. If you haven't already, download and install [Virtual Box](https://www.virtualbox.org/wiki/Downloads) and [Vagrant](https://www.vagrantup.com/).

2. Clone the repository

		git clone --recursive https://github.com/steelheaddigital/NeighborMarket.git
		cd neighbormarket

3. Install the vagrant digital ocean plugin

		vagrant plugin install vagrant-digitalocean

4. Add the Digital Ocean vagrant box

		vagrant box add digital_ocean https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box'

5. Create an SSH key pair for 'neighbormarket'. The name of the key should be 'neighbormarket'. Good instruction for doing this can be found [here](https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys--2).

6. Copy the public key created above to (neighbormarket.pub) to puppet/modules/neighbormarket/files

7. Edit line 112 of the Vagrantfile with the value for your domain.  If you stored the ssh keys created above in a location other than '~/.ssh/', then also edit the values in line 116 and 122 to match that location.

8. Add your Digital Ocean API token to line 119 in Vagrantfile.

9. In /puppet/manifest/site.pp, change the name of the last node from 'production.mysite.com' to your domain name. IMPORTANT: also change the db_password line here to your desired database password, something long and secure.

10. By default, the site will have SSL enabled in production. Put your SSL .crt and .key files under /puppet/modules/neighbormarket/files/certs. These will be automatically deployed and everything setup for SSL. It is highly reccommended that you use SSL in production, but if you really don't want to, then disable it in config/environments/production.rb by setting config.force_ssl to false.

11. OK, time to create the VM on Digital Ocean

		vagrant up production --provider=digital_ocean

	This will take quite a while, so be patient.  Make a note of the IP address that Vagrant prints on the screen for the new VM, we will need this later.  Sometimes the Rsync commands time out, especially on the first try since it's a lot to upload. Also, occasionally it will also hang when installing Ruby. If the Ruby installation step is taking longer than 20 minutes or so, simply stop the installation with Ctrl + C, and then restart the provisioning process. You can restart the provisioning process with:

		vagrant provision production

12. Set up your DNS entries to point your domain to the IP address you obtained in the step above. How you do this depends on where you registered your domain. Check with your domain registrar.

13. Now to deploy the app with Capistrano.  First, change the host_name parameter at the top of capistrano/config/deploy/production.rb to your domain.

14. And finally, deploy the application

		cd capistrano
		cap production deploy

15. Seed the database

		cap production deploy:seed

16. You should now have the site up and running! You can log in with the default manager account, username: manager, password: Abc123!. Obviously, you should change the password as soon as possible.

Contributing
------------
Pull requests are more than welcome.

Fork and then clone the repo:

	git clone --recursive https://github.com/steelheaddigital/NeighborMarket.git

Follow the steps above to set up your development environment, making sure the tests pass

	rake test

Make your change, add tests for it, and make sure the tests pass

	rake test

Push to your fork and [submit a pull request](https://help.github.com/articles/using-pull-requests/)








