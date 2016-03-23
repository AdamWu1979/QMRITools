(* ::Package:: *)

(* ::Title:: *)
(*DTITools ProcessingTools*)


(* ::Subtitle:: *)
(*Written by: Martijn Froeling, PhD*)
(*m.froeling@gmail.com*)


(* ::Section:: *)
(*Begin Package*)


BeginPackage["DTITools`ProcessingTools`",{"Developer`"}];
$ContextPath=Union[$ContextPath,System`$DTIToolsContextPaths];

Unprotect @@ Names["DTITools`ProcessingTools`*"];
ClearAll @@ Names["DTITools`ProcessingTools`*"];


(* ::Section:: *)
(*Usage Notes*)


(* ::Subsection::Closed:: *)
(*Functions*)


TensorCalc::usage = 
"TensorCalc[data, gradients, bvalue] calculates the diffusion tensor for the given dataset. \
Allows for one unweighted image and one b value. \
Gradient directions must be in the form {{x1,y1,z1}, ..., {xn,yn,zn}} without the unweighted gradient direction. \
bvalue is a singe number indicating the b-value used.
TensorCalc[data, gradients, bvec] calculates the diffusion tensor for the given dataset. \
allows for multiple unweighted images and multiple bvalues. \
allows for differnt tensor fitting methods. \
gradient directions must be in the form {{x1,y1,z1}, ..., {xn,yn,zn}} with the unweighted direction as {0,0,0}. \
bvec the bvector, with a bvalue defined for each gradient direction. b value for unweighted images is 0."

EigenvalCalc::usage = 
"EigenvalCalc[tensor] caculates the eigenvalues for the given tensor."

EigenvecCalc::usage =
"EigenvecCalc[tensor] caculates the eigenvectors for the given tensor."

EigensysCalc::usage = 
"EigensysCalc[tensor] caculates the eigensystem for the given tensor."

ADCCalc::usage =
"ADCCalc[eigenvalues] caculates the ADC from the given eigenvalues."

FACalc::usage =
"FACalc[eigenvalues] caculates the FA from the given eigenvalues."

ECalc::usage =
"ECalc[eigenvalues] caculates the e from the given eigenvalues."

ParameterCalc::usage = "ParameterCalc[tensor] caculates the eigenvalues and MD and FA from the given tensor."

SigmaCalc::usage = 
"SigmaCalc[DTI,grad,bvec] calculates the noise sigma based on the tensor residual, using a blur factor of 10.
SigmaCalc[DTI,tens,grad,bvec] calculates the noise sigma based on the tensor residual, using a blur factor of 10.
SigmaCalc[DTI,grad,bvec,blur] calculates the noise sigma based on the tensor residual, If blur is 1 ther is no blurring.
SigmaCalc[DTI,tens,grad,bvec,blur] calculates the noise sigma based on the tensor residual. If blur is 1 ther is no blurring."

SNRCalc::usage = 
"SNRCalc[data,masksig,masknoise] calculates the Signal to noise ratio of the signal selected by masksig and the noise selected by masknoise."

SNRMapCalc::usage =
"SNRMapCalc[data1,noisemap] calcualtes the signal to noise ratio of the data using MN[data]/(1/sqrt[pi/2] sigma), \
where sigma is the local mean of the noise map assuming it is a rician distribution.

SNRMapCalc[{data1,data2}] calcualtes the signal to noise ratio from two identical images using \
MN[data1,data2] / (.5 SQRT[2] STDV[data2-data1]).

SNRMapCalc[{data1, .. dataN}] calcualtes the signal to noise ratio of the data using MN/sigma where the mean signal MN is the average voxe \
value over all dynamics N and the sigma is the standard deviation over all dynamics N."

PhaseCalc::usage = 
"PhaseCalc[B0data] unwraps the two B0 phase maps and calculates the phase difference between the two sets. Output is in radials."

AngleCalc::usage = 
"AngleCalc[data, vector] calculates the angel between the vector and the data. Data shoud be an array of dimensions {xxx,3}."

AngleMap::usage = 
"AngleMap[data] calculates the zennith and azimuth angles of a 3D dataset (z,x,y,3) containing vectors relative to the slice direction."

ResidualCalc::usage =
"ResidualCalc[DTI,tensor,gradients,bvalue] calculates the tensor residuals for the given dataset. \
Allows for one unweighted image and one b value. \
Gradient directions must be in the form {{x1,y1,z1}, ..., {xn,yn,zn}} without the unweighted gradient direction. \
bvalue is a singe number indicating the b-value used.
ResidualCalc[DTI,tensor,gradients,bvector] calculates the tensor residuals for the given dataset. \
allows for multiple unweighted images and multiple bvalues. \
allows for differnt tensor fitting methods. \
gradient directions must be in the form {{x1,y1,z1}, ..., {xn,yn,zn}} with the unweighted direction as {0,0,0}. \
bvec the bvector, with a bvalue defined for each gradient direction. b value for unweighted images is 0."

FitData::usage = 
"FitData[data,range] converts the data into 100 bins within the +/- range around the mean. Function is used in ParameterFit."

ParameterFit::usage = 
"ParameterFit[data] fits a (skew)Normal probability density function to the data.
ParameterFit[{data1, data2,...}] fits a (skew)Normal probability density function to each of the datasets. Is used in Hist."

ParameterFit2::usage = 
"ParameterFit2[data] fits two skewNormal probaility density fucntions to the data. Assuming two compartments, \
one for fat and one for muscle. Is used in SmartMask2 and Hist2."

DatTot::usage = 
"DatTot[{data1, data2, ..}, name, vox] calculates the parameter table conating the volume, mean, std and 95 CI for each of the diffusion parameters."

DatTotXLS::usage = 
"DatTotXLS[{data1, data2, ..}, name, vox] is the same as DatTot, but gives the parameters as strings for easy export to excel."

SliceData::usage = 
"SliceData[data] calculates the mean and std of the diffuison parameters per slice of data."

MeanSignal::usage = 
"MeanSignal[diffdata] calculates the mean signal per volume of the diff data.
MeanSignal[diffdata, pos] calculates the mean signal per volume of the diff data cor the given positions."

FiberDensityMap::usage =
"FiberDensityMap[fiberPoins, dim, vox] generates a fiber density map for the fiberPoins which are imported by LoadFiberTracts. \
The dimensions dim should be the dimensions of the tracked datasets van vox its volxel size."

FiberLengths::usage =
"FiberLengths[fpoints,flines] calculates the fiber lenght using the output from LoadFiberTacts.
FiberLengths[{fpoints,flines}] calculates the fiber lenght using the output from LoadFiberTacts."

DixonToPercent::usage = 
"DixonToPercent[water, fat] converts the dixon water and fat data to percent maps.
DixonToPercent[water, fat,mask] converts the dixon water and fat data within the mask to percent maps."


(* ::Subsection::Closed:: *)
(*Options*)


SmoothPhase::usage = 
"SmoothPhase is an option for PhaseCalc. Defines how the fasemap is smoothed. Default setting is \"Smooth\". Only works when a mask is also given as input. \
Possible values are \"None\", \"Mask\", \"Median\", \"Smooth\", \"Grow\""

Mara::usage = 
"Mara is an option for PhaseCalc. When True it uses a different phase unwrapping and phasemap calculation approach to cope with two legs. Default value is False."

PhaseCorrect::usage = 
"PhaseCorrect is an option for PhaseCalc. Sometimes the enitre dataset is unwraped to the wrong baseline. \
Shifts the entire phasemap with the given value. Default value is 0." 

MonitorCalc::usage = 
"MonitorCalc is an option for all Calc fucntions. When true the proceses of the calculation is shown."

FullOutput::usage = 
"FullOutput is an option for TensorCalc when using bvector. When True also the S0 is given as output."

RejectMap::usage = 
"RejectMap is an option for EigenvalCalc. If Reject is True and RejectMap is True both the eigenvalues aswel as a map showing je rejected values is returned."

Reject::usage = 
"Reject is an option for EigenvalCalc. It True then voxels with negative eigenvalues are rejected and set to 0."

Distribution::usage = 
"Distribution is an option for AngleCalc. values can be \"0-180\", \"0-90\" and \"-90-90\"."

MeanRes::usage = 
"MeanRes is an option for ResidualCalc. When True the root mean square of the residual is calculated."

NormResidual::usage = 
"NormResidual is an option for ResidualCalc. When True the residuals are normalize to the S0 image."

FilterShape::usage = 
"FilterShape is an option for SigmaCalc. Can be \"Gaussian\" of \"Median\"."

FitFunction::usage = 
"FitFunction is an option for ParameterFit. Options are \"Normal\" or \"SkewNormal\". Indicates which function wil be fitted."

FitOutput::usage = 
"FitOutput is an option for ParameterFit and ParameterFit2. Option can be \"Parameters\", \"Function\" or \"BestFitParameters\"."

UseMask::usage = 
"UseMask is a function for MeanSignal and DriftCorrect"

OutputSNR::usage = "OutputSNR is an option for SNRMapCalc."

SeedDensity::usage = "SeedDensity is an option for FiberDensityMap. The seedpoint spacing in mm."

(*
BackgroundFilter::usage = "nog schrijven"
*)


(* ::Subsection::Closed:: *)
(*Error Messages*)


TensorCalc::grad =
"The `2` gradient directions defined do not match the `1` gradients directions in the data set.";

TensorCalc::data =
"Data set dimensions (`1`D) unknown, posibilities:
- Multiple slices (4D)-> {slices, directions, x,y}
- Single slice (3D)-> {directions, x, y}
- Multiple voxels (2D)-> {directions, voxels}
- Single voxel (1D)-> {directions}";

TensorCalc::bvec =
"the `1` gradient directions do not match the `2` b values in the b vector.";

TensorCalc::met =
"The method specified (`1`) is not a valid method, please use: \"LLS\",\"WLLS\",\"NLS\" "

PhaseCalc::inp = 
"The given data is nog a 4D array, or the mask is not a 3D array or the dimensions of the data and the mask are not the same
Dimensions data: `1`; Dimensions mask: `2`";

ParameterFit::func=
"Unknow fit function: `1`. options are SkewNormal or Normal"

ParameterFit::outp=
"Unknow output format: `1`. options are Parameters or Function";

ResidualCalc::datdim=
"DTIdata (`1`) and tensor data (`2`) are not the same dimensions"

AngleCalc::dist = 
"Unknown option (`1`), options can be. \"0-180\", \"0-90\" or \"-90-90\" "


(* ::Section:: *)
(*Functions*)


Begin["`Private`"]


(* ::Subsection::Closed:: *)
(*TensorCalc*)


Options[TensorCalc]= {MonitorCalc->True,Method->"LLS",FullOutput->False};

SyntaxInformation[TensorCalc] = {"ArgumentsPattern" -> {_, _, _., OptionsPattern[]}};

(*bvalue*)
TensorCalc[dat_,gr_,bvalue:_?NumberQ,opts:OptionsPattern[]]:=
Block[{depthD,dirD,dirG,grad,bvec,data},
	
	data=dat;
	(*data=N[Clip[dat,{0,Infinity}]];*)
	
	depthD=ArrayDepth[data];
	dirD=If[depthD==4,Length[data[[1]]],Length[data]];
	dirG=Length[gr];
	
	(*check if data is 4D, 3D, 2D or 1D*)
	If[depthD>4,Return[Message[TensorCalc::data,ArrayDepth[data]]]];
	(*check if gradient dimensions are the same in the data and grad vector*)
	If[(dirD-1)!=dirG,Return[Message[TensorCalc::grad,dirD,dirG]]];
	
	bvec=Prepend[ConstantArray[bvalue,{dirG}],0];
	grad=N[Prepend[gr,{0,0,0}]];
	
	If[OptionValue[Method]!="DKI",
		TensorCalc[data,Bmatrix[bvec,grad],opts],
		TensorCalc[data,Bmatrix[bvec,grad,Method->"DKI"],opts]
	]
]

(*bvector*)
TensorCalc[dat_,grad_,bvec:{_?NumberQ ..},opts:OptionsPattern[]]:=
Block[{data,depthD,rl,rr,dirD,dirG,dirB},
	
	data=dat;
	(*data=N[Clip[dat,{0,Infinity}]];*)

	depthD=ArrayDepth[data];
	rl=RotateRight[Range[depthD]];
	rr=RotateLeft[Range[depthD]];
	dirD=If[depthD==4,Length[data[[1]]],Length[data]];
	dirG=Length[grad];
	dirB=Length[bvec];
	
	(*check if data is 4D, 3D, 2D or 1D*)
	If[depthD>4,Return[Message[TensorCalc::data,ArrayDepth[data]]]];
	(*check if gradient dimensions are the same in the data and grad vector*)
	If[dirD!=dirG,Return[Message[TensorCalc::grad,dirD,dirG]]];
	(*check if bvec is the same lengt as gradient vec*)
	If[dirB!=dirG,Return[Message[TensorCalc::bvec,dirG,dirB]]];
	
	If[OptionValue[Method]!="DKI",
		TensorCalc[data,Bmatrix[bvec,grad],opts],
		TensorCalc[data,Bmatrix[bvec,grad,Method->"DKI"],opts]
	]
]


(*bmatrix*)
TensorCalc[dat_,bmati:{_?ListQ ..},OptionsPattern[]]:=
Block[{dirD,dirB,tensor,rl,rr,TensMin,out,tenscalc,x,data,depthD,xx,met,bmatI,fout,bmat},

	bmat=bmati;
	data=N[Clip[dat,{0,Infinity}]];

	If[!MemberQ[{"LLS","WLLS","NLS","GMM","CLLS","CWLLS","CNLS","DKI"},OptionValue[Method]],Return[Message[TensorCalc::met,OptionValue[Method]]]];
		
	depthD=ArrayDepth[data];
	dirD=If[depthD==4,Length[data[[1]]],Length[data]];
	dirB=Length[bmat];
	
	(*check if data is 4D, 3D, 2D or 1D*)
	If[depthD>4,Return[Message[TensorCalc::data,ArrayDepth[data]]]];
	(*check if bmat is the same lengt as data*)
	If[dirB!=dirD,Return[Message[TensorCalc::bvec,dirD,dirB]]];
	
	bmatI=PseudoInverse[bmat];
	
	(*if data is 4D handle as multiple 3D sets (saves memory and calculation time)*)
	If[depthD==4,
		(*4D data*)
		(*Quiet[LaunchKernels[]];
		xx={};
		met=OptionValue[Method];
		fout=OptionValue[FullOutput];
		SetSharedVariable[xx,data,bmat,bmatI,depthD,met,fout];
		DistributeDefinitions[TensorCalci];
		If[OptionValue[MonitorCalc],PrintTemporary[ProgressIndicator[Dynamic[Max[xx]], {0, Length[data]}]]];
		tensor = ParallelTable[
			AppendTo[xx,x];
			TensorCalci[data[[x]],bmat,bmatI,depthD-1,Method->met,FullOutput->fout]
			,{x,1,Length[data],1}];
			*)
		xx=0;		
		If[OptionValue[MonitorCalc],PrintTemporary[ProgressIndicator[Dynamic[xx], {0, Length[data]}]]];
		tensor = Table[
			xx=x;
			TensorCalci[data[[x]],bmat,bmatI,depthD-1,Method->OptionValue[Method],FullOutput->OptionValue[FullOutput]]
			,{x,1,Length[data],1}];
			
		tensor=Transpose[tensor];
		If[OptionValue[MonitorCalc],Print["Done calculating tensor for "<>ToString[Length[data]]<>" slices!"]];
		(*Other*)
		,
		tensor=TensorCalci[data,bmat,bmatI,depthD,Method->OptionValue[Method],FullOutput->OptionValue[FullOutput]];
		If[depthD==3&&OptionValue[MonitorCalc],Print["Done calculating tensor for 1 slice!"]];
	];
	tensor
]


Options[TensorCalci]= {Method->"LLS",FullOutput->False};

TensorCalci[data_, bmat_, bmatI_, depthD_,OptionsPattern[]]:=Block[
	{rl,rr,TensMin,tensor},
	
	rl=RotateRight[Range[depthD]];
	rr=RotateLeft[Range[depthD]];
	
	TensMin=Quiet[Transpose[Map[Function[S,##[S,(Log[S /. (0. -> 1.)]),bmat,bmatI]],Transpose[data,rl],{depthD-1}],rr]]&;
		
	tensor=Chop[Switch[OptionValue[Method],
		(*"LLS",TensMin[TensMinLLS],
		"WLLS",TensMin[TensMinWLLS],*)
		"LLS", Transpose[TensMinLLS[Transpose[data, rl] /. 0. -> 1., bmatI], rr],
		"WLLS", Transpose[TensMinWLLS[Transpose[data, rl] /. 0. -> 1., bmat, IdentityMatrix[Length[bmat]]], rr],
		"NLS",TensMin[TensMinNLS],
		"GMM",TensMin[TensMinGMM],
		"CLLS",TensMin[TensMinCLLS],
		"CWLLS",TensMin[TensMinCWLLS],
		"CNLS",TensMin[TensMinCNLS],
		(*"DKI",TensMin[TensMinDKI]*)
		"LLS", Transpose[TensMinDKI[Transpose[data, rl] /. 0. -> 1, bmatI], rr]
		],10^-8];
	
	If[OptionValue[FullOutput],
		Return[Join[Clip[Drop[tensor,-1],{-0.1,0.1}],{Exp[Last[tensor]]}]],
		Return[Clip[Drop[tensor,-1],{-0.1,0.1}]]
	];
]



(* ::Subsubsection:: *)
(*LLS*)


(*TensMinLLS[S_,LS_,bmat_,bmatI_]:=bmatI.LS*)
TensMinLLS = Compile[{{S, _Real, 1}, {bmatI, _Real, 2}},
	If[Mean[S]==1.,
    	{0.,0.,0.,0.,0.,0.,0.},	
    	bmatI.Log[S]
	],RuntimeAttributes -> {Listable}, RuntimeOptions -> "Speed"];


(* ::Subsubsection:: *)
(*DKI*)


(*TensMinDKI[S_,LS_,bmat_,bmatI_]:=bmatI.LS*)
TensMinDKI = Compile[{{S, _Real, 1}, {bmatI, _Real, 2}},
	If[Mean[S]==1.,
    	{0.,0.,0.,0.,0.,0.,0.},
    	bmatI.Log[S]
	],RuntimeAttributes -> {Listable}, RuntimeOptions -> "Speed"(*, Parallelization -> True*)];


(* ::Subsubsection:: *)
(*WLLS*)

(*
TensMinWLLS[S_,bmat_,I_]:=
Module[{wmat},
	wmat=Transpose[bmat].DiagonalMatrix[S^2];
	PseudoInverse[wmat.bmat].wmat.Log[S]
]
*)

TensMinWLLS = Block[{wmat,mat},Compile[{{S, _Real, 1}, {bmat, _Real, 2}, {II, _Real, 2}}, 
    If[Mean[S]==1.,
    	{0.,0.,0.,0.,0.,0.,0.},
    	wmat = Transpose[bmat].(II S^2);
    	mat = PseudoInverse[wmat.bmat];
    	mat.wmat.Log[S]
    ]
    ,{{mat,_Real,2},{wmat,_Real,2}}, RuntimeAttributes -> {Listable}, RuntimeOptions -> "Speed"]];


(* ::Subsubsection:: *)
(*NLS*)


TensMinNLS[S_,LS_,bmat_,bmatI_]:=
Module[{v,xx,yy,zz,xy,xz,yz,init,tens,sol},
	tens=bmatI.LS;
	If[tens=={0.,0.,0.,0.,0.,0.,0.},
		tens,
		v={xx,yy,zz,xy,xz,yz,tens[[7]]};
		init=Thread[{v[[1;;6]],tens[[1;;6]]}];
		sol=FindMinimum[.5 Total[(S-Exp[bmat.v])^2],init][[2]];
		v/.sol
	]
]



(* ::Subsubsection:: *)
(*NLS*)


TensMinGMM[S_,LS_,bmat_,bmatI_]:=
Module[{v,xx,yy,zz,xy,xz,yz,init,tens,res,w},
	S;
	tens=bmatI.LS;
	If[tens=={0.,0.,0.,0.,0.,0.,0.},tens,
		v={xx,yy,zz,xy,xz,yz,tens[[7]]};
		init=Thread[{v[[1;;6]],tens[[1;;6]]}];
		v/.FindMinimum[(
			res=LS-bmat.v;
			w=1/(res^2+Mean[res]^2);
			.5 Total[(w/Mean[w])*(res)^2]
		(*w=1/(res^2+(1.4826*Median[Abs[res-Median[res]]])^2);*)
		),init][[2]]
		]
	]


(* ::Subsubsection:: *)
(*CLLS*)


TensMinCLLS[S_,LS_,bmat_,bmatI_]:=
Module[{v,R0,R1,R2,R3,R4,R5,init,tens},
	S;
	tens=bmatI.LS;
	If[tens=={0.,0.,0.,0.,0.,0.,0.},tens,
		v={R0^2,R1^2+R3^2,R2^2+R4^2+R5^2,R0 R3,R0 R4,R3 R4+R1 R5,tens[[7]]};
		init=Thread[{{R0,R1,R2,R3,R4,R5},TensVec[ExtendedCholeskyDecomposition[TensMat[tens]]]}];
		v/.FindMinimum[.5Total[(LS-bmat.v)^2],init][[2]]
		]
	]


(* ::Subsubsection:: *)
(*CWLLS*)


TensMinCWLLS[S_,LS_,bmat_,bmatI_]:=
Module[{v,R0,R1,R2,R3,R4,R5,init,tens,std=1,wmat},
	bmatI;
	wmat=Transpose[bmat].DiagonalMatrix[S^2/std^2];
	tens=PseudoInverse[wmat.bmat].wmat.LS;
	If[tens=={0.,0.,0.,0.,0.,0.,0.},tens,
		v={R0^2,R1^2+R3^2,R2^2+R4^2+R5^2,R0 R3,R0 R4,R3 R4+R1 R5,tens[[7]]};
		init=Thread[{{R0,R1,R2,R3,R4,R5},TensVec[ExtendedCholeskyDecomposition[TensMat[tens]]]}];
		v/.FindMinimum[.5Total[(S^2/std^2)*(LS-bmat.v)^2],init][[2]]
		]
	]


(* ::Subsubsection:: *)
(*CNLS*)


TensMinCNLS[S_,LS_,bmat_,bmatI_]:=
Module[{v,R0,R1,R2,R3,R4,R5,init,tens},
	tens=bmatI.LS;
	If[tens=={0.,0.,0.,0.,0.,0.,0.},tens,
		v={R0^2,R1^2+R3^2,R2^2+R4^2+R5^2,R0 R3,R0 R4,R3 R4+R1 R5,tens[[7]]};
		init=Thread[{{R0,R1,R2,R3,R4,R5},TensVec[ExtendedCholeskyDecomposition[TensMat[tens]]]}];
		v/.FindMinimum[.5Total[(S-Exp[bmat.v])^2],init][[2]]
		]
	]


(* ::Subsubsection:: *)
(*ExtendeCholeskyDecomposition*)


ExtendedCholeskyDecomposition[Tm_]:=
Module[{n,beta,theta,Cm,Lm,Dm,Em,j},
	n=Length[Tm];
	beta=Max[{Max[Diagonal[Tm]],Max[UpperTriangularize[Tm,1]]/Sqrt[n^2-1],10^-15}];
	Cm=DiagonalMatrix[Diagonal[Tm]];
	Lm=Dm=Em=ConstantArray[0,{n,n}];
	For[j=1,j<=3,j++,
		If[j==1,
			(*j=1 maak eerste colom Cm gelijk aan Tm*)
			Cm[[j+1;;,j]]=Tm[[j+1;;,j]];
			,
			(*j>1 vul Lm matrix*)
			Lm[[j,;;j-1]]=Cm[[j,;;j-1]]/(Diagonal[Dm][[;;j-1]]/.(0.->Infinity));
			If[j<n,
				Cm[[j+1;;,j]]=Tm[[j+1;;,j]]-Lm[[j,j-1;;]].Transpose[Cm[[j+1;;,j-1;;]]]
				];
			];
		theta=If[j==n,0,Max[Abs[Cm[[j+1;;,j]]]]];
		Dm[[j,j]]=Max[{Abs[Cm[[j,j]]],theta^2/beta}];
		Em[[j,j]]=Dm[[j,j]]-Cm[[j,j]];
		Cm=Cm-DiagonalMatrix[PadLeft[(1/(Dm[[j,j]]/.(0.->Infinity)))*Cm[[j+1;;,j]]^2,n]];
		];
	Lm=Lm+IdentityMatrix[n];
	Transpose[Lm.MatrixPower[Dm,.5]]
	]


(* ::Subsection::Closed:: *)
(*EigenvalCalc*)


(* ::Subsubsection::Closed:: *)
(*EigenvalCalc*)


Options[EigenvalCalc]= {MonitorCalc->True,RejectMap->False,Reject->True};

SyntaxInformation[EigenvalCalc] = {"ArgumentsPattern" -> {_, OptionsPattern[]}};

EigenvalCalc[tensor_?ArrayQ,OptionsPattern[]]:=
Module[{output},
	Switch[ArrayDepth[tensor],
		4,
		output=EigenvalCalci[Transpose[tensor,{4,1,2,3}],RejectMap->OptionValue[RejectMap],Reject->OptionValue[Reject]];
		If[OptionValue[MonitorCalc],Print["Done calculating eigenvalues for ",Length[tensor[[1]]]," slices!"]];,
		3,
		output=EigenvalCalci[Transpose[tensor,{3,1,2}],RejectMap->OptionValue[RejectMap],Reject->OptionValue[Reject]];
		If[OptionValue[MonitorCalc],Print["Done calculating eigenvalues for 1 slice!"]];,
		1,
		output=EigenvalCalci[tensor,RejectMap->OptionValue[RejectMap],Reject->OptionValue[Reject]];
		If[OptionValue[MonitorCalc],Print["Done calculating eigenvalues for 1 voxel!"]];	
	];
		
	(*If[ArrayQ[tensor,4],
		output=EigenvalCalci[Transpose[tensor,{4,1,2,3}],RejectMap->OptionValue[RejectMap],Reject->OptionValue[Reject]];
		If[OptionValue[MonitorCalc],Print["Done calculating eigenvalues for ",Length[tensor[[1]]]," slices!"]];,
		If[ArrayQ[tensor,3],
			output=EigenvalCalci[Transpose[tensor,{3,1,2}],RejectMap->OptionValue[RejectMap],Reject->OptionValue[Reject]];
			If[OptionValue[MonitorCalc],Print["Done calculating eigenvalues for 1 slice!"]];,
			If[VectorQ[tensor],
				output=EigenvalCalci[tensor,RejectMap->OptionValue[RejectMap],Reject->OptionValue[Reject]];
				If[OptionValue[MonitorCalc],Print["Done calculating eigenvalues for 1 voxel!"]];
				]
			]		
		];*)
	Return[N[output]];
	]


(* ::Subsubsection::Closed:: *)
(*EigenvalCalci*)


Options[EigenvalCalci]={RejectMap->False,Reject->True}

EigenvalCalci[tensor_, OptionsPattern[]] := Module[{rejectmap, values},
  (*calculate eigenvalues*)
  values = Map[Eigenvalues2, tensor, {ArrayDepth[tensor] - 1}];
  (*reject negative eigenvalues*)
  values = If[OptionValue[Reject], RejectEig[values], values];
  (*create rejectmap*)
  If[OptionValue[RejectMap],
  rejectmap = Map[RejectMapi, values, {ArrayDepth[tensor] - 1}];
   {values, rejectmap},
   values
   ]
  ]

Eigenvalues2[{0., 0., 0., 0., 0., 0.}] := {0., 0., 0.};
Eigenvalues2[{0, 0, 0, 0, 0, 0}] := {0., 0., 0.};
Eigenvalues2[tens_] := Eigenvalues[TensMat[tens]];
RejectEig = Compile[{{eig, _Real, 1}}, 
	If[Total[1 - UnitStep[eig]] > 0, {0., 0., 0.}, eig], 
	RuntimeAttributes -> {Listable}, RuntimeOptions -> "Speed", Parallelization -> True];
RejectMapi[{0., 0., 0.}] := 0;
RejectMapi[{_, _, _}] := 1;


(* ::Subsection::Closed:: *)
(*EigenvecCalc*)


(* ::Subsubsection::Closed:: *)
(*EigenvecCalc*)


Options[EigenvecCalc]= {MonitorCalc->False};

SyntaxInformation[EigenvecCalc] = {"ArgumentsPattern" -> {_, OptionsPattern[]}};

EigenvecCalc[tensor_?ArrayQ,OptionsPattern[]]:=
Module[{output},
	
	Switch[ArrayDepth[tensor],
		4,
		output=If[OptionValue[MonitorCalc],
			Monitor[EigenvecCalci[Transpose[tensor,{4,1,2,3}]],ProgressIndicator[Dynamic[Clock[Infinity]], Indeterminate]],
			EigenvecCalci[Transpose[tensor,{4,1,2,3}]]
			];
		If[OptionValue[MonitorCalc],Print["Done calculating eigenvalues for "<>ToString[Length[tensor[[1]]]]<>" slices!"]];,
		3,
		output=EigenvecCalci[Transpose[tensor,{3,1,2}]];
		If[OptionValue[MonitorCalc],Print["Done calculating eigenvalues for 1 slice!"]];,
		1,
		output=EigenvecCalci[tensor];
		If[OptionValue[MonitorCalc],Print["Done calculating eigenvalues for 1 voxel!"]];	
	];
	(*
	If[ArrayQ[tensor,4],
		Monitor[
			output=EigenvecCalci[Transpose[tensor,{4,1,2,3}]];,If[OptionValue[MonitorCalc],ProgressIndicator[Dynamic[Clock[Infinity]], Indeterminate],""]];
		If[OptionValue[MonitorCalc],Print["Done calculating eigenvalues for "<>ToString[Length[tensor[[1]]]]<>" slices!"]];,
		If[ArrayQ[tensor,3],
			output=EigenvecCalci[Transpose[tensor,{3,1,2}]];
			If[OptionValue[MonitorCalc],Print["Done calculating eigenvalues for 1 slice!"]];,
			If[VectorQ[tensor],
				output=EigenvecCalci[tensor];
				If[OptionValue[MonitorCalc],Print["Done calculating eigenvalues for 1 voxel!"]];
				]
			]
		];*)
	Return[output]
	]


(* ::Subsubsection::Closed:: *)
(*EigenvecCalci*)


EigenvecCalci[tensor_]:=
Map[
	If[#[[1]]==#[[2]]==#[[3]]==#[[4]]==#[[5]]==#[[6]],
		{{0,0,1},{0,1,0},{1,0,0}},
		Eigenvectors[{{#[[1]],#[[4]],#[[5]]},{#[[4]],#[[2]],#[[6]]},{#[[5]],#[[6]],#[[3]]}}]
		]&,tensor,{ArrayDepth[tensor]-1}
	]


(* ::Subsection::Closed:: *)
(*EigensysCalc*)


(* ::Subsubsection::Closed:: *)
(*EigensysCalc*)


Options[EigensysCalc]= {MonitorCalc->False};

SyntaxInformation[EigensysCalc] = {"ArgumentsPattern" -> {_, OptionsPattern[]}};

EigensysCalc[tensor_?ArrayQ,OptionsPattern[]]:=
Module[{output},
	
	Switch[ArrayDepth[tensor],
		4,
		output=If[OptionValue[MonitorCalc],
			Monitor[EigensysCalci[Transpose[tensor,{4,1,2,3}]],
				ProgressIndicator[Dynamic[Clock[Infinity]], Indeterminate]],
			EigensysCalci[Transpose[tensor,{4,1,2,3}]]
			];
		If[OptionValue[MonitorCalc],Print["Done calculating eigensystem for "<>ToString[Length[tensor[[1]]]]<>" slices!"]];,
		3,
		output=EigensysCalci[Transpose[tensor,{3,1,2}]];
		If[OptionValue[MonitorCalc],Print["Done calculating eigensystem for 1 slice!"]];,
		2,
		output=EigensysCalci[Transpose[tensor]];
		If[OptionValue[MonitorCalc],Print["Done calculating eigensystem for Row of voxels!"]];,
		1,
		output=EigensysCalci[tensor];
		If[OptionValue[MonitorCalc],Print["Done calculating eigensystem for 1 voxel!"]];	
	];
	(*
	If[ArrayQ[tensor,4],
		output=EigensysCalci[Transpose[tensor,{4,1,2,3}]];
		If[OptionValue[MonitorCalc],Print["Done calculating eigensystem for "<>ToString[Length[tensor[[1]]]]<>" slices!"]];,
		If[ArrayQ[tensor,3],
			output=EigensysCalci[Transpose[tensor,{3,1,2}]];
			If[OptionValue[MonitorCalc],Print["Done calculating eigensystem for 1 slice!"]];,
			If[VectorQ[tensor],
				output=EigensysCalci[tensor];
				If[OptionValue[MonitorCalc],Print["Done calculating eigensystem for 1 voxel!"]];
				]
			]
		];*)
	Return[output]
	]


(* ::Subsubsection::Closed:: *)
(*EigensysCalc*)


EigensysCalci[tensor_]:=
Module[{eig},
	Map[
		If[#[[1]]==#[[2]]==#[[3]]==#[[4]]==#[[5]]==#[[6]],
			{{0,0,0},{{0,0,1},{0,1,0},{1,0,0}}},
			eig=Eigensystem[TensMat[#]];
			If[Positive[eig[[1,1]]]&&Positive[eig[[1,2]]]&&Positive[eig[[1,3]]],eig,{{0,0,0},{{0,0,1},{0,1,0},{1,0,0}}}]
			]&,tensor,{ArrayDepth[tensor]-1}
		]
	]


(* ::Subsection::Closed:: *)
(*ADCCalc*)


SyntaxInformation[ADCCalc] = {"ArgumentsPattern" -> {_}};

ADCCalc[eig_] := ADCCalci[eig]

ADCCalci = Compile[{{eig, _Real, 1}}, Mean[eig], RuntimeAttributes -> {Listable}, RuntimeOptions -> "Speed", Parallelization -> True];

(*
ADCCalc[eigen_,OptionsPattern[]]:=
Module[{output,slices,x},
	slices=Length[eigen];
	If[ArrayQ[eigen,4],
		(*#D array calculate per slice*)
		If[OptionValue[MonitorCalc],
			Monitor[output=Table[ADCCalci[eigen[[x]]],{x,1,slices,1}];,Column[{"Calculation ADC for Multiple slices",ProgressIndicator[x,{0,slices}]}]],
			output=Table[ADCCalci[eigen[[x]]],{x,1,slices,1}];	
		];
		If[OptionValue[MonitorCalc],Print["Done calculating ADC for "<>ToString[slices]<>" slices!"]];
		,
		output=ADCCalci[eigen];
		If[OptionValue[MonitorCalc],
			If[ArrayQ[eigen,3],Print["Done calculating ADC for 1 slice!"]];
			If[VectorQ[eigen],Print["Done calculating ADC for 1 voxel!"]];
			]
		];
	Return[output];
	]


ADCCalci[eigen_]:=
Module[{ADCC},
	ADCC=Compile[{l1,l2,l3},Mean[{l1,l2,l3}]];
	Map[If[#=={0,0,0},0,
		ADCC[#[[1]],#[[2]],#[[3]]]
		]&,eigen,{ArrayDepth[eigen]-1}]
	]
*)


(* ::Subsection::Closed:: *)
(*FACalc*)


SyntaxInformation[FACalc] = {"ArgumentsPattern" -> {_}};

FACalc[eig_] := FACalci[eig]

FACalci = Block[{l1, l2, l3, teig},Compile[{{eig, _Real, 1}}, 
   	teig = Sqrt[2.*Total[eig^2]];
    If[teig == 0., 
    	0.,
    	l1 = eig[[1]];	l2 = eig[[2]];	l3 = eig[[3]];
    	Sqrt[(l1 - l2)^2 + (l2 - l3)^2 + (l1 - l3)^2]/teig
    	]
    	, 
    {{l1, _Real, 0}, {l3, _Real, 0}, {l3, _Real, 0}},
     RuntimeAttributes -> {Listable}, RuntimeOptions -> "Speed"(*, Parallelization -> True*)]];

(*
FACalc[eigen_,OptionsPattern[]]:=
Module[{output,x,slices},
	slices=Length[eigen];
	If[ArrayQ[eigen,4],
		(*3D array calculate per slice*)
		If[OptionValue[MonitorCalc],
			Monitor[output=Table[FACalci[eigen[[x]]],{x,1,slices,1}];,Column[{"Calculation FA for Multiple slices",ProgressIndicator[x,{0,slices}]}]],
			output=Table[FACalci[eigen[[x]]],{x,1,slices,1}];	
		];
		
		If[OptionValue[MonitorCalc],Print["Done calculating FA for "<>ToString[slices]<>" slices!"]];
		,
		output=FACalci[eigen];
		If[OptionValue[MonitorCalc],
			If[ArrayQ[eigen,3],Print["Done calculating FA for 1 slice!"]];
			If[VectorQ[eigen],Print["Done calculating FA for 1 voxel!"]]
			];
		];
	Return[Clip[output,{0,1}]];
	]


FACalci[eigen_]:=
Module[{FAC},
	FAC=Compile[{l1,l2,l3},Sqrt[(l1-l2)^2+(l2-l3)^2+(l1-l3)^2]/Sqrt[2*(l1^2+l2^2+l3^2)]];
	Map[If[#=={0,0,0},0,
		FAC[#[[1]],#[[2]],#[[3]]]
		]&,eigen,{ArrayDepth[eigen]-1}]
	]
*)


(* ::Subsection::Closed:: *)
(*ECalc*)


Options[ECalc]= {MonitorCalc->True};

SyntaxInformation[ECalc] = {"ArgumentsPattern" -> {_, OptionsPattern[]}};

ECalc[eigen_,OptionsPattern[]]:=
Module[{output,slices,x},
	slices=Length[eigen];
	If[ArrayQ[eigen,4],
		Monitor[output=Table[ECalci[eigen[[x]]],{x,1,slices,1}];,If[OptionValue[MonitorCalc],Column[{"Calculation E for Multiple slices",ProgressIndicator[x,{0,slices}]}],""]];
		If[OptionValue[MonitorCalc],Print["Done calculating e for "<>ToString[slices]<>" slices!"]];
		,
		output=ECalci[eigen];
		If[ArrayQ[eigen,3],If[OptionValue[MonitorCalc],Print["Done calculating e for 1 slice!"]],
			If[VectorQ[eigen],If[OptionValue[MonitorCalc],Print["Done calculating e for 1 voxel!"]]]
			]
		];
	Return[output];
	]


ECalci[eigen_]:=
Module[{EC},
	EC=Compile[{l1,l3},Sqrt[1-(l3/l1)]];
	Map[If[#[[3]]!=0,
		EC[#[[1]],#[[3]]],
		0]&,eigen,{ArrayDepth[eigen]-1}]
	]


(* ::Subsection::Closed:: *)
(*ParameterCalc*)


Options[ParameterCalc]={Reject->True,MonitorCalc->False}

SyntaxInformation[ParameterCalc] = {"ArgumentsPattern" -> {_, OptionsPattern[]}};

ParameterCalc[tensor_,OptionsPattern[]]:=
Module[{eig,adc,fa},
	eig=1000.*EigenvalCalc[tensor,Reject->OptionValue[Reject],MonitorCalc->OptionValue[MonitorCalc]];
	adc=ADCCalc[eig];
	fa=FACalc[eig];
	Switch[ArrayDepth[tensor],
		1,
		{eig[[1]],eig[[2]],eig[[3]],adc,fa},
		2,
		{eig[[All,1]],eig[[All,2]],eig[[All,3]],adc,fa},
		3,
		{eig[[All,All,1]],eig[[All,All,2]],eig[[All,All,3]],adc,fa},
		4,
	{eig[[All,All,All,1]],eig[[All,All,All,2]],eig[[All,All,All,3]],adc,fa}
	]
	]


(* ::Subsection::Closed:: *)
(*PhaseCalc*)


Options[PhaseCalc]={SmoothPhase->"Smooth",BackgroundFilter->6,MonitorUnwrap->True,UnwrapDimension->"2D"};

SyntaxInformation[PhaseCalc] = {"ArgumentsPattern" -> {_, _., OptionsPattern[]}};

PhaseCalc[dat_?ArrayQ, opts : OptionsPattern[]] :=PhaseCalc[dat, 1, opts]

PhaseCalc[dat_?ArrayQ, mask_,OptionsPattern[]] :=
Module[{B0data, B0unw, phase, data},
  If[mask != 1 && Dimensions[dat[[All, 1]]] != Dimensions[mask], 
   Return["error"]];
   data=If[Min[dat]>=-Pi&&Max[dat]<=Pi,
   	Transpose[dat],
   	N[(((1.53455433455433 Transpose[dat]) - 3142)/1000)]
   ];
  B0data = mask*(data[[2]] - data[[1]]);
  B0unw = Unwrap[B0data, BackgroundFilter->OptionValue[BackgroundFilter],MonitorUnwrap->OptionValue[MonitorUnwrap],UnwrapDimension->OptionValue[UnwrapDimension]];
  phase = 
   Switch[OptionValue[SmoothPhase], 
   	"None", Chop[B0unw], 
   	"Median",Chop[MedianFilter[B0unw, 1]], 
    "Smooth", Chop[GaussianFilter[MedianFilter[B0unw, 1], 3]]];
  Return[phase]]


(* ::Subsection::Closed:: *)
(*AngleCalc*)


Options[AngleCalc]={Distribution->"0-180"};

SyntaxInformation[AngleCalc] = {"ArgumentsPattern" -> {_, _, OptionsPattern[]}};

AngleCalc[data_?ArrayQ,vec_?VectorQ,OptionsPattern[]]:=
Module[{angles},
	angles=Map[If[Re[#]==#,ArcCos[#.vec],"no"]&,data,{Depth[data]-2}];
	
	Switch[
		OptionValue[Distribution],
		"0-180",
		(180/Pi)angles,
		"0-90",
		Map[If[#!="no",If[#>=1/2Pi,(180/Pi)(Pi-#),(180/Pi)(#)]]&,angles,{ArrayDepth[angles]}],
		"-90-90",
		Map[If[#!="no",If[#>=1/2Pi,(180/Pi)(#-Pi),(180/Pi)(#)]]&,angles,{ArrayDepth[angles]}],
		_,
		Message[AngleCalc::dist,OptionValue[Distribution]]
		]
	]

AngleCalc[data_?ArrayQ,vec_?ArrayQ,OptionsPattern[]]:=
Module[{angles},
	If[Dimensions[data]!=Dimensions[vec],
		Print["Error"],
		
		angles=MapThread[If[Re[#1]==#1,ArcCos[#1.#2],"no"]&,{data,vec},ArrayDepth[vec]-1];
		
		Switch[
			OptionValue[Distribution],
			"0-180",
			(180/Pi)angles,
			"0-90",
			Map[If[#!="no",If[#>=1/2Pi,(180/Pi)(-(#-Pi)),(180/Pi)(#)]]&,angles,{ArrayDepth[angles]}],
			"-90-90",
			Map[If[#!="no",If[#>=1/2Pi,(180/Pi)(#-Pi),(180/Pi)(#)]]&,angles,{ArrayDepth[angles]}],
			_,
			Message[AngleCalc::dist,OptionValue[Distribution]]
			]
		]
	]


(* ::Subsection::Closed:: *)
(*AngleMap*)


SyntaxInformation[AngleMap] = {"ArgumentsPattern" -> {_}};

AngleMap[vec_]:=
Module[{az,zen},
	Transpose[Map[If[#=={0,0,1},
		{0,0},
		If[Negative[#[[3]]],v=-#,v=#];
		az=ArcCos[v[[3]]]/Degree;
		zen=ArcTan[v[[2]],v[[1]]]/Degree;
		(*zen=If[zen<-90,zen+180,If[zen>90,zen-180,zen]];*)
		zen=If[Negative[zen],zen+180,zen];
		{az,zen}
		]&,vec,{3}],{2,3,4,1}]
	]


(* ::Subsection::Closed:: *)
(*ResidualCalc*)


Options[ResidualCalc] = {MonitorCalc -> False, MeanRes -> "All", NormResidual -> True};

SyntaxInformation[ResidualCalc] = {"ArgumentsPattern" -> {_, _, _, _, OptionsPattern[]}};

ResidualCalc[data_?ArrayQ, tensor_?ArrayQ, grad : {{_?NumberQ, _?NumberQ, _?NumberQ} ..}, bfac_, OptionsPattern[]] := Module[
	{DTI = N[data], err, bmat, x,mr,n,tens},
	
	bmat = If[NumberQ[bfac] || VectorQ[bfac], Bmatrix[bfac, grad], bfac];
  
  If[Dimensions[DTI[[All, 1]]] != Dimensions[tensor[[1]]], 
  	Return[Message[ResidualCalc::datdim, Dimensions[DTI], Dimensions[tensor]]]];
  
  Monitor[
   err = Table[
   If[Length[tensor[[All, x]]] == 6,
    bmat = bmat[[All, ;; 6]];
    DTI[[x]] - ((DTI[[x, 1]]*#) & /@ Exp[bmat.tensor[[All, x]]])
    ,
    tens=tensor[[All, x]];
    tens[[7]] = Log[tens[[7]]];
    DTI[[x]] - Exp[bmat.tens]
    
    ], {x, 1, Length[DTI], 1}];
   ,
   If[OptionValue[MonitorCalc], Column[{"Calculation residual for multiple slices", ProgressIndicator[x, {0, Length[DTI]}]}], ""]];
  
  If[OptionValue[MonitorCalc],Print["Done calculating residual for ", Length[DTI], " slices!"]];
  
  n=If[Length[tensor] == 6, 2,1];
  Switch[
   OptionValue[MeanRes],
   "All",
   err // N,
   "RMSE",
   PrintTemporary["Calculating root mean square residual"];
   Sqrt[Mean[Drop[Transpose[err], 1]^2]] // N,
   "MAD",
   PrintTemporary["Calculating MAD residual estimation"];
   mr = Median[Transpose[err][[n ;;]]];
   Median[Abs[# - mr] & /@ Transpose[err][[n ;;]]]
   ]
  ]


(* ::Subsection:: *)
(*ParameterFit*)


(* ::Subsubsection::Closed:: *)
(*ParameterFit*)


Options[ParameterFit]={FitFunction->"SkewNormal",FitOutput->"Parameters"}

SyntaxInformation[ParameterFit] = {"ArgumentsPattern" -> {_, OptionsPattern[]}};

ParameterFit[dat:{_?ListQ..},OptionsPattern[]]:=
Module[{mod,out},
	mod=OptionValue[FitFunction];
	out=OptionValue[FitOutput];
	ParameterFit[Flatten[#],FitFunction->mod,FitOutput->out]&/@dat
	]


ParameterFit[dat_List,OptionsPattern[]]:=
Module[{sol,par,data,mod,out,Omega,Xi,Alpha,Mu,Sigma,x},
	Off[NonlinearModelFit::"cvmit"];Off[NonlinearModelFit::"sszero"];
	mod=OptionValue[FitFunction];
	out=OptionValue[FitOutput];
	
	data=DeleteCases[Flatten[dat//N],0.];
	If[data=={}||Length[data]<=5,
		par={Null,Null},
		Switch[mod,
			"SkewNormal",
			sol=NonlinearModelFit[FitData[data],SkewNorm[x,Omega,Xi,Alpha],{Omega,Xi,Alpha},x];
			par={Mn[Omega,Xi,Alpha],Sqrt[Var[Omega,Alpha]]}/.sol["BestFitParameters"];,
			"Normal",
			sol=NonlinearModelFit[FitData[data],RegNorm[x,Mu,Sigma],{Mu,Sigma},x];
			par={Mu,Sigma}/.sol["BestFitParameters"];,
			_,
			Message[ParameterFit::func,mod]
			]
	];
	On[NonlinearModelFit::"cvmit"];On[NonlinearModelFit::"sszero"];
	Switch[
		out,
		"Parameters",
		par,
		"Function",
		sol,
		"BestFitParameters",
		{Omega,Xi,Alpha}/.sol["BestFitParameters"]
		,
		_,
		Message[ParameterFit::outp,out]
		]
	]


(* ::Subsubsection::Closed:: *)
(*ParameterFit2*)


Options[ParameterFit2]={FitOutput->"BestFitParameters"}

SyntaxInformation[ParameterFit2] = {"ArgumentsPattern" -> {_, OptionsPattern[]}};

ParameterFit2[dat_List,OptionsPattern[]]:=
Module[{i,datf,init,out,sol,par,
	Omega1i,Omega2i,Alpha1i,Alpha2i,Xi1i,Xi2i,
	Omega1,Xi1,Alpha1,Omega2,Xi2,Alpha2},
	Off[NonlinearModelFit::cvmit];Off[NonlinearModelFit::eit];Off[NonlinearModelFit::sszero];
	
	init={
		{.2,.2,0,0,.6,2.1},
		{.2,.2,0,0,.6,1.6},
		{.2,.2,0,0,.6,1.3},
		{.2,.2,0,0,.6,1.7},
		{.2,.2,0,0,.3,.2}
		};
	datf=DeleteCases[DeleteCases[Flatten[#]//N,0.],1.]&/@dat;
	out=OptionValue[FitOutput];
	i=0;
	sol=MapThread[
		(
		i++;
		{Omega1i,Omega2i,Alpha1i,Alpha2i,Xi1i,Xi2i}=#2;
		NonlinearModelFit[
			FitData[#1,3.5],
			{f SkewNorm[x,Omega1,Xi1,Alpha1]+(1-f)SkewNorm[x,Omega2,Xi2,Alpha2],
			0<=f<=1,
			0<Omega1,
			0<Omega2,
			0<Mn[Omega1,Xi1,Alpha1]<1,
			If[i==5,Mn[Omega1,Xi1,Alpha1]>1.2Mn[Omega2,Xi2,Alpha2],Mn[Omega1,Xi1,Alpha1]<Mn[Omega2,Xi2,Alpha2]],
			If[i==5,-2<Alpha1<0,-1.5<Alpha1<1.5],
			If[i==5,0<Alpha2<2,-1.5<Alpha2<1.5]},
			{{f,0.5},{Omega1,Omega1i},{Omega2,Omega2i},{Alpha1,Alpha1i},{Alpha2,Alpha2i},{Xi1,Xi1i},{Xi2,Xi2i}},
			x,MaxIterations->1000]
		)&,{datf,init}];
	
	par={Mn[Omega1,Xi1,Alpha1],Sqrt[Var[Omega1,Alpha1]]}/.#["BestFitParameters"]&/@sol;
	
	On[NonlinearModelFit::cvmit];On[NonlinearModelFit::eit];On[NonlinearModelFit::sszero];
	
	Switch[
		out,
		"Parameters",
		{Mn[Omega1,Xi1,Alpha1],Sqrt[Var[Omega1,Alpha1]],Mn[Omega2,Xi2,Alpha2],Sqrt[Var[Omega2,Alpha2]]}/.#["BestFitParameters"]&/@sol,
		"Function",
		sol,
		"BestFitParameters",
		{f,Omega1,Omega2,Xi1,Xi2,Alpha1,Alpha2}/.#["BestFitParameters"]&/@sol,
		_,
		Message[ParameterFit::outp,out]
		]
	]


(* ::Subsubsection::Closed:: *)
(*FitData*)


SyntaxInformation[FitData] = {"ArgumentsPattern" -> {_, _.}};

FitData[dat_,sdr_:2]:=
Module[{m, s, min, max, range, step, xdat, data, out}, 
  If[dat == {} || Length[dat] == 1, {}, m = Mean[dat];
   s = StandardDeviation[dat];
   min = (m - sdr s); max = (m + sdr s);
   range = max - min;
   step = range/100;
   data = BinCounts[dat, {min, max, step}];
   xdat = Range[min + 0.5 step, max - 0.5 step, step];
   out = Transpose[{xdat, data/Length[dat]/step}];
   DeleteCases[out, {_, 0.}]
   ]
  ];


(* ::Subsubsection::Closed:: *)
(*RegNorm*)


RegNorm[x_,Mu_,Sigma_]:=1/(E^((x - Mu)^2/(2*Sigma^2))*(Sqrt[2*Pi]*Sigma));


(* ::Subsubsection::Closed:: *)
(*SkewNorm*)


Phi[x_]:=1/(E^(x^2/2)*Sqrt[2*Pi]);
CapitalPhi[x_]:=.5(1+Erf[(x)/Sqrt[2]]);
SkewNorm[x_,Omega_,Xi_,Alpha_]:=(2/Omega)Phi[(x-Xi)/Omega]CapitalPhi[Alpha (x-Xi)/Omega];
Delta[a_]:=a/Sqrt[1+a^2];
Mn[w_,e_,a_]:=e+w Delta[a] Sqrt[2/Pi];
Var[w_,a_]:=w^2(1-(2Delta[a]^2/Pi));


SkewNormC=Compile[{{x, _Real},{Omega, _Real},{Xi, _Real},{Alpha, _Real}},
Chop[(2/Omega)(1/(E^(((x-Xi)/Omega)^2/2)*Sqrt[2*Pi]))(.5(1+Erf[((Alpha (x-Xi)/Omega))/Sqrt[2]]))]
];


(* ::Subsection::Closed:: *)
(*DataTot and DataTotXLS*)


SyntaxInformation[DatTot] = {"ArgumentsPattern" -> {_, _, _}};

DatTot[data_,name_,vox_]:=
Module[{fitdat},
	fitdat=ParameterFit[DeleteCases[Flatten[#],Null]&/@data];
	With[{Quant=Function[dat,{dat[[1]],dat[[2]],100dat[[2]]/dat[[1]]}]},
		Flatten[{name,vox[[1]],vox[[2]],Quant[fitdat[[1]]],Quant[fitdat[[2]]],Quant[fitdat[[3]]],Quant[fitdat[[4]]],Quant[fitdat[[5]]]}]
		]
	]

SyntaxInformation[DatTotXLS] = {"ArgumentsPattern" -> {_, _, _}};

DatTotXLS[data_,name_,vox_]:=
Module[{fitdat},
	fitdat=ParameterFit[DeleteCases[Flatten[#],Null]&/@data];
	With[{Quant=Function[dat,ToString[Round[dat[[1]],.01]]<>" \[PlusMinus] "<>ToString[Round[dat[[2]],.01]]]},
		Flatten[{name,vox[[1]],vox[[2]],Quant[fitdat[[1]]],Quant[fitdat[[2]]],Quant[fitdat[[3]]],Quant[fitdat[[4]]],Quant[fitdat[[5]]]}]
		]
	]


(* ::Subsection::Closed:: *)
(*SliceData*)


SyntaxInformation[SliceData] = {"ArgumentsPattern" -> {_}};

SliceData[data_]:=
Module[{fitdat},
	fitdat=ParameterFit[DeleteCases[#,Null,{2}]]&/@data;
	Prepend[MapIndexed[Flatten[{#2,#1}]&,Transpose[fitdat]],
	{"Slice Number","first-Mean","first-SD","second-Mean","second-SD","third-Mean","third-SD","ADC-Mean","ADC-SD","FA-Mean","FA-SD"}]
	]


(* ::Subsection::Closed:: *)
(*SigmaCalc*)


Options[SigmaCalc] = {FilterShape -> "Median"};

SyntaxInformation[SigmaCalc] = {"ArgumentsPattern" -> {_, _, _, _., _., OptionsPattern[]}};

SigmaCalc[DTI_?ArrayQ, grad : {{_, _, _} ..}, bvalue_, blur_: 2, OptionsPattern[]] := Module[
	{tens, res,len,sig}, 
  tens = TensorCalc[DTI, grad, bvalue, MonitorCalc -> False];
  res = ResidualCalc[DTI, tens, grad, bvalue, MeanRes -> "MAD"];
  len = Length[grad];
  sig = Sqrt[len/(len - 7)]*res;
   PrintTemporary["Filtering noisemap"];
  Switch[OptionValue[FilterShape],
   "Gaussian",
   GaussianFilter[sig, blur],
   "Median",
   MedianFilter[sig, blur]
   ]
  ]


SigmaCalc[DTI_?ArrayQ, tens_?ArrayQ, grad : {{_, _, _} ..}, bvalue_, blur_: 2, OptionsPattern[]] := Module[
	{res,len,sig},
  res = ResidualCalc[DTI, tens, grad, bvalue, MeanRes -> "MAD"];
  len = Length[grad];
  sig = Sqrt[len/(len - 7)]*res;
   PrintTemporary["Filtering noisemap"];
  Switch[OptionValue[FilterShape],
   "Gaussian",
   GaussianFilter[sig, blur],
   "Median",
   MedianFilter[sig, blur]
   ]
  ]


(* ::Subsection::Closed:: *)
(*SNRCalc*)


SyntaxInformation[SNRCalc] = {"ArgumentsPattern" -> {_, _, _}};

SNRCalc[data_?ArrayQ,mask1_?ArrayQ,mask2_?ArrayQ]:=
Module[{noise,signal,Msignal,Mnoise},
	signal=GetMaskData[data,mask1];
	noise=GetMaskData[data,mask2];
	Mnoise=Mean[Flatten[noise]];
	Msignal=N[Map[Mean[#]&,signal]]/.Mean[{}]->0;
	Msignal/(0.8Mnoise)/.(1/Mean[{}])->0
	]



(* ::Subsection::Closed:: *)
(*SNRMapCalc*)


Options[SNRMapCalc] = {OutputSNR -> "SNR"};

SyntaxInformation[SNRMapCalc] = {"ArgumentsPattern" -> {_, _., _., OptionsPattern[]}};

SNRMapCalc[data_?ArrayQ, noise_?ArrayQ, k_: 2, OptionsPattern[]] := 
 Module[{sigma, sigmac, snr},
  sigmac = (sigma = N[GaussianFilter[noise, 5]]) /. 0. -> Infinity;
  snr = GaussianFilter[data/((1/Sqrt[Pi/2.]) sigmac), k];
  Switch[OptionValue[OutputSNR],
	 "Sigma", sigma,
	 "Both", {snr, sigma},
	 _, snr
	 ]
  ]

SNRMapCalc[{data1_?ArrayQ, data2_?ArrayQ}, k_: 2, OptionsPattern[]] := 
 Module[{noise, signal, sigma, snr},
  noise = (data1 - data2);
  signal = Mean[{data1, data2}];
  sigma = ConstantArray[StandardDeviation[DeleteCases[Flatten[noise] // N, 0.]],Dimensions[signal]];
  snr = GaussianFilter[signal/(.5 Sqrt[2] sigma), k];
  Switch[OptionValue[OutputSNR],
	 "Sigma", sigma,
	 "Both", {snr, sigma},
	 _, snr
	 ]
 ]

SNRMapCalc[data : {_?ArrayQ ...}, k_: 2, OptionsPattern[]] := 
 Module[{signal, sigma, snr,div},
  signal = Mean[data];
  sigma = Chop[StandardDeviation[data]]-10^-15;
  div=Clip[signal / sigma, {0, Infinity}];
  div=Clip[div, {0., 100 Median[DeleteCases[Flatten[div], 0.]]}];
  snr = GaussianFilter[div, k];
  
  Switch[OptionValue[OutputSNR],
	 "Sigma", sigma,
	 "Both", {snr, sigma},
	 _, snr
	 ]
 ]


(* ::Subsection::Closed:: *)
(*MeanSignal*)

Options[MeanSignal]={UseMask->True}

SyntaxInformation[MeanSignal] = {"ArgumentsPattern" -> {_, _.,OptionsPattern[]}};

MeanSignal[data_, opts : OptionsPattern[]] := MeanSignal[data, 1, opts];

MeanSignal[data_, pos_: 1,OptionsPattern[]] := Block[{datat, mean, mask},
  datat = Transpose[data];
  
  If[ListQ[pos],
   mask = If[OptionValue[UseMask],
   	Round@GaussianFilter[Mask[datat[[First@pos]]/MeanNoZero[datat[[First@pos]]], .5], 5],
   	ConstantArray[1,Dimensions[data[[All,1]]]]];   
   mean = MeanNoZero[Flatten[#]] & /@ Transpose[MaskDTIdata[data[[All, pos]], mask]];
   ,
   mask = If[OptionValue[UseMask],
   	Round@GaussianFilter[Mask[datat[[pos]]/MeanNoZero[datat[[pos]]], .5], 5],
   	ConstantArray[1,Dimensions[data[[All,1]]]]];
   mean = MeanNoZero[Flatten[#]] & /@ Transpose[MaskDTIdata[data, mask]];
   ];
  N@mean
  ]


(* ::Subsection::Closed:: *)
(*FiberDensityMap*)


Options[FiberDensityMap] = {SeedDensity -> Automatic};

SyntaxInformation[FiberDensityMap] = {"ArgumentsPattern" -> {_, _, _,OptionsPattern[]}};

FiberDensityMap[fibers_, dim_, vox_, OptionsPattern[]] := 
 Module[{pixindex, density, dens,densi},
  pixindex = GetFiberCoor[fibers, vox];
  pixindex = Transpose[MapThread[Clip[#1, {1, #2}] &, {Transpose[pixindex], dim}]];
  density = CountVoxels[ConstantArray[0, dim], pixindex];
  densi = OptionValue[SeedDensity];
  (*Print[{(Times @@ vox)/0.75,Median[DeleteCases[Flatten[density], 0]]}];*)
  dens = If[NumberQ[densi],
    Times @@ (vox/densi),
    Median[DeleteCases[Flatten[density], 0]]
    ];
  Clip[NormalizeDens[density, dens], {0., 10.}]
  ]

GetFiberCoor = Compile[{{fibcor, _Real, 1}, {vox, _Real, 1}},
   Round[Reverse[fibcor + vox]/vox],
   RuntimeAttributes -> {Listable}, RuntimeOptions -> "Speed", 
   Parallelization -> True];

CountVoxels = Compile[{{const, _Integer, 3}, {pix, _Integer, 2}}, Block[{out = const},
    (out[[#[[1]], #[[2]], #[[3]]]] += 1) & /@ pix;
    out
    ]];

NormalizeDens = Compile[{{dens, _Integer, 3}, {n, _Real, 0}}, dens/n];


(* ::Subsection::Closed:: *)
(*FiberLengths*)


SyntaxInformation[FiberLengths] = {"ArgumentsPattern" -> {_, _.}};

FiberLengths[fpoints_, flines_] := FiberLengths[{fpoints, flines}]
FiberLengths[{fpoints_, flines_}] := Module[{len, mpos},
   len = (Length /@ flines) - 1;
   mpos = First@First@Position[len, Max[len]];
   len Mean[EuclideanDistance @@@ Partition[fpoints[[flines[[mpos]]]], 2, 1]]
];


(* ::Subsection::Closed:: *)
(*DixonToPercent*)


SyntaxInformation[DixonToPercent] = {"ArgumentsPattern" -> {_, _, _.}};

DixonToPercent[water_, fat_, maskt_:1] := 
 Block[{tot, fatMap, waterMap, fmask},
  tot = fat + water + 10^-10;
  fatMap = maskt fat/tot;
  waterMap = maskt water/tot;
  fmask = Mask[fat, 50];
  fatMap = maskt (fmask fatMap + (1 - fmask) (1 - waterMap));
  waterMap = maskt (1 - fatMap);
  {waterMap, fatMap}/. 1->0;
  ]


(* ::Section:: *)
(*End Package*)


End[]

SetAttributes[#,{Protected, ReadProtected}]&/@ Names["DTITools`ProcessingTools`*"];

EndPackage[]
