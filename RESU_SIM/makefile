VERDI_HOME = /xxx/eda_path TODO
PLATFORM = linux64

all:clean elab run verdi

elab: 
	vcs -full64 -debug_acc+all -sverilog -nc -l comp_log +v2k \
       -f ./filelist.f   \
       -P ${VERDI_HOME}/share/PLI/VCS/${PLATFORM}/novas.tab \
					${VERDI_HOME}/share/PLI/VCS/${PLATFORM}/pli.a \
       -timescale=1ns/1ps   \
       +notimingcheck +nospecify -top tb_top \

run:
	./simv -l run_log

verdi: 
	verdi -nologo -f ./filelist.f -ssf ./novas.fsdb &

clean: 
	rm -rf AN.DB DVEfiles csrc simv.* *simv inter.vpd ucli.key *_log novas* *fsdb
