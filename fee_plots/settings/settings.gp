set terminal pngcairo font "arial,10" fontscale 2.0 size 1200, 800 
set output outfile
set title  font ",20" norotate

set xrange [ * : * ] noreverse writeback
set x2range [ * : * ] noreverse writeback
set yrange [ * : * ] noreverse writeback
set y2range [ * : * ] noreverse writeback
set zrange [ * : * ] noreverse writeback
set cbrange [ * : * ] noreverse writeback
set rrange [ * : * ] noreverse writeback

set xlabel "L/B"
set ylabel "Fee (%)"
