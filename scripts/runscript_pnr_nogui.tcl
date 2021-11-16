set tb $env(TOP_PNR);
probe -create -shm $tb -all -depth all
#simvision -input ./scripts/simvision.sv
run
exit
