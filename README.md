Shopper
=======

Shopper is a perl script that finds deals at Tesco on-line shopping site. First
you have to specify a list which is a JSON file. Shopper then goes over the list
and tries to find best deals.

There are two shopping strategies shopper can use.

   * deal
   * best

Deal will try to find the cheapest stuff. Best will try to find the best stuff
under given price. The quality is determined by original price.

When more then one deal is found all the URLs are printed out.

See the list.3dots file for shopping list specification.

## Example output

```
./shopper.pl example_list

category            savings cost  net   quantity url                                                                                                                                                   
================================================================================
pytle               310     190   163%  500ks    http://lidl.cz/pytel
--------------------------------------------------------------------------------
sirup_hello         220     340   64%   10l      http://nakup.itesco.cz/20010195 
                                                 http://nakup.itesco.cz/20010191 
                                                 http://nakup.itesco.cz/20010195 
                                                 http://nakup.itesco.cz/20010191 
                                                 http://nakup.itesco.cz/20010191 
                                                 http://nakup.itesco.cz/20010191
--------------------------------------------------------------------------------
jar                 100.5   174.5 57%   5l       http://nakup.itesco.cz/20010162 
                                                 http://nakup.itesco.cz/20010178 
                                                 http://nakup.itesco.cz/20010165 
                                                 http://nakup.itesco.cz/20010148 
                                                 http://nakup.itesco.cz/20010192 
                                                 http://nakup.itesco.cz/20010148
--------------------------------------------------------------------------------
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
./shopper.pl example_list
```
