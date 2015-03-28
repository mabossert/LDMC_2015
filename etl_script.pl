#!/usr/bin/env perl

use strict;
use warnings;
use 5.020;
use Carp qw(cluck carp croak);
use Data::Dumper;
use Mojo::UserAgent;
use Mojo::Util qw(html_unescape quote url_escape);
use Text::CSV_XS;

my $rootDir = '/tempssd/bossert/LDMC_movies/';
my $rawDir = $rootDir.'raw/';
my $outDir = $rootDir.'triples/';

#=+ Create our useragent object
my $ua = Mojo::UserAgent->new;

my %disambiguations = ( "<http://dbpedia.org/resource/21_and_Over_(film)>" =>	"<http://dbpedia.org/resource/21_&_Over_(film)>",
                        "<http://dbpedia.org/resource/Aftershock_(2013_film)>" =>	"<http://dbpedia.org/resource/Aftershock_(2012_film)>",
                        "<http://dbpedia.org/resource/Alice_et_Martin>" =>	"<http://dbpedia.org/resource/Alice_and_Martin_(1998_film)>",
                        "<http://dbpedia.org/resource/Alien_Resurrection>" =>	"<http://dbpedia.org/resource/Alien:_Resurrection>",
                        "<http://dbpedia.org/resource/All_the_Right_Moves>" =>	"<http://dbpedia.org/resource/All_the_Right_Moves_(film)>",
                        "<http://dbpedia.org/resource/As_Cool_As_I_Am_(film)>" =>	"<http://dbpedia.org/resource/As_Cool_as_I_Am_(film)>",
                        "<http://dbpedia.org/resource/As_Luck_Would_Have_It>" =>	"<http://dbpedia.org/resource/As_Luck_Would_Have_It_(2012_film)>",
                        "<http://dbpedia.org/resource/Bad_Education>" =>	"<http://dbpedia.org/resource/Bad_Education_(film)>",
                        "<http://dbpedia.org/resource/Bandido_(2004._film)>" =>	"<http://dbpedia.org/resource/Bandido_(2004_film)>",
                        "<http://dbpedia.org/resource/Beau_travail>" =>	"<http://dbpedia.org/resource/Beau_Travail>",
                        "<http://dbpedia.org/resource/Being_Human_(film)>" =>	"<http://dbpedia.org/resource/Being_Human_(1994_film)>",
                        "<http://dbpedia.org/resource/Body_Shots>" =>	"<http://dbpedia.org/resource/Body_Shots_(film)>",
                        "<http://dbpedia.org/resource/Branded_(film)>" =>	"<http://dbpedia.org/resource/Branded_(2012_film)>",
                        "<http://dbpedia.org/resource/Dazed_and_Confused>" =>	"<http://dbpedia.org/resource/Dazed_and_Confused_(film)>",
                        "<http://dbpedia.org/resource/Enough>" =>	"<http://dbpedia.org/resource/Enough_(film)>",
                        "<http://dbpedia.org/resource/Frailty>" =>	"<http://dbpedia.org/resource/Frailty_(film)>",
                        "<http://dbpedia.org/resource/Gods_and_Monsters>" =>	"<http://dbpedia.org/resource/Gods_and_Monsters_(film)>",
                        "<http://dbpedia.org/resource/Good_Hair>" =>	"<http://dbpedia.org/resource/Good_Hair_(film)>",
                        "<http://dbpedia.org/resource/Hansel_and_Gretel:_Witch_Hunters>" =>	"<http://dbpedia.org/resource/Hansel_&_Gretel:_Witch_Hunters>",
                        "<http://dbpedia.org/resource/Horns_and_Halos>" =>	"<http://dbpedia.org/resource/Horns_and_Halos_(film)>",
                        "<http://dbpedia.org/resource/I_Will_Follow_You_Into_the_Dark_(film)>" =>	"<http://dbpedia.org/resource/Into_the_Dark_(film)>",
                        "<http://dbpedia.org/resource/In_the_Name_of_the_King:_A_Dungeon_Siege_Tale>" =>	"<http://dbpedia.org/resource/In_the_Name_of_the_King>",
                        "<http://dbpedia.org/resource/In_the_Shadow_of_the_Moon>" =>	"<http://dbpedia.org/resource/In_the_Shadow_of_the_Moon_(film)>",
                        "<http://dbpedia.org/resource/JCVD>" =>	"<http://dbpedia.org/resource/JCVD_(film)>",
                        "<http://dbpedia.org/resource/Jolene_(2008_film)>" =>	"<http://dbpedia.org/resource/Jolene_(film)>",
                        "<http://dbpedia.org/resource/King's_Ransom>" =>	"<http://dbpedia.org/resource/King's_Ransom_(film)>",
                        "<http://dbpedia.org/resource/La_promesse>" =>	"<http://dbpedia.org/resource/La_Promesse>",
                        "<http://dbpedia.org/resource/Little_Man_(film)>" =>	"<http://dbpedia.org/resource/Little_Man_(2006_film)>",
                        "<http://dbpedia.org/resource/Lone_Star_(1996_film>" =>	"<http://dbpedia.org:8890/resource/Lone_Star_(1996_film)>",
                        "<http://dbpedia.org/resource/Margin_Call>" =>	"<http://dbpedia.org/resource/Margin_Call_(film)>",
                        "<http://dbpedia.org/resource/Mulan>" =>	"<http://dbpedia.org/resource/Mulan_(1998_film)>",
                        "<http://dbpedia.org/resource/My_Brother_is_an_Only_Child>" =>	"<http://dbpedia.org/resource/My_Brother_Is_an_Only_Child>",
                        "<http://dbpedia.org/resource/National_Security_(film)>" =>	"<http://dbpedia.org/resource/National_Security_(2003_film)>",
                        "<http://dbpedia.org/resource/Oldboy>" =>	"<http://dbpedia.org/resource/Oldboy_(2003_film)>",
                        "<http://dbpedia.org/resource/Percy_Jackson:_Sea_of_Monsters_(film)>" =>	"<http://dbpedia.org/resource/Percy_Jackson:_Sea_of_Monsters>",
                        "<http://dbpedia.org/resource/Playing_for_Keeps_(film)>" =>	"<http://dbpedia.org/resource/Playing_for_Keeps_(2012_film)>",
                        "<http://dbpedia.org/resource/Quiz_Show>" =>	"<http://dbpedia.org/resource/Quiz_Show_(film)>",
                        "<http://dbpedia.org/resource/Shark_Night_3D>" =>	"<http://dbpedia.org/resource/Shark_Night>",
                        "<http://dbpedia.org/resource/Silent_Hill:_Revelation_3D>" =>	"<http://dbpedia.org/resource/Silent_Hill:_Revelation>",
                        "<http://dbpedia.org/resource/Slow_Burn>" =>	"<http://dbpedia.org/resource/Slow_Burn_(2005_film)>",
                        "<http://dbpedia.org/resource/Smiley_(film)>" =>	"<http://dbpedia.org/resource/Smiley_(2012_film)>",
                        "<http://dbpedia.org/resource/Spinning_Into_Butter_(film)>" =>	"<http://dbpedia.org/resource/Spinning_into_Butter_(film)>",
                        "<http://dbpedia.org/resource/Star_Wars_Episode_V:_The_Empire_Strikes_Back>" =>	"<http://dbpedia.org/resource/The_Empire_Strikes_Back>",
                        "<http://dbpedia.org/resource/Stranded_(film)>" =>	"<http://dbpedia.org/resource/Stranded_(2013_film)>",
                        "<http://dbpedia.org/resource/Summer_School_(film)>" =>	"<http://dbpedia.org/resource/Summer_School_(1987_film)>",
                        "<http://dbpedia.org/resource/The_Aryan_Couple_(2004_film)>" =>	"<http://dbpedia.org/resource/The_Aryan_Couple>",
                        "<http://dbpedia.org/resource/The_Cold_Light_of_Day_(film)>" =>	"<http://dbpedia.org/resource/The_Cold_Light_of_Day_(2012_film)>",
                        "<http://dbpedia.org/resource/The_Ex_(2007_film)>" =>	"<http://dbpedia.org/resource/The_Ex_(2006_film)>",
                        "<http://dbpedia.org/resource/The_Goods:_Live_Hard,_Sell_Hard.>" =>	"<http://dbpedia.org/resource/The_Goods:_Live_Hard,_Sell_Hard>",
                        "<http://dbpedia.org/resource/The_House_I_Live_In>" =>	"<http://dbpedia.org/resource/The_House_I_Live_In_(2012_film)>",
                        "<http://dbpedia.org/resource/The_Player>" =>	"<http://dbpedia.org/resource/The_Player_(film)>",
                        "<http://dbpedia.org/resource/The_Samaritan>" =>	"<http://dbpedia.org/resource/Fury_(2012_film)>",
                        "<http://dbpedia.org/resource/The_Story_of_Us>" =>	"<http://dbpedia.org/resource/The_Story_of_Us_(film)>",
                        "<http://dbpedia.org/resource/The_Weather_Underground>" =>	"<http://dbpedia.org/resource/The_Weather_Underground_(film)>",
                        "<http://dbpedia.org/resource/The_Yellow_Handkerchief>" =>	"<http://dbpedia.org/resource/The_Yellow_Handkerchief_(2008_film)>",
                        "<http://dbpedia.org/resource/Thr3e_(film)>" =>	"<http://dbpedia.org/resource/Three_(2006_film)>",
                        "<http://dbpedia.org/resource/To_Die_Like_a_Man>" =>	"<http://dbpedia.org/resource/To_Die_like_a_Man>",
                        "<http://dbpedia.org/resource/Tooth_Fairy_(film)>" =>	"<http://dbpedia.org/resource/Tooth_Fairy_(2010_film)>",
                        "<http://dbpedia.org/resource/Virginia_(film)>" =>	"<http://dbpedia.org/resource/Virginia_(2010_film)>",
                        "<http://dbpedia.org/resource/Wah-Wah>" =>	"<http://dbpedia.org/resource/Wah-Wah_(film)>",
                        "<http://dbpedia.org/resource/We_Are_What_We_Are>" =>	"<http://dbpedia.org/resource/We_Are_What_We_Are_(2013_film)>",
                        "<http://dbpedia.org/resource/What_Goes_Up_(film)>" =>	"<http://dbpedia.org/resource/What_Goes_Up>",
                        "<http://dbpedia.org/resource/Deadgirl_(2008_film)>" =>	"<http://dbpedia.org/resource/Deadgirl>",
                        "<http://dbpedia.org/resource/The_In_Crowd_(film)>" =>	"<http://dbpedia.org/resource/The_In_Crowd_(2000_film)>",
                        "<http://dbpedia.org/resource/Copperhead_(film)>" =>	"<http://dbpedia.org/resource/Copperhead_(2013_film)>",
                        "<http://dbpedia.org/resource/Whatever_It_Takes_(film)>" =>	"<http://dbpedia.org/resource/Whatever_It_Takes_(2000_film)>",
                        "<http://dbpedia.org/resource/The_Glass_House_(film)>" =>	"<http://dbpedia.org/resource/The_Glass_House_(2001_film)>",
                        "<http://dbpedia.org/resource/Deck_the_Halls_(film)>" =>	"<http://dbpedia.org/resource/Deck_the_Halls_(2006_film)>",
                        "<http://dbpedia.org/resource/The_Beastmaster_(film)>" =>	"<http://dbpedia.org/resource/The_Beastmaster>",
                        "<http://dbpedia.org/resource/Diary_of_a_Mad_Black_Woman_(film)>" =>	"<http://dbpedia.org/resource/Diary_of_a_Mad_Black_Woman>",
                        "<http://dbpedia.org/resource/Skinwalkers_(film)>" =>	"<http://dbpedia.org/resource/Skinwalkers_(2006_film)>",
                        "<http://dbpedia.org/resource/See_No_Evil_(film)>" =>	"<http://dbpedia.org/resource/See_No_Evil_(2006_film)>",
                        "<http://dbpedia.org/resource/Summer_School_(film)>" =>	"<http://dbpedia.org/resource/Summer_School_(1987_film)>",
                        "<http://dbpedia.org/resource/Sucker_Punch_(film)>" =>	"<http://dbpedia.org/resource/Sucker_Punch_(2011_film)>",
                        "<http://dbpedia.org/resource/Queen_of_the_Damned_(film)>" =>	"<http://dbpedia.org/resource/Queen_of_the_Damned>",
                        "<http://dbpedia.org/resource/Ghost_Rider_(film)>" =>	"<http://dbpedia.org/resource/Ghost_Rider_(2007_film)>"
                       );

