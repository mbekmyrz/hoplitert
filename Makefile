GUI ?= 0
X_DIM ?= 4
Y_DIM ?= 4
MAX_RATE ?= 5
MAX_TOKEN ?= 2
MEM_D ?= 20

git:
	make clean
	git pull
	git add .
	git commit -m "edits"
	git push

sw-xsim-test:
	make clean
	cd tb && zsh sw_sim.sh ${GUI}
	make sw-out-test

sw-out-test:
	cd tb && python3 sw_test_mem.py

torus-xsim-test:
	make clean
	cd tb && zsh torus_sim.sh ${X_DIM} ${Y_DIM} ${MAX_RATE} ${MAX_TOKEN} ${MEM_D} ${GUI}
	make torus-out-test

torus-modelsim:
	make clean
	cd tb && vsim -c -do msim.tcl

torus-out-test:
	cd tb && python3 torus_test_mem.py

torus-synth:
	make clean
	cd tb && zsh torus_synth.sh

vivado:
	cd tb && vivado -mode tcl -source build.tcl

pack_kernel:
	rm -rf package; mkdir package; cd package; vivado -mode batch -source ../scripts/pack_kernel.tcl
	make clean

clean:
	rm -rf *.jou *.log *.str *.pb *.dir/ *.wdb .Xil/
	cd tb && rm -rf *.jou *.log *.str *.pb *.dir/ *.wdb .Xil/
	cd rtl && rm -rf *.jou *.log *.str *.pb *.dir/ *.wdb .Xil/
	cd package && rm -rf rtl_kernel rtl_kernel_ip *.jou *.log *.str *.pb *.dir/ *.wdb .Xil/

