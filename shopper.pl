#!/usr/bin/perl -w

# Zajimave funkce
#
# 1/ vyber pastu v rozmezi <25, 40> , poradi urci podle vyse slevy (preferuj vyssi slevy = puvodne drazsi zbozi). Az potom to vynasob a zjisti, kolik bych usetril.
#     - tohle umozni nasazet tam vsechny pasty, ne jen ty, co chci
# 2/ prace s kategoriema - misto zadavani vsech moznych url si url zjistim vyhledavanim a prolezu si vsechny URL. Toto vyuzije use case 1.


use Furl;
use Data::Dumper;
use DateTime;
use File::Slurp;
use Digest::MurmurHash qw(murmur_hash);
use File::Path qw(make_path);

my $furl = Furl->new(
	agent   => 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/28.0.1500.71 Chrome/28.0.1500.71 Safari/537.36',
	timeout => 10,
);

#my $listing = Fetch('http://nakup.itesco.cz/cs-CZ/Product/BrowseProducts?taxonomyID=Cat00000572&pageNo=1&sortBy=Default');
#my @urls = $listing =~ m|(cs-CZ/ProductDetail/ProductDetail/[^"]*)"|g;
#my $rules = [];
#foreach (@urls) {
#	push(@$rules, ['jar', 'http://nakup.itesco.cz/'.$_, 3, undef, 55]);
#}
#local $Data::Dumper::Terse = 1;
#local $Data::Dumper::Indent = 0;
#local $Data::Dumper::Useqq = 1;
#local $Data::Dumper::Deparse = 1;
#local $Data::Dumper::Quotekeys = 0;
#local $Data::Dumper::Sortkeys = 1;
#my $tmp_str = Dumper($rules);
#$tmp_str =~ s/\],\[/\],\n\[/g;
#warn $tmp_str;
#exit;

my $shopping_list = [
	#  kategorie, url, kolik_ma_smysl_nakoupit_dopredu, bezna_cena, bezna_cena_za_kus
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120009655",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120073554",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120560473",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120073577",5,undef,55],
#	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120817608",5,undef,55],
#	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120817620",5,undef,55],
#	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120817614",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001018305956",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001018305963",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001017684465",5,undef,55],
#	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001017400041",5,undef,55],
#	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001017400065",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120689396",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120689385",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120689407",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120689413",5,undef,55],

	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120560640",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001016188193",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001016221661",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001016221821",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001017890637",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001017890583",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001017890569",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001017285167",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001016553564",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120711589",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001016553595",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120374739",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120009805",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120009413",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120009747",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120009765",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120009753",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120009816",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120008645",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120009839",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120009661",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120009776",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120785132",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120376772",5,undef,55],

	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001019263224",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001019263293",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001016188070",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001014858784",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120711566",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001014860169",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120001053",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120001076",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120711595",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120329685",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120329702",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120001047",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120711572",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120001065",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001019265075",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001019265044",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001019265099",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001016188063",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001014858562",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001014859804",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120560634",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120560657",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120560628",5,undef,55],
	["jar","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120711606",5,undef,55],

	["caro","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001009635376",0.6,undef,460],
	["caro","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001019246968",0.6,undef,460],
	["caro","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120011145",0.6,undef,460],

	["filtr_bazen","http://www.mall.cz/prislusenstvi-bazeny/marimex-filtracna-kartus-nahradna-",3,300,undef],

	["mycka","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120008950",192,undef,7],
	["mycka","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120560663",192,undef,7],
	["mycka","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120560675",192,undef,7],
	["mycka","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120708692",192,undef,7],
	["mycka","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120708703",192,undef,7],
	["mycka","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120009275",192,undef,7],
	["mycka","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001018921644",192,undef,7],
	["mycka","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001018921651",192,undef,7],
	["mycka","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120009309",192,undef,7],
	["mycka","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120009321",192,undef,7],
#	["mycka","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120243526",192,undef,7],
	["mycka","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120243549",192,undef,7],
