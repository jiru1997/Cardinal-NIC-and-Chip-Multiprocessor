set tb $env(TOP_SYN);
probe -create -shm $tb -all -depth all
#simvision -input ./scripts/simvision.sv
run
