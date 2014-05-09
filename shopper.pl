#!/usr/bin/perl -w


# Examples:
# 
# warn Dumper( productsInSearch('http://nakup.itesco.cz/cs-CZ/Product/BrowseProducts?taxonomyID=Cat00000572&sortBy=Default&pageNo=1') );
# warn Dumper( productsInCategory('Cat00000602') );
# warn Dumper( productsInSearch(searchByQuery('jar')) );
# 
# Rename ./example_list to ./list and edit it


use Furl;
use Data::Dumper;
use DateTime;
use File::Slurp;
use Digest::MurmurHash qw(murmur_hash);
use File::Path qw(make_path);
use JSON::XS;

my $furl = Furl->new(
	agent   => 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/28.0.1500.71 Chrome/28.0.1500.71 Safari/537.36',
	timeout => 10,
);

sub searchByQuery {
	my ($query) = @_;
	return $query if $query =~ /^http:/;
	return "http://nakup.itesco.cz/cs-CZ/Search/List?searchQuery=$query&Hledat=Hledat";
}

sub searchFromCategory {
	my ($category) = @_;
	return "http://nakup.itesco.cz/cs-CZ/Product/BrowseProducts?taxonomyId=$category"
}

sub productsInCategory {
	my ($category) = @_;
	my $search = searchFromCategory($category);
	return productsInSearch($search);
}

