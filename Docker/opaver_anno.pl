#!/usr/bin/env perl
# parse_prot_tran_data.pl
# ver 0.1
# 2014/09/13
#
# Po-E (Paul) Li
# B-11
# Los Alamos National Lab.
#
# 2017/07/21
# - add support for metabolic expression data
# 2015/05/23
# - add codes to take average proteomic data if genes has multiple expression level
use strict;
use Getopt::Long;
use FindBin qw($Bin);
use LWP::UserAgent;
use JSON;
use strict;

$|=1;
my %opt;
my $res=GetOptions( \%opt,
    'gff3|g=s',
    'outdir|o=s',
    'prefix|p=s',
    'ecinfojson|e=s',
    'pwyinfojson|y=s',
    'help|?') || &usage();

if ( $opt{help} || !-e  $opt{gff3} ) { &usage(); }

# Create a user agent
my $ua = LWP::UserAgent->new();
$ua->env_proxy;

#init
my $prefix  = defined $opt{prefix} ? $opt{prefix} : "output";
my $outdir  = defined $opt{outdir} ? $opt{outdir} : "./$prefix";
my $kojson  = defined $opt{ecinfojson} ? $opt{ecinfojson} : "$outdir/info_ec.json";
my $pwyjson = defined $opt{pwyinfojson} ? $opt{pwyinfojson} : "$outdir/info_pathway.json";
my ($ecinfo,$pwyinfo,$map,$pathway,$gene_exp);

#init directory
`mkdir -p $outdir`;
`mkdir -p $Bin/ec_info`;
die "[ERROR] Can't create output directory $outdir: $!\n" unless -d $outdir;
die "[ERROR] Can't create ec_info directory $Bin/ec_info: $!\n" unless -d "$Bin/ec_info";

#init KEGG info
$ecinfo = &retrieveKoInfoJson( $kojson ) if -s $kojson;

#init pathway info
if( -s $pwyjson ){
    $pwyinfo = &retrievePathwayInfoJson($pwyjson);
}
if( ! defined $pwyinfo->{"00010"} ){
    $pwyinfo =  &builtPathwayInfoJson();
    &writeJSON($pwyinfo, $pwyjson);
}

print STDERR "[INFO] Parsing GFF3 file...\n";
my $anno = &parseGFF3($opt{gff3});

foreach my $ec ( keys %$anno ){
    my @mapid = split /, /, $ecinfo->{$ec}->{pathway};
    foreach my $mapid (@mapid){
        (my $ec_num = $ec) =~ s/EC://i;
        $map->{$mapid}->{$ec_num}->{anno} = $anno->{$ec};
        $map->{$mapid}->{$ec_num}->{info} = $ecinfo->{$ec};
    }
}

print STDERR "[INFO] Retrieve pathway image and KGML...";
foreach my $mapid ( keys %$map ){
    print STDERR "[INFO] download map$mapid...";
    if( -e "$Bin/ec_info/ec$mapid.png" && -e "$Bin/ec_info/ec$mapid.xml" ){
    `cp $Bin/ec_info/ec$mapid.png $outdir/ec$mapid.png`;
    `cp $Bin/ec_info/ec$mapid.xml $outdir/ec$mapid.xml`;
    }

    if( !-e "$outdir/ec$mapid.png" || !-e "$outdir/ec$mapid.xml" ){
        my $exitcode1 = system("curl --retry 5 --retry-delay 1 https://rest.kegg.jp/get/map$mapid/image > $outdir/ec$mapid.png");
        my $exitcode2 = system("curl --retry 5 --retry-delay 1 https://rest.kegg.jp/get/ec$mapid/kgml > $outdir/ec$mapid.xml");
        if ( $exitcode1 || $exitcode2 ){
            print STDERR "[WARNING] Failed to download map$mapid image/KGML from KEGG.\n";
        }
        else{
        `cp $outdir/ec$mapid.png  $Bin/ec_info/ec$mapid.png`;
        `cp $outdir/ec$mapid.xml $Bin/ec_info/ec$mapid.xml`;
            print STDERR "Done.\n";
        }
    }
    else{
            print STDERR "File exists. Skipped.\n";
    }
}
print STDERR "[INFO] Done\n";

print STDERR "[INFO] Writing pathway list...";
open OUT, ">$outdir/exp_pathway.txt" or die "[ERROR] Can't write pathway file: $!\n";
foreach my $mapid ( sort {$pathway->{$b}<=>$pathway->{$a}} keys %$pathway ){
    print OUT "$mapid\t$pathway->{$mapid}\t$pwyinfo->{$mapid}\n";
}
close OUT;
print STDERR "[INFO] Done\n";

print STDERR "[INFO] Writing annotation JSON files for KEGG maps...";
foreach my $mapid ( keys %$map ){
    &writeJSON($map->{$mapid}, "$outdir/ec$mapid.anno.json");
}
print STDERR "[INFO] Done\n";

print STDERR "[INFO] Writing EC JSON files...";
&writeJSON($ecinfo, $kojson);
print STDERR "[INFO] Done\n";

####################################################################################

