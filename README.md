##Steps to Launch this app:

* Obtain source via git [How To Git](http://git-scm.com/book/en/v2/Git-Basics-Getting-a-Git-Repository)

* Ruby 1.9+ & Rails 4 installed

* By default configured for MySQL (config/database.yml)

* cd panda

* bundle install   (to get dependancies from Gemfile)

* rake db:setup  or db:migrate:reset  (Database creation)

* rake db:seed   (Database initialization, creates admin)

* rails runner lib/tasks/kegg_ETL.rb   (populates KEGG Pathways)


##Example Data to Quick Start
There are four files provided to try once the webapp is up and running.
Location: EXAMPLES/

##How Preloaded Data was obtained

####DGIDB
```
wget http://dgidb.genome.wustl.edu/downloads/interactions.tsv
#Add header
perl -ne 'chomp;if ($.==1){print "#$_\tLink\n"}else{@gene=split("\t",$_);print "$_\t<a target=\"_blank\" href=http://dgidb.genome.wustl.edu/interaction_search_results?genes=$gene[0]>$gene[0]</a>\n"}' interactions.tsv > DGIDB.out
rm interactions.tsv
```

####PharmGKB Genes
```
wget http://www.pharmgkb.org/download.do?objId=genes.zip&dlCls=common
unzip download.do\?objId\=genes.zip
rm CREATED_2014-12-05.txt VERSIONS.txt
perl -p -i -e 's/^PharmGKB/#PharmGKB/' genes.tsv
#subset to only VIP and CPIC Genes
awk -F'\t' '{if(NR==1){print"#"$5"\t"$8"\t"$9"\t"$11"\tLinkOut"}else{if(($8~/true/)|| ($11~/true/)){print $5"\t"$8"\t"$9"\t"$11"\t<a target=\"_blank\" href=http://www.pharmgkb.org/gene/"$1">"$5"</a>"}}}' genes.tsv  >PharmGKB.out
rm genes.tsv
```

####GAD
```
wget http://geneticassociationdb.nih.gov/data.zip
unzip data/GADCDC/GADCDC_data.zip
cat GADCDC_data.tsv |cut -f3,6,10,56|perl -ne 'chomp;$line=$_;$line=~s/"//g;if ($.==1){print "#Gene\tDisease\tPubMed\n"}else{if (@line[3] !~ /[a-z]/){$status="PubMed"}else{$status=@line[3]};@line=split("\t",$line);print "@line[1]\t@line[0]\t<a target=\"_blank\" href=http://www.ncbi.nlm.nih.gov/pubmed/?term=@line[2] >$status</a>\n"}' > GAD.out
rm GADCDC_data.tsv
rm -fr data*
```


####ENSEMBLE GENES 78
*GRCh38, Get bioMART data for OMIM
*Filter: with MIM diseaseID
*Attributes: HGNC Symbol, MIM Morbid accession, Phenotype Description
```
perl -ne 'chomp;@line=split("\t",$_);if($.==1){print "#Gene\tPhenotype Link\n" }else{print "@line[0]\t<a target=\"_blank\" href=http://omim.org/entry/@line[1]>@line[2]</a>\n"}' bioMart.out > OMIM.out
rm export.tsv
```

####Malacards
```
wget http://www.genecards.org/cgi-bin/listdiseasecards.pl?type=full&no_limit=1
perl -ne 's/^(\s+)//g;if ($_=~/<table cellpadding=\"10\" class=\"genesDisorders\">/){$start="TRUE"} if ($start eq "TRUE"){;$_=~s/<td class=\"geneSymbol\">|<\/td>|<\/td>|<td>| $|<tr>//g;next if ($_=~/^$/);print}' listdiseasecards.pl\?type\=full |perl -pne 's/\n//g;s/<\/tr>/\n\n/g;s/<td width="250">//g;s/<\/a>/<\/a>\t/;s/<\/a>/<\/a>\t/;s/<\/a>/<\/a>\t/;'|perl -ne 'chomp;if($.==1){print "#Gene\tGeneCards\tMalacards\n";next};next if ($_=~/^$/);@line=split("\t",$_);$gene=@line[0];@gene=split(/(>)(.+)(<)/,$gene);$rest=join(",",@line[4..@line]);$rest=~s/,{1,}/,/g;$rest=~s/^,|,$//g;$tmp=$line[0];$tmp=~s/\/cgi-bin/http:\/\/www.genecards.org\/cgi-bin/;print join ("\t",$gene[2],$tmp,$rest)."\n"' > MalaCards.out
rm listdiseasecards.pl\?type\=full
```

####HPO
```
wget http://compbio.charite.de/hudson/job/hpo.annotations.monthly/lastStableBuild/artifact/annotation/ALL_SOURCES_TYPICAL_FEATURES_phenotype_to_genes.txt
sed '1,1d' ALL_SOURCES_TYPICAL_FEATURES_phenotype_to_genes.txt |perl -ne 'chomp;@line=split("\t");print "@line[3]\t@line[1],\n"'|sort -k1| awk 'BEGIN{print "#Gene\tHPO_terms"}{if(a!=$1) {a=$1; printf "\n%s%s",$0,FS} else {a=$1;$1="";printf $0 }} END {printf "\n" }' |grep -v -e '^$' > HPO.out
```

####Get icons
```
wget http://www.iconarchive.com/download/i87453/graphicloads/medical-health/dna.ico
wget http://www.iconarchive.com/download/i78650/icons-land/medical/Body-DNA.ico
wget https://www.iconfinder.com/icons/294398/download/png/128 -O hourglass.png
wget https://www.iconfinder.com/icons/294393/download/png/128 -O shield.png
wget https://www.iconfinder.com/icons/294397/download/png/128 -O semiconductor.png
wget https://www.iconfinder.com/icons/294395/download/png/128 -O ruby.png
wget https://www.iconfinder.com/icons/294399/download/png/128 -O bell.png
wget https://www.iconfinder.com/icons/294390/download/png/128 -O cross.png
wget https://www.iconfinder.com/icons/32135/download/png/128 -O blueI.png
wget https://www.iconfinder.com/icons/32140/download/png/128 -O yellowPower.png
wget https://www.iconfinder.com/icons/32142/download/png/128 -O blueClock.png
wget https://www.iconfinder.com/icons/32137/download/png/128 -O greenBall.png
wget https://www.iconfinder.com/icons/32139/download/png/128 -O redShutdown.png
wget https://www.iconfinder.com/icons/32133/download/png/128 -O greenCheck.png
wget https://www.iconfinder.com/icons/32141/download/png/128 -O redX.png
wget https://www.iconfinder.com/icons/32131/download/png/128 -O blueStar.png
wget https://www.iconfinder.com/icons/17524/download/png/48 -O blueQuote.png
wget https://www.iconfinder.com/icons/12622/download/png/48 -O greenExcl.png
wget https://www.iconfinder.com/icons/12595/download/png/48 -O lightBulb.png
wget https://www.iconfinder.com/icons/66984/download/png/48 -O blueQ.png
wget https://www.iconfinder.com/icons/66987/download/png/48 -O lifesaver.png
wget https://www.iconfinder.com/icons/66972/download/png/48 -O redAlarm.png
wget https://www.iconfinder.com/icons/66981/download/png/48 -O redHeart.png
wget https://www.iconfinder.com/icons/55470/download/png/48 -O ekg.png
wget https://www.iconfinder.com/icons/55807/download/png/64 -O magnify.png
wget https://www.iconfinder.com/icons/55638/download/png/64 -O reads.png
wget https://www.iconfinder.com/icons/54767/download/png/128 -O network.png
wget https://www.iconfinder.com/icons/54760/download/png/128 -O vine.png
wget https://www.iconfinder.com/icons/54715/download/png/128 -O star.png
```

Only the Admin User can change an uploaded annotation set, into a preloaded annotation:
Account details in db/seeds.rb