#=+ open training data
open(my $OF, '>', $outDir.'ldmc.nt') or croak "Cannot open output file.";
open(my $trainFile, '<', $rawDir.'train.csv') or croak "Cannot open input file: ".$rawDir.'train.csv';
my $dummy = <$trainFile>;

#=+ Create out csv parser
my $csv = Text::CSV_XS->new({ sep_char => ";",binary => 1});

#=+ iterate over the rows from the training data filehandle
while (my $row = $csv->getline($trainFile)) {
  my @fields = @$row;
  
  #=+ Dbpedia URI
  my $uri = '<'.$fields[2].'>';
  
  #=+ Need to make sure that we incorporate our disambiguations/corrections
  if (exists $disambiguations{$uri}) {
    $uri = $disambiguations{$uri};
  }
  
  
  #=+ Parse the date and convert to a proper xsd:date object
  my $ReleaseDate;
  my $year;
  if ($fields[1] =~ m/(\d{1,2})\/(\d{1,2})\/(\d{2})/) {
    my $y = $3; my $m = $1; my $d = $2;
    my $pre = '20';
    $pre = '19' if $y > 14;
    $year = $pre.$y;
    $ReleaseDate = '"'.sprintf("%02d-%02d-$pre%02d",$m,$d,$y).'"^^<http://www.w3.org/2001/XMLSchema#date>';
  }
  else {
    say Dumper(\@fields);
    last;
  }
  
  #=+ Create the rdfs:label for the movie
  my $label = quote $fields[0];
  
  #=+ Grab the rating
  my $rating = quote $fields[3];
  
  #=+ Grab the id field
  my $id = '"'.$fields[4].'"^^<http://www.w3.org/2001/XMLSchema#float>';
  
  #=+ Grab the OMDB data from the API, example call: http://www.omdbapi.com/?t=We+Are+What+We+Are&y=2013&plot=full&r=json
  $fields[0] =~ s/ /\+/g;
  my $escapedTitle = url_escape $fields[0];
  #my $tx = $ua->get('http://www.omdbapi.com/?t='.$escapedTitle.'&y='.$year.'&plot=full&r=json');
  #if ($tx->success) {
  #  my $json = $tx->res->json;
  #  if ($json->{'Response'} eq 'False') {
  #    say $id.';'.$uri.';'.$label.';'.$year;
  #  }
  #}
  
  say {$OF} $uri.' <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://ldmc.org/ontology/training_data> .';
  say {$OF} $uri.' <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://ldmc.org/ontology/selected_film> .';
  say {$OF} $uri.' <http://ldmc.org/p/label> '.$label.' .';
  say {$OF} $uri.' <http://ldmc.org/p/release_date> '.$ReleaseDate.' .';
  say {$OF} $uri.' <http://ldmc.org/p/rating> '.$rating.' .';
  say {$OF} $uri.' <http://ldmc.org/p/id> '.$id.' .';
  #sleep(1);
}