sub productsInSearch {
	my ($search) = @_;
	$search =~ s/&pageNo=.//;

	my $continue = 1;
	my $counter = 1;
	my $rules = [];
	while ($continue) {
		my $listing = Fetch($search."&pageNo=$counter");

		my @urls = $listing =~ m|(cs-CZ/ProductDetail/ProductDetail/[^"]*)"|g;
		$continue = undef;
		foreach (@urls) {
			push(@$rules, 'http://nakup.itesco.cz/'.$_);
			$continue = 1;
		}
		$counter++;
	}
	return @$rules;
}


sub upgradeShoppingList {
	my ($list) = @_;
	my $new = {};
	foreach my $entry (@$list) {
		push( @{$new->{$entry->[0]}{product_urls}}, $entry->[1] );
		$new->{$entry->[0]}{common_price} = $entry->[3];
		$new->{$entry->[0]}{common_unit_price} = $entry->[4];
		$new->{$entry->[0]}{max_stock_amount} = $entry->[2];
		$new->{$entry->[0]}{stocks} = 0;
		$new->{$entry->[0]}{ban_urls} = [];
		$new->{$entry->[0]}{product_search} = [];
		$new->{$entry->[0]}{product_category} = [];
	}
	return $new;
}

sub loadShoppingList {
	die "Please specify a shopping list file as first argument.." unless $ARGV[0];
	return JSON::XS::decode_json(read_file($ARGV[0]));
}

sub storeShoppingList {
	my ($list) = @_;
	write_file("./list", JSON::XS->new->pretty(1)->encode($list));
}

my $shopping_list = loadShoppingList();

my $prices = {};


# find products and get their prices
foreach my $item (keys %$shopping_list) {
	print "Fetching prices for $item ...\n";
	my $ban = {};
	map {$ban->{$_} = undef} @{$shopping_list->{$item}{ban_urls}};

	my $found_urls = [];
	foreach my $query (@{$shopping_list->{$item}{product_search}}) {
		push(@$found_urls, productsInSearch(searchByQuery($query)));
	}

	foreach my $category (@{$shopping_list->{$item}{product_category}}) {
		push(@$found_urls, productsInCategory($category));
	}

	foreach my $url (@{$shopping_list->{$item}{product_urls}}, @$found_urls) {
		next if exists $ban->{$url};
		my ($price, $itemPrice, $itemUnit, $drop, $original) = GetPrice($url);
		$prices->{$item}{tmp_urls}{$url}{price} = $price;
		$prices->{$item}{tmp_urls}{$url}{itemPrice} = $itemPrice;
		$prices->{$item}{tmp_urls}{$url}{unit} = $itemUnit;
		$prices->{$item}{tmp_urls}{$url}{drop} = $drop;
		$prices->{$item}{tmp_urls}{$url}{original} = $original;
	}
}

# analyze prices - separately for each shopping strategy
my $bestDeal = {};

foreach my $item (keys %$shopping_list) {
	foreach my $url (keys %{$prices->{$item}{tmp_urls}}) {
		unless ($prices->{$item}{tmp_urls}{$url}{price} or $prices->{$item}{tmp_urls}{$url}{itemPrice}) {
			next;
		}
		next if TooExpensive($shopping_list->{$item}, $prices->{$item}{tmp_urls}{$url});
		my ($deal, $unit_price);
		if ($shopping_list->{$item}{strategy}) {
			print  "Too cheap $item: $url\n" if TooCheap($shopping_list->{$item}, $prices->{$item}{tmp_urls}{$url});
			next if TooCheap($shopping_list->{$item}, $prices->{$item}{tmp_urls}{$url});
			($deal, $unit_price) = Drop($shopping_list->{$item}, $prices->{$item}{tmp_urls}{$url});
		} else {
			 ($deal, $unit_price) = Deal($shopping_list->{$item}, $prices->{$item}{tmp_urls}{$url});
		}

		if (!exists $bestDeal->{$item}) {
			if ($deal > 0) {
				$bestDeal->{$item}{url} = $url;
				$bestDeal->{$item}{deal} = $deal;
				$bestDeal->{$item}{invest} = $shopping_list->{$item}{max_stock_amount} * $unit_price;
				$bestDeal->{$item}{quantity} = $shopping_list->{$item}{max_stock_amount};
				$bestDeal->{$item}{unit} = $prices->{$item}{tmp_urls}{$url}{unit};
			}
		} else {
			if ($deal == $bestDeal->{$item}{deal}) {
				$bestDeal->{$item}{url} .= " ,".$url;
			} else {
				if ($deal > $bestDeal->{$item}{deal}) {

					$bestDeal->{$item}{deal} = $deal;
					$bestDeal->{$item}{url} = $url;
					$bestDeal->{$item}{invest} = $shopping_list->{$item}{max_stock_amount} * $unit_price;
					$bestDeal->{$item}{quantity} = $shopping_list->{$item}{max_stock_amount};
				}
			}
		}
	}
}

#warn Dumper($bestDeal);

my $packstring = "A20xA8xA6xA6xA9xA150";
print "\n";
print pack($packstring, 'category', 'savings', 'cost', 'net', 'quantity', 'url')."\n";
print ('=' x 120);
print "\n";
my $total = 0;
my $total_invest = 0;

foreach (keys %$bestDeal) {
	next unless $shopping_list->{$_}{stocks} - $shopping_list->{$_}{max_stock_amount};
	if ($shopping_list->{$_}{strategy}) {

		my $ratio = int($bestDeal->{$_}{deal} / $bestDeal->{$_}{invest} * 100);
		$total += $bestDeal->{$_}{deal};
		$total_invest += $bestDeal->{$_}{invest};
		print pack("A20xA8xA6xA6xA9", $_, $bestDeal->{$_}{deal}, $bestDeal->{$_}{invest}, "$ratio%", $bestDeal->{$_}{quantity}.$bestDeal->{$_}{unit});

		print join("\n".(' ' x 49), split(/,/, $bestDeal->{$_}{url}))."\n";
		print ('-' x 120);
		print "\n";
	} elsif ($bestDeal->{$_}{deal} > 100) { # absolute saving greater then 100
		my $ratio = int($bestDeal->{$_}{deal} / $bestDeal->{$_}{invest} * 100);
		if ($ratio > 20) { # ROI higher then 20%
			$total += $bestDeal->{$_}{deal};
			$total_invest += $bestDeal->{$_}{invest};
			print pack("A20xA8xA6xA6xA9", $_, $bestDeal->{$_}{deal}, $bestDeal->{$_}{invest}, "$ratio%", $bestDeal->{$_}{quantity}.$bestDeal->{$_}{unit});

			print join("\n".(' ' x 49), split(/,/, $bestDeal->{$_}{url}))."\n";
			print ('-' x 120);
			print "\n";
		}
	}
}
print "\nDate: ".DateTime->now->ymd."\n";
print "Total savings: $total/year\n";
print "Total costs: $total_invest\n";

print "\n";

sub TooCheap {
	my ($item, $price) = @_;
	return undef unless $item->{common_price};
	my $delta = $price->{original}*0.6;
	return $price->{original}  < ($item->{common_price} - $delta);
}

sub TooExpensive {
	my ($item, $price) = @_;
	if (defined $item->{common_price}) { #price
		return $item->{common_price} < $price->{price};
	} elsif (defined $item->{common_unit_price}) { #itemPrice
		return $item->{common_unit_price} < $price->{itemPrice};
	}
}

sub Drop {
	my ($item, $price) = @_;
	if (defined $item->{common_price}) { #price
		return ($price->{drop}, $price->{price});
	} elsif (defined $item->{common_unit_price}) { #itemPrice
		return ($price->{drop}, $price->{itemPrice});
	}
	die "Wrong data:".Dumper($item);
}

sub Deal {
	my ($item, $price) = @_;
	if (defined $item->{common_price}) { #price
		return (($item->{max_stock_amount} - ($item->{stocks} || 0))*($item->{common_price}-$price->{price}), $price->{price});
	} elsif (defined $item->{common_unit_price}) { #itemPrice
		return (($item->{max_stock_amount} - ($item->{stocks} || 0))*($item->{common_unit_price}-$price->{itemPrice}), $price->{itemPrice});
	}
	die "Wrong data:".Dumper($item);
}
	

sub GetPrice {
	my ($url) = @_;
	if ($url eq 'http://lidl.cz/pytel') {
		return (19,0.38, 'ks');
	} elsif ($url =~ /mall\.cz/) {
		my $body = Fetch($url);
		my ($price) = $body =~ /se_price">(.*)\&nbsp;K/;
		return ($price, $price, 'ks');

	} elsif ($url =~ /itesco\.cz/) {

		my $body = Fetch($url);
		my ($pricePerPiece) = $body =~ /\((.*) Kč\/Kus\)/;
		my ($pricePerKilo) = $body =~ /\((.*) Kč\/kg\)/;
		my ($pricePerLiter) = $body =~ /\((.*) Kč\/l\)/;

		my $itemUnit = 'ks';
		$itemUnit = 'l' if $pricePerLiter;
		$itemUnit = 'kg' if $pricePerKilo;
		my $pricePerItem = $pricePerPiece || $pricePerKilo || $pricePerLiter;
		warn "Product not available: $url\n" unless $pricePerItem;

		my ($price) = $body =~ />(\d*),(\d*) Kč<\/span>/;
		$price =~ s/,/\./ if $price;
		$price =~ s/&#160;// if $price;
		$pricePerItem =~ s/,/\./ if $pricePerItem;
		$pricePerItem =~ s/&#160;// if $pricePerItem;

		my ($drop) = $body =~ /-(..)% /;
		$drop = 0 unless $drop;

		my ($original) = $body =~ /cena (.{3,9}) nyn/;
		$original = $original || $price;
		$original =~ s/,/\./ if $original;
		$original =~ s/&#160;// if $original;
		$original += 0;

		return ($price, $pricePerItem, $itemUnit, $drop, $original);
	} elsif ($url eq 'http://globus.cz/toaletak') {
		return (34, 4.25, 'ks');
	}
	die "Unknown URL: $url";

}


sub Fetch {
	my ($url) = @_;
	my $dir = './tmp/'.DateTime->now->ymd;
	my $file = $dir.'/'.murmur_hash($url);
	if (-f $file) {
		return read_file($file);
	}

	my $headers = [];
	if ($url =~ /itesco.cz/) {
		$headers = [
            Cookie  => 'ProductsDisplayMode=grid; pm=1',
            Accept  => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
            'Accept-Language' => 'en-US,en;q=0.8,cs;q=0.6,sk;q=0.4',
            Host    => 'nakup.itesco.cz',

    	];
	}

	my $res = eval { $furl->get( $url, $headers) };
	my $body = $res->body;
	make_path($dir);
	write_file($file, $body);
	return $body;
}


1;

__END__

This Source Code Form is subject to the
terms of the Mozilla Public License, v.
2.0. If a copy of the MPL was not
distributed with this file, You can
obtain one at
http://mozilla.org/MPL/2.0/.
