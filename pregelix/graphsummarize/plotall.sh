rm *.eps

cd pagerank
./plotall.sh

cd ../sssp
./plotall.sh

cd ../cc
./plotall.sh

cd ..

gnuplot plotscale
cp *.eps ../figs/