close($trainFile);

#=+ open testing data
open(my $testFile, '<', $rawDir.'test.csv') or croak "Cannot open input file: ".$rawDir.'test.csv';
$dummy = <$testFile>;

#=+ iterate over the rows from the test data filehandle
while (my $row = $csv->getline ($testFile)) {
  my @fields = @$row;
  
  #=+ Dbpedia URI
  my $uri = '<'.$fields[2].'>';
  
  #=+ Need to make sure that we incorporate our disambiguations/corrections
  if (exists $disambiguations{$uri}) {
    $uri = $disambiguations{$uri};
  }
  
  #=+ Parse the date and convert to a proper xsd:date object
  my $ReleaseDate;
  my $year;
  if ($fields[1] =~ m/(\d{1,2})\/(\d{1,2})\/(\d{2})/) {
    my $y = $3; my $m = $1; my $d = $2;
    my $pre = '20';
    $pre = '19' if $y > 14;
    $year = $pre.$y;
    $ReleaseDate = '"'.sprintf("%02d-%02d-$pre%02d",$m,$d,$y).'"^^<http://www.w3.org/2001/XMLSchema#date>';
  }
  else {
    say Dumper(\@fields);
    last;
  }
  
  #=+ Create the rdfs:label for the movie
  my $label = quote $fields[0];
  
  #=+ Grab the id field
  my $id = '"'.$fields[3].'"^^<http://www.w3.org/2001/XMLSchema#float>';
  
  #=+ Grab the OMDB data from the API, example call: http://www.omdbapi.com/?t=We+Are+What+We+Are&y=2013&plot=full&r=json
  $fields[0] =~ s/ /\+/g;
  my $escapedTitle = url_escape $fields[0];
  #my $tx = $ua->get('http://www.omdbapi.com/?t='.$escapedTitle.'&y='.$year.'&plot=full&r=json');
  #if ($tx->success) {
  #  my $json = $tx->res->json;
  #  if ($json->{'Response'} eq 'False') {
  #    say $id.';'.$uri.';'.$label.';'.$year;
  #  }
  #}
  
  say {$OF} $uri.' <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://ldmc.org/ontology/testing_data> .';
  say {$OF} $uri.' <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://ldmc.org/ontology/selected_film> .';
  say {$OF} $uri.' <http://ldmc.org/p/label> '.$label.' .';
  say {$OF} $uri.' <http://ldmc.org/p/release_date> '.$ReleaseDate.' .';
  say {$OF} $uri.' <http://ldmc.org/p/id> '.$id.' .';
  #sleep(1);
}

close($testFile);
close($OF);
