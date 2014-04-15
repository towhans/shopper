Shopper
=======

Shopper is a perl script that finds deals at Tesco on-line shopping site.

## Example output


```
category            savings cost  net   quantity url                                                                                                                                                   
=====================================================================================
pytle               310     190   163%  500ks    http://lidl.cz/pytel
-------------------------------------------------------------------------------------
sirup_hello         220     340   64%   10l      http://nakup.itesco.cz/2001019586583 
                                                 http://nakup.itesco.cz/2001019115349 
                                                 http://nakup.itesco.cz/2001019586538 
                                                 http://nakup.itesco.cz/2001019115325 
                                                 http://nakup.itesco.cz/2001019115301 
                                                 http://nakup.itesco.cz/2001019115295
-------------------------------------------------------------------------------------
jar                 100.5   174.5 57%   5l       http://nakup.itesco.cz/2001016221661 
                                                 http://nakup.itesco.cz/2001017890583 
                                                 http://nakup.itesco.cz/2001016553564 
                                                 http://nakup.itesco.cz/2001014858784 
                                                 http://nakup.itesco.cz/2001019265044 
                                                 http://nakup.itesco.cz/2001014858562
-------------------------------------------------------------------------------------
toaletak            176     272   64%   64ks     http://globus.cz/toaletak
-------------------------------------------------------------------------------------
```

## Try

```
# clone repo
git clone https://github.com/towhans/shopper.git
cd shopper

# install dependencies
sudo cpan Furl
sudo cpan Data::Dumper
sudo cpan DateTime
sudo cpan File::Slurp
sudo cpan Digest::MurmurHash
sudo cpan File::Path

# run
./shopper.pl
```
