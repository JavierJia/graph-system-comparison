rm *.txt
./gen.sh
./genscale.sh
./genconnector.sh
./sumptp.sh
gnuplot plotres
gnuplot plotiter
gnuplot plotspeed
gnuplot plotscale
gnuplot plotspeedcompare 
gnuplot plotresconnector
gnuplot plotresconnector8
gnuplot plotiterconnector
gnuplot plotiterconnector8
gnuplot plottp

./genjoin.sh
gnuplot plotiterjoin8

#epstopdf figs/response32.eps --outfile figs/response32.pdf
#epstopdf figs/iteration32.eps --outfile figs/iteration32.pdf
#epstopdf figs/speedup.eps --outfile figs/speedup.pdf
cp *.eps ../../figs/