sub parseGFF3 {
    my ($file) = @_;
    my $data;

    open GFF3, $file or die "[ERROR] Can't open GFF3 file: $!\n";
    foreach(<GFF3>){
        chomp;
        #skip header
        next if /^#/;
        next if /^$/;
        last if /^>/;
        # skip gene annotation that doesn't have EC#
        next unless /eC_number=/i;

        my ($seqid,$source,$type,$start,$end,$score,$strand,$phase,$attributes) = split /\t/, $_;

        my ($id,$ec,$inf,$gene,$locus_tag,$prod);
        foreach my $attr ( split /;/, $attributes ){
            $id = $1 if $attr =~ /ID=(.*)/i;
            $ec = $1 if $attr =~ /eC_number=(.*)/i;
            $inf = $1 if $attr =~ /inference=(.*)/i;
            $gene = $1 if $attr =~ /gene=(.*)/i;
            $locus_tag = $1 if $attr =~ /locus_tag=(.*)/i;
            $prod = $1 if $attr =~ /product=(.*)/i;
        }

        my @temp = split /,/, $ec;

        foreach my $ec ( @temp ){
            $data->{$ec}->{$id}->{inf}=$inf;
            $data->{$ec}->{$id}->{gene}=$gene;
            $data->{$ec}->{$id}->{locus_tag}=$locus_tag;
            $data->{$ec}->{$id}->{prod}=$prod;
            $data->{$ec}->{$id}->{contig}=$seqid;
            $data->{$ec}->{$id}->{type}=$type;
            $data->{$ec}->{$id}->{start}=$start;
            $data->{$ec}->{$id}->{end}=$end;
            $data->{$ec}->{$id}->{strand}=$strand;

            &getECinfo($ec);

            print STDERR "$id\t$ec\t$gene\t$prod\n";
        }
    }
    close GFF3;
    return $data;
}

sub writeJSON {
    my ($map, $outfile) = @_;
    open OUT, ">$outfile" or die "[ERROR] Can't write JSON file: $!\n";
    my $json_text = to_json($map, {utf8 => 1, pretty => 1});
    print OUT $json_text;
    close OUT;
}

sub retrieveKoInfoJson {
    my $jsonfile = shift;
    open JSON, $jsonfile or die "[ERROR] Can't read KO info JSON file: $!\n";
    local $/ = undef;
    my $json_text = from_json(<JSON>);
    close JSON;
    return $json_text;
}

sub retrievePathwayInfoJson {
    my $jsonfile = shift;
    open JSON, $jsonfile or die "[ERROR] Can't read Pathway info JSON file: $!\n";
    local $/ = undef;
    my $json_text = from_json(<JSON>);
    close JSON;
    return $json_text;
}

sub builtPathwayInfoJson {
    # URL for service
    my $url = "https://rest.kegg.jp/list/pathway";
    my $response = $ua->post("$url");
    my $pwy;
    
    # Check for HTTP error codes
    print STDERR "ERROR: https://rest.kegg.jp/list/pathway\n" unless ($response->is_success); 
      
    # Output the entry
    my $content = $response->content();
    my @lines = split /\n/, $content;
    
    foreach my $line (@lines){
        my ($id,$name) = $line =~ /path:map(\d+)\t(.*)$/;
        $pwy->{$id} = $name;
    }
    return $pwy;
}

sub getECinfo {
    my $ec = shift;
    my @p;

    if( !defined $ecinfo->{$ec} ){
        # URL for service
        my $info;
        my $url = "https://rest.kegg.jp/get";
        my $content;
        my $ec_info_file = "$Bin/ec_info/$ec";

        if( -e $ec_info_file ){
            local $/;
            open my $fh, '<', $ec_info_file or die "can't open $ec_info_file: $!";
            $content = <$fh>;
            close $fh;
            print STDERR "[INFO] EC info loaded from $ec_info_file.\n";
        }
        else {
            my $response = $ua->post( "$url/".lc($ec));

            # Check for HTTP error codes
            open my $fh, '>', $ec_info_file or die "can't open $ec_info_file: $!";
            if( $response->is_success ){ 
                print $fh $response->content();
                $content = $response->content();
                print STDERR "[INFO] EC info loaded from $url/$ec.\n";
            }
            else{
                print $fh "";
                print STDERR "No $ec info found.\n";
            }
            close $fh;
        }
  
        # Output the entry
        my @lines = split /\n/, $content;
    
        my $pwyflag=0;
        foreach my $line (@lines){
            last if $line =~ /^\w+/ && $pwyflag;
            $pwyflag = 1 if $line =~ /PATHWAY\s+/;
            if( $pwyflag ){
                # koXXXXXX for KO, mapXXXXXX for compound
                if( $line =~ /\s+ec(\d+)/ ){
                    push @p, $1; 
                    $pathway->{$1} = 1;
                }
            }
            else{
                $info->{name}       = $1 if $line =~ /NAME\s+(.*);?$/;
                $info->{class}      = $1 if $line =~ /CLASS\s+(.*);?$/;
                $info->{reaction}   = $1 if $line =~ /REACTION\s+(.*);?$/;
                $info->{product}    = $1 if $line =~ /PRODUCT\s+(.*);?$/;
                $info->{comment}    = $1 if $line =~ /COMMENT\s+(.*);?$/;
            }
        }
        $info->{pathway} = join ", ", @p;
        $ecinfo->{$ec} = $info;
    }

    my $info = $ecinfo->{$ec};
    my @mapids = split /, /, $info->{pathway};
    foreach my $mapid ( @mapids ){
        $pathway->{$mapid} ||= 0;
        $pathway->{$mapid}++;
    }
}

sub timeInterval{
    my $now = shift;
    $now = time - $now;
    return sprintf "%02d:%02d:%02d", int($now / 3600), int(($now % 3600) / 60), int($now % 60);
}

sub usage {
print <<__END__;
OPaver (Omics Pathway Viewer) is a web-based viewer to provide 
an integrated and interactive visualization of omics data in KEGG maps.

Version: v0.3

$0 [OPTIONS] -g <GFF3>
    --gff3|g    genome annotation in gff3 file (with EC#)

[OPTIONS]
    --outdir|o
    --prefix|p
    --ecinfojson|e
    --pwyinfojson|y
__END__
exit();
}
