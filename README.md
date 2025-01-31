This is Nutrimatic (http://nutrimatic.org/usage.html).

To build the source, run `./build.py`.  You will need the following installed:
* Python (2.x)
* `g++`
* libxml2 (ubuntu: `apt-get install libxml2-dev`; osx: `pip install lxml`)
* libtre (ubuntu: `apt-get install libtre-dev`; osx: `brew install tre`)

To do anything useful, you will need to build an index from Wikipedia.

1. Download the latest Wikipedia database dump (this is a ~13GB file!):

```
curl -O https://dumps.wikimedia.org/enwiki/latest/enwiki-latest-pages-articles.xml.bz2
```

2. Extract the text from the articles using Wikipedia Extractor
   (this generates ~12GB of text, and can take several hours!):

See https://github.com/attardi/wikiextractor (Requires Python 3.x)
```
git clone https://github.com/attardi/wikiextractor.git
python3 -m wikiextractor.WikiExtractor enwiki-latest-pages-articles.xml.bz2
```

This will write many files named `text/??/wiki_??`.

3. Index the text (this generates ~50GB of data, and can also take hours!):

```
find text -type f | xargs cat | bin/make-index wikipedia
```

This will write many files named `wikipedia.?????.index`.

(You can break this up; run make-index several times with different
sets of input files, replacing "wikipedia" with unique names each time.)

4. Merge the indexes; I normally do this in two stages:

```
for x in 0 1 2 3 4 5 6 7 8 9
 do bin/merge-indexes 2 wikipedia.????$x.index wiki-merged.$x.index
done

bin/merge-indexes 5 wiki-merged.*.index wiki-merged.index
```

There's nothing magical about this appproach with 10 batches, you can use
any way you like to merge the files. The 2 and 5 numbers are minimum phrase
frequency cutoffs (how many times a string must occur to be included).

5. Enjoy your new index:

```
bin/find-expr wiki-merged.index '<aciimnrttu>'
```

If you want to set up the web interface, write a short shell wrapper that runs
cgi-search.py with arguments pointing it at your binaries and data files, e.g.:

```
#!/bin/sh

export NUTRIMATIC_FIND_EXPR=/path/to/nutrimatic/bin/find-expr
export NUTRIMATIC_INDEX=/path/to/nutrimatic/data/wiki-merged.index
exec /path/to/nutrimatic/cgi-search.py
```

Then arrange for your web server to invoke that shell wrapper as a CGI script.

Have fun,

-- egnor@ofb.net

Optional: There is a `Dockerfile` present in this repo that can make building the project much easier and portable.

Example:
```
docker build -t nutrimatic:latest .
docker run -it --rm -v "$(pwd)":/mnt nutrimatic:latest sh
# cd /mnt
# for x in 0 1 2 3 4 5 6 7 8 9
> do /usr/local/nutrimatic/bin/merge-indexes 2 wikipedia.????$x.index wiki-merged.$x.index
> done

/usr/local/nutrimatic/bin/merge-indexes 5 wiki-merged.*.index wiki-merged.index
exit

docker run --rm -v "$(pwd)":/mnt nutrimatic:latest bin/find-expr /mnt/wiki-merged.index '<aciimnrttu>'
```
