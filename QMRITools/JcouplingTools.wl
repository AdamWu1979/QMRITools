(* ::Package:: *)

(* ::Title:: *)
(*QMRITools JcouplingTools*)


(* ::Subtitle:: *)
(*Written by: Martijn Froeling, PhD*)
(*m.froeling@gmail.com*)


(* ::Section:: *)
(*start Package*)


BeginPackage["QMRITools`JcouplingTools`", Join[{"Developer`"}, Complement[QMRITools`$Contexts, {"QMRITools`JcouplingTools`"}]]];


(* ::Section:: *)
(*Usage Notes*)


(* ::Subsection::Closed:: *)
(*Functions*)


SimHamiltonian::usage = 
"SimHamiltonian[sysi] simulates the hamiltionan for a given spin system. The spinsystem is generated by GetSpinSystem.
The output is the spin system and hamiltonian structure.

SimHamiltonian[] is based on DOI: 10.1016/j.jmr.2010.12.008 and 10.1002/mrm.24340."

SimEvolve::usage =
"SimEvolve[din,H,t] evolves the spin system din given the hamiltonian H over a time t. din and H are generated by SimHamiltonian. 
The output is a new spinsystem dout."

SimRotate::usage = 
"SimRotate[din, H ,angle] rotates the spin system din given the hamiltonian H over angele with phase 90 degrees.
SimRotate[din, H ,angle, phase] rotates the spin system din given the hamiltonian H over angele with phase.
din and H are generated by SimHamiltonian. 
The angle and phase are defined in degree. 
The output is a new spinsystem dout."

SimAddPhase::usage = 
"SimAddPhase[din ,H ,phase] adds phase to the spin system din given the hamiltonian H.
din and H are generated by SimHamiltonian. 
The phase is defined in degree.
The output is a new spinsystem dout."

SimSpoil::usage = 
"SimSpoil[din] spoils all the non zeroth order states of a spin system.
The output is a new spinsystem dout."

SequencePulseAcquire::usage = 
"SequencePulseAcquire[din, H] performs a pulsaquire experiment of the spin system din given the hamiltonian H with a 90 Degree pulse.
SequencePulseAcquire[din, H, b1] performs a pulsaquire experiment of the spin system din given the hamiltonian H with a 90 Degree pulse and b1.
The output is a new spinsystem dout."

SequenceSpinEcho::usage =
"SequenceSpinEcho[din, H, te] performs a spin echo experiment with echo time te of the spin system din given the hamiltonian H with a 90 and 180 Degree pulse.
SequenceSpinEcho[din, H, te, b1] performs a spin echo experiment with echo time te of the spin system din given the hamiltonian H with a 90 and 180 Degree pulse and b1.
The te is defined in ms and the b1 of 100% is defined as 1. 
The output is a new spinsystem dout."

SequenceSteam::usage =
"SequenceSteam[din, H, {te, tm}] performs a stimulated echo experiment with echo time te and mixing time tm of the spin system din given the hamiltonian H with 3 90 Degree pulses.
The te and tm are defined in ms.
The output is a new spinsystem dout."

SequenceTSE::usage =
"SequenceTSE[din ,H, {te, necho}, {ex, ref}] performs a multi echo spin echo experiment with echo time te with necho echos of the spin system din given the hamiltonian H using ex Degree exitation and ref Degree refocus pulses.
SequenceTSE[din ,H, {te, necho}, {ex, ref}, b1] performs a multi echo spin echo experiment with echo time te with necho echos of the spin system din given the hamiltonian H using ex Degree exitation and ref Degree refocus pulses and b1.
The te is defined in ms, the ex and ref are defined in degree and b1 of 100% is defined as 1. 
The output is a new spinsystem dout."

SequenceSpaceEcho::usage =
"SequenceSpaceEcho[din, H, t1, t2, necho, b1] performs a multi echo spin echo experiment with a 90 degree spin echo, with t1 the time between the 90 degree RF pulse and the first 180 degree RF pulse, 
t2 the time betwteen a 180 degree RF pulse and the following readout (and 2xt1 the time between two consecutive 180 degree RF pulses.
Further defines necho the number of 180 degree RF pulses, din the spin system given the hamiltonian H using b1.
The t1 and t2 are defined in ms, and b1 of 100% is defines as 1.
The output is a new spinsystem dout"

SimReadout::usage = 
"SimReadout[din, H] performs a readout of a spinsystem din with hamiltonian H.
Output is {time,fids,ppm,spec,dout}, which are the free induction decay fids with its time, the spectrum spec with its ppm and the evolved spin system dout."

SimSignal::usage = 
"SimSignal[din, H] performs a readout of a spinsystem din with hamiltonian H.
Output is the complex signal."

GetSpinSystem::usage = 
"GetSpinSystem[name] get a spinsystem that can be used in SimHamiltonian. Current implementes systems are \"glu\", \"lac\", \"gaba\", \"fatGly\", \"fatAll\", \"fatEnd\", \"fatDouble\", \"fatStart\", and \"fatMet\"."

MakeSpinSystem::usage = 
"MakeSpinSystem[name, freqs, jcoup] makes a spin system for jcoupling simulations. The with name is defined by the freqs of the nuclei and the jcoup values {{n1, nx}, j} between nuclei.
MakeSpinSystem[{name,labs}, freqs, jcoup] same but each nuclei has a specific name, e.g.{\"ATP\", {\"\[Gamma]\",\"\[Alpha]\",\"\[Beta]\"}.
MakeSpinSystem[name, freqs, jcoup, scales] same but each nuclei has a scale, default scales are 1.
MakeSpinSystem[{name,labs}, freqs, jcoup, scales] same as alle before. "

SysTable::usage = 
"SysTable[sys] shows the spinsystem as a table. The spinsytem is obtained form GetSpinSystem."


(* ::Subsection::Closed:: *)
(*Options*)


FieldStrength::usage = 
"FieldStrength is an option for SimHamiltonian. It defines the field strength for which the hamiltonian is calculated defined in Tesla."

SimNucleus::usage = 
"SimNucleus is an option for SimHamiltonian. It defines the nucleus for which to simulate the spectra."

ReadoutOutput::usage = 
"ReadoutOutput is an option for SimReadout and SimSignal and values can be \"all\" and \"each\". When set to \"all\" the total signal and signal is given, when set to \"each\" the signal or spectrum for each peak is given seperately."

ReadoutPhase::usage = 
"ReadoutPhase is an option for SimReadout and defines the readout phase in degrees."

ReadoutMethod::usage
"ReadoutMethod is an option of SimReadout and can be \"Fid\" or \"Echo\". With \"Fid\" it is also possbile to define a delay time in ms {\"Fid\", delay}. 
With \"Echo\" it is also possbile to define a delay time in ms {\"Echo\", delay} and it than assumes te is half the readout, or a custom te can be defined {\"Echo\", delay, te}."

Linewidth::usage = 
"Linewidth is an option for SimReadout and defines the spectral linewidth in Hz."

LinewidthShape::usage = 
"LinewidthShape is an option for SimReadout and defines the linewidth shape, values can be \"Lorentzian\", \"Gaussian\" or \"Voigt\"."

ReadoutSamples::usage = 
"ReadoutSamples is an option for SimReadout and defines the number of readout samples for the spectrum."

ReadoutBandwith::usage = 
"ReadoutBandwith is an option for SimReadout defines the spectral bandwith in Hz."

CenterFrequency::usage = 
"CenterFrequency is an option for GetSpinSystem and defines the center frequency in ppm."


(* ::Subsection:: *)
(*Error messages*)


(* ::Section:: *)
(*Jcoupling Core Functionality*)


Begin["`Private`"]


verb = False;


(* ::Subsection::Closed:: *)
(*SimHamiltonian*)


Options[SimHamiltonian] = {FieldStrength->3, SimNucleus -> "1H"}

SyntaxInformation[SimHamiltonian] = {"ArgumentsPattern" -> {_, OptionsPattern[]}};

SimHamiltonian[sysi_,OptionsPattern[]]:=Block[{
	sys, sysJ, sysS, scale, sysSi, names, it, name, Hj, Hres, nSpins, nSpins2, nuc,
	iden, zero, set, HbasisA, HbasisB, states, statesi, st, bas, Hix, Hiy, Hiz, 
	di, Hfx, Hfy, Hfz, wIxy, Ixy, Fxy, wFxy, dn, weight, weighti, Hcs, Hjs, Hjw, 
	ham, hamJ, valD, matU, valDJ, matUJ, hstruc, bField, gyro},
	
	bField = OptionValue[FieldStrength];
	nuc = OptionValue[SimNucleus];
	gyro = GyromagneticRatio[nuc];
	
	sys = If[StringQ[sysi],GetSpinSystem[sysi],sysi];
	
	(*define frequencys*)
	{sysJ,sysS,scale,sysSi,names,it,name} = sys;
	Hj = 2Pi sysJ;
	Hres = sysS (-2.*Pi*bField*gyro)(*omega at ppm*);
	
	(*standard matrixes and sizes*)
	nSpins = Length[sysS];nSpins2=2^nSpins;
	iden = SparseArray[IdentityMatrix[nSpins2]];
	zero = SparseArray[ConstantArray[0,{nSpins2,nSpins2}]];
	
	(*make spin basis set*)
	set = Permutations[-Sort@Flatten[ConstantArray[{1,-1},nSpins]],{nSpins}];
	HbasisA = Transpose[.5ConstantArray[set,nSpins2],{2,3,1}];
	HbasisB = Transpose/@HbasisA;
	
	(*make states*)
	statesi = Round@Abs[HbasisB-HbasisA];(*see where both are equal \[Rule] 0 equal, 1 different*)
	states = SparseArray[1-Unitize[Total[statesi]-1]];(*find where only one is different, thus sum of states = 1*)
	statesi = states #&/@statesi; (*get the individual spin states, thus find *)
	
	(*Create All the angular momentum opperators Iix, Iiy and Iiz*)
	{Hix,Hiy,Hiz,di} = Transpose[Table[
		st = statesi[[i]];
		bas = HbasisA[[i]];
		{st Abs[bas], st bas I, iden bas, iden bas}
		,{i,1,nSpins}]
	];
	{Hfx,Hfy,Hfz,dn} = Total/@{Hix,Hiy,Hiz,di};
	
	(*create the readout angular momentum opperators*)
	Ixy = (Hix-Hiy I);
	Fxy = (Hfx-Hfy I);(*unweighted versions*)
	wIxy = scale Ixy;
	wFxy = Total[wIxy];(*weighted for spin occurence*)
	
	(*construct the hamiltonian Sum of Ii.Ij for j>i*)
	Hcs = Hjs = Hjw = zero;
	MatrixForm@Table[Hcs-=Hres[[j]]Hiz[[j]] ;(* izj *)
		Table[
			Hjs-=Hj[[j,k]](Hiz[[j]].Hiz[[k]]);(* izj, izk*)
			Hjw-=Hj[[j,k]](Hix[[j]].Hix[[k]]);(* ixj, ixk*)
			Hjw-=Hj[[j,k]](Hiy[[j]].Hiy[[k]]);(* ixj, ixk*)
		,{k,j+1,nSpins}]
	,{j,nSpins}];
	
	(*make the hamilonian with and without chemical shift*)
	ham = Hcs + Hjs + Hjw;
	hamJ = Hjs + Hjw;
	
	(*get eigensystem of the hamiltonian*)
	{valD,matU} = Eigensystem[Normal[ham]];
	matU = SparseArray[Chop[matU]];
	{valDJ,matUJ} = Eigensystem[Normal[hamJ]];
	matUJ = SparseArray[Chop[matUJ]];
	
	(*make hstructure and output*)
	hstruc = {
		"J"->Hj,
		"shifts"->sysS,
		"shifts_rad"->Hj,
		"Bfield"->bField,
		"scale"->scale,
		"nSpins"->nSpins,
		"nSpins2"->nSpins2,
		"basisA"->HbasisA,
		"basisB"->HbasisB,
		"sates"->states,
		"statesi"->statesi,
		"Fx"->Hfx,
		"Fy"->Hfy,
		"Fz"->Hfz,
		"Fxy"->Fxy,
		"wFxy"->wFxy,
		"Ix"->Hix,
		"Iy"->Hiy,
		"Iz"->Hiz,
		"Ixy"->Ixy,
		"wIxy"->wIxy,
		"weight"->weight,
		"weighti"->weighti,
		"Hab"->ham,
		"HabJ"->hamJ,
		"Hval"->valD,
		"Hvec"->matU,
		"HvalJ"->valDJ,
		"HvecJ"->matUJ,
		"nucleus"->nuc,
		"gyro"->gyro
		};
		
	(*output*)
	{dn,hstruc}
]


(* ::Subsection:: *)
(*Excite and evolve*)


(* ::Subsubsection::Closed:: *)
(*SimEvolve*)


SyntaxInformation[SimEvolve]={"ArgumentsPattern" -> {_, _, _}};

SimEvolve[din_,H_,t_]:=Block[{d, matU,valD},
	{valD,matU}={"Hval","Hvec"}/.H;(*use eigen basis for fast computation*)
	d = SimEvolveM[matU,valD,t](*= Exp[-I ham t]*);
	Chop[d.din.ConjugateTranspose[d]]
]

SimEvolveM[matU_,valD_,t_]:=Chop[Transpose[matU].SparseArray[DiagonalMatrix[Exp[I valD t]]].matU]


(* ::Subsubsection::Closed:: *)
(*SimRotate*)


SyntaxInformation[SimRotate]={"ArgumentsPattern" -> {_, _, _, _.}};

SimRotate[din_,H_,angle_,phase_:90]:=Block[{alpha,ph,dinS,Fx,Fy,Fz,Rz,rotate, pMat,rMat, tMat},
	{alpha,ph}={angle, phase}Degree;(*to rad*)
	rMat=MatrixExp[I alpha ("Fx"/.H)];(*rotation around x*)
	pMat=MatrixExp[-I ph ("Fz"/.H)];(*phase - rotation around z*)
	tMat=pMat.rMat.ConjugateTranspose[pMat];(*define rot matirx*)
	Chop[tMat.din.ConjugateTranspose[tMat]](*predef matrix preven extra comp*)
];


(* ::Subsubsection::Closed:: *)
(*SimAddPhase*)


SyntaxInformation[SimAddPhase]={"ArgumentsPattern" -> {_, _, _}};

SimAddPhase[din_,H_,phase_]:=Block[{pMat},
	pMat=MatrixExp[-I ("Fz"/.H) phase Degree];(*phase - rotation around z*)
	Chop[pMat.din.ConjugateTranspose[pMat]](*add phase due to gradients, rotation around z*)
]


(* ::Subsubsection::Closed:: *)
(*SimSpoil*)


SyntaxInformation[SimSpoil]={"ArgumentsPattern" -> {_}};

SimSpoil[din_]:=Chop[IdentityMatrix[Length[din]]din](*spoil all non zeroth order states*)


(* ::Subsection:: *)
(*Sequences*)


(* ::Subsubsection::Closed:: *)
(*SequencePulseAcquire*)


SyntaxInformation[SequencePulseAcquire]={"ArgumentsPattern" -> {_, _, _.}};

SequencePulseAcquire[din_,H_,te_:0,b1_:1]:=SimEvolve[SimRotate[din,H,b1 90,0],H,te](*excite*)


(* ::Subsubsection::Closed:: *)
(*SequenceSpinEcho*)


SyntaxInformation[SequenceSpinEcho]={"ArgumentsPattern" -> {_, _, _, _.}};

SequenceSpinEcho[din_,H_,te_,b1_:1]:=Block[{d,tau},
	tau=te/2;
	d=SimRotate[din,H,b1 90,0];(*excite*)
	d=SimEvolve[d,H,tau];(*evolve by tau, no crush*)
	d=SimRotate[d,H,b1 180,90];(* refocus*)
	SimEvolve[d,H,tau](*evolve by tau, no crush*)
]


(* ::Subsubsection::Closed:: *)
(*SequenceSteam*)


SyntaxInformation[SequenceSteam]={"ArgumentsPattern" -> {_, _, {_, _}}};

SequenceSteam[din_,H_,{te_,tm_}]:=Block[{d,tau},
	tau=te/2;
	Total@Table[
	d=SimRotate[din,H,-90,0];(*excite*)
	d=(2/Pi)SimAddPhase[d,H,j];(*dephase the transverse signal*)
	d=SimEvolve[d,H,tau]; (*evolve by tau*)
	d=SimRotate[d,H,-90,0]; (*tip up*)
	d=SimSpoil[d];(*destroy all non zero order states*)
	d=SimEvolve[d,H,tm];(*evolve by tm*)
	d=SimRotate[d,H,-90,0];(*tip down*)
	d=(Pi/4)SimAddPhase[d,H,j];(*dephase the transverse signal*)
	d=SimEvolve[d,H,tau];(*evolve by tau*)
	d
	,{j,0,270,90}]
]


(* ::Subsubsection::Closed:: *)
(*SequenceTSE*)


SyntaxInformation[SequenceTSE]={"ArgumentsPattern" -> {_, _, {_, _, _.}, {_,_}, _.}};

SequenceTSE[din_,H_,{te_,necho_},{ex_,ref_}, b1_:1]:=Block[{d,tau},
	tau=te/2;
	d=SimRotate[din,H,b1 ex,0];
	(*loop over reg pulses*)
	Table[
		d=SimEvolve[d,H,tau];
		d=SimRotate[d,H,b1 ref,90];
		d=SimEvolve[d,H,tau]
	,{i,0,necho}]
]

SequenceTSE[din_,H_,{te1_,te_,necho_},{ex_,ref_}, b1_:1]:=Block[{d,tau},
	d=SimRotate[din,H,b1 ex,0];
	(*loop over reg pulses*)
	Table[
		tau=If[i==0, te1/2, te/2];
		d=SimEvolve[d,H,tau];
		d=SimRotate[d,H,b1 ref,90];
		d=SimEvolve[d,H,tau]
	,{i,0,necho}]
]


(* ::Subsubsection::Closed:: *)
(*SequenceSpaceEcho*)


SyntaxInformation[SequenceSpaceEcho]={"ArgumentPattern" -> {_, _, _, _, _., _.}}; 

SequenceSpaceEcho[din_, H_, t1_, t2_, nEcho_:1, b1_:1]:=Block[{d,n=2},
	d=SimRotate[din,H,b1 90,0];(*excite*)
	d=SimEvolve[d,H,t1];(*evolve by t1*)
	While[n<=nEcho,
		d=SimRotate[d,H,b1 180,90];(*refocus*)
		d=SimEvolve[d,H,2*t1];(*evolve by 2 times t1*)
		n++];
	d=SimRotate[d,H,b1 180,90];(*refocus*)
	SimEvolve[d,H,t2](*evolve by t2*)
]


(* ::Subsection:: *)
(*ReadOut*)


(* ::Subsubsection::Closed:: *)
(*SimReadout*)


Options[SimReadout] = {
	ReadoutOutput->"all", 
	ReadoutPhase->90, 
	Linewidth->5, 
	LinewidthShape->"Lorentzian", 
	ReadoutSamples -> 2046, 
	ReadoutBandwith -> 2000,
	CenterFrequency -> 4.65,
	ReadoutMethod -> "Fid"
	}

SyntaxInformation[SimReadout]={"ArgumentsPattern" -> {_, _, OptionsPattern[]}};

SimReadout[din_,H_,OptionsPattern[]]:=Block[{
	nsamp, bandwidth, linewidth, output, phase, shape, shift, dt, devolve, di, time, decay, val, fids, samp, 
	valD, matU, nSpins2, Fxy, Ixy, met, delay, te
	},
	
	nsamp = OptionValue[ReadoutSamples];
	bandwidth = OptionValue[ReadoutBandwith];
	linewidth = OptionValue[Linewidth];
	met = OptionValue[ReadoutMethod];
	output = OptionValue[ReadoutOutput];
	phase = OptionValue[ReadoutPhase];
	shape = OptionValue[LinewidthShape];
	shift = OptionValue[CenterFrequency];
	
	(*Get hamiltonian info*)
	{valD, matU, nSpins2, Fxy, Ixy}={"Hval","Hvec","nSpins2","wFxy","wIxy"}/.H;
	(*evlolve matrix*)
	dt = 1./bandwidth;
	devolve = SimEvolveM[matU,valD,dt];
	(*initial signal and spin state*)
	di = din;
	
	(*get the time*)
	time = dt (Range[nsamp]-1);	
	{met, delay, te} = If[StringQ[met], {met, 0, Max[time]}, If[Length[met] == 2, {met[[1]], met[[2]], Max[time]}, met]];
	time = If[met === "Echo", Abs[0.5te - (time + delay)], time + delay];
	
	(*shape and signal definition*)
	decay = If[linewidth===0, 1, 
		Switch[shape,
		"Lorentzian", Exp[-time linewidth],
		"Gaussian", Exp[-time^2 linewidth^2],
		"Voigt", 0.5 Exp[-time linewidth] + 0.5 Exp[-time^2 linewidth^2]
	]];
	val = (1./nSpins2) decay Exp[I phase Degree];
	
	(*perform readout and evolve spin states by dt*)
	fids = val Table[
		samp = If[output === "all", Tr[(di.Fxy)], (Tr[di.#])&/@Ixy];
		di = Chop[devolve.di.ConjugateTranspose[devolve]];
		samp
	,{i,1,nsamp}];
	
	(*output*)
	If[output === "each", {Transpose[fids], di}, {fids, di}]
]



(* ::Subsubsection::Closed:: *)
(*SimSignal*)


Options[SimSignal] = {ReadoutOutput->"all"}

SyntaxInformation[SimSignal] = {"ArgumentsPattern" -> {_, _, OptionsPattern[]}};

SimSignal[din_,H_,OptionsPattern[]]:=Block[{Ixy,w,sel},
	w=(1/"nSpins2")/.H;
	sel=OptionValue[ReadoutOutput];
	Switch[sel,
		(*total signal*)
		"all",w Tr[din.("wFxy"/.H)],
		(*seperate signal for each peak*)
		"each",Ixy=("wIxy"/.H);w Tr[din.#]&/@Ixy,
		(*signal for peak selection either one or list*)
		_,Ixy=("wIxy"/.H);If[ListQ[sel],w Tr[din.Ixy[[#]]]&/@sel,w Tr[din.Ixy[[sel]]]]
	]
]


(* ::Subsection:: *)
(*Spin Systems*)


(* ::Subsubsection::Closed:: *)
(*GetSpinSystem*)


Options[MakeSpinSystem] = {CenterFrequency -> 4.65};

SyntaxInformation[MakeSpinSystem] = {"ArgumentsPattern" -> {_, _., _., _., OptionsPattern[]}};

MakeSpinSystem[nam_, freq_, jcoup_, opts : OptionsPattern[]] := MakeSpinSystem[{nam, freq, jcoup, ConstantArray[1, Length[freq]]}, opts]

MakeSpinSystem[nam_, freq_, jcoup_, scale_, opts : OptionsPattern[]] := MakeSpinSystem[{nam, freq, jcoup, scale}, opts]

MakeSpinSystem[{nam_, freq_, jcoup_}, opts : OptionsPattern[]] := MakeSpinSystem[{nam, freq, jcoup, ConstantArray[1, Length[freq]]}, opts]

MakeSpinSystem[{nam_, freq_, jcoup_, scale_}, OptionsPattern[]] := Block[
	{cf, alf, num, it, sysS, labs, name, sysJ},
	(*get the center frequency*)
	cf = OptionValue[CenterFrequency];
	(*get the alphabet*)
	alf = Capitalize /@ Alphabet[];
	num = Length[freq];
	it = Range[num];
	sysS = freq - cf;
	If[StringQ[nam], name = nam; 
	labs = alf[[;; num]];, {name, labs} = nam;];
	sysJ = SysToMat[jcoup, num];
	{sysJ, sysS, scale, freq, labs, it, name}
]


(* ::Subsubsection::Closed:: *)
(*GetSpinSystem*)


Options[GetSpinSystem] = {CenterFrequency->4.65};

SyntaxInformation[GetSpinSystem]={"ArgumentsPattern" -> {_, OptionsPattern[]}};

GetSpinSystem[name_, OptionsPattern[]]:=Block[{names, n, it, sysS, sysSi, sysJ, scale, j, j1, j2, cf},

	cf=OptionValue[CenterFrequency];
	
	Switch[name,
		"PPA",
		(*single spin system*)
		names={"A"};
		n=Length[names];
		it=Range[n];
		(*sysSi={-2.52,-7.56,-16.15};*)
		sysSi={20};
		sysS=sysSi-cf;
		sysJ={};
		sysJ=SysToMat[sysJ,n];
		scale={1};
		{sysJ,sysS,scale,sysSi,names,it,name}
		,
		"ATP",
		(*single spin system*)
		names={"\[Gamma]","\[Alpha]","\[Beta]"};
		n=Length[names];
		it=Range[n];
		(*sysSi={-2.52,-7.56,-16.15};*)
		sysSi={-2.45,-7.5,-16.0};
		sysS=sysSi-cf;
		sysJ={
			{{1,3},17.31},
			{{2,3},16.12}
		};
		sysJ=SysToMat[sysJ,n];
		scale={1,1,1};
		{sysJ,sysS,scale,sysSi,names,it,name}
		,
		"PCr",
		(*single spin system*)
		names={"A"};
		n=Length[names];
		it=Range[n];
		sysSi={0};
		sysS=sysSi-cf;
		sysJ={};
		sysJ=SysToMat[sysJ,n];
		scale={1};
		{sysJ,sysS,scale,sysSi,names,it,name}
		,
		"Piin",
		(*single spin system*)
		names={"A"};
		n=Length[names];
		it=Range[n];
		sysSi={4.82};
		sysS=sysSi-cf;
		sysJ={};
		sysJ=SysToMat[sysJ,n];
		scale={1};
		{sysJ,sysS,scale,sysSi,names,it,name}
		,
		"Piex",
		(*single spin system*)
		names={"A"};
		n=Length[names];
		it=Range[n];
		sysSi={5.24};
		sysS=sysSi-cf;
		sysJ={};
		sysJ=SysToMat[sysJ,n];
		scale={1};
		{sysJ,sysS,scale,sysSi,names,it,name}
		,
		
		"PE",
		(*single spin system*)
		names={"A"};
		n=Length[names];
		it=Range[n];
		sysSi={6.76};
		sysS=sysSi-cf;
		sysJ={};
		sysJ=SysToMat[sysJ,n];
		scale={1};
		{sysJ,sysS,scale,sysSi,names,it,name}
		,
		"PC",
		(*single spin system*)
		names={"A"};
		n=Length[names];
		it=Range[n];
		sysSi={6.24};
		sysS=sysSi-cf;
		sysJ={};
		sysJ=SysToMat[sysJ,n];
		scale={1};
		{sysJ,sysS,scale,sysSi,names,it,name}
		,
		"GPE",
		(*single spin system*)
		names={"A"};
		n=Length[names];
		it=Range[n];
		sysSi={3.50};
		sysS=sysSi-cf;
		sysJ={};
		sysJ=SysToMat[sysJ,n];
		scale={1};
		{sysJ,sysS,scale,sysSi,names,it,name}
		,
		"GPC",
		(*single spin system*)
		names={"A"};
		n=Length[names];
		it=Range[n];
		sysSi={2.95};
		sysS=sysSi-cf;
		sysJ={};
		sysJ=SysToMat[sysJ,n];
		scale={1};
		{sysJ,sysS,scale,sysSi,names,it,name}
		,
		"NAD",
		(*single spin system*)
		names={"A","B"};
		n=Length[names];
		it=Range[n];
		sysSi={-8.06,-8.34};(*8.2 + 0.13*)
		sysS=sysSi-cf;
		sysJ={
			{{1,2},21}
		};
		sysJ=SysToMat[sysJ,n];
		scale={1,1};
		{sysJ,sysS,scale,sysSi,names,it,name}
		,
		"UDPG",
		(*single spin system*)
		names={"A","B"};
		n=Length[names];
		it=Range[n];
		sysSi={-9.66,-9.94};(*9.8 + 0.13*)
		sysS=sysSi-cf;
		sysJ={
			{{1,2},21}
		};
		sysJ=SysToMat[sysJ,n];
		scale={1,1};
		{sysJ,sysS,scale,sysSi,names,it,name}
		,
		
		
		"glu",
		(*single spin system*)
		names={"A","B","C","D","E"};
		n=Length[names];
		it=Range[n];
		sysSi={3.7433,2.0375,2.1200,2.3378,2.3520};
		sysS=sysSi-cf;
		sysJ={
			{{1,2},7.3310},{{1,3},5.84},
			{{2,3},-14.8490},{{2,4},6.4130},{{2,5},8.406},
			{{3,4},8.4780},{{3,5},6.875},
			{{4,5},-15.915}
		};
		sysJ=SysToMat[sysJ,n];
		scale={1,1,1,1,1};
		{sysJ,sysS,scale,sysSi,names,it,name}
		,
		"lac",
		(*single spin system*)
		names={"A","B","C","D"};
		n=Length[names];
		it=Range[n];
		sysSi={4.0974,1.3142,1.3142,1.3142};
		sysS=sysSi-cf;
		sysJ={
			{{1,2},6.933},{{1,3},6.933},{{1,4},6.933}
		};
		sysJ=SysToMat[sysJ,n];
		scale={1,1,1,1};
		{sysJ,sysS,scale,sysSi,names,it,name}
		,
		"lac2",
		(*single spin system*)
		names={"A","B","C","D"};
		n=Length[names];
		it=Range[n];
		sysSi={4.2,1.32,1.32,1.32};
		sysS=sysSi-cf;
		sysJ={
			{{1,2},7.25},{{1,3},7.25},{{1,4},7.25}
		};
		sysJ=SysToMat[sysJ,n];
		scale={1,1,1,1};
		{sysJ,sysS,scale,sysSi,names,it,name}
		,
		"gaba",
		(*single spin system*)
		names={"A","B","C","D","E","F"};
		n=Length[names];
		it=Range[n];
		sysSi={2.2840, 2.2840, 1.8880, 1.8880, 3.0130, 3.0130};
		sysS=sysSi-cf;
		sysJ={
			{{1,2},-15.938},{{1,3},7.678},{{1,4},6.98},
			{{2,3},6.9800},{{2,4},7.678},
			{{3,4},-15},{{3,5},8.5100},{{3,6},6.503},
			{{4,5},6.503},{{4,6},8.51},
			{{5,6},-14.062}
		};
		sysJ=SysToMat[sysJ,n];
		scale={1,1,1,1,1,1};
		{sysJ,sysS,scale,sysSi,names,it,name}
		,
		
		
		"fatAll",
		(*single spin system*)
		names={"A","B","C","D","E","J"};
		n=Length[names];
		it=Range[n];
		sysSi={0.9,1.3,1.6,2.0,2.3,5.3};
		sysS=sysSi-cf;
		sysJ={
			{{1,2},5.0},
			{{2,3},6},{{2,4},6},
			{{3,5},6},
			{{4,6},6.2}
		};
		sysJ=SysToMat[sysJ,n];
		scale={9,66,6,12,6,6};
		{sysJ,sysS,scale,sysSi,names,it,name}
		,
		
		
		"fatGly",
		(*single spin system*)
		names={"G","G","H","H","I"};
		n=Length[names];
		it=Range[n];
		sysSi={4.2,4.2,4.45,4.45,5.15};
		sysS=sysSi-cf;
		sysJ={
			{{1, 3}, -12.4},{{2, 4}, -12.4},
			{{1, 5}, 7},{{2, 5}, 7},
			{{3, 5}, 7},{{4, 5}, 7}
		};
		sysJ=SysToMat[sysJ,n];
		scale={1,1,1,1,1};
		{sysJ,sysS,scale,sysSi,names,it,name}
		,
		"fatEnd",
		(*single spin system*)
		names={"A","A","A","B","B"};
		n=Length[names];
		it=Range[n];
		sysSi={0.9,0.9,0.9,1.3,1.3};
		sysS=sysSi-cf;
		j=8.0;(*8.0*)
		sysJ={
			{{1,4},j},{{1,5},j},
			{{2,4},j},{{2,5},j},
			{{3,4},j},{{3,5},j}
		};
		sysJ=SysToMat[sysJ,n];
		scale=3{1,1,1,1,1}(*3 chains with head*);
		{sysJ,sysS,scale,sysSi,names,it,name}
		,
		"fatDouble",
		(*single spin system*)
		names={"B","B","D","D","J"};
		n=Length[names];
		it=Range[n];
		sysSi={1.3,1.3,2.08,2.08,5.45};
		sysS=sysSi-cf;
		j1=7.1;j2=6.2;
		sysJ={
			{{1, 3}, j1},{{1, 4}, j1},
			{{2, 3}, j1},{{2, 4}, j1},
			{{3, 5}, j2},{{4, 5}, j2}
		};
		sysJ=SysToMat[sysJ,n];
		scale=6{1,1,1,1,1}(*2x to complete, 3 chains with double*);
		{sysJ,sysS,scale,sysSi,names,it,name}
		,
		"fatDouble2",
		(*single spin system*)
		names={"F","F","J","J"};
		n=Length[names];
		it=Range[n];
		sysSi={2.63,2.63,5.45,5.45};
		sysS=sysSi-cf;
		j=1;
		sysJ={
			{{1,3},j},{{1,4},j},
			{{2,3},j},{{2,4},j}
		};
		sysJ=SysToMat[sysJ,n];
		scale=1{1,1,1,1}(*2x to complete, 3 chains with double*);
		
		{sysJ,sysS,scale,sysSi,names,it,name}
		,
		"fatStart",
		(*single spin system*)
		names={"B","B","C","C","E","E"};
		n=Length[names];
		it=Range[n];
		sysSi={1.3,1.3,1.64,1.64,2.35,2.35};
		sysS=sysSi-cf;
		j1=7.1(*CE*);j2=7.1(*BC*);
		sysJ={(*7.1*)
			{{1, 3}, j1},{{1, 4}, j1},
			{{2, 3}, j1},{{2, 4}, j1},
			{{3, 5}, j2},{{3, 6}, j2},
			{{4, 5}, j2},{{4, 6}, j2}
		};
		sysJ=SysToMat[sysJ,n];
		scale=3 {1,1,1,1,1,1}(*3 chains with start*);
		{sysJ,sysS,scale,sysSi,names,it,name}
		,
		"fatMet",
		names={"B"};
		n=Length[names];
		it=Range[n];
		sysSi={1.3};
		sysS=sysSi-cf;
		sysJ={};
		sysJ=SysToMat[sysJ,n];
		scale=3 2 6{1}(*3 chains with 6 normal met with 2 H*);
		{sysJ,sysS,scale,sysSi,names,it,name}
	]
]

SysToMat[sysJ_,n_]:=Block[{out},
	out=N@ConstantArray[0,{n,n}];
	(out[[#[[1,1]],#[[1,2]]]]=#[[2]])&/@sysJ;
	out
]


(* ::Subsubsection::Closed:: *)
(*SysTable*)


SyntaxInformation[SysTable]={"ArgumentsPattern" -> {_}};

SysTable[sys_]:=Module[{sysJ,sysS,sysSi,scale,names,it,
	head,lab,tables,name},
	tables=(
	{sysJ,sysS,scale,sysSi,names,it,name}=#;
	head=Thread[{(*it,*)names,sysSi,scale}];
	lab={Row[#[[{1}]],"  "]&/@head,Column/@head};
	Column[{Style[name,Bold,Large],TableForm[sysJ/. (0.->"-"),TableHeadings->lab]},Alignment->Center]
	)&/@sys;
	(*Column[tables,Alignment\[Rule]Center,Spacings\[Rule]2]*)
	tables
]


(* ::Section:: *)
(*End Package*)


End[]

EndPackage[]