#	["mycka","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120243475",192,undef,7],
	["mycka","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120008985",192,undef,7],
	["mycka","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120009004",192,undef,7],
	["mycka","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120008996",192,undef,7],
	["mycka","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120009056",192,undef,7],
	["mycka","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001017894024",192,undef,7],
	["mycka","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001017894031",192,undef,7],
	["mycka","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120560692",192,undef,7],
	["mycka","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120560686",192,undef,7],
	["mycka","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120816840",192,undef,7],
	["mycka","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120816834",192,undef,7],
	["mycka","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120243555",192,undef,7],
	["mycka","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120560559",192,undef,7],
	["mycka","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120560507",192,undef,7],
	["mycka","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120560513",192,undef,7],
	["mycka","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120560565",192,undef,7],
	["mycka","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120560525",192,undef,7],
	["mycka","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120560536",192,undef,7],
	["mycka","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120560542",192,undef,7],
	["mycka","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120560605",192,undef,7],
	["mycka","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120560611",192,undef,7],
	["mycka","http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120243561",192,undef,7],

	[ 'kapsle', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120597389', 200, undef, 7 ],
	[ 'kapsle', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120597251', 200, undef, 7 ],
	[ 'kapsle', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120608165', 200, undef, 7 ],
	[ 'kapsle', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120608171', 200, undef, 7 ],
	[ 'kapsle', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120608159', 200, undef, 7 ],
	[ 'kapsle', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120597337', 200, undef, 7 ],
	[ 'kapsle', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120597268', 200, undef, 7 ],
	[ 'kapsle', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120597297', 200, undef, 7 ],

	[ 'mleko', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001019361395', 50, 20, undef ],
	[ 'mleko', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001018131135', 50, 20, undef ],
	[ 'mleko', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001019499326', 50, 20, undef ],
	[ 'mleko', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001012354899', 50, 20, undef ],

	[ 'toaletak', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120094310', 64, undef, 7 ],
	[ 'toaletak', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120297675', 64, undef, 7 ],
	[ 'toaletak', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001018724634', 64, undef, 7 ],
	[ 'toaletak', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120518922', 64, undef, 7 ],
	[ 'toaletak', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001018797904', 64, undef, 7 ],
	[ 'toaletak', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001010522085', 64, undef, 7 ],
	[ 'toaletak', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001019005671', 64, undef, 7 ],
	[ 'toaletak', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120702312', 64, undef, 7 ],
	[ 'toaletak', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001019234705', 64, undef, 7 ],
	[ 'toaletak', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001019402807', 64, undef, 7 ],
	[ 'toaletak', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001019404160', 64, undef, 7 ],
	[ 'toaletak', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001019027499', 64, undef, 7 ],
	[ 'toaletak', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120052118', 64, undef, 7 ],
	[ 'toaletak', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001019628412', 64, undef, 7 ],
	[ 'toaletak', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001018104191', 64, undef, 7 ],
	[ 'toaletak', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001019575877', 64, undef, 7 ],
	[ 'toaletak', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001018104146', 64, undef, 7 ],
	[ 'toaletak', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001019395871', 64, undef, 7 ],
	[ 'toaletak', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001015730591', 64, undef, 7 ],
	[ 'toaletak', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001018104184', 64, undef, 7 ],
	[ 'toaletak', 'http://globus.cz/toaletak', 64, undef, 7 ],

	[ 'veprova', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001018361563', 4, 120, undef ],

	[ 'kure', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120570893', 4, 120, undef ],
	[ 'kure', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001012124188', 4, 120, undef ],

	[ 'musli', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001019062162', 4, 79, undef ],

	[ 'nutella', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001000004942', 4, 52, undef ],
	[ 'nutella', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001013548587', 4, 52, undef ],

	[ 'ryze', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001000094592', 5, 37, undef ],
	[ 'ryze', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001016807834', 5, 37, undef ],
	[ 'ryze', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001018707620', 5, 37, undef ],
	[ 'ryze', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001000103850', 5, 37, undef ],

	[ 'kukurice', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001000092499', 10, 21, undef ],
	[ 'kukurice', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001018442033', 10, 21, undef ],

	[ 'hrach', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001000092406', 10, 17, undef ],
	[ 'hrach', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001019347160', 10, 17, undef ],

	[ 'olej_slunecnice', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001017307043', 5, 69, undef ],
	[ 'olej_slunecnice', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001019037740', 5, 69, undef ],
	[ 'olej_slunecnice', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120034647', 5, 69, undef ],
	[ 'olej_slunecnice', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001019260193', 5, 69, undef ],


	[ 'olej_oliva', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001017346172', 10, 183, undef ],
	[ 'olej_oliva', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120034958', 10, 183, undef ],
	[ 'olej_oliva', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120601368', 10, 183, undef ],
	[ 'olej_oliva', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120036599', 10, 183, undef ],
	[ 'olej_oliva', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120479996', 10, 183, undef ],

	[ 'pytle', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001010947710', 500, undef, 1 ],
	[ 'pytle', 'http://lidl.cz/pytel', 500, undef, 1 ],

	[ 'pasta', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001011496286', 10, 29, undef ],

	[ 'bref', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001015598795', 10, 50, undef ],

	# sirup
	[ 'sirup', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120520055', 10, 49, undef ],
	[ 'sirup', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120522916', 10, 49, undef ],
	[ 'sirup', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120275782', 10, 49, undef ],
	[ 'sirup', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120048700', 10, 49, undef ],
	[ 'sirup', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120275765', 10, 49, undef ],
	[ 'sirup', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120048735', 10, 49, undef ],
	[ 'sirup', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120048717', 10, 49, undef ],

	[ 'sirup_jupi', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001012299664', 10, 34, undef ],
	[ 'sirup_jupi', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001012299664', 10, 34, undef ],
	[ 'sirup_jupi', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001012299824', 10, 34, undef ],
	[ 'sirup_jupi', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001012299879', 10, 34, undef ],
	[ 'sirup_jupi', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001012299725', 10, 34, undef ],

	[ 'sirup_yo', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001014615424', 10, 71, undef ],

	[ 'sirup_hello', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001019115363', 10, 56, undef ],
	[ 'sirup_hello', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001019586583', 10, 56, undef ],
	[ 'sirup_hello', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001019115349', 10, 56, undef ],
	[ 'sirup_hello', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001019586538', 10, 56, undef ],
	[ 'sirup_hello', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001019115325', 10, 56, undef ],
	[ 'sirup_hello', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001019115301', 10, 56, undef ],
	[ 'sirup_hello', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001019115295', 10, 56, undef ],

	[ 'sirup_relax', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120507601', 10, 59, undef ],
	[ 'sirup_relax', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120507590', 10, 59, undef ],
	[ 'sirup_relax', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120736266', 10, 59, undef ],
	[ 'sirup_relax', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120061418', 10, 59, undef ],
	[ 'sirup_relax', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120061430', 10, 59, undef ],

	[ 'sirup_kubik', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120507584', 10, 69, undef ],
	[ 'sirup_kubik', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120507578', 10, 69, undef ],
	
	# mrazene sisky s makem

	# pizza

	# mrazene kukurice

	# protlak 2 x 70 nikdy neudela slevu vetsi nez 100 takze protlak nema smysl kupovat
	[ 'protlak', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001018783907', 2, undef, 71 ],
	[ 'protlak', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120001410', 2, undef, 71 ],
	[ 'protlak', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001005127813', 2, undef, 71 ],
	[ 'protlak', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001011634282', 2, undef, 71 ],
	[ 'protlak', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120503185', 2, undef, 71 ],

	# maslo
	[ 'maslo', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001018209377', 1, undef, 183 ],
	[ 'maslo', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001019268984', 1, undef, 183 ],
	[ 'maslo', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001019333552', 1, undef, 183 ],
	[ 'maslo', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001000129478', 1, undef, 183 ],

	# avivaz
	[ 'avivaz', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120625616', 5, undef, 60 ],
	[ 'avivaz', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120030185', 5, undef, 60 ],
	[ 'avivaz', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120030093', 5, undef, 60 ],
	[ 'avivaz', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120030248', 5, undef, 60 ],
	[ 'avivaz', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120030145', 5, undef, 60 ],
	[ 'avivaz', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001019267406', 5, undef, 60 ],
	[ 'avivaz', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001019267413', 5, undef, 60 ],
	[ 'avivaz', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120030156', 5, undef, 60 ],
	[ 'avivaz', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120030070', 5, undef, 60 ],
	[ 'avivaz', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120625605', 5, undef, 60 ],
	[ 'avivaz', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120709777', 5, undef, 60 ],
	[ 'avivaz', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120625576', 5, undef, 60 ],
	[ 'avivaz', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001018807603', 5, undef, 60 ],
	[ 'avivaz', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001019529221', 5, undef, 60 ],
	[ 'avivaz', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001018807559', 5, undef, 60 ],
	[ 'avivaz', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001019468001', 5, undef, 60 ],
	[ 'avivaz', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001019468049', 5, undef, 60 ],
	[ 'avivaz', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120030254', 5, undef, 60 ],
	[ 'avivaz', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120709760', 5, undef, 60 ],
	[ 'avivaz', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001017720767', 5, undef, 60 ],
	[ 'avivaz', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001013302806', 5, undef, 60 ],
	[ 'avivaz', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001019435676', 5, undef, 60 ],
	[ 'avivaz', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001015443590', 5, undef, 60 ],
	[ 'avivaz', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001013302790', 5, undef, 60 ],
	[ 'avivaz', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001019435690', 5, undef, 60 ],
	[ 'avivaz', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001015443613', 5, undef, 60 ],
	[ 'avivaz', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120625547', 5, undef, 60 ],

	# kartacek
	[ 'curaprox', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001019130199', 6, undef, 85 ],
	[ 'curaprox', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001120001957', 6, undef, 85 ],
	[ 'curaprox', 'http://nakup.itesco.cz/cs-CZ/ProductDetail/ProductDetail/2001019130205', 6, undef, 85 ],

	# mydla a sampony

	# pasta

	# kafe

	# caj

	# vino

];


my $stocks = {
	'mycka'           => 230,
    'olej_slunecnice' => 5,
    'pasta'           => 0,
    'mleko'           => 0,
    'sirup_relax'     => 0,
    'bref'            => 10,
    'olej_oliva'      => 0,
    'nutella'         => 0,
    'sirup'           => 0,  
    'ryze'            => 0,
    'veprova'         => 0,
    'sirup_kubik'     => 0,
    'kapsle'          => 192,
    'hrach'           => 0,
    'pytle'           => 0,
    'musli'           => 0,
    'kukurice'        => 0,
    'sirup_hello'     => 0,
    'kure'            => 0,
    'sirup_yo'        => 0,
    'sirup_jupi'      => 0,
    'toaletak'        => 0,
	'pasta'           => 0,
};

my $prices = [];
my $counter = 0;


foreach my $item (@$shopping_list) {
	my ($price, $itemPrice, $itemUnit) = GetPrice($item->[1]);
	$prices->[$counter][0] = $price;
	$prices->[$counter][1] = $itemPrice;
	$prices->[$counter][2] = $itemUnit;
	$counter++;
}

$counter = 0;
my $bestDeal = {};
foreach my $item (@$shopping_list) {
	unless ($prices->[$counter][0] or $prices->[$counter][1]) {
		$counter++;
		next;
	}
	my ($deal, $unit_price) = Deal($item, $prices->[$counter]);
	if (!exists $bestDeal->{$item->[0]}) {
		$bestDeal->{$item->[0]}{url} = $item->[1];
		$bestDeal->{$item->[0]}{deal} = $deal;
		$bestDeal->{$item->[0]}{invest} = $item->[2] * $unit_price;
		$bestDeal->{$item->[0]}{quantity} = $item->[2];
		$bestDeal->{$item->[0]}{unit} = $prices->[$counter][2];
	} else {
		if ($deal > $bestDeal->{$item->[0]}{deal}) {
			$bestDeal->{$item->[0]}{deal} = $deal;
			$bestDeal->{$item->[0]}{url} = $item->[1];
			$bestDeal->{$item->[0]}{invest} = $item->[2] * $unit_price;
			$bestDeal->{$item->[0]}{quantity} = $item->[2];
		} elsif ($deal == $bestDeal->{$item->[0]}{deal}) {
			$bestDeal->{$item->[0]}{url} .= " ,".$item->[1];
		}
	}
	$counter++;
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
	if ($bestDeal->{$_}{deal} > 100) { # absolute saving greater then 100
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

sub Deal {
	my ($item, $price) = @_;

	if (defined $item->[3]) { #price
		return (($item->[2] - ($stocks->{$item->[0]} || 0))*($item->[3]-$price->[0]), $price->[0]);
	} elsif (defined $item->[4]) { #itemPrice
		return (($item->[2] - ($stocks->{$item->[0]} || 0))*($item->[4]-$price->[1]), $price->[1]);
	}
	die "Wrong data for $item->[1]";
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
		$pricePerItem =~ s/,/\./ if $pricePerItem;

		return ($price, $pricePerItem, $itemUnit);
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
