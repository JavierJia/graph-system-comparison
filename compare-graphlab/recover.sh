for i in {1..38}; do 
    echo $i; 
    ssh sensorium-$i "ps aux | grep mpd | gawk '{print \$2;}' | xargs -rn1 kill -9 ";
done
