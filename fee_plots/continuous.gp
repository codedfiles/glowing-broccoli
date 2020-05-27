outfile = 'output/continuous.png'
load 'settings/settings.gp'

set title "Continuous Fee"

n = 5
a = 100
f(x) = x < 2.0/3.0 ? 0 : 100*(3*x - 2)**n
plot [0:1] [0:100] f(x) notitle
