rm *.txt
rm *.eps
./gen.sh
./genscale.sh
gnuplot plotres
gnuplot plotiter
gnuplot plotspeed
gnuplot plotscale
gnuplot plotspeedcompare 

./genjoin.sh
gnuplot plotresjoin
gnuplot plotresjoin8
gnuplot plotiterjoin
gnuplot plotiterjoin8
gnuplot plotiterjoin16


#epstopdf figs/response32.eps --outfile figs/response32.pdf
#epstopdf figs/iteration32.eps --outfile figs/iteration32.pdf
#epstopdf figs/speedup.eps --outfile figs/speedup.pdf
#cp *.eps ../../figs/

for file in *.eps; do
  mv $file cc-${file%%}
done
cp *.eps ../../figs/
