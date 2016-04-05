(* ::Package:: *)

(* ::Title:: *)
(*DTITools DenoiseTools*)


(* ::Subtitle:: *)
(*Written by: Martijn Froeling, PhD*)
(*m.froeling@gmail.com*)


(* ::Section:: *)
(*Begin Package*)


BeginPackage["DTITools`DenoiseTools`"];
$ContextPath=Union[$ContextPath,System`$DTIToolsContextPaths];

Unprotect @@ Names["DTITools`DenoiseTools`*"];
ClearAll @@ Names["DTIToos'DenoiseTools`*"];


(* ::Section:: *)
(*Usage Notes*)


(* ::Subsection:: *)
(*Fuctions*)


PCAFit::usage = 
"PCAFit[data, pars] fits the marchencopasteur distribution to the PCA of the data. pars is {bins, start comps, max itterations}.
PCAFit[data, pars, sig] fits the marchencopasteur distribution to the PCA of the data using sig as start value or fixed value."

DeNoise::usage =
"DeNoise[data,sigma,filtersize] removes Rician noise with standard deviation \"sigma\" from the given dataset using a kernel with size \"filtersize\" a gaussian kernel.
DeNoise[data,sigma,filtersize, Kernel->\"kerneltype\"] removes Rician noise with standard deviation \"sigma\" from the given dataset using a kernel with size \"filtersize\" and type \"kerneltype\"."

PCADeNoise::usage = 
"PCADeNoise[data] removes rician noise from the data with PCA.
PCADeNoise[data, mask] removes rician noise from the data with PCA only withing the mask.
PCADeNoise[data, mask, sig] removes rician noise from the data with PCA only withing the mask using sig as prior knowledge or fixed value."

(* ::Subsection:: *)
(*Options*)


PlotSolution::usage = 
"PlotSolution is an option for PCAFit, if set true it dispays the fitting itterations"

FitSigma::usage = 
"FitSigma is an option of PCAFit and PCADeNoise, if set True sig is fitted if set False sigma is fixed to input value"

PCAKernel::usage = 
"PCAKernel is an option of PCADeNoise. It sets the kernel size."

BinSize::usage = 
"BinSize is an option of PCADeNoise. Sets the binsize."

InitializationP::usage = 
"InitializationP is an option of PCADeNoise. How many signal PCA components are initialized."

MaxIterationsFit::usage = 
"MaxIterationsFit is an option of PCADeNoise. How many itterations can be used."

PCAOutput::usage = 
"PCAOutput is an option of PCADeNoise. If output is full the output is {datao, {output[[1]], sigmat}, {output[[2]], output[[3]], j}, timetot}.
Else the output is {datao, sigmat}."


(* ::Subsection:: *)
(*Error Messages*)


DeNoise::data =
"Error: not able to proces the combination of this data set (Dimensions `2` ) with the given size kernel `1`, posibilities:
- 2D data, 2D kernel, sigma = single value
- 3D data, 2D kernel, sigma = single value or list with value specified for each slice
- 3D data, 3D kernel, sigma = single value
- 4D data, 2D kernel, sigma = single value or 2D array with value specified for each slice and diffusion direction
- 4D data, 3D kernel, sigma = single value or list with value specified for each diffusion direction"

DeNoise::filt =
"Error: The dimension of the kernel (`1`D) is of higher order than the dimension of the dataset (`2`D)."

DeNoise::dim =
"Error: The dimension of the sigmap (`1`) is not the same as the dimension of the dataset (`2`)."

DeNoise::kern = 
"Error: Unknown kernel type:`1`, use \"Gaussian\", \"Box\" or \"Disk\"."

DeNoise::sig =
"Data and simga are of unequal dimensions. Data: `1`, Sigma: `2`."


(* ::Section:: *)
(*Functions*)


Begin["`Private`"]


(* ::Subsection:: *)
(*PCADenoise*)


(* ::Subsubsection::Closed:: *)
(*PCADeNoise*)


Options[PCADeNoise] = {PCAKernel -> 5, BinSize -> 5, InitializationP -> 10, MaxIterationsFit -> 10, FitSigma -> True, PCAOutput -> Full};

SyntaxInformation[PCADeNoise] = {"ArgumentsPattern" -> {_, _., _., OptionsPattern[]}};

PCADeNoise[data_, opts : OptionsPattern[]] := PCADeNoise[data, 1, opts];

PCADeNoise[data_, mask_, opts : OptionsPattern[]] := PCADeNoise[data, mask, 0., opts];

PCADeNoise[datai_, maski_, sigmai_, OptionsPattern[]] := 
 Module[{data, mask, sigm, ker, off, datao, weights, sigmat, dim, 
   zdim, ydim, xdim, ddim, g, i, j, nb, pi, maxit, pars, output,
   time1, time, timetot, sigi, zm, zp, xm, xp, ym, yp, fitdata, filt, out},
  
  (*make everything numerical to speed up*)
  data = N@datai;
  mask = N@maski;
  sigm = N@sigmai;
  
  (*get data dimensions*)
  dim = {zdim, ddim, ydim, xdim} = Dimensions[data];
  
  (*get options for fit*)
  nb = OptionValue[BinSize];
  nb = If[NumberQ[nb], nb, 5];
  pi = OptionValue[InitializationP];
  pi = If[NumberQ[pi], pi, 10];
  maxit = OptionValue[MaxIterationsFit];
  maxit = If[NumberQ[maxit], maxit, 10];
  ker = OptionValue[PCAKernel];
  pars = {nb, pi, maxit};
  
  (*define runtime parameters*)
  off = Round[(ker - 1)/2];
  datao = ConstantArray[0., dim];
  weights = sigmat = datao[[All, 1]];
  
  (*if mask is a number make it 1 for all voxels*)
  mask = If[NumberQ[mask], weights + 1, mask];
  
  (*allow for progess and timing monitoring*)
  time = AbsoluteTime[];
  time1 = 0;
  timetot = {};
  g = off + 1; i = j = 0;
  PrintTemporary[Row[{
     ProgressIndicator[Dynamic[g], {off + 1, zdim - off+1}], 
     Row[{Dynamic[i], Dynamic[j], Dynamic[Round[100. j/(i + 1), .1]]},
       " / "]
     }, "     "]];
  
  output = Table[
    (*Check if masked voxel*)
    If[mask[[z, y, x]] == 0.,
     {0., 0., 0.}
     ,
     (*monitor time progress every 500 itterations*)
     i++;
     If[Mod[i, 100] == 0,
      g = z;
      time1 = AbsoluteTime[];
      AppendTo[timetot, time1 - time];
      time = time1;
      ];
     
     sigi = 
      If[sigm === 0., sigm, If[NumberQ[sigm], sigm, sigm[[z, y, x]]]];
     (*get pixel range*)
     {{zm, ym, xm}, {zp, yp, xp}} = {{z, y, x} - off, {z, y, x} + off};
     (*get the data*)
     fitdata = 
      Flatten[data[[zm ;; zp, All, ym ;; yp, xm ;; xp]], {1, 3, 4}];
     
     (*perform the fit and reconstruct the noise free data*)
     out = 
      PCAFit[fitdata, pars, sigi, FitSigma -> OptionValue[FitSigma]];
     (*check if max limit is hit*)
     If[out[[3]] == 10, j++];
     
     (*collect the noise free data and weighting matrix*)
     filt = 
      Transpose[Fold[Partition, out[[4]], {ker, ker}], {1, 3, 4, 2}];
     datao[[zm ;; zp, All, ym ;; yp, xm ;; xp]] += filt;
     sigmat[[zm ;; zp, ym ;; yp, xm ;; xp]] += out[[1]];
     weights[[zm ;; zp, ym ;; yp, xm ;; xp]] += 1.;
     (*output sig, Nest and itterations *)
     out[[1 ;; 3]]
     ]
    , {z, off + 1, zdim - off}, {y, off + 1, ydim - off}, {x, off + 1,
      xdim - off}];
  (*correct output data for weightings*)
  datao = 
   Transpose[
    Clip[#/(weights + 10^-10), {0., 10^9}, {0., 0.}] & /@ 
     Transpose[datao]];
  sigmat = 
   Clip[sigmat/(weights[[All]] + 10^-10), {0., 10^9}, {0., 0.}];
  output = ArrayPad[#, off] & /@ TransData[output, "r"];
  
  (*define output*)
  If[OptionValue[PCAOutput] === Full,
   (*fitted dta , {sigma fit, average sigma}, {number components, number of fitted voxesl, number of max fits}, total fit time per 500 ittt*)
   {datao, {output[[1]], sigmat}, {output[[2]], output[[3]], j}, 
    timetot},
   {datao, sigmat}
   ]
  ]


(* ::Subsubsection::Closed:: *)
(*MarchenkoPasturC*)


(*MarchenkoPastur Compile*)
MarchenkoPasturC[lab_, Q_?NumericQ, sig_?NumericQ] := MarchenkoPasturCi[lab, Q, sig];
MarchenkoPasturCi = Compile[{{lab, _Real, 0}, {Q, _Real, 0}, {sig, _Real, 0}},
   Block[{labm, sig2, labp, Qs},
    sig2 = sig^2;
    Qs = Sqrt[Q];
    labm = sig2 (1 - Qs)^2;
    labp = sig2 (1 + Qs)^2;
    Piecewise[{{Sqrt[(labp - lab) (lab - labm)]/(2 Pi sig2 Q lab), 
       labm < lab < labp}}, 0]
    ], RuntimeAttributes -> {Listable}, RuntimeOptions -> "Speed"
   ];


(* ::Subsubsection::Closed:: *)
(*CalcSigFunc*)


(*Fit sig on MarchenkoPatur distribution*)
CalcSigFunc[dat_, Q_, sigi_] := Block[{sig, lab},
   (Quiet@
      FindFit[dat, MarchenkoPasturC[lab, Q, sig], {{sig, sigi}}, lab,
       AccuracyGoal -> 5, PrecisionGoal -> 5,
       Method -> "LevenbergMarquardt", MaxIterations -> 50])[[1, 2]]
   ];


(* ::Subsubsection::Closed:: *)
(*HistListC*)


(*Make Histogram bins, is fast then using normal mathematica function*)
HistListC = Compile[{{dat, _Real, 1}, {nbins, _Integer, 0}}, Block[
    {min, max, maxmin, binw, bins, cpos, binst, comp, ydat, xdat, 
     tall, miss},
    (*get histogram range*)
    min = Min[dat]; max = Max[dat];
    {min, max} = Chop[{min, max}];
    (*check if range > 0*)
    If[min === max,
     (*no range make delta function*)
     binw = 1/nbins;
     cpos = Ceiling[(nbins + 0.001)/2];
     bins = ConstantArray[0, nbins];
     bins[[cpos]] = nbins;
     Transpose[{Range[-0.5 + binw/2, 0.5, binw], bins}]
     ,
     (*range is greate then zero, thus calculate the bin width *)
     maxmin = max - min;
     binw = maxmin/nbins;
     (*count in number of bins*)
     tall = Tally[Floor[nbins (dat - min)/(1.001 maxmin)]];
     (*check if bins are empty*)
     comp = Complement[Range[0, nbins], tall[[All, 1]]];
     If[comp[[1]] != nbins,
      (*fil in missing bins*)
      miss = {#, 0} & /@ comp[[;; -2]];
      binst = Sort[Join[tall, miss]],
      (*no bins missing*)
      binst = Sort[tall]
      ];
     (*calcualte the y and x data*)
     bins = binst[[All, 2]];
     ydat = N@bins/Total[bins]/binw;
     xdat = Range[min + binw/2, max, binw];
     (*output the data*)
     Transpose[{xdat, ydat}]
     ]], RuntimeOptions -> "Speed"];


(* ::Subsubsection::Closed:: *)
(*ErrorFunc*)


(*Errorfunction only used for plotting the minimization*)
ErrorFunc[data_, Q_, sig_] := Block[{xdata, ydata, vals, tvals},
   xdata = data[[1]];
   ydata = data[[2]];
   vals = MarchenkoPasturC[xdata, Q, sig];
   Total[(ydata - vals)^2]
   ];
   

(* ::Subsubsection::Closed:: *)
(*PCAFit*)


Options[PCAFit] = {PlotSolution -> False, FitSigma -> True};

SyntaxInformation[PCAFit] = {"ArgumentsPattern" -> {_, _, _., OptionsPattern[]}};

(*no initial sigma given*)
PCAFit[data_, pars_, opts : OptionsPattern[]] :=  PCAFit[data, pars, 0., opts]
(*initial sigma is given*)
PCAFit[data_, pars_, sigii_, OptionsPattern[]] := Module[{
   nb, pi, maxit, Nd, M, U, W, V, labs, pi1, pi0, Nes,
   Q, Qs, sig, sigi, fdata, labp, pmax, i, sigstr},
  
  (*get options*)
  {nb, pi, maxit} = pars;
  (*determine dimensions*)
  {Nd, M} = MinMax@Dimensions[data];
  
  (*perform singular value decomposition*)
  {U, W, V} = SingularValueDecomposition[data]; V = Transpose[V];
  (*get eigenvalues and *)
  labs = Diagonal[W]^2/M;
  (*lmsq=Sqrt[Last[labs]];*)
  
  (*perform heuristic ittarative fitting*)
  i = pi1 = pi0 = 0;
  Do[
   (*count fit and how often max fit*)
   i++;
   Nes = (Nd - pi);
   Q = N[Nes/M];
   Qs = Sqrt[Q];
   
   (*calcualte initial sig from data or use input for i=1*)
   sigi = 
    If[i == 1, 
     If[sigii == 0, Sqrt[Last[labs]]/Sqrt[(1 - Qs)^2], sigii], sig];
   
   (*perform the fit, data from histogramlist*)
   sig = If[OptionValue[FitSigma],
     CalcSigFunc[HistListC[labs[[pi + 1 ;;]], nb], Q, sigi],
     sigi
     ];
   
   (*determine number of noise components*)
   labp = sig^2 (1 + Qs)^2;
   pi1 = Clip[Length[Select[labs, # > labp &]], {1, Nd - 5}];
   
   (*Plot fit itterations*)
   If[OptionValue[PlotSolution],
    fdata = HistListC[labs[[pi + 1 ;;]], nb];
    pmax = Max[{Max[fdata[[All, 1]]], labp}];
    sigstr = "\!\(\*
StyleBox[SubscriptBox[OverscriptBox[\"\[Sigma]\", \"~\"], \"i\"],\n\
FontColor->RGBColor[0, 0, 1]]\): " <> ToString[Round[sigi, .01]] <> 
      "  \\  \!\(\*
StyleBox[SubscriptBox[\"\[Sigma]\", \"i\"],\nFontColor->RGBColor[1, \
0, 0]]\): " <> ToString[Round[sig, .01]] <> "  \\  \!\(\*
StyleBox[SubscriptBox[\"\[Sigma]\", \"noise\"],\n\
FontColor->RGBColor[1, 0.5, 0]]\): " <> ToString[Round[sigii, .01]];
    Print[GraphicsRow[{
       Show[
        Plot[{MarchenkoPasturC[x, Q, sigi], 
          MarchenkoPasturC[x, Q, sigii], 
          MarchenkoPasturC[x, Q, sig]}, {x, 0, pmax},
         PlotRange -> Full, PlotStyle -> {Blue, Orange, Red}, 
         Frame -> True, Axes -> False, Exclusions -> None],
        ListLinePlot[fdata, PlotRange -> Full, 
         PlotStyle -> Directive[{Thickness[0.01], Black}]],
        PlotLabel -> "Fit Sigma\n" <> sigstr]
       ,
       Plot[
        ErrorFunc[Transpose@fdata, Q, psig], {psig, 0.1 sigi, 2 sigi},
        GridLines -> {{{sigi, Lighter[Blue]}, {sig, 
            Lighter[Red]}, {sigii, Orange}}, None}, 
        GridLinesStyle -> Directive[Thick], PlotStyle -> Black, 
        Frame -> True, Axes -> False, Exclusions -> None,
        PlotLabel -> "Error Function\n" <> sigstr]
       }
      , ImageSize -> 600, Spacings -> -20, 
      PlotLabel -> 
       "Itteration: " <> ToString[i] <> "    Nes: " <> ToString[Nes], 
      LabelStyle -> Black]];
    ];
   
   (*this ends if the same solution or the same solution as the previous itteration is found*)
   If[pi == pi1 || pi1 == pi0, W[[pi + 1 ;;, pi + 1 ;;]] = 0.; 
    Break[]];
   
   (*updata pi values*)
   {pi0, pi} = {pi, pi1};
   , {maxit}];
  
  {sig, Nes, i, U.W.V}
  ]

(* ::Subsection:: *)
(*Denoise*)


(* ::Subsubsection::Closed:: *)
(*Denoise*)


Options[DeNoise] = {Kernel -> "Gaussian", MonitorDeNoise -> False, DeNoiseIterations -> 1};

SyntaxInformation[DeNoise] = {"ArgumentsPattern" -> {_, _, _, OptionsPattern[]}};

DeNoise[dat_, sigi_, filt_, OptionsPattern[]] := 
 Module[{kern, out, type, dimsig, dimdat, data, sig},
  sig = N[sigi];
  data = N[dat];
  (*Check dimensions,must be of lower order than data*)
  If[
   ArrayQ[sig] && (ArrayDepth[data] == 3 || ArrayDepth[data] == 4),
   dimsig = Dimensions[sig];
   dimdat = Dimensions[data];
   If[
    (ArrayDepth[data] == 3 && dimsig != dimdat) || 
     ArrayDepth[data] == 4 && dimsig != dimdat[[{1, 3, 4}]], 
    Return[Message[DeNoise::dim, dimsig, dimdat]]
    ];
   ];
  
  (*Check dimensions,filter must be of lower order than data*)
  If[Length[filt] > ArrayDepth[data], 
   Return[Message[DeNoise::filt, Length[filt], ArrayDepth[data]]]];
  
  (*Create filter*)
  kern = Switch[type = OptionValue[Kernel],
    "Box", kern = BoxMatrix[filt]/Total[Flatten[BoxMatrix[filt]]],
    "Disk", kern = DiskMatrix[filt]/Total[Flatten[DiskMatrix[filt]]],
    "Gaussian", kern = GaussianMatrix[{filt}],
    _, Return[Message[DeNoise::kern, type]];];
  
  If[OptionValue[MonitorDeNoise], 
   PrintTemporary["Using " <> type <> " kernel."]];
  
  (*out = DeNoisei[data, sig, filt, kern];*)
  
  out=Nest[DeNoisei[#, sig, filt, kern] &, data, OptionValue[DeNoiseIterations]];
  
  If[
   ArrayQ[out], Return[Clip[out, {0.9 Min[data], 1.1 Max[data]}]], 
   Return[Message[DeNoise::data, Dimensions[sig], Dimensions[data]]]
   ]
  ]


(* ::Subsubsection::Closed:: *)
(*DeNoisei*)


DeNoisei[data_?MatrixQ,sig_,filt_,kern_?MatrixQ]:=
Module[{},
	(*PrintTemporary["Appling 2D kernel on 2D dataset."];*)
	DeNoiseApp[data,sig,filt,kern]]

DeNoisei[data:{_?MatrixQ..},sig_,filt_,kern:{_?MatrixQ..}]:=
Module[{},
	(*PrintTemporary["Appling 3D kernel on 3D dataset."];*)
	DeNoiseApp[data,sig,filt,kern]]

DeNoisei[data:{_?MatrixQ..},sig_,filt_,kern_?MatrixQ]:=
Module[{},
	(*PrintTemporary["Appling 2D kernel on 3D dataset."];*)
	(*Using one sigma value for all slices."];*)
	If[NumberQ[sig],
		Map[DeNoiseApp[#,sig,filt,kern]&,data],
		MapThread[DeNoiseApp[#1,#2,filt,kern]&,{data,sig}]
		]
	]

DeNoisei[data:{{_?MatrixQ..}..},sig_,filt_,kern_?MatrixQ]:=
Module[{},
	(*PrintTemporary["Appling 2D kernel on 4D dataset."];*)
	(*Using one sigma value for all slices and directions."];*)
	If[NumberQ[sig],
		Map[DeNoiseApp[#,sig,filt,kern]&,data,{2}],
		Transpose[Map[MapThread[DeNoiseApp[#1,#2,filt,kern]&,{#,sig}]&,Transpose[data]]]
		]
	]

DeNoisei[data:{{_?MatrixQ..}..},sig_,filt_,kern:{_?MatrixQ..}]:=
Module[{},
	(*PrintTemporary["Appling 3D kernel on 4D dataset."];*)
	(*Using one sigma value for all diffusion directions."];*)
	Transpose[Map[DeNoiseApp[#1,sig,filt,kern]&,Transpose[data]]]
	]


(* ::Subsubsection::Closed:: *)
(*DeNoiseApp*)


DeNoiseApp[data_, sig_, filt_, kern_] := 
 Module[{secmod, quadmod},
  secmod = ListConvolve[kern, data^2, Transpose[{filt + 1, -(filt + 1)}], 0.];
  quadmod = ListConvolve[kern, data^4, Transpose[{filt + 1, -(filt + 1)}], 0.];
  If[NumberQ[sig],
  	NoiseAppCN[secmod, quadmod, data, sig],
  	NoiseAppC[secmod, quadmod, data, sig]
  ]
  ]

NoiseAppCN = Compile[{{secmod, _Real, 2}, {quadmod, _Real, 2}, {data, _Real, 2}, {sig, _Real, 0}},
   Block[{top, div, K, deb},
    top = (4 sig^2 (secmod - sig^2));
    div = (quadmod - secmod^2) + 10^-10;
    K = (1 - top/div);
    deb = Sqrt[Clip[(secmod - 2 sig^2) + (K (data^2 - secmod)), {0., Infinity}]]
    ]];

NoiseAppC = Compile[{{secmod, _Real, 2}, {quadmod, _Real, 2}, {data, _Real, 2}, {sig, _Real, 2}},
   Block[{top, div, K, deb},
    top = (4 sig^2 (secmod - sig^2));
    div = (quadmod - secmod^2) + 10^-10;
    K = (1 - top/div);
    deb = Sqrt[Clip[(secmod - 2 sig^2) + (K (data^2 - secmod)), {0., Infinity}]]
    ]];

NoiseAppCN = Compile[{{secmod, _Real, 3}, {quadmod, _Real, 3}, {data, _Real, 3}, {sig, _Real, 0}},
   Block[{top, div, K, deb},
    top = (4 sig^2 (secmod - sig^2));
    div = (quadmod - secmod^2) + 10^-10;
    K = (1 - top/div);
    deb = Sqrt[Clip[(secmod - 2 sig^2) + (K (data^2 - secmod)), {0., Infinity}]]
    ]];
    
NoiseAppC = Compile[{{secmod, _Real, 3}, {quadmod, _Real, 3}, {data, _Real, 3}, {sig, _Real, 3}},
   Block[{top, div, K, deb},
    top = (4 sig^2 (secmod - sig^2));
    div = (quadmod - secmod^2) + 10^-10;
    K = (1 - top/div);
    deb = Sqrt[Clip[(secmod - 2 sig^2) + (K (data^2 - secmod)), {0., Infinity}]]
    ]];



(* ::Section:: *)
(*End Package*)


End[]

SetAttributes[#,{Protected, ReadProtected}]& /@ Names["DTITools`DenoiseTools`*"];

EndPackage[